import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/kandang/alarm/alarm.dart';
import 'package:qbsc_saas/app/views/kandang/kandang_controller.dart';
import 'package:qbsc_saas/app/views/kandang/kipas/kipas.dart';
import 'package:qbsc_saas/app/views/kandang/lampu/lampu.dart';
import 'package:qbsc_saas/app/views/kandang/suhu/suhu.dart';
import 'package:qbsc_saas/app/views/kandang/suhu/suhu_controller.dart';

class Kandang extends StatelessWidget {
  const Kandang({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KandangController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Daftar Kandang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
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
              'Belum ada data kandang di Hive.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final kandang = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama kandang
                    Text(
                      kandang.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.05,
                        color: const Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Detail info
                    Text(
                      'Kode: ${kandang.code}\n'
                      'Suhu Standar: ${kandang.stdTemp}°C | Kipas: ${kandang.fanAmount}\n'
                      'Status: ${kandang.isEmpty ? 'Kosong' : 'Terisi'}',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol-tombol kontrol
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 400;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildControlButton(
                              label: 'Suhu',
                              icon: Icons.thermostat,
                              color: Colors.orangeAccent,
                              onTap: () {
                                Get.to(
                                  () =>
                                      Suhu(id: kandang.id, name: kandang.name),
                                );
                              },
                              size: size,
                              fullWidth: !isWide,
                            ),
                            _buildControlButton(
                              label: 'Kipas',
                              icon: Icons.wind_power,
                              color: Colors.lightBlueAccent,
                              onTap: () {
                                Get.to(
                                  () => Kipas(
                                    id: kandang.id,
                                    name: kandang.name,
                                    jumlahKipas: kandang.fanAmount,
                                  ),
                                );
                              },
                              size: size,
                              fullWidth: !isWide,
                            ),
                            _buildControlButton(
                              label: 'Alarm',
                              icon: Icons.alarm,
                              color: Colors.redAccent,
                              onTap: () {
                                Get.to(
                                  () =>
                                      Alarm(id: kandang.id, name: kandang.name),
                                );
                              },
                              size: size,
                              fullWidth: !isWide,
                            ),
                            _buildControlButton(
                              label: 'Lampu',
                              icon: Icons.lightbulb,
                              color: Colors.amber,
                              onTap: () {
                                Get.to(
                                  () =>
                                      Lampu(id: kandang.id, name: kandang.name),
                                );
                              },
                              size: size,
                              fullWidth: !isWide,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required Size size,
    bool fullWidth = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: fullWidth ? 6 : 0),
      child: SizedBox(
        width: fullWidth ? double.infinity : size.width * 0.2,
        height: size.height * 0.06,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: Icon(icon, size: size.width * 0.08, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
