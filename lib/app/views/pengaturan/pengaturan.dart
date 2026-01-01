import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_controller.dart';

class Pengaturan extends StatelessWidget {
  Pengaturan({super.key});
  final LokasiController _lokasiController = Get.put(LokasiController());

  List<Map<String, dynamic>> getMenuItems(String role) {
    final items = <Map<String, dynamic>>[];

    if (role == '1') {
      items.add({'icon': Icons.location_on, 'label': 'Lokasi'});
    }

    items.addAll([
      {'icon': Icons.person, 'label': 'Profil'},
      {'icon': Icons.lock_reset, 'label': 'Ubah Password'},
    ]);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final iconSize = isTablet ? 48.0 : 36.0;
    final fontSize = isTablet ? 18.0 : 14.0;

    final appMenu = getMenuItems(AppPrefs.getIsDanru() ?? '0');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 18,
          vertical: 24,
        ),
        itemCount: appMenu.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = appMenu[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (item['label'] == 'Lokasi') {
                Get.toNamed('/pengaturan/lokasi')?.then((_) {
                  _lokasiController.fetchLokasi();
                });
              } else if (item['label'] == 'Profil') {
                Get.toNamed('/pengaturan/profile');
              } else if (item['label'] == 'Ubah Password') {
                Get.toNamed('/pengaturan/password');
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // ================= ICON BADGE =================
                    Container(
                      width: iconSize + 20,
                      height: iconSize + 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'],
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ================= TEXT =================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPengaturanSubtitle(item['label']),
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= ARROW =================
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _getPengaturanSubtitle(String label) {
  switch (label) {
    case 'Lokasi':
      return 'Kelola titik lokasi patroli';
    case 'Profil':
      return 'Informasi akun pengguna';
    case 'Ubah Password':
      return 'Keamanan dan kredensial akun';
    default:
      return '';
  }
}
