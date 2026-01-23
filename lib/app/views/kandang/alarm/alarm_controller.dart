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
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading(false);
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
    // 1️⃣ Cek service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // 2️⃣ Cek permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3️⃣ Ambil last known (offline-first & cepat)
    Position? last = await Geolocator.getLastKnownPosition();

    if (last != null && last.timestamp != null) {
      final age = DateTime.now().difference(last.timestamp!);

      // ⬅️ Masih fresh & cukup akurat
      if (age.inSeconds <= 30 && last.accuracy <= 50) {
        return last;
      }
    }

    // 4️⃣ Paksa GPS (HIGH accuracy, tapi ada batas waktu)
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      // 5️⃣ Fallback terakhir (jangan return null kalau masih ada data)
      return last;
    }
  }
}
