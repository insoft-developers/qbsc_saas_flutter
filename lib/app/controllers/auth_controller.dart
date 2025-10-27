import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/views/home_view.dart';
import 'package:qbsc_saas/app/views/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var token = ''.obs;
  var userName = ''.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);

      final response = await api.post(
        ApiEndpoint.login,
        data: {'username': email, 'password': password},
      );

      token.value = response.data['token'] ?? '';
      userName.value = response.data['data']['name'] ?? 'Unknown';

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.value);
      await prefs.setString('userName', userName.value);

      // Navigasi ke home
      Get.offAllNamed('/home');

      _showSnackbar('Berhasil', 'Login sukses!');
    } catch (e) {
      _showSnackbar('Error', 'Login gagal: $e');
    } finally {
      isLoading(false);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    token.value = '';
    Get.offAllNamed('/login');
  }

  // CEK STATUS LOGIN
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
}

void _showSnackbar(String title, String message) {
  if (Get.context == null) return;

  Future.delayed(const Duration(milliseconds: 100), () {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: title == 'Error'
            ? Colors.red.shade600
            : Colors.green.shade600,
      ),
    );
  });
}
