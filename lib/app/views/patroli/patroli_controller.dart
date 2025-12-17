import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:qbsc_saas/app/models/patroli_model.dart';
import 'package:uuid/uuid.dart';

class PatroliController extends GetxController {
  late StreamSubscription _connectivitySubscription;
  Timer? _periodicSyncTimer;
  final ApiProvider api = Get.find<ApiProvider>();

  late Box<LocationModel> lokasiBox;

  @override
  void onInit() {
    super.onInit();
    lokasiBox = Hive.box<LocationModel>('locations');

    // Jalankan sync saat controller pertama aktif
    syncPatroliToServer();

    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      status,
    ) {
      // ignore: unrelated_type_equality_checks
      if (status != ConnectivityResult.none) {
        syncPatroliToServer();
      }
    });

    // Jalankan sync otomatis setiap 5 menit (backup)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      syncPatroliToServer();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

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

  Future<void> savePatroliLocal({
    required String locationId,
    required String locationCode,
    required String satpamId,
    required double latitude,
    required double longitude,
    String? note,
    required String comid,
    String? photoPath,
  }) async {
    final box = Hive.box<PatroliModel>('patroli');
    final now = DateTime.now();
    final id = const Uuid().v4();

    final patroli = PatroliModel(
      id: id,
      tanggal: DateFormat('yyyy-MM-dd').format(now),
      jam: DateFormat('HH:mm:ss').format(now),
      locationId: locationId,
      locationCode: locationCode,
      satpamId: satpamId,
      latitude: latitude,
      longitude: longitude,
      note: note ?? '',
      comid: comid,
      photoPath: photoPath ?? '',
      isSynced: false,
    );

    await box.put(id, patroli);
    await cekHivePatroli();
  }

  Future<void> syncPatroliToServer() async {
    final box = Hive.box<PatroliModel>('patroli');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data ke server...");

    int sukses = 0;
    int gagal = 0;

    final ApiProvider api = Get.find<ApiProvider>();

    for (var p in unsynced) {
      try {
        File? file = (p.photoPath != null && p.photoPath!.isNotEmpty)
            ? File(p.photoPath!)
            : null;

        // Siapkan FormData
        final formData = dio.FormData.fromMap({
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
          if (file != null && await file.exists())
            'photo': await dio.MultipartFile.fromFile(
              file.path,
              filename: basename(file.path),
            ),
        });

        // Kirim ke server
        final response = await api.client.post(
          ApiEndpoint.sendPatroliToServer,
          data: formData,
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          p.isSynced = true;
          await p.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${p.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${p.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${p.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }

  Future<void> cekHivePatroli() async {
    final box = Hive.box<PatroliModel>(
      'patroli',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK PATROLI DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, Tanggal: ${item.tanggal}, jam: ${item.jam}, locid: ${item.locationId}, loccd: ${item.locationCode}, satpamid: ${item.satpamId}, lat: ${item.latitude.toString()},lng: ${item.longitude.toString()}, note: ${item.note},',
      );
    }
  }
}
