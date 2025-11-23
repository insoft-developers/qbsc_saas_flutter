import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/doc_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class DocReportController extends GetxController {
  final ApiProvider api = Get.find<ApiProvider>();
  late Box<DocModel> docBox;
  late Box<EkspedisiModel> eksBox;

  var docList = <DocModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    docBox = Hive.box<DocModel>('doc');
    eksBox = Hive.box<EkspedisiModel>('ekspedisi');
    loadData();

    docBox.listenable().addListener(loadData);
  }

  void loadData() {
    final list = docBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    docList.value = list;
  }

  void hapusData() async {}

  void deleteLaporanDoc(int index) {
    final data = docList[index];
    final target = docBox.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  @override
  void onClose() {
    docBox.listenable().removeListener(loadData);
    super.onClose();
  }

  String getNamaEkspedisi(int id) {
    try {
      final ekspedisi = eksBox.values.firstWhere((ek) => ek.id == id);
      return ekspedisi.name;
    } catch (_) {
      return '-';
    }
  }

  Future<void> syncDocManual(DocModel p) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': p.id,
        'tanggal': p.tanggal,
        'input_date': p.createdAt,
        'jam': p.jam,
        'satpam_id': p.satpamId,
        'jumlah': p.jumlah,
        'ekspedisi_id': p.ekspedisiId,
        'tujuan': p.tujuan,
        'no_polisi': p.noPolisi,
        'jenis': p.jenis,
        'note': p.note,
        'comid': p.comid,
        if (p.foto != null && File(p.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            p.foto!,
            filename: basename(p.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.syncDocReport,
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
