import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController auth = Get.put(AuthController());
  final AbsenController absenController = Get.put(AbsenController());

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Delay kecil biar logo sempat kelihatan (opsional)
    await Future.delayed(const Duration(milliseconds: 300));

    await auth.checkLoginStatus();
    // Navigasi biasanya dilakukan di dalam checkLoginStatus()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(image: AssetImage("assets/images/qb_icon.png"), width: 160),
            SizedBox(height: 24),
            CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
