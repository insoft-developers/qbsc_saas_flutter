import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/models/kandang_kipas_model.dart';
import 'package:uuid/uuid.dart';

class KipasController extends GetxController {
  RxList<bool> kipasStatus = <bool>[].obs;
  RxBool isLoading = true.obs;
  RxInt kipasCount = 0.obs;
  late Box<KandangKipasModel> box;

  void initKipas(int jumlahKipas) {
    box = Hive.box<KandangKipasModel>('kandang_kipas');
    if (kipasStatus.isEmpty) {
      kipasStatus.addAll(List.generate(jumlahKipas, (_) => false));
      isLoading.value = false;
      kipasCount.value = jumlahKipas;
    } else {
      kipasCount.value = jumlahKipas;
    }
  }

  void toggleKipas(int index) {
    kipasStatus[index] = !kipasStatus[index];
    kipasStatus.refresh();
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

    // 3️⃣ AMBIL TERCEPAT DULU (INI KUNCI)
    Position? position = await Geolocator.getLastKnownPosition();

    // 4️⃣ Fallback kalau null (LOW accuracy, BUKAN GPS)
    position ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    return position;
  }

  void hidupkanSemua() {
    for (int i = 0; i < kipasStatus.length; i++) {
      kipasStatus[i] = true;
    }
    kipasStatus.refresh();
  }

  void matikanSemua() {
    for (int i = 0; i < kipasStatus.length; i++) {
      kipasStatus[i] = false;
    }
    kipasStatus.refresh();
  }

  Future<void> insertKipas({
    required int kandangId,
    required int satpamId,
    String? note,
    File? foto,
    required int comId,
  }) async {
    // ambil lokasi
    isLoading(true);
    Position? position = await getCurrentPosition();
    double latitude = position?.latitude ?? 0.0;
    double longitude = position?.longitude ?? 0.0;
    final kipasString = kipasStatus.map((e) => e ? 1 : 0).join(',');

    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final nextId = box.isEmpty
        ? 1
        : (box.values.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) +
              1);

    final model = KandangKipasModel(
      id: nextId, // Hive auto assign key
      uuid: uuid,
      tanggal: DateFormat('yyyy-MM-dd').format(now),
      jam: DateFormat('HH:mm:ss').format(now),
      kandangId: kandangId,
      satpamId: satpamId,
      kipas: kipasString,
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
}
