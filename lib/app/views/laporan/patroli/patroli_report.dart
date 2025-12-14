import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'patroli_report_controller.dart';

class PatroliReport extends StatelessWidget {
  PatroliReport({super.key});

  final PatroliReportController controller = Get.put(PatroliReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan Patroli',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Hapus data yang sudah sync',
            onPressed: () => controller.clearSynced(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.patroliList.isEmpty) {
          return const Center(child: Text('Belum ada data patroli'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: controller.patroliList.length,
          itemBuilder: (context, index) {
            final patroli = controller.patroliList[index];
            final namaLokasi = controller.getNamaLokasi(patroli.locationId);

            return Card(
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
                            '$namaLokasi (${patroli.locationCode})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            patroli.isSynced ? 'Tersync' : 'Belum Sync',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: patroli.isSynced
                              ? Colors.green
                              : Colors.red,
                          avatar: Icon(
                            patroli.isSynced
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
                                patroli.note.isNotEmpty ? patroli.note : '-',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tanggal: ${patroli.tanggal}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Jam: ${patroli.jam}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${patroli.latitude} | Lng: ${patroli.longitude}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Kanan: foto kecil
                        if (patroli.photoPath != null &&
                            patroli.photoPath!.isNotEmpty &&
                            File(patroli.photoPath!).existsSync())
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(patroli.photoPath!),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Tombol sync manual
                    if (!patroli.isSynced)
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
                          onPressed: () =>
                              controller.syncPatroliManual(patroli),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
