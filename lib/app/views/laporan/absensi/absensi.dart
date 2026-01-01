import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/absensi/absensi_controller.dart';
import 'package:qbsc_saas/app/views/laporan/absensi/absensi_model.dart';

class Absensi extends StatefulWidget {
  const Absensi({super.key});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  final AbsensiController controller = Get.put(AbsensiController());
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

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Laporan Absensi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
              final AbsensiModel absensi = controller.absensiList[index];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Get.to(() => AbsensiDetail(data: absensi));
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
                          "${Fungsi.tanggalIndo(absensi.tanggal)} - ${absensi.satpamName}",
                        ),
                        _buildRow(
                          "Jam Masuk / Pulang",
                          "${Fungsi.formatToTime(absensi.jamMasuk)} - ${Fungsi.formatToTime(absensi.jamKeluar)}",
                        ),

                        _buildRow(
                          "Status",
                          absensi.status == 1 ? 'Masuk' : 'Pulang',
                        ),

                        _buildRow(
                          "Catatan Masuk/Pulang",
                          "${absensi.catatanMasuk} - ${absensi.catatanKeluar}",
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
