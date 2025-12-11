import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/home_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final homeC = Get.find<HomeController>();
    homeC.increment(); // 🔥 tambah angka notif jika app background
  } catch (_) {
    // jika HomeController belum terdaftar, abaikan
  }
}
