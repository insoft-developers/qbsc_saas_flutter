import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  final AuthController auth = Get.put(AuthController());
  final AbsenController absenController = Get.put(AbsenController());

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _init();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 1)); // minimal delay
    await auth.checkLoginStatus();

    // Pindah ke halaman utama
    // Get.offAllNamed('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset("assets/images/logo_satpam.png", width: 200),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
