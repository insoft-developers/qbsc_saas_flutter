import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/controllers/home_controller.dart'; // 🔥 DITAMBAHKAN
import 'package:qbsc_saas/app/controllers/auth_controller.dart'; // 🔥 DITAMBAHKAN

import 'package:qbsc_saas/app/models/doc_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/models/kandang_alarm_model.dart';
import 'package:qbsc_saas/app/models/kandang_kipas_model.dart';
import 'package:qbsc_saas/app/models/kandang_lampu_model.dart';
import 'package:qbsc_saas/app/models/kandang_model.dart';
import 'package:qbsc_saas/app/models/kandang_suhu_model.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:qbsc_saas/app/models/patroli_model.dart';
import 'package:qbsc_saas/app/models/situasi_model.dart';

import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/firebase_background_handler.dart';
import 'package:qbsc_saas/app/utils/topic_service.dart';

import 'package:qbsc_saas/app/views/absensi/absensi_shift.dart';
import 'package:qbsc_saas/app/views/doc/doc.dart';
import 'package:qbsc_saas/app/views/emergency/emgergency.dart';
import 'package:qbsc_saas/app/views/home_view.dart';
import 'package:qbsc_saas/app/views/kandang/kandang.dart';
import 'package:qbsc_saas/app/views/kejadian/kejadian.dart';
import 'package:qbsc_saas/app/views/laporan/doc/doc_report.dart';
import 'package:qbsc_saas/app/views/laporan/ekspedisi/ekspedisi_report.dart';
import 'package:qbsc_saas/app/views/laporan/kandang/kandang_laporan.dart';
import 'package:qbsc_saas/app/views/laporan/kejadian/kejadian_report.dart';
import 'package:qbsc_saas/app/views/laporan/laporan.dart';
import 'package:qbsc_saas/app/views/laporan/lokasi/lokasi_report.dart';
import 'package:qbsc_saas/app/views/laporan/patroli/patroli_report.dart';
import 'package:qbsc_saas/app/views/login_view.dart';
import 'package:qbsc_saas/app/views/notif/notif.dart';
import 'package:qbsc_saas/app/views/patroli/patroli.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi.dart';
import 'package:qbsc_saas/app/views/pengaturan/password/change_password.dart';
import 'package:qbsc_saas/app/views/pengaturan/pengaturan.dart';
import 'package:qbsc_saas/app/views/pengaturan/profil/profil.dart';
import 'package:qbsc_saas/app/views/splash_view.dart';
import 'package:qbsc_saas/app/views/tamu/daftar_tamu.dart';
import 'package:qbsc_saas/app/views/tamu/tambah_tamu.dart';
import 'package:qbsc_saas/app/views/tamu/tamu.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ===========================
  //  ANDROID NOTIFICATION SETUP
  // ===========================
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notif'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const initAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
  const initSettings = InitializationSettings(android: initAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ===========================
  //  HIVE DATABASE
  // ===========================
  await Hive.initFlutter();
  Hive.registerAdapter(LocationModelAdapter());
  Hive.registerAdapter(PatroliModelAdapter());
  Hive.registerAdapter(KandangModelAdapter());
  Hive.registerAdapter(KandangSuhuModelAdapter());
  Hive.registerAdapter(KandangKipasModelAdapter());
  Hive.registerAdapter(KandangAlarmModelAdapter());
  Hive.registerAdapter(KandangLampuModelAdapter());
  Hive.registerAdapter(EkspedisiModelAdapter());
  Hive.registerAdapter(DocModelAdapter());
  Hive.registerAdapter(SituasiModelAdapter());

  await Hive.openBox<LocationModel>('locations');
  await Hive.openBox<PatroliModel>('patroli');
  await Hive.openBox<KandangModel>('kandang');
  await Hive.openBox<KandangSuhuModel>('kandang_suhu');
  await Hive.openBox<KandangKipasModel>('kandang_kipas');
  await Hive.openBox<KandangAlarmModel>('kandang_alarm');
  await Hive.openBox<KandangLampuModel>('kandang_lampu');
  await Hive.openBox<EkspedisiModel>('ekspedisi');
  await Hive.openBox<DocModel>('doc');
  await Hive.openBox<SituasiModel>('situasi');

  await Get.putAsync<ApiProvider>(() async => await ApiProvider().init());
  await AppPrefs.init();

  // ====================================
  //  PUT CONTROLLERS GLOBAL (🔥 WAJIB)
  // ====================================
  Get.put(HomeController(), permanent: true); // 🔥 NOTIF BADGE
  Get.put(AuthController(), permanent: true); // 🔥 untuk foto dll

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final homeC = Get.find<HomeController>(); // 🔥 akses badge notif

  @override
  void initState() {
    super.initState();
    TopicService.initializeTopicOnStartup();
    setupForegroundMessageHandler();
  }

  void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      // ==============================
      //   INCREMENT BADGE (🔥)
      // ==============================
      homeC.increment();

      final notif = message.notification;
      final android = notif?.android;

      if (notif != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notif.hashCode,
          notif.title,
          notif.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('notif'),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: ApiProvider.isDev ? true : false,
      title: 'QBSC',
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashView()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/patroli', page: () => Patroli()),
        GetPage(name: '/pengaturan', page: () => Pengaturan()),
        GetPage(name: '/pengaturan/lokasi', page: () => Lokasi()),
        GetPage(name: '/laporan', page: () => Laporan()),
        GetPage(name: '/laporan/patroli', page: () => PatroliReport()),
        GetPage(name: '/laporan/lokasi', page: () => LokasiReport()),
        GetPage(name: '/patroli/kandang', page: () => Kandang()),
        GetPage(name: '/laporan/kandang', page: () => KandangLaporan()),
        GetPage(name: '/laporan/ekspedisi', page: () => EkspedisiReport()),
        GetPage(name: '/doc', page: () => Doc()),
        GetPage(name: '/laporan/doc', page: () => DocReport()),
        GetPage(name: '/shift', page: () => AbsensiShift()),
        GetPage(name: '/kejadian', page: () => Kejadian()),
        GetPage(name: '/laporan/kejadian', page: () => KejadianReport()),
        GetPage(name: '/tamu', page: () => Tamu()),
        GetPage(name: '/tambah/tamu', page: () => TambahTamu()),
        GetPage(name: '/laporan/tamu', page: () => DaftarTamu()),
        GetPage(name: '/darurat', page: () => Emgergency()),
        GetPage(name: '/notifikasi', page: () => Notif()),
        GetPage(name: '/pengaturan/profile', page: () => ProfilePage()),
        GetPage(name: '/pengaturan/password', page: () => ChangePassword()),
      ],
    );
  }
}
