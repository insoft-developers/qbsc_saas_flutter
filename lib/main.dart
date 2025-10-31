import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/services/face_services.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/absensi/absensi_list.dart';
import 'package:qbsc_saas/app/views/home_view.dart';
import 'package:qbsc_saas/app/views/login_view.dart';
import 'package:qbsc_saas/app/views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<ApiProvider>(() async => await ApiProvider().init());
  await AppPrefs.init();
  Get.put(FaceService());
  Get.put(AuthController()); // Daftarkan controller
  Get.put(AbsenController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QBSC SaaS',
      initialRoute: '/splash', // 🔹 mulai dari splash screen
      getPages: [
        GetPage(name: '/splash', page: () => const SplashView()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/home', page: () => HomeView()),

        GetPage(name: '/absensi_list', page: () => AbsensiList()),
      ],
    );
  }
}

/// 🔹 SplashScreen — untuk memastikan Get sudah siap sebelum navigasi
