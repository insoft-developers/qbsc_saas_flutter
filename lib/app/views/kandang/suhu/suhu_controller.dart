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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    bool permissionGranted = await checkLocationPermission();
    if (!permissionGranted) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> insertSuhu({
    required int kandangId,
    required int satpamId,
    required double temperature,
    String? note,
    File? foto,
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

    final model = KandangSuhuModel(
      id: nextId, // Hive auto assign key
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
      isSynced: false, // belum sync ke server
      syncedAt: null,
    );

    await box.add(model);
    cekHive();
    isLoading(false);
  }

  Future<void> cekHive() async {
    final box = Hive.box<KandangSuhuModel>(
      'kandang_suhu',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK SUHU DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, UUID: ${item.uuid}, Temp: ${item.temperature}, Tanggal: ${item.tanggal}, jam: ${item.jam}, kandang: ${item.kandangId.toString()}, satpamid: ${item.satpamId}, lat: ${item.latitude.toString()},lng: ${item.longitude.toString()}, note: ${item.note}, foto: ${item.foto},',
      );
    }
  }
}
