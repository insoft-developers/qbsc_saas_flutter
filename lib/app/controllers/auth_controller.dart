import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var token = ''.obs;
  var userName = ''.obs;
  var userPhoto = ''.obs;
  var userId = ''.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  /// LOGIN
  Future<void> login(String email, String password) async {
    try {
      isLoading(true);

      final response = await api.post(
        ApiEndpoint.login,
        data: {'username': email, 'password': password},
      );

      token.value = response.data['token'] ?? '';
      userName.value = response.data['data']['name'] ?? 'Unknown';
      userPhoto.value = response.data['data']['face_photo_path'];
      userId.value = response.data['data']['id'].toString();

      await AppPrefs.setToken(token.value);
      await AppPrefs.setUserName(userName.value);
      await AppPrefs.setUserId(userId.value);
      await AppPrefs.setUserPhoto(userPhoto.value);

      // Navigasi dengan sedikit delay agar UI halus
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed('/home');
        _showSnackbar('Berhasil', 'Login sukses!');
      });
    } catch (e) {
      _showSnackbar('Error', 'Login gagal: $e');
    } finally {
      isLoading(false);
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await AppPrefs.clearAll();

    token.value = '';
    userName.value = '';
    userId.value = '';
    userPhoto.value = '';
    Get.offAllNamed('/login');
  }

  /// CEK STATUS LOGIN
  Future<void> checkLoginStatus() async {
    final savedToken = AppPrefs.getToken();

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      userName.value = AppPrefs.getUserName() ?? '';
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
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
