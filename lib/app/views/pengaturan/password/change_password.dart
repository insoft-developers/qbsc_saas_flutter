import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/pengaturan/password/change_password_controller.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final controller = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Ubah Password",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildPasswordField(
                label: 'Password Lama',
                controller: controller.oldPasswordC,
                visible: controller.showOld,
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                label: 'Password Baru',
                controller: controller.newPasswordC,
                visible: controller.showNew,
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                label: 'Konfirmasi Password Baru',
                controller: controller.confirmPasswordC,
                visible: controller.showConfirm,
                confirm: true,
              ),
              const SizedBox(height: 30),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      elevation: MaterialStateProperty.all(4),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Password',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================
  // PASSWORD FIELD
  // ======================
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool visible,
    bool confirm = false,
  }) {
    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: !visible.value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: Icon(visible.value ? Icons.visibility : Icons.visibility_off),
            onPressed: () => visible.toggle(),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tidak boleh kosong';
          }

          if (confirm &&
              value != Get.find<ChangePasswordController>().newPasswordC.text) {
            return 'Password tidak sama';
          }

          if (!confirm && value.length < 6) {
            return 'Minimal 6 karakter';
          }

          return null;
        },
      ),
    );
  }
}
