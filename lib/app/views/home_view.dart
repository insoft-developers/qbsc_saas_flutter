import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthController controller = Get.put(AuthController());

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.supervised_user_circle, 'label': 'Data Satpam'},
    {'icon': Icons.assignment, 'label': 'Laporan Harian'},
    {'icon': Icons.qr_code, 'label': 'Absensi QR'},
    {'icon': Icons.location_on, 'label': 'Patroli'},
    {'icon': Icons.notifications_active, 'label': 'Notifikasi'},
    {'icon': Icons.settings, 'label': 'Pengaturan'},
  ];

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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Tambah bagian foto profil
              Center(
                child: Column(
                  children: [
                    Obx(() {
                      // Misalnya controller.userPhoto.value berisi URL foto profil
                      final photoUrl =
                          "${ApiProvider.imageUrl}/${controller.userPhoto.value}";
                      return CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : const AssetImage(
                                    'assets/images/satpam_default.png',
                                  )
                                  as ImageProvider,
                      );
                    }),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        'Selamat datang, ${controller.userName.value}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih menu di bawah untuk mulai bekerja:',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Grid menu (6 tombol)
              Expanded(
                child: GridView.builder(
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuCard(
                      context,
                      icon: item['icon'],
                      label: item['label'],
                      onTap: () {
                        Get.snackbar(
                          'Menu',
                          'Kamu menekan: ${item['label']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.indigo.shade100,
                          colorText: Colors.black87,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
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
              child: Icon(icon, color: Colors.indigo.shade600, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              label,
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
}
