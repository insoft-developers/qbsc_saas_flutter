import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/patroli_model.dart';
import 'package:uuid/uuid.dart';

class PatroliController extends GetxController {
  late StreamSubscription _connectivitySubscription;
  Timer? _periodicSyncTimer;
  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();

    // Jalankan sync saat controller pertama aktif
    syncPatroliToServer();

    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      status,
    ) {
      if (status != ConnectivityResult.none) {
        syncPatroliToServer();
      }
    });

    // Jalankan sync otomatis setiap 5 menit (backup)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncPatroliToServer();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

  Future<void> savePatroliLocal({
    required String locationId,
    required String locationCode,
    required String satpamId,
    required double latitude,
    required double longitude,
    String? note,
    required String comid,
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
      isSynced: false,
    );

    await box.put(id, patroli);
    await cekHivePatroli();
  }

  Future<void> syncPatroliToServer() async {
    final box = Hive.box<PatroliModel>('patroli');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda");
      return;
    }

    print("Mulai sync ${unsynced.length} data ke server...");

    for (var p in unsynced) {
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

      var body = response.data;
      if (body['success'] == true) {
        // ✅ update status di Hive
        p.isSynced = true;
        await p.save();
        print('✅ Sync sukses untuk ID: ${p.id}');
      } else {
        print('❌ Sync gagal untuk ID: ${p.id}');
      }
    }
  }

  Future<void> cekHivePatroli() async {
    final box = Hive.box<PatroliModel>(
      'patroli',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK PATROLI DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, Tanggal: ${item.tanggal}, jam: ${item.jam}, locid: ${item.locationId}, loccd: ${item.locationCode}, satpamid: ${item.satpamId}, lat: ${item.latitude.toString()},lng: ${item.longitude.toString()}, note: ${item.note}',
      );
    }
  }
}
