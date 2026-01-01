import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/kejadian/kejadian_report_controller.dart';

class KejadianReport extends StatelessWidget {
  KejadianReport({super.key});

  final KejadianReportController controller = Get.put(
    KejadianReportController(),
  );

  final Color primary = const Color(0xFF3C3535);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Laporan Kejadian',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Obx(() {
        if (controller.situasiList.isEmpty) {
          return Center(child: Text('Belum ada data kejadian'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.situasiList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final kejadian = controller.situasiList[index];

            return GestureDetector(
              onLongPress: () {
                Get.defaultDialog(
                  title: "Hapus Data",
                  middleText: "Yakin ingin menghapus laporan ini?",
                  textCancel: "Batal",
                  textConfirm: "Hapus",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteLaporan(index);
                    Get.back();
                    Get.snackbar(
                      'Dihapus',
                      'Data berhasil dihapus',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= HEADER =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            kejadian.createdAt,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          _SyncBadge(isSynced: kejadian.isSynced),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= LAPORAN =================
                      Text(
                        kejadian.laporan,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),

                      // ================= FOTO =================
                      if (kejadian.foto != null &&
                          kejadian.foto!.isNotEmpty &&
                          File(kejadian.foto!).existsSync()) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(kejadian.foto!),
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      // ================= ACTION =================
                      if (!kejadian.isSynced) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('Sync Manual'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => controller.syncManual(kejadian),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isSynced;

  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final color = isSynced ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    final icon = isSynced ? Icons.cloud_done : Icons.cloud_off;
    final text = isSynced ? 'Tersync' : 'Belum Sync';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
