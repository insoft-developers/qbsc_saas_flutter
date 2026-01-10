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

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> menuItems;

  final AuthController authC = Get.put(AuthController());
  final HomeController homeC = Get.put(HomeController());
  final AbsenController absenC = Get.put(AbsenController());

  late final ScrollController _marqueeScrollController;
  late final AnimationController _marqueeAnimationController;

  final String? isPeternakan = AppPrefs.getIsPeternakan();

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
    absenC.getLocationData();
    _initMenu();
    _marqueeScrollController = ScrollController();
    _marqueeAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..addListener(() {
            if (_marqueeScrollController.hasClients) {
              _marqueeScrollController.jumpTo(
                _marqueeAnimationController.value *
                    _marqueeScrollController.position.maxScrollExtent,
              );
            }
          });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marqueeAnimationController.repeat();
    });
  }

  @override
  void dispose() {
    _marqueeAnimationController.dispose();
    _marqueeScrollController.dispose();
    super.dispose();
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
    homeC.checkPaket();
    homeC.setRunningText();
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
      await homeC.getJadwalPatroli();

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
      'Patroli': '/jadwal_patroli',
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

  Widget _buildRunningText() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.white]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON KIRI
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 8),

          // RUNNING TEXT
          Expanded(
            child: ClipRect(
              child: ListView(
                controller: _marqueeScrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: const [
                      _MarqueeText(),
                      _MarqueeText(), // DUPLIKAT = LOOP MULUS
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return GestureDetector(
      onTap: () {
        // ganti nomor WA

        homeC.callWhatsApp();
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF25D366),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Image.asset('assets/images/wa_icon.png'),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildWhatsAppButton(),
          const SizedBox(height: 14),
          _buildEmergencyButton(),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: 20,
          ),
          child: Column(
            children: [
              _buildProfileCard(isTablet),
              const SizedBox(height: 14),
              _buildRunningText(),
              const SizedBox(height: 28),
              _buildMenuList(),
              const SizedBox(height: 38),
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
    return GestureDetector(
      onTap: () => Get.toNamed('/darurat'),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade700,
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade700.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isTablet) {
    return Obx(() {
      final photo = "${ApiProvider.imageUrl}/${authC.userPhoto.value}";
      final role = AppPrefs.getIsDanru() ?? '-';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F8F8)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            // AVATAR
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF34C759).withOpacity(0.9),
                    const Color(0xFF2FBF71),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: isTablet ? 38 : 32,
                backgroundColor: const Color(0xFFE5E5EA),
                backgroundImage: authC.userPhoto.value.isNotEmpty
                    ? NetworkImage(photo)
                    : const AssetImage('assets/images/satpam_default.png')
                          as ImageProvider,
              ),
            ),

            const SizedBox(width: 18),

            // TEKS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GREETING + JABATAN
                  Row(
                    children: [
                      Text(
                        'Selamat Bertugas',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(role),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // NAMA
                  Text(
                    AppPrefs.getUserName() ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: 0.15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // PERUSAHAAN
                  Row(
                    children: [
                      const Icon(
                        Icons.apartment_rounded,
                        size: 14,
                        color: Color(0xFF34C759),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          AppPrefs.getCompanyName() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF34C759),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuList() {
    return Column(
      children: menuItems.map((item) {
        return _MenuListCard(
          icon: item['icon'],
          label: item['label'],
          onTap: () => _onMenuTap(item['label']),
        );
      }).toList(),
    );
  }
}

class _MenuListCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MenuListCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.black.withOpacity(0.04),
          highlightColor: Colors.black.withOpacity(0.02),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                // ===== LEFT ACCENT BAR =====
                Container(
                  width: 5,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ===== ICON =====
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C3535).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Image.asset(icon, width: 40, height: 40),
                  ),
                ),

                const SizedBox(width: 16),

                // ===== TEXT =====
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // ===== ARROW =====
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge(this.role);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF34C759).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role == '1' ? 'Danru' : 'Anggota',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: role == '1' ? Colors.blue : Colors.redAccent,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MarqueeText extends StatelessWidget {
  const _MarqueeText();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Obx(
        () => Text(
          controller.runningText.value.toString(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
