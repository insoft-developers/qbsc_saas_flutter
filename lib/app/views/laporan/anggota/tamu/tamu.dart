import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_detail.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_model.dart';

class TamuPage extends StatefulWidget {
  const TamuPage({super.key});

  @override
  State<TamuPage> createState() => _TamuPageState();
}

class _TamuPageState extends State<TamuPage> {
  final TamuController controller = Get.put(TamuController());
  final ScrollController scrollController = ScrollController();
  final myComId = AppPrefs.getComId();

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
      controller.fetchTamu(loadMore: true);
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
    int? selectedUserId = controller.selectedUserId.value;
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
                    'Filter Tamu',
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
                      value: selectedUserId,
                      decoration: const InputDecoration(
                        labelText: 'Dibuat Oleh',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...controller.userList.map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedUserId = val);
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
                              userId: selectedUserId,
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
          'Monitoring Tamu',
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.refreshData();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),

      backgroundColor: Colors.white,
      body: Obx(() {
        // 1️⃣ Loading pertama kali
        if (controller.isLoading.value && controller.tamuList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Data kosong (hasil filter tidak ada)
        if (!controller.isLoading.value && controller.tamuList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Data tamu tidak ditemukan',
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
              controller.tamuList.length +
              (controller.isMoreDataAvailable.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.tamuList.length) {
              final TamuModel _tamu = controller.tamuList[index];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => TamuDetail(data: _tamu));
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
                          "${Fungsi.tanggalIndo(_tamu.createdAt)} - ${Fungsi.formatToTime(_tamu.createdAt)}",
                        ),
                        _buildRow(
                          "Nama Tamu/Jumlah",
                          "${_tamu.namaTamu} - ${_tamu.jumlahTamu.toString()} orang",
                        ),
                        _buildRow("Tujuan", _tamu.tujuan ?? ''),
                        _buildRow("Catatan", _tamu.catatan ?? ''),
                        _buildRow("Dibuat Oleh", _tamu.createdName ?? ''),
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
