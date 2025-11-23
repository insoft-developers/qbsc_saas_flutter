import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class AbsenController extends GetxController {
  var absenData = {}.obs;
  var isLoading = false.obs;
  var absenStatus = ''.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> getDataAbsensi() async {
    isLoading.value = true;

    String satpamId = AppPrefs.getUserId().toString();

    if (satpamId.isNotEmpty) {
      try {
        final response = await api.post(
          ApiEndpoint.absenActive, // endpoint kamu, contoh: POST /api/absensi
          data: {'satpam_id': satpamId},
        );

        var result = response.data;
        if (result['success']) {
          absenData.value = result['data'];
          // ignore: no_leading_underscores_for_local_identifiers
          String _status = '';
          if (result['data']['status'] == 1) {
            _status = 'masuk';
          } else if (result['data']['status'] == 2) {
            _status = 'pulang';
          } else {
            _status = 'kosong';
          }
          absenStatus.value = _status;
        }
      } on DioException catch (e) {
        Get.snackbar(
          'Gagal',
          e.response?.data['message'] ?? 'Terjadi kesalahan saat mengirim',
        );
      } catch (e) {
        Get.snackbar('Error', e.toString());
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'User id tidak ditemukan');
    }
  }

  Future<void> getLocationData() async {
    isLoading.value = true;
    String satpamId = AppPrefs.getUserId().toString();

    if (satpamId.isNotEmpty) {
      try {
        final response = await api.post(
          ApiEndpoint.locationData, // endpoint kamu, contoh: POST /api/absensi
          data: {'satpam_id': satpamId},
        );

        var result = response.data;
        if (result['success']) {
          await AppPrefs.setLocationName(
            result['data']['location_name'].toString(),
          );
          await AppPrefs.setLatitude(result['data']['latitude'].toString());
          await AppPrefs.setLongitude(result['data']['longitude'].toString());
          await AppPrefs.setMaxDistance(
            result['data']['max_distance'].toString(),
          );
        } else {
          Get.snackbar('Gagal', result['message'].toString());
        }
      } on DioException catch (e) {
        Get.snackbar(
          'Gagal',
          e.response?.data['message'] ?? 'Terjadi kesalahan saat mengirim',
        );
      } catch (e) {
        Get.snackbar('Error', e.toString());
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'User id tidak ditemukan');
    }
  }
}
