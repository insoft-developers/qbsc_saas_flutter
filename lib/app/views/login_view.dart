import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🌈 Background gradasi
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 💨 Efek blur lembut di tengah
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/logo_satpam.png",
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                        width: 200,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✉️ Email
                      TextField(
                        keyboardType: TextInputType.phone,
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Whatsapp',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔒 Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

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
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: const Color(0xFF4A00E0),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: auth.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF4A00E0),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      }),
                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Lupa password?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
