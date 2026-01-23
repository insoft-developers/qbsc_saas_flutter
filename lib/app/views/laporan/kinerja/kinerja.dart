import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/components/satpam_summary_slider.dart';
import 'package:qbsc_saas/app/views/laporan/kinerja/kinerja_controller.dart';

class Kinerja extends StatelessWidget {
  const Kinerja({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KinerjaController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan Kinerja',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        // ===== LOADING AWAL =====
        if (controller.isLoading.value && controller.kinerjaData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // ===== EMPTY STATE =====
        if (controller.kinerjaData.isEmpty) {
          return const Center(
            child: Text(
              'Data kinerja belum tersedia',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // ===== CONTENT + PULL TO REFRESH =====
        return RefreshIndicator(
          onRefresh: controller.kinerjaSatpam,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SatpamSummarySlider(
                  data: controller.kinerjaData
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList(),
                ),

                // ===== LOADING BAWAH (SAAT REFRESH / LOAD ULANG) =====
                if (controller.isLoading.value) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
