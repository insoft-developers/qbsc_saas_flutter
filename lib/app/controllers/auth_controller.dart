import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var token = ''.obs;
  var userName = ''.obs;

  final Dio _dio = Dio();

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await _dio.post(
        ApiEndpoint.login,
        data: {'email': email, 'password': password},
      );

      token.value = response.data['token'];
      userName.value = response.data['user']['name'];

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Login gagal: $e');
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    token.value = '';
    Get.offAllNamed('/login');
  }
}
