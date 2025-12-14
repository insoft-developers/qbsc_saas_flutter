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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.situasiList.length,
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

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: Colors.black26,
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- TEXT LAPORAN ----------------
                      Text(
                        kejadian.createdAt,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        kejadian.laporan,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ---------------- FOTO ----------------
                      if (kejadian.foto != null &&
                          kejadian.foto!.isNotEmpty &&
                          File(kejadian.foto!).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(kejadian.foto!),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------------------
                      //  BOTTOM ROW: STATUS SYNC (left) + SYNC MANUAL (right)
                      // ------------------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // === STATUS SYNC (kiri) ===
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kejadian.isSynced
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  kejadian.isSynced
                                      ? Icons.cloud_done
                                      : Icons.cloud_off,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  kejadian.isSynced ? "Tersync" : "Belum Sync",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // === BUTTON SYNC MANUAL (kanan) – tampil kalau belum sync ===
                          if (!kejadian.isSynced)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.sync, size: 18),
                              label: const Text('Sync Manual'),
                              onPressed: () => controller.syncManual(kejadian),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
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
