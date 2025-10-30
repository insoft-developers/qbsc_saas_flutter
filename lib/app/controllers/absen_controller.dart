import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsenController extends GetxController {
  var absenData = {}.obs;
  var isLoading = false.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> getDataAbsensi() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    String satpamId = prefs.getString('userId').toString();

    if (satpamId.isNotEmpty) {
      try {
        final response = await api.post(
          ApiEndpoint.absenActive, // endpoint kamu, contoh: POST /api/absensi
          data: {'satpam_id': satpamId},
        );

        var result = response.data;
        if (result['success']) {
          absenData.value = result['data'];
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

  /// SNACKBAR HELPER
  void _showSnackbar(String title, String message) {
    if (Get.context == null) return;
    Get.snackbar(
      title,
      message,
      backgroundColor: title == 'Error'
          ? Colors.red.shade600
          : Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
