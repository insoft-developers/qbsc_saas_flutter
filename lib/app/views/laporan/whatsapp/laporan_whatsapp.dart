import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/bulan.dart';

class LaporanWhatsapp extends StatelessWidget {
  LaporanWhatsapp({super.key});

  final String? isPeternakan = AppPrefs.getIsPeternakan();

  late final List<Map<String, dynamic>> menuItems = _buildMenu();

  List<Map<String, dynamic>> _buildMenu() {
    final baseMenu = [
      {
        'icon': Icons.location_on,
        'label': 'Kirim Patroli via WhatsApp',
        'route': '',
      },
    ];

    if (isPeternakan == '1') {
      baseMenu.insertAll(1, [
        {
          'icon': Icons.bungalow_rounded,
          'label': 'Kirim Laporan Kandang via WhatsApp',
          'route': '',
        },
        {
          'icon': Icons.fire_truck,
          'label': 'Kirim Laporan DOC via WhatsApp',
          'route': '',
        },
      ]);
    }

    return baseMenu;
  }

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
          'Laporan',
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
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (item['label'] == 'Kirim Laporan Kandang via WhatsApp') {
                Get.to(() => Bulan(menu: 'kandang'));
              } else if (item['label'] == 'Kirim Laporan DOC via WhatsApp') {
                Get.to(() => Bulan(menu: 'doc'));
              } else if (item['label'] == 'Kirim Patroli via WhatsApp') {
                Get.to(() => Bulan(menu: 'patroli'));
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
                            _getSubtitle(item['label']),
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

String _getSubtitle(String label) {
  switch (label) {
    case 'Kirim Patroli via WhatsApp':
      return 'Kirim laporan Patroli berdasarkan tanggal dan tempat melalui WhatsApp';

    case 'Kirim Laporan Kejadian via WhatsApp':
      return 'Kirim laporan Kejadian berdasarkan tanggal dan tempat melalui WhatsApp';

    case 'Kirim Laporan Kandang via WhatsApp':
      return 'Kirim laporan Kandang berdasarkan tanggal dan tempat melalui WhatsApp';

    case 'Kirim Laporan DOC via WhatsApp':
      return 'Kirim laporan DOC berdasarkan tanggal dan tempat melalui WhatsApp';

    default:
      return '';
  }
}
