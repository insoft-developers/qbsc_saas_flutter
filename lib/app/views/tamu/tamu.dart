import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_scan.dart';

class Tamu extends StatelessWidget {
  const Tamu({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF2D3E50); // warna elegan gelap

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Menu Tamu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuCard(
              title: "Scan QR Tamu",
              subtitle: "Scan QR untuk mencatat kedatangan tamu",
              icon: Iconsax.scan,
              color: const Color(0xFF2D3E50),
              textColor: Colors.white,
              onTap: () => Get.to(() => TamuScan()),
            ),

            const SizedBox(height: 18),

            _menuCard(
              title: "Tambah Data Tamu",
              subtitle: "Input data tamu secara manual",
              icon: Iconsax.add,
              color: Colors.white,
              borderColor: const Color(0xFF2D3E50),
              iconColor: const Color(0xFF2D3E50),
              textColor: const Color(0xFF2D3E50),
              onTap: () => Get.toNamed('/tambah/tamu'),
            ),

            const SizedBox(height: 18),

            _menuCard(
              title: "Daftar Tamu Datang",
              subtitle: "Lihat histori kunjungan tamu",
              icon: Iconsax.people,
              color: Colors.lightBlueAccent.shade100,
              borderColor: const Color(0xFF2D3E50),
              iconColor: const Color(0xFF2D3E50),
              textColor: const Color(0xFF2D3E50),
              onTap: () => Get.toNamed('/laporan/tamu'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _menuCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  Color? borderColor,
  Color? iconColor,
  Color? textColor,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Ink(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.6)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.white).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor ?? Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: (textColor ?? Colors.white).withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            color: (textColor ?? Colors.white).withOpacity(0.6),
          ),
        ],
      ),
    ),
  );
}
