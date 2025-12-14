import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final oldPasswordC = TextEditingController();
  final newPasswordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  final isLoading = false.obs;
  final showOld = false.obs;
  final showNew = false.obs;
  final showConfirm = false.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onClose() {
    oldPasswordC.dispose();
    newPasswordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }

  // ======================
  // SUBMIT CHANGE PASSWORD
  // ======================
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.changePassword,
        data: {
          'satpam_id': satpamId,
          'old_password': oldPasswordC.text,
          'new_password': newPasswordC.text,
          'new_password_confirmation': confirmPasswordC.text,
        },
      );
      var body = response.data;
      if (body['success']) {
        SnackbarHelper.success('sukses', 'Sukses Ubah Password');
      } else {
        SnackbarHelper.error('Warning', body['message'].toString());
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
