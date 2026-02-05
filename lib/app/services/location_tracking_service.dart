import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qbsc_saas/app/models/offline_tracking_model.dart';
import 'package:uuid/uuid.dart';

import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class LocationTrackingService {
  final ApiProvider api = Get.find<ApiProvider>();
  final _uuid = const Uuid();

  Timer? _timer;
  bool _isRunning = false;

  /// ⏱ INTERVAL TRACKING (MENIT)
  /// ganti sesuai kebutuhan (2 / 5 / 10)
  final int trackingIntervalMinutes = 1;

  /* ===========================================================
   * START TRACKING
   * =========================================================== */
  Future<void> startTracking() async {
    if (_isRunning) return;

    await _syncPendingLocations();

    final granted = await _handlePermission();
    if (!granted) return;

    _isRunning = true;

    // 🔔 ambil lokasi langsung saat start
    await _captureLocation();

    _timer = Timer.periodic(
      Duration(minutes: trackingIntervalMinutes),
      (_) => _captureLocation(),
    );

    print('🟢 Tracking dimulai (interval $trackingIntervalMinutes menit)');
  }

  /* ===========================================================
   * STOP TRACKING
   * =========================================================== */
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    print('🔴 Tracking dihentikan');
  }

  /* ===========================================================
   * PERMISSION
   * =========================================================== */
  Future<bool> _handlePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Get.snackbar('GPS Mati', 'Aktifkan GPS terlebih dahulu');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Izin Lokasi Ditolak',
          'Aplikasi membutuhkan akses lokasi',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Izin Lokasi Ditolak Permanen',
        'Aktifkan lokasi melalui Settings',
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  /* ===========================================================
   * AMBIL 1 LOKASI (TIME BASED)
   * =========================================================== */
  Future<void> _captureLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // ❌ accuracy jelek → skip
      if (position.accuracy > 80) {
        print('🚫 Accuracy ${position.accuracy} buruk, dilewati');
        return;
      }

      await _saveLocation(position);
    } catch (e) {
      print('❌ Gagal ambil lokasi: $e');
    }
  }

  /* ===========================================================
   * SAVE LOCATION (ONLINE → OFFLINE)
   * =========================================================== */
  Future<void> _saveLocation(Position position) async {
    int satpamId = int.tryParse(AppPrefs.getUserId() ?? '') ?? 0;
    if (satpamId == 0) return;

    final box = Hive.box<OfflineTrackingModel>('tracking');

    final location = OfflineTrackingModel(
      uuid: _uuid.v4(),
      satpamId: satpamId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      recordedAt: DateTime.now().toIso8601String(),
      synced: false,
    );

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity != ConnectivityResult.none) {
      try {
        final response = await api.post(
          ApiEndpoint.updateLastPosition,
          data: {
            'uuid': location.uuid,
            'satpam_id': location.satpamId,
            'latitude': location.latitude,
            'longitude': location.longitude,
            'accuracy': location.accuracy,
            'recorded_at': location.recordedAt,
          },
        );

        if (response.data['success'] == true) {
          print('✅ Lokasi terkirim (${location.uuid})');
          return;
        }
      } catch (e) {
        print('❌ Error kirim lokasi: $e');
      }
    }

    await box.add(location);
    print('💾 Lokasi disimpan offline (${location.uuid})');
  }

  /* ===========================================================
   * SYNC OFFLINE DATA
   * =========================================================== */
  Future<void> _syncPendingLocations() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final box = Hive.box<OfflineTrackingModel>('tracking');
    final pending = box.values.toList();

    for (final item in pending) {
      try {
        final response = await api.post(
          ApiEndpoint.updateSatpamLocation,
          data: {
            'uuid': item.uuid,
            'satpam_id': item.satpamId,
            'latitude': item.latitude,
            'longitude': item.longitude,
            'accuracy': item.accuracy,
            'recorded_at': item.recordedAt,
          },
        );

        if (response.data['success'] == true) {
          await item.delete();
          print('🗑️ Pending lokasi disync (${item.uuid})');
        } else {
          break;
        }
      } catch (e) {
        print('❌ Gagal sync pending lokasi');
        break;
      }
    }
  }
}
