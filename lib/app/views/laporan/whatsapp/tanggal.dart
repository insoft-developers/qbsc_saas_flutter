import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/doc/pemeriksaan_doc.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/jam.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/patroli/patroli_wa_page.dart';

class PilihTanggal extends StatelessWidget {
  final int year;
  final int month;
  final String menu;

  const PilihTanggal({
    super.key,
    required this.year,
    required this.month,
    required this.menu,
  });

  static const List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  int _jumlahHari(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _hariIndonesia(DateTime date) {
    return _namaHari[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int daysInMonth = _jumlahHari(year, month);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          '${_namaBulan[month - 1]} $year',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: daysInMonth,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(year, month, day);
          final isToday = _isToday(date);

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final date = DateTime(year, month, day);

              final String formattedDate =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

              if (menu == 'kandang') {
                Get.to(() => JamPage(menu: menu, tanggal: formattedDate));
              } else if (menu == 'doc') {
                Get.to(() => PemeriksaanDoc(tanggal: formattedDate));
              } else if (menu == 'patroli') {
                Get.to(() => PatroliWaPage(tanggal: formattedDate));
              }
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isToday
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isToday
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : theme.dividerColor,
                ),
              ),
              child: Row(
                children: [
                  // 🔹 tanggal besar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isToday ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 🔹 hari & bulan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hariIndonesia(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$day ${_namaBulan[month - 1]} $year',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right, size: 22),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
