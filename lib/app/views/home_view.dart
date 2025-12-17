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
  late List<Map<String, dynamic>> menuItems;

  final AuthController authC = Get.put(AuthController());
  final HomeController homeC = Get.put(HomeController());
  final AbsenController absenC = Get.put(AbsenController());

  final String? isPeternakan = AppPrefs.getIsPeternakan();

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
    absenC.getLocationData();
    _initMenu();
  }

  void _initMenu() {
    final baseMenu = [
      {'icon': 'assets/images/absensi.png', 'label': 'Absensi'},
      {'icon': 'assets/images/patroli.png', 'label': 'Patroli'},
      {'icon': 'assets/images/laporan.png', 'label': 'Laporan'},
      {'icon': 'assets/images/kejadian.png', 'label': 'Kejadian'},
      {'icon': 'assets/images/setting.png', 'label': 'Pengaturan'},
      {'icon': 'assets/images/tamu.png', 'label': 'Tamu'},
    ];

    if (isPeternakan == '1') {
      baseMenu.insertAll(2, [
        {'icon': 'assets/images/kandang.png', 'label': 'Kontrol Kandang'},
        {'icon': 'assets/images/doc.png', 'label': 'Catat DOC'},
      ]);
    }

    menuItems = baseMenu;
  }

  void _loadUserPhoto() {
    final photo = AppPrefs.getUserPhoto();
    if (photo != null && photo.isNotEmpty) {
      authC.userPhoto.value = photo;
    }
  }

  // ================= SYNC =================
  void _showSyncDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sinkronisasi Data'),
        content: const Text(
          'Apakah Anda yakin ingin menyinkronkan data sekarang?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _syncData();
            },
            child: const Text('Sinkronkan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _syncData() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await homeC.getDataLocation();
      await homeC.getDataKandang();
      await absenC.getLocationData();
      await homeC.getDataEkspedisi();

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Data berhasil disinkronkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Sinkronisasi gagal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ================= MENU ACTION =================
  void _onMenuTap(String label) {
    final routes = {
      'Absensi': '/shift',
      'Patroli': '/patroli',
      'Pengaturan': '/pengaturan',
      'Laporan': '/laporan',
      'Kontrol Kandang': '/patroli/kandang',
      'Catat DOC': '/doc',
      'Kejadian': '/kejadian',
      'Tamu': '/tamu',
    };

    if (routes.containsKey(label)) {
      Get.toNamed(routes[label]!);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(),
      floatingActionButton: _buildEmergencyButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: 20,
          ),
          child: Column(
            children: [
              _buildProfileCard(isTablet),
              const SizedBox(height: 28),
              _buildMenuGrid(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text(
        'Dashboard',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      actions: [
        Obx(
          () => Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  homeC.clear();
                  Get.toNamed('/notifikasi');
                },
              ),
              if (homeC.unreadCount.value > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      homeC.unreadCount.value.toString(),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.sync, color: Colors.white),
          onPressed: _showSyncDialog,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: authC.logout,
        ),
      ],
    );
  }

  Widget _buildEmergencyButton() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.red.shade700,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      label: const Text(
        'Kontak Darurat',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Get.toNamed('/darurat'),
    );
  }

  Widget _buildProfileCard(bool isTablet) {
    return Obx(() {
      final photo = "${ApiProvider.imageUrl}/${authC.userPhoto.value}";

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // shadow halus ala iOS
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // FOTO PROFIL
            CircleAvatar(
              radius: isTablet ? 38 : 32,
              backgroundColor: const Color(0xFFE5E5EA), // iOS system gray
              backgroundImage: authC.userPhoto.value.isNotEmpty
                  ? NetworkImage(photo)
                  : const AssetImage('assets/images/satpam_default.png')
                        as ImageProvider,
            ),

            const SizedBox(width: 16),

            // TEKS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Bertugas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    AppPrefs.getUserName() ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600, // iOS preferred weight
                      color: Color(0xFF1C1C1E),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    AppPrefs.getCompanyName() ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF34C759), // iOS green
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuGrid(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemBuilder: (_, i) {
        final item = menuItems[i];
        return _MenuCard(
          icon: item['icon'],
          label: item['label'],
          onTap: () => _onMenuTap(item['label']),
        );
      },
    );
  }
}

// ================= MENU CARD =================

class _MenuCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // shadow tipis ala iOS
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON BESAR TANPA KOTAK
            Image.asset(icon, width: 64, height: 64, fit: BoxFit.contain),

            const SizedBox(height: 18),

            // LABEL
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500, // iOS style
                color: Color(0xFF1C1C1E),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
