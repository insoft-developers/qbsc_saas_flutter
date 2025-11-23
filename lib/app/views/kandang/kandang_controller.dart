import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
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

class KandangController extends GetxController {
  var kandangList = <KandangModel>[].obs;

  late StreamSubscription _connectivitySubscription;
  Timer? _periodicSyncTimer;
  final ApiProvider api = Get.find<ApiProvider>();
  late Box<KandangSuhuModel> _boxSuhu;
  late Box<KandangKipasModel> _boxKipas;
  late Box<KandangAlarmModel> _boxAlarm;
  late Box<KandangLampuModel> _boxLampu;
  late Box<KandangModel> _kandangBox;

  @override
  void onInit() {
    super.onInit();
    _kandangBox = Hive.box<KandangModel>('kandang');
    loadKandangs();

    // auto listen perubahan di Hive
    _kandangBox.watch().listen((event) {
      loadKandangs();
    });

    syncDataKandangToServer();

    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      status,
    ) {
      // ignore: unrelated_type_equality_checks
      if (status != ConnectivityResult.none) {
        syncDataKandangToServer();
      }
    });

    // Jalankan sync otomatis setiap 5 menit (backup)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      syncDataKandangToServer();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

  void syncDataKandangToServer() async {
    await syncSuhuToServer();
    await syncKipasToServer();
    await syncAlarmToServer();
    await syncLampuToServer();
  }

  void loadKandangs() {
    kandangList.value = _kandangBox.values.toList();
  }

  Future<void> syncSuhuToServer() async {
    final box = Hive.box<KandangSuhuModel>('kandang_suhu');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data suhu yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data suhu ke server...");

    int sukses = 0;
    int gagal = 0;

    for (var data in unsynced) {
      try {
        // Siapkan FormData
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
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          data.isSynced = true;
          await data.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${data.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${data.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${data.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }

  Future<void> syncKipasToServer() async {
    final box = Hive.box<KandangKipasModel>('kandang_kipas');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data kipas yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data kipas ke server...");

    int sukses = 0;
    int gagal = 0;

    for (var data in unsynced) {
      try {
        // Siapkan FormData
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
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          data.isSynced = true;
          await data.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${data.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${data.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${data.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }

  Future<void> syncAlarmToServer() async {
    final box = Hive.box<KandangAlarmModel>('kandang_alarm');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data alarm yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data alarm ke server...");

    int sukses = 0;
    int gagal = 0;

    for (var data in unsynced) {
      try {
        // Siapkan FormData
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
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          data.isSynced = true;
          await data.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${data.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${data.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${data.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }

  Future<void> syncLampuToServer() async {
    final box = Hive.box<KandangLampuModel>('kandang_lampu');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data lampu yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data lampu ke server...");

    int sukses = 0;
    int gagal = 0;

    for (var data in unsynced) {
      try {
        // Siapkan FormData
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
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          data.isSynced = true;
          await data.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${data.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${data.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${data.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }
}
