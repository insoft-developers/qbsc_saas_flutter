import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/models/kandang_alarm_model.dart';
import 'package:uuid/uuid.dart';

class AlarmController extends GetxController {
  final RxBool isLoading = false.obs;
  late Box<KandangAlarmModel> box;

  void init() {
    box = Hive.box<KandangAlarmModel>('kandang_alarm');
  }

  Future<void> insertAlarm({
    required int kandangId,
    required int satpamId,
    required bool isAlarmOn,
    String? note,
    File? foto,
    required int comId,
  }) async {
    // ambil lokasi
    isLoading(true);
    Position? position = await getCurrentPosition();
    double latitude = position?.latitude ?? 0.0;
    double longitude = position?.longitude ?? 0.0;

    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final nextId = box.isEmpty
        ? 1
        : (box.values.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) +
              1);

    final model = KandangAlarmModel(
      id: nextId, // Hive auto assign key
      uuid: uuid,
      tanggal: DateFormat('yyyy-MM-dd').format(now),
      jam: DateFormat('HH:mm:ss').format(now),
      kandangId: kandangId,
      satpamId: satpamId,
      isAlarmOn: isAlarmOn,
      note: note ?? '',
      foto: foto?.path ?? '',
      comid: comId,
      latitude: latitude,
      longitude: longitude,
      isSynced: false, // belum sync ke server
      syncedAt: null,
    );

    await box.add(model);
    cekHive();
    isLoading(false);
  }

  Future<void> cekHive() async {
    final box = Hive.box<KandangAlarmModel>(
      'kandang_kipas',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK ALARM DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, UUID: ${item.uuid}, Alarm: ${item.isAlarmOn.toString()}, Tanggal: ${item.tanggal}, jam: ${item.jam}, kandang: ${item.kandangId.toString()}, satpamid: ${item.satpamId}, lat: ${item.latitude.toString()},lng: ${item.longitude.toString()}, note: ${item.note}, foto: ${item.foto},',
      );
    }
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Mendapatkan posisi saat ini
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    bool permissionGranted = await checkLocationPermission();
    if (!permissionGranted) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
