import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/home_view.dart';
import 'package:qbsc_saas/app/views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan GetX tahu ApiProvider dulu sebelum menjalankan app
  await initServices();
  runApp(MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<ApiProvider>(() async => await ApiProvider().init());
  final auth = Get.put(AuthController());
  await auth.checkLoginStatus(); // 🔥 Cek status login saat start
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QBSC SaaS',
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()), // sementara loading
      ),
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
      ],
    );
  }
}
