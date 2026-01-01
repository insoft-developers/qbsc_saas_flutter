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

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lokasi & kode
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaLokasi,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                patroli.locationCode,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        _SyncBadge(isSynced: patroli.isSynced),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ===== CONTENT =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patroli.note.isNotEmpty
                                    ? patroli.note
                                    : 'Tidak ada catatan',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 10),

                              _InfoRow(
                                icon: Icons.calendar_today,
                                text: patroli.tanggal,
                              ),
                              _InfoRow(
                                icon: Icons.access_time,
                                text: patroli.jam,
                              ),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text:
                                    '${patroli.latitude}, ${patroli.longitude}',
                              ),
                            ],
                          ),
                        ),

                        // Foto
                        if (patroli.photoPath != null &&
                            patroli.photoPath!.isNotEmpty &&
                            File(patroli.photoPath!).existsSync())
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(patroli.photoPath!),
                                width: 86,
                                height: 86,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // ===== ACTION =====
                    if (!patroli.isSynced) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Sync Manual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2FBF71),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () =>
                              controller.syncPatroliManual(patroli),
                        ),
                      ),
                    ],
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

class _SyncBadge extends StatelessWidget {
  final bool isSynced;

  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_off,
            size: 14,
            color: isSynced ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Tersinkron' : 'Belum Sync',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSynced ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
