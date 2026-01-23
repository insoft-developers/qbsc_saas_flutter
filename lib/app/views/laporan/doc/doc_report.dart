import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/views/laporan/doc/doc_report_controller.dart';

class DocReport extends StatelessWidget {
  DocReport({super.key});

  final DocReportController controller = Get.put(DocReportController());

  // FORMAT RIBUAN INDONESIA
  final NumberFormat nf = NumberFormat.decimalPattern('id');

  String f(dynamic value) {
    if (value == null) return '0';
    final n = int.tryParse(value.toString()) ?? 0;
    return nf.format(n);
  }

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
            final boxOptions = parseDocBoxOption(docs.docBoxOptionJson);

            return GestureDetector(
              // ===== LONG PRESS HAPUS =====
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
                        children: [
                          Expanded(
                            child: Text(
                              namaEkspedisi,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _SyncBadge(isSynced: docs.isSynced),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ===== INFO =====
                      _InfoRow(
                        icon: Icons.calculate_outlined,
                        label: 'Total Box',
                        value: f(docs.jumlah),
                      ),
                      _InfoRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Total Ekor',
                        value: f(docs.totalEkor),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal',
                        value: '${docs.tanggal} ${docs.jam}',
                      ),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Nama Supir',
                        value: docs.namaSupir,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Tujuan',
                        value: docs.tujuan ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.directions_car_outlined,
                        label: 'No Polisi',
                        value: docs.noPolisi ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.shield_moon_outlined,
                        label: 'Nomor Segel',
                        value: docs.nomorSegel,
                      ),

                      // ===== DETAIL BOX =====
                      if (boxOptions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Detail Box',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          children: boxOptions.map((opt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.inventory,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${opt['option_name']} • '
                                      '${f(opt['jumlah_box'])} box × '
                                      '${f(opt['isi'])} = '
                                      '${f(opt['total_ekor'])} ekor',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // ===== FOTO (1 BARIS) =====
                      if (docs.foto.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Foto',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 64,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: docs.foto.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final path = docs.foto[i];
                              if (!File(path).existsSync()) {
                                return const SizedBox.shrink();
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(path),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // ===== CATATAN =====
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

                      // ===== SYNC MANUAL =====
                      if (!docs.isSynced) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('Sync Manual'),
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

// ================= PARSER =================
List<Map<String, dynamic>> parseDocBoxOption(String? jsonStr) {
  if (jsonStr == null || jsonStr.isEmpty) return [];
  try {
    final List list = jsonDecode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}

// ================= BADGE =================
class _SyncBadge extends StatelessWidget {
  final bool isSynced;

  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final color = isSynced ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isSynced ? 'Tersync' : 'Belum Sync',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ================= INFO ROW =================
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
        children: [
          Icon(icon, size: 14, color: Colors.grey),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
