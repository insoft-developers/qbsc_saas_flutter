import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/device_security_service.dart';
import 'package:qbsc_saas/app/utils/topic_service.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  var isLoading = false.obs;
  var token = ''.obs;
  var userName = ''.obs;
  var userPhoto = ''.obs;
  var userId = ''.obs;
  var comId = ''.obs;
  var companyName = ''.obs;
  var isPeternakan = ''.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // 🔐 CEK SETIAP APP KEMBALI AKTIF
      final isDevMode = await DeviceSecurityService.isDeveloperMode();
      if (isDevMode && ApiProvider.isFakeLogout) {
        await _forceLogout();
      }
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    try {
      isLoading(true);

      final response = await api.post(
        ApiEndpoint.login,
        data: {'username': email, 'password': password},
      );

      final isDevMode = await DeviceSecurityService.isDeveloperMode();
      debugPrint('🔥 DEV MODE STATUS: $isDevMode');

      if (isDevMode && ApiProvider.isFakeLogout) {
        await _forceLogout();
        return;
      }

      token.value = response.data['token'] ?? '';
      userName.value = response.data['data']['name'] ?? 'Unknown';
      userPhoto.value = response.data['data']['face_photo_path'];
      userId.value = response.data['data']['id'].toString();
      comId.value = response.data['data']['comid'].toString();
      companyName.value = response.data['data']['company']['company_name']
          .toString();
      isPeternakan.value = response.data['data']['company']['is_peternakan']
          .toString();

      await AppPrefs.setToken(token.value);
      await AppPrefs.setUserName(userName.value);
      await AppPrefs.setUserId(userId.value);
      await AppPrefs.setUserPhoto(userPhoto.value);
      await AppPrefs.setComId(comId.value);
      await AppPrefs.setCompanyName(companyName.value);
      await AppPrefs.setIsPeternakan(isPeternakan.value);

      final topic = 'qbsc_satpam_${comId.value}';
      await TopicService.unsubscribeOldTopic();
      await TopicService.subscribeNewTopic(topic);

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed('/home');
        _showSnackbar('Berhasil', 'Login sukses!');
      });
    } catch (e) {
      _showSnackbar('Error', 'Login gagal');
    } finally {
      isLoading(false);
    }
  }

  // =========================
  // FORCE LOGOUT (SECURITY)
  // =========================
  Future<void> _forceLogout() async {
    await AppPrefs.clearAll();

    token.value = '';
    userName.value = '';
    userId.value = '';
    userPhoto.value = '';

    Get.offAllNamed('/login');

    Get.snackbar(
      'Akses Ditolak',
      'Untuk Menghindarai penggunaan aplikasi Fake GPS dan sejenisnya, silahkan matikan Developer Mode untuk menggunakan aplikasi',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // =========================
  // LOGOUT MANUAL
  // =========================
  Future<void> logout() async {
    await AppPrefs.clearAll();
    token.value = '';
    userName.value = '';
    userId.value = '';
    userPhoto.value = '';
    Get.offAllNamed('/login');
  }

  // =========================
  // CEK LOGIN
  // =========================
  Future<void> checkLoginStatus() async {
    final isDevMode = await DeviceSecurityService.isDeveloperMode();
    debugPrint('🔥 DEV MODE STATUS: $isDevMode');

    if (isDevMode && ApiProvider.isFakeLogout) {
      await _forceLogout();
      return;
    }

    final savedToken = AppPrefs.getToken();

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      userName.value = AppPrefs.getUserName() ?? '';
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  // =========================
  // SNACKBAR
  // =========================
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
