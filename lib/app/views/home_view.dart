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
  final HomeController _homec = Get.put(HomeController());
  final AbsenController absenc = Get.put(AbsenController());

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.qr_code, 'label': 'Absensi'},
    {'icon': Icons.location_on, 'label': 'Patroli'},
    {'icon': Icons.house, 'label': 'Kontrol Kandang'},
    {'icon': Icons.fire_truck, 'label': 'Catat DOC'},
    {'icon': Icons.assignment, 'label': 'Laporan'},
    {'icon': Icons.info, 'label': 'Kejadian'},
    {'icon': Icons.settings, 'label': 'Pengaturan'},
    {'icon': Icons.person_pin_circle, 'label': 'Tamu'},
  ];

  @override
  void initState() {
    super.initState();
    setFoto();
    absenc.getLocationData();
  }

  void setFoto() async {
    String? savedPhoto = AppPrefs.getUserPhoto();
    if (savedPhoto != null && savedPhoto.isNotEmpty) {
      controller.userPhoto.value = savedPhoto;
    }
  }

  // =====================================================
  //                   SYNC DIALOG
  // =====================================================
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
              Navigator.of(context).pop();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
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

  Future<void> _syncData(BuildContext ctx) async {
    try {
      await _homec.getDataLocation();
      await _homec.getDataKandang();
      await absenc.getLocationData();
      await _homec.getDataEkspedisi();

      if (mounted) Navigator.of(ctx).pop();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sinkronisasi berhasil!')));
      }
    } catch (e) {
      if (mounted) Navigator.of(ctx).pop();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sinkronisasi gagal: $e')));
      }
    }
  }

  // =====================================================
  //                  MENU HANDLER
  // =====================================================
  void _onMenuTap(String label) {
    switch (label) {
      case 'Absensi':
        Get.toNamed('/shift');
        break;
      case 'Patroli':
        Get.toNamed('/patroli');
        break;
      case 'Pengaturan':
        Get.toNamed('/pengaturan');
        break;
      case 'Laporan':
        Get.toNamed('/laporan');
        break;
      case 'Kontrol Kandang':
        Get.toNamed('/patroli/kandang');
        break;
      case 'Catat DOC':
        Get.toNamed('/doc');
        break;
      case 'Kejadian':
        Get.toNamed('/kejadian');
        break;
      case 'Tamu':
        Get.toNamed('/tamu');
        break;
    }
  }

  // =====================================================
  //                 MODERN MENU BUILDER
  // =====================================================
  Widget _buildModernMenu({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8EAF6),
              ),
              child: Icon(icon, color: Color(0xFF3F51B5), size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  //                        UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3C3535),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          Obx(() {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    _homec.clear();
                    Get.toNamed('/notifikasi');
                  },
                ),

                if (_homec.unreadCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _homec.unreadCount.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),

          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _showSyncConfirmation,
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 223, 12, 12),
        icon: const Icon(Icons.contact_emergency, color: Colors.white),
        label: const Text(
          'Kontak Darurat',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => Get.toNamed('/darurat'),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 600;
            final crossAxisCount = isTablet ? 3 : 2;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: isTablet ? 28 : 20,
              ),
              child: Column(
                children: [
                  // ================= TOP CARD =================
                  Obx(() {
                    final photoUrl =
                        "${ApiProvider.imageUrl}/${controller.userPhoto.value}";

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image(
                              width: isTablet ? 90 : 70,
                              height: isTablet ? 90 : 70,
                              fit: BoxFit.cover,
                              image: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : const AssetImage(
                                          'assets/images/satpam_default.png',
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat datang 👋",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppPrefs.getUserName() ?? '-',
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // ================= GRID MENU =================
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return _buildModernMenu(
                        icon: item['icon'],
                        label: item['label'],
                        onTap: () => _onMenuTap(item['label']),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
