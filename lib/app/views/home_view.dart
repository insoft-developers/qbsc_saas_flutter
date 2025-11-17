import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';
import 'package:qbsc_saas/app/controllers/home_controller.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController controller = Get.put(AuthController());
  late final HomeController _homec;
  final AbsenController absenc = Get.put(AbsenController());

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.qr_code, 'label': 'Absensi'},
    {'icon': Icons.location_on, 'label': 'Patroli'},
    {'icon': Icons.house, 'label': 'Kontrol Kandang'},
    {'icon': Icons.display_settings_sharp, 'label': 'Kontrol Mesin'},
    {'icon': Icons.fire_truck, 'label': 'Catat DOC'},
    {'icon': Icons.assignment, 'label': 'Laporan'},
    {'icon': Icons.notifications_active, 'label': 'Notifikasi'},
    {'icon': Icons.settings, 'label': 'Pengaturan'},
  ];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _homec = Get.put(HomeController());
    });

    setFoto();
    absenc.getLocationData();

    super.initState();
  }

  void setFoto() async {
    String? savedPhoto = AppPrefs.getUserPhoto();

    if (savedPhoto != null && savedPhoto.isNotEmpty) {
      controller.userPhoto.value = savedPhoto;
    }
  }

  void _showSyncConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Sync'),
        content: const Text('Yakin mau sinkronisasi data sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // tutup dialog konfirmasi

              // tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  // jalankan sinkronisasi di sini
                  _syncData(dialogContext);
                  return AlertDialog(
                    content: Row(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Expanded(child: Text('Sedang sinkronisasi...')),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Text('Ya, Sync'),
          ),
        ],
      ),
    );
  }

  // fungsi async sinkronisasi
  Future<void> _syncData(BuildContext dialogContext) async {
    try {
      await _homec.getDataLocation();
      await _homec.getDataKandang();
      await absenc.getLocationData();
      await _homec.getDataEkspedisi();

      // tutup loading dialog
      if (mounted) Navigator.of(dialogContext).pop();

      // tampilkan snackbar sukses
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sinkronisasi berhasil!')));
      }
    } catch (e) {
      // tutup loading dialog
      if (mounted) Navigator.of(dialogContext).pop();

      // tampilkan snackbar error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sinkronisasi gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sync Data',
            onPressed: () {
              _showSyncConfirmation();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isTablet = width >= 600;
            final bool isDesktop = width >= 900;

            int crossAxisCount = 2;
            if (isTablet) crossAxisCount = 3;
            if (isDesktop) crossAxisCount = 4;

            double iconSize = isTablet ? 42 : 34;
            double fontSize = isTablet ? 16 : 14;
            double avatarRadius = isTablet ? 55 : 45;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 16,
                vertical: isTablet ? 30 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Foto profil dan sambutan
                  Obx(() {
                    final photoUrl =
                        "${ApiProvider.imageUrl}/${controller.userPhoto.value}";
                    return CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.indigo.shade100,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/images/satpam_default.png')
                                as ImageProvider,
                    );
                  }),
                  const SizedBox(height: 12),

                  Text(
                    'Selamat datang, ${AppPrefs.getUserName()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Pilih menu di bawah untuk mulai bekerja:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Grid menu bisa ikut scroll juga
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isTablet ? 1.1 : 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return _buildMenuCard(
                        icon: item['icon'],
                        label: item['label'],
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTap: () {
                          if (item['label'] == 'Absensi') {
                            Get.toNamed('/absensi_list');
                          } else if (item['label'] == 'Patroli') {
                            Get.toNamed('/patroli');
                          } else if (item['label'] == 'Pengaturan') {
                            Get.toNamed('/pengaturan');
                          } else if (item['label'] == 'Laporan') {
                            Get.toNamed('/laporan');
                          } else if (item['label'] == 'Kontrol Kandang') {
                            Get.toNamed('/patroli/kandang');
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required double iconSize,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.shade100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: Colors.indigo.shade600, size: iconSize),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
