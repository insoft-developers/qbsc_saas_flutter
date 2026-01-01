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
      backgroundColor: Colors.white,
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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.docList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
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
                      // ===== HEADER =====
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              namaEkspedisi,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                          _SyncBadge(isSynced: docs.isSynced),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ===== BODY =====
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TEXT INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Jumlah Box',
                                  value: docs.jumlah.toString(),
                                ),
                                _InfoRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Tanggal',
                                  value: '${docs.tanggal} ${docs.jam}',
                                ),
                                _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'Tujuan',
                                  value: docs.tujuan ?? '',
                                ),
                                _InfoRow(
                                  icon: Icons.directions_car_outlined,
                                  label: 'No Polisi',
                                  value: docs.noPolisi ?? '',
                                ),
                                _InfoRow(
                                  icon: Icons.pets_outlined,
                                  label: 'Jenis',
                                  value: jenis,
                                ),
                              ],
                            ),
                          ),

                          // FOTO
                          if (docs.foto != null &&
                              docs.foto!.isNotEmpty &&
                              File(docs.foto!).existsSync())
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(docs.foto!),
                                height: 86,
                                width: 86,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),

                      if (docs.note != null && docs.note!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Catatan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          docs.note!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],

                      // ===== ACTION =====
                      if (!docs.isSynced) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('Sync Manual'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              controller.syncDocManual(docs);
                            },
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
    final color = isSynced ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
