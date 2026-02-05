import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/tanggal.dart';

class Bulan extends StatelessWidget {
  final String menu;
  const Bulan({super.key, required this.menu});

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

  List<Map<String, int>> _getMonthsUntilNow() {
    final now = DateTime.now();
    final List<Map<String, int>> result = [];

    for (int month = now.month; month >= 1; month--) {
      result.add({'year': now.year, 'month': month});
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final months = _getMonthsUntilNow();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Pilih Bulan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: months.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = months[index];
          final int month = item['month']!;
          final int year = item['year']!;
          final bool isCurrent = index == 0;

          final String label = '${_namaBulan[month - 1]} $year';

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PilihTanggal(year: year, month: month, menu: menu),
                ),
              );
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : theme.dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCurrent
                              ? 'Bulan berjalan'
                              : 'Riwayat bulan sebelumnya',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
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
