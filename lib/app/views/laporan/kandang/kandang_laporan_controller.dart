import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/kandang_alarm_model.dart';
import 'package:qbsc_saas/app/models/kandang_kipas_model.dart';
import 'package:qbsc_saas/app/models/kandang_lampu_model.dart';
import 'package:qbsc_saas/app/models/kandang_model.dart';
import 'package:qbsc_saas/app/models/kandang_suhu_model.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class KandangLaporanController extends GetxController {
  final ApiProvider api = Get.find<ApiProvider>();
  var suhuList = <KandangSuhuModel>[].obs;
  var kipasList = <KandangKipasModel>[].obs;
  var alarmList = <KandangAlarmModel>[].obs;
  var lampuList = <KandangLampuModel>[].obs;
  late Box<KandangSuhuModel> box;
  late Box<KandangKipasModel> boxKipas;
  late Box<KandangAlarmModel> boxAlarm;
  late Box<KandangLampuModel> boxLampu;
  late Box<KandangModel> boxKandang;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box<KandangSuhuModel>('kandang_suhu');
    boxKipas = Hive.box<KandangKipasModel>('kandang_kipas');
    boxAlarm = Hive.box<KandangAlarmModel>('kandang_alarm');
    boxLampu = Hive.box<KandangLampuModel>('kandang_lampu');
    boxKandang = Hive.box<KandangModel>('kandang');
    loadData();
  }

  void loadData() {
    suhuList.value = box.values.toList().reversed.toList();
    alarmList.value = boxAlarm.values.toList().reversed.toList();
    lampuList.value = boxLampu.values.toList().reversed.toList();
    kipasList.value = boxKipas.values.toList().reversed.toList();
  }

  void deleteLaporanSuhu(int index) {
    final data = suhuList[index];
    final target = box.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  void deleteLaporanKipas(int index) {
    final data = kipasList[index];
    final target = boxKipas.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  void deleteLaporanAlarm(int index) {
    final data = alarmList[index];
    final target = boxAlarm.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  void deleteLaporanLampu(int index) {
    final data = lampuList[index];
    final target = boxLampu.values.firstWhere((e) => e.id == data.id);
    target.delete();

    loadData();
  }

  File? getFotoFile(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  String? getKandangName(int kandangId) {
    try {
      final kandang = boxKandang.values.firstWhereOrNull(
        (k) => k.id == kandangId,
      );
      return kandang?.name;
    } catch (e) {
      return null;
    }
  }

  Future<void> syncSuhuData(KandangSuhuModel data) async {
    final connectivity = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': data.uuid,
        'tanggal': data.tanggal,
        'jam': data.jam,
        'kandang_id': data.kandangId,
        'satpam_id': data.satpamId,
        'std_temp': data.stdTemp,
        'temperature': data.temperature,
        'note': data.note,
        'comid': data.comid,
        'latitude': data.latitude,
        'longitude': data.longitude,
        if (data.foto != null && File(data.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            data.foto!,
            filename: basename(data.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.syncSuhuKandang,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final body = response.data;

      if (body['success'] == true) {
        data.isSynced = true;
        await data.save();
        loadData();
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

  Future<void> syncKipasData(KandangKipasModel data) async {
    final connectivity = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': data.uuid,
        'tanggal': data.tanggal,
        'jam': data.jam,
        'kandang_id': data.kandangId,
        'satpam_id': data.satpamId,
        'kipas': data.kipas,
        'note': data.note,
        'comid': data.comid,
        'latitude': data.latitude,
        'longitude': data.longitude,
        if (data.foto != null && File(data.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            data.foto!,
            filename: basename(data.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.syncKipasKandang,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final body = response.data;

      if (body['success'] == true) {
        data.isSynced = true;
        await data.save();
        loadData();
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

  Future<void> syncAlarmData(KandangAlarmModel data) async {
    final connectivity = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': data.uuid,
        'tanggal': data.tanggal,
        'jam': data.jam,
        'kandang_id': data.kandangId,
        'satpam_id': data.satpamId,
        'is_alarm_on': data.isAlarmOn,
        'note': data.note,
        'comid': data.comid,
        'latitude': data.latitude,
        'longitude': data.longitude,
        if (data.foto != null && File(data.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            data.foto!,
            filename: basename(data.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.syncAlarmKandang,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final body = response.data;

      if (body['success'] == true) {
        data.isSynced = true;
        await data.save();
        loadData();
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

  Future<void> syncLampuData(KandangLampuModel data) async {
    final connectivity = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivity == ConnectivityResult.none) {
      SnackbarHelper.error('Error', 'Tidak ada koneksi internet');
      return;
    }

    try {
      final formData = dio.FormData.fromMap({
        'uuid': data.uuid,
        'tanggal': data.tanggal,
        'jam': data.jam,
        'kandang_id': data.kandangId,
        'satpam_id': data.satpamId,
        'is_lamp_on': data.isLampOn,
        'note': data.note,
        'comid': data.comid,
        'latitude': data.latitude,
        'longitude': data.longitude,
        if (data.foto != null && File(data.foto!).existsSync())
          'foto': await dio.MultipartFile.fromFile(
            data.foto!,
            filename: basename(data.foto!),
          ),
      });

      final response = await api.post(
        ApiEndpoint.syncLampuKandang,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final body = response.data;

      if (body['success'] == true) {
        data.isSynced = true;
        await data.save();
        loadData();
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
