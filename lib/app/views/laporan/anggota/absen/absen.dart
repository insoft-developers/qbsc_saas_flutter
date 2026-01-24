import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absen/absen_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absen/absen_detail.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absen/absen_model.dart';

class AbsenLaporan extends StatefulWidget {
  const AbsenLaporan({super.key});

  @override
  State<AbsenLaporan> createState() => _AbsenLaporanState();
}

class _AbsenLaporanState extends State<AbsenLaporan> {
  final AbsenLaporanController controller = Get.put(AbsenLaporanController());
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
      controller.getDataAbsensi(loadMore: true);
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
    String? selectedStatus = controller.status.value;
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
                    'Filter Absensi',
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

                  // ===== FILTER STATUS =====
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Masuk')),
                      DropdownMenuItem(value: '2', child: Text('Pulang')),
                    ],
                    onChanged: (val) {
                      setState(() => selectedStatus = val);
                    },
                  ),

                  const SizedBox(height: 20),

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
                              statusValue: selectedStatus,
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
          'Monitoring Absensi',
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
        if (controller.isLoading.value && controller.absensiList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Data kosong (hasil filter tidak ada)
        if (!controller.isLoading.value && controller.absensiList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Data absensi tidak ditemukan',
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
              controller.absensiList.length +
              (controller.isMoreDataAvailable.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.absensiList.length) {
              final AbsenModel absensi = controller.absensiList[index];

              String catatanStatus = absensi.status == 1
                  ? "Masuk - ${absensi.catatanMasuk ?? ''}"
                  : "Pulang - ${absensi.catatanMasuk ?? ''} - ${absensi.catatanKeluar ?? ''}";

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => AbsenDetail(data: absensi));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          "Tanggal / Satpam",
                          "${Fungsi.tanggalIndo(absensi.tanggal)} - ${absensi.namaSatpam}",
                        ),
                        _buildRow(
                          "Shift / Jam Masuk / Pulang",
                          "${absensi.shiftName} - ${Fungsi.formatToTime(absensi.jamMasuk)} - ${Fungsi.formatToTime(absensi.jamKeluar ?? '')}",
                        ),
                        _buildRow(
                          "Status",
                          absensi.status == 1 ? 'MASUK' : 'PULANG',
                        ),
                        _buildRow(
                          "Catatan Masuk / Catatan Pulang",
                          "${absensi.catatanMasuk ?? '-'} | ${absensi.catatanKeluar ?? '-'}",
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (absensi.fotoMasuk!.isNotEmpty)
                              _buildFoto(
                                "${ApiProvider.imageUrl}/${absensi.fotoMasuk}",
                                'Masuk',
                              ),

                            if (absensi.fotoMasuk!.isNotEmpty ||
                                absensi.fotoKeluar!.isNotEmpty)
                              const SizedBox(width: 12),

                            if (absensi.fotoKeluar!.isNotEmpty)
                              _buildFoto(
                                "${ApiProvider.imageUrl}/${absensi.fotoKeluar}",
                                'Pulang',
                              ),
                          ],
                        ),
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

Widget _buildFoto(String url, String label) {
  return Column(
    children: [
      ClipOval(
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 24),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}
