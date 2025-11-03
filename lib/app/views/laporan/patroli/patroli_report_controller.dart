import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/patroli_model.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class PatroliReportController extends GetxController {
  late Box<PatroliModel> patroliBox;
  late Box<LocationModel> lokasiBox;

  var patroliList = <PatroliModel>[].obs;
  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    patroliBox = Hive.box<PatroliModel>('patroli');
    lokasiBox = Hive.box<LocationModel>('locations');
    loadPatroli();

    // Listener Hive: update list otomatis kalau ada perubahan
    patroliBox.listenable().addListener(loadPatroli);
  }

  void loadPatroli() {
    final list = patroliBox.values.toList()
      ..sort((a, b) {
        final aDateTime = DateTime.parse('${a.tanggal} ${a.jam}');
        final bDateTime = DateTime.parse('${b.tanggal} ${b.jam}');
        return bDateTime.compareTo(aDateTime); // terbaru di atas
      });
    patroliList.value = list;
  }

  /// Ambil nama lokasi dari Hive locations berdasarkan locationId
  String getNamaLokasi(String locationId) {
    try {
      final lokasi = lokasiBox.values.firstWhere(
        (loc) => loc.id.toString() == locationId,
      );
      return lokasi.namaLokasi;
    } catch (_) {
      return '-';
    }
  }

  Future<void> syncPatroliManual(PatroliModel p) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.sendPatroliToServer,
        data: {
          'id': p.id,
          'tanggal': p.tanggal,
          'jam': p.jam,
          'location_id': p.locationId,
          'location_code': p.locationCode,
          'satpam_id': p.satpamId,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'note': p.note,
          'comid': p.comid,
        },
      );

      final body = response.data;
      if (body['success'] == true) {
        p.isSynced = true;
        await p.save();
        SnackbarHelper.success('Sukses', 'Data berhasil di sync');
      } else {
        SnackbarHelper.error('Gagal', 'Sync gagal, coba lagi nanti');
      }
    } catch (e) {
      SnackbarHelper.error('Error', e.toString());
    }
  }

  Future<void> clearSynced(BuildContext context) async {
    final synced = patroliBox.values.where((p) => p.isSynced).toList();
    if (synced.isEmpty) {
      SnackbarHelper.info('Info', 'Tidak ada data yang sudah sync');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${synced.length} data yang sudah tersync?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    for (var p in synced) {
      await p.delete();
    }

    SnackbarHelper.success('Sukses', '${synced.length} data sudah dihapus');
  }

  @override
  void onClose() {
    patroliBox.listenable().removeListener(loadPatroli);
    super.onClose();
  }
}
