import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class PengaturanController extends GetxController {
  final ApiProvider api = Get.find<ApiProvider>();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1️⃣ Cek GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showEnableLocationDialog();
      return null;
    }

    // 2️⃣ Cek permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Get.snackbar('Izin Ditolak', 'Aplikasi memerlukan izin lokasi');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionSettingsDialog();
      return null;
    }

    // 3️⃣ Ambil lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _showEnableLocationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Lokasi Tidak Aktif'),
        content: const Text(
          'Layanan lokasi belum aktif. Silakan aktifkan lokasi.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            child: const Text('AKTIFKAN'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Izin Lokasi'),
        content: const Text(
          'Izin lokasi ditolak permanen. Aktifkan di pengaturan aplikasi.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('PENGATURAN'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// contoh kirim ke server
  Future<void> setAbsensiPosition() async {
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      SnackbarHelper.error('Error', 'Com id tidak ditemukan');
      return;
    }

    try {
      final position = await getCurrentLocation();
      if (position == null) {
        SnackbarHelper.error('Gagal', 'Lokasi belum ditemukan');
      }

      final lat = position?.latitude;
      final lng = position?.longitude;

      final response = await api.post(
        ApiEndpoint.updatePosAbsenSatpam,
        data: {'comid': comid, 'latitude': lat, 'longitude': lng},
      );

      var body = response.data;
      if (body['success']) {
        SnackbarHelper.success('Barhasil', body['message'].toString());
      } else {
        SnackbarHelper.error('Error', body['message'].toString());
      }
    } catch (e) {
      SnackbarHelper.error('Error', 'Offline');
    } finally {}
  }
}
