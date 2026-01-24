import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/kipas/kipas_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/kipas/kipas_detail.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/kipas/kipas_model.dart';

class KandangKipas extends StatefulWidget {
  const KandangKipas({super.key});

  @override
  State<KandangKipas> createState() => _KandangKipasState();
}

class _KandangKipasState extends State<KandangKipas> {
  final KipasController controller = Get.put(KipasController());
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
      controller.fetchKipas(loadMore: true);
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
    int? selectedKandangId = controller.selectedKandangId.value;
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
                    'Filter Kandang',
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
                      value: selectedKandangId,
                      decoration: const InputDecoration(
                        labelText: 'Kandang',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Kandang'),
                        ),
                        ...controller.kandangList.map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedKandangId = val);
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
                              kandangId: selectedKandangId,
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

  List<int> parseKipas(String data) {
    return data.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            child: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.refreshData();
            },
          ),
        ],
      ),

      backgroundColor: Colors.white,
      body: Obx(() {
        // 1️⃣ Loading pertama kali
        if (controller.isLoading.value && controller.kipasList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Data kosong (hasil filter tidak ada)
        if (!controller.isLoading.value && controller.kipasList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Data Suhu tidak ditemukan',
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
              controller.kipasList.length +
              (controller.isMoreDataAvailable.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.kipasList.length) {
              final KipasModel kipasData = controller.kipasList[index];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => KipasDetail(data: kipasData));
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
                          "${Fungsi.tanggalIndo(kipasData.tanggal)} - ${kipasData.jam}",
                        ),
                        _buildRow(
                          "Kandang/Satpam",
                          "${kipasData.kandangName} - ${kipasData.satpamName}",
                        ),
                        _card(
                          title: 'Kipas',
                          children: [buildKipasGrid(kipasData.kipas)],
                        ),

                        _buildRow("Catatan", kipasData.note ?? ''),
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

  Widget buildKipasGrid(String data) {
    final List<int> kipasList = parseKipas(data);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kipasList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // ✅ 1 baris 6 kipas
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9, // sedikit lebih ramping
      ),
      itemBuilder: (context, index) {
        final bool isOn = kipasList[index] == 1;

        return Container(
          decoration: BoxDecoration(
            color: isOn ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8), // lebih kecil
            border: Border.all(
              color: isOn ? Colors.green : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${index + 1}', // 🔥 lebih ringkas dari "Kipas 1"
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isOn ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE =====
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // ===== CONTENT =====
          ...children,
        ],
      ),
    );
  }
}
