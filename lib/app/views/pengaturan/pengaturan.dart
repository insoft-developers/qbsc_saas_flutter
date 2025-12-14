import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_controller.dart';

class Pengaturan extends StatelessWidget {
  Pengaturan({super.key});
  final LokasiController _lokasiController = Get.put(LokasiController());

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.location_on, 'label': 'Lokasi'},
    {'icon': Icons.person, 'label': 'Profil'},
    {'icon': Icons.lock_reset, 'label': 'Ubah Password'},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final iconSize = isTablet ? 48.0 : 36.0;
    final fontSize = isTablet ? 18.0 : 14.0;

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
          horizontal: isTablet ? 32 : 16,
          vertical: 20,
        ),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
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
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        item['icon'],
                        color: Colors.indigo,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[900],
                      ),
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
