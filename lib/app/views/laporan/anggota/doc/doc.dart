import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/doc/doc_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/doc/doc_detail.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/doc/doc_model.dart';

class DocPage extends StatefulWidget {
  const DocPage({super.key});

  @override
  State<DocPage> createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  final DocController controller = Get.put(DocController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        controller.isMoreDataAvailable.value &&
        !controller.isLoading.value) {
      controller.fetchDoc(loadMore: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // =========================
  // FILTER BOTTOM SHEET
  // =========================
  void _showFilterBottomSheet() {
    int? selectedSatpamId = controller.selectedSatpamId.value;
    int? selectedEkspedisiId = controller.selectedEkspedisiId.value;
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Catatan DOC',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // ===== FILTER TANGGAL =====
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => startDate = date);
                            }
                          },
                          child: Text(
                            startDate == null
                                ? 'Tanggal Mulai'
                                : Fungsi.tanggalIndo(
                                    startDate!.toIso8601String().substring(
                                      0,
                                      10,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => endDate = date);
                            }
                          },
                          child: Text(
                            endDate == null
                                ? 'Tanggal Akhir'
                                : Fungsi.tanggalIndo(
                                    endDate!.toIso8601String().substring(0, 10),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== FILTER SATPAM (DROPDOWN DB) =====
                  Obx(() {
                    return DropdownButtonFormField<int>(
                      value: selectedSatpamId,
                      decoration: const InputDecoration(
                        labelText: 'Satpam',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Satpam'),
                        ),
                        ...controller.satpamList.map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedSatpamId = val);
                      },
                    );
                  }),

                  const SizedBox(height: 12),

                  // ===== FILTER SATPAM (DROPDOWN DB) =====
                  Obx(() {
                    return DropdownButtonFormField<int>(
                      value: selectedEkspedisiId,
                      decoration: const InputDecoration(
                        labelText: 'Ekspedisi',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Ekspedisi'),
                        ),
                        ...controller.ekspedisiList.map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedEkspedisiId = val);
                      },
                    );
                  }),

                  const SizedBox(height: 12),
                  // ===== ACTION =====
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilter();
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.applyFilter(
                              start: startDate?.toIso8601String().substring(
                                0,
                                10,
                              ),
                              end: endDate?.toIso8601String().substring(0, 10),
                              satpamId: selectedSatpamId,
                              ekspedisiId: selectedEkspedisiId,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Lihat Catatan DOC',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
        onPressed: () {
          controller.refreshData();
        },
      ),

      backgroundColor: Colors.white,
      body: Obx(() {
        // 1️⃣ Loading pertama kali
        if (controller.isLoading.value && controller.docList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Data kosong (hasil filter tidak ada)
        if (!controller.isLoading.value && controller.docList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Data Doc Keluar tidak ditemukan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Coba ubah filter atau rentang tanggal',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        // 3️⃣ Data ada → List
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              controller.docList.length +
              (controller.isMoreDataAvailable.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.docList.length) {
              final DocModel dataShow = controller.docList[index];
              final fotos = parseFotoDynamic(dataShow.foto);
              final boxOptions = parseDocBoxOption(dataShow.docBoxOptionJson);

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => DocDetail(data: dataShow));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          "Tanggal / Jam",
                          "${Fungsi.tanggalIndo(dataShow.tanggal)} - ${dataShow.jam}",
                        ),
                        _buildRow(
                          "Jumlah Box/Total Ekor",
                          "${dataShow.jumlah} Box - ${dataShow.totalEkor} Ekor",
                        ),
                        _buildRow(
                          "Ekspedisi/Satpam",
                          "${dataShow.ekspedisiName} - ${dataShow.satpamName}",
                        ),
                        _buildRow(
                          "No Polisi/Tujuan",
                          "${dataShow.noPolisi} - ${dataShow.tujuan}",
                        ),

                        // ===== DETAIL BOX =====
                        if (boxOptions.isNotEmpty) ...[
                          const SizedBox(height: 10),
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
                                        '${opt['jumlah_box']} box × '
                                        '${opt['isi']} = '
                                        '${opt['total_ekor']} ekor',
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

                        // ===== FOTO =====
                        if (fotos.isNotEmpty) ...[
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
                              itemCount: fotos.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "${ApiProvider.imageUrl}/${fotos[i]}",
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        _buildRow("Catatan", dataShow.note ?? ''),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        );
      }),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.25, // 🔥 lebih padat
            ),
          ),
          const SizedBox(height: 6),
          Divider(height: 1, thickness: 0.6, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

// ===== FOTO PARSER (STRING / JSON ARRAY) =====
List<String> parseFotoDynamic(dynamic foto) {
  if (foto == null) return [];

  if (foto is List) {
    return foto.map((e) => e.toString()).toList();
  }

  if (foto is String && foto.isNotEmpty) {
    if (foto.trim().startsWith('[')) {
      try {
        final List list = jsonDecode(foto);
        return list.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return [foto];
  }

  return [];
}

// ===== DETAIL BOX PARSER =====
List<Map<String, dynamic>> parseDocBoxOption(String? jsonStr) {
  if (jsonStr == null || jsonStr.isEmpty) return [];
  try {
    final List list = jsonDecode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}
