import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.value);
      await prefs.setString('userName', userName.value);
      await prefs.setString('userId', userId.value);
      await prefs.setString('userPhoto', userPhoto.value);

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    token.value = '';
    userName.value = '';
    Get.offAllNamed('/login');
  }

  /// CEK STATUS LOGIN
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      userName.value = prefs.getString('userName') ?? '';
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
