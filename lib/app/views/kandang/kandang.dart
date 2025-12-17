import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/kandang/alarm/alarm.dart';
import 'package:qbsc_saas/app/views/kandang/kandang_controller.dart';
import 'package:qbsc_saas/app/views/kandang/kipas/kipas.dart';
import 'package:qbsc_saas/app/views/kandang/lampu/lampu.dart';
import 'package:qbsc_saas/app/views/kandang/suhu/suhu.dart';

class Kandang extends StatelessWidget {
  const Kandang({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KandangController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Daftar Kandang',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3C3535),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Laporan', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.toNamed('/laporan/kandang');
        },
      ),
      body: Obx(() {
        final list = controller.kandangList;

        if (list.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada data kandang',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final kandang = list[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kandang.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kandang.isEmpty
                              ? Colors.grey.shade200
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          kandang.isEmpty ? 'Kosong' : 'Terisi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kandang.isEmpty ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ================= INFO =================
                  _infoRow('Kode', kandang.code),
                  _infoRow('Suhu Standar', '${kandang.stdTemp} °C'),
                  _infoRow('Jumlah Kipas', kandang.fanAmount.toString()),

                  const SizedBox(height: 18),

                  // ================= CONTROL =================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 420;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _controlButton(
                            label: 'Suhu',
                            icon: Icons.thermostat,
                            color: Colors.orange,
                            width: isWide
                                ? constraints.maxWidth / 4 - 12
                                : constraints.maxWidth,
                            onTap: () {
                              Get.to(
                                () => Suhu(id: kandang.id, name: kandang.name),
                              );
                            },
                          ),
                          _controlButton(
                            label: 'Kipas',
                            icon: Icons.wind_power,
                            color: Colors.blue,
                            width: isWide
                                ? constraints.maxWidth / 4 - 12
                                : constraints.maxWidth,
                            onTap: () {
                              Get.to(
                                () => Kipas(
                                  id: kandang.id,
                                  name: kandang.name,
                                  jumlahKipas: kandang.fanAmount,
                                ),
                              );
                            },
                          ),
                          _controlButton(
                            label: 'Alarm',
                            icon: Icons.alarm,
                            color: Colors.red,
                            width: isWide
                                ? constraints.maxWidth / 4 - 12
                                : constraints.maxWidth,
                            onTap: () {
                              Get.to(
                                () => Alarm(id: kandang.id, name: kandang.name),
                              );
                            },
                          ),
                          _controlButton(
                            label: 'Lampu',
                            icon: Icons.lightbulb,
                            color: Colors.amber.shade700,
                            width: isWide
                                ? constraints.maxWidth / 4 - 12
                                : constraints.maxWidth,
                            onTap: () {
                              Get.to(
                                () => Lampu(id: kandang.id, name: kandang.name),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _controlButton({
    required String label,
    required IconData icon,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
