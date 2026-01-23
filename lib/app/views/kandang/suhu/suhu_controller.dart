import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/models/kandang_suhu_model.dart';
import 'package:uuid/uuid.dart';

class SuhuController extends GetxController {
  late Box<KandangSuhuModel> box;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box<KandangSuhuModel>('kandang_suhu');
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

  Future<void> insertSuhu({
    required int kandangId,
    required int satpamId,
    required double temperature,
    String? note,
    File? foto,
  }) async {
    try {
      isLoading.value = true; // ⬅️ PASTI TRUE

      final position = await getCurrentPosition();
      final latitude = position?.latitude ?? 0.0;
      final longitude = position?.longitude ?? 0.0;

      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final nextId = box.isEmpty
          ? 1
          : box.values.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) +
                1;

      final model = KandangSuhuModel(
        id: nextId,
        uuid: uuid,
        tanggal: DateFormat('yyyy-MM-dd').format(now),
        jam: DateFormat('HH:mm:ss').format(now),
        kandangId: kandangId,
        satpamId: satpamId,
        temperature: temperature,
        note: note ?? '',
        foto: foto?.path ?? '',
        comid: 1,
        latitude: latitude,
        longitude: longitude,
        isSynced: false,
        syncedAt: null,
      );

      await box.add(model);

      // ⬇️ BIAR USER LIHAT LOADING (UX)
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      isLoading.value = false; // ⬅️ PASTI BALIK
    }
  }
}
