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
  StreamSubscription<Position>? _positionStream;

  final _uuid = const Uuid();

  /// START TRACKING
  Future<void> startTracking() async {
    if (_positionStream != null) return;

    bool granted = await _handlePermission();
    if (!granted) return;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            _saveLocation(position);
          },
          onError: (error) {
            print('❌ Location stream error: $error');
          },
        );

    print('🟢 Tracking lokasi dimulai');
  }

  /// STOP TRACKING
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    print('🔴 Tracking lokasi dihentikan');
  }

  /// HANDLE PERMISSION
  Future<bool> _handlePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

  /// SAVE LOCATION (OFFLINE FIRST)
  /// SAVE LOCATION (ONLINE FIRST, FALLBACK OFFLINE)
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
      // 🔹 Ada internet, coba kirim dulu
      try {
        final response = await api.post(
          ApiEndpoint.updateSatpamLocation,
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
          print('✅ Lokasi terkirim ke server (${location.uuid})');
          return; // sukses online, tidak perlu simpan offline
        } else {
          print('⚠️ Gagal kirim ke server, simpan offline');
        }
      } catch (e) {
        print('❌ Error kirim lokasi: $e, simpan offline');
      }
    } else {
      print('📴 Offline, simpan lokasi di Hive');
    }

    // 🔹 Simpan ke Hive sebagai fallback
    await box.add(location);
    print('💾 Lokasi disimpan ke Hive (${location.uuid})');
  }

  /// SYNC PENDING DATA TO SERVER
  Future<void> _syncPendingLocations() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      print('📴 Offline, sync ditunda');
      return;
    }

    final box = Hive.box<OfflineTrackingModel>('tracking');
    final pending = box.values.where((e) => !e.synced).toList();

    if (pending.isEmpty) return;

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
          await item.delete(); // 🔥 hapus dari Hive
          print('🗑️ Lokasi dihapus dari Hive (${item.uuid})');
        }
      } catch (e) {
        print('❌ Gagal sync, akan dicoba ulang');
        break;
      }
    }
  }
}
