import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/doc/doc_report_controller.dart';

class DocReport extends StatelessWidget {
  DocReport({super.key});

  final DocReportController controller = Get.put(DocReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan DOC Keluar',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.docList.isEmpty) {
          return const Center(child: Text('Belum ada data doc keluar'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: controller.docList.length,
          itemBuilder: (context, index) {
            final docs = controller.docList[index];
            final namaEkspedisi = controller.getNamaEkspedisi(docs.ekspedisiId);
            final jenis = docs.jenis == 1 ? 'Male' : 'Female';

            return GestureDetector(
              onLongPress: () {
                Get.defaultDialog(
                  title: "Hapus Data",
                  middleText: "Yakin mau hapus laporan ini?",
                  textCancel: "Batal",
                  textConfirm: "Hapus",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteLaporanDoc(index);
                    Get.back();
                    Get.snackbar(
                      'Dihapus',
                      'Data laporan berhasil dihapus',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama lokasi + status sync
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              namaEkspedisi,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              docs.isSynced ? 'Tersync' : 'Belum Sync',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: docs.isSynced
                                ? Colors.green
                                : Colors.red,
                            avatar: Icon(
                              docs.isSynced
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Teks dan foto di satu baris
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kiri: teks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jumlah Box : ${docs.jumlah.toString()}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tanggal: ${docs.tanggal} ${docs.jam}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Tujuan: ${docs.tujuan}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),

                                Text(
                                  'No Polisi: ${docs.noPolisi}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Jenis: ${jenis}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Catatan: ${docs.note}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Kanan: foto kecil
                          if (docs.foto != null &&
                              docs.foto!.isNotEmpty &&
                              File(docs.foto!).existsSync())
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(docs.foto!),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Tombol sync manual
                      if (!docs.isSynced)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('Sync Manual'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              controller.syncDocManual(docs);
                            },

                            // controller.syncdocsManual(docs),
                          ),
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
