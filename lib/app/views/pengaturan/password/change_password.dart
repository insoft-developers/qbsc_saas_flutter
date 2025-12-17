import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/pengaturan/password/change_password_controller.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final controller = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== HEADER ====================
              const Text(
                "Keamanan Akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                "Pastikan password baru Anda aman dan mudah diingat",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // ==================== CARD ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      label: 'Password Lama',
                      icon: Icons.lock_outline,
                      controller: controller.oldPasswordC,
                      visible: controller.showOld,
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      label: 'Password Baru',
                      icon: Icons.lock_reset_outlined,
                      controller: controller.newPasswordC,
                      visible: controller.showNew,
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      label: 'Konfirmasi Password Baru',
                      icon: Icons.check_circle_outline,
                      controller: controller.confirmPasswordC,
                      visible: controller.showConfirm,
                      confirm: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================== BUTTON ====================
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
    required IconData icon,
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
          prefixIcon: Icon(icon),
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
