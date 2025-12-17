import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final auth = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isTablet {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: isTablet ? 100 : 60,
              left: 30,
              right: 30,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🧩 Logo
                  Image.asset(
                    "assets/images/logo_satpam.png",
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    width: isTablet ? 220 : 180,
                  ),
                  const SizedBox(height: 20),

                  // 🏷️ Judul
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 📱 Nomor WA
                  TextField(
                    keyboardType: TextInputType.phone,
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Whatsapp',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isTablet ? 18 : 14,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🔒 Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isTablet ? 18 : 14,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔘 Tombol Login
                  Obx(() {
                    return ElevatedButton(
                      onPressed: auth.isLoading.value
                          ? null
                          : () async {
                              await auth.login(
                                emailController.text,
                                passwordController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: auth.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Login',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 🔗 Lupa password
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Silahkan hub administrator anda untuk minta reset password',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Text(
                      "Lupa password?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Versi ${ApiProvider.appVersion}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
