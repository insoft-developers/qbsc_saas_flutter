import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/kandang/kandang.dart';

class JamPage extends StatelessWidget {
  final String menu;
  final String tanggal;
  const JamPage({super.key, required this.menu, required this.tanggal});

  List<String> _generateJam() {
    return List.generate(24, (index) {
      final hour = index + 1;
      return '${hour.toString().padLeft(2, '0')}:00';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jamList = _generateJam();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Pilih Jam',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: jamList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final jam = jamList[index];
          final isNow = DateTime.now().hour == int.parse(jam.substring(0, 2));

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (menu == 'kandang') {
                Get.to(() => KandangWa(tanggal: tanggal, jam: jam));
              }
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isNow
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isNow
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : theme.dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: isNow
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      jam,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isNow ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Sekarang',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
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
