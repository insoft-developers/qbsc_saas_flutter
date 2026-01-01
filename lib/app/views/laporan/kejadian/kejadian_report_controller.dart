import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/situasi_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class KejadianReportController extends GetxController {
  final ApiProvider api = Get.find<ApiProvider>();
  late Box<SituasiModel> situasiBox;

  var situasiList = <SituasiModel>[].obs;

  late int _loginUserId;

  @override
  void onInit() {
    super.onInit();
    _loginUserId = int.parse(AppPrefs.getUserId() ?? '0');
    situasiBox = Hive.box<SituasiModel>('situasi');
    loadData();

    situasiBox.listenable().addListener(loadData);
  }

  void loadData() {
    final list =
        situasiBox.values.where((e) => e.satpamId == _loginUserId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    situasiList.value = list;
  }

  void hapusData() async {}

  void deleteLaporan(int index) {
    final data = situasiList[index];
    final target = situasiBox.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  @override
  void onClose() {
    situasiBox.listenable().removeListener(loadData);
    super.onClose();
  }

  Future<void> syncManual(SituasiModel p) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': p.id,
        'tanggal': p.createdAt,
        'satpam_id': p.satpamId,
        'laporan': p.laporan,
        'comid': p.comid,
        if (p.foto != null && File(p.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            p.foto!,
            filename: basename(p.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.laporanSituasi,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final body = response.data;

      if (body['success'] == true) {
        p.isSynced = true;
        await p.save();
        SnackbarHelper.success('Sukses', 'Data berhasil di-sync');
      } else {
        SnackbarHelper.error(
          'Gagal',
          'Sync gagal: ${body['message'] ?? 'Coba lagi nanti'}',
        );
      }
    } catch (e) {
      SnackbarHelper.error('Error', e.toString());
    }
  }
}
