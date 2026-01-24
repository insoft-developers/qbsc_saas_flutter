import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absensi/absensi_anggota_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absensi/absensi_anggota_model.dart';

class AbsensiAnggota extends StatelessWidget {
  const AbsensiAnggota({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AbsensiAnggotaController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan Satpam Bertugas',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.getDataAbsensi,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.absensiList.isEmpty) {
          return const Center(
            child: Text(
              'Data absensi belum tersedia',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.absensiList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.absensiList[index];
              // CARD ITEM (sama seperti sebelumnya)
              return _AbsensiCard(item: item);
            },
          ),
        );
      }),
    );
  }
}

class _AbsensiCard extends StatelessWidget {
  final AbsensiAnggotaModel item;
  const _AbsensiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AbsensiAnggotaController>();
    return GestureDetector(
      onTap: () {
        controller.callWhatsApp(item.whatsapp);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: item.foto != null && item.foto!.isNotEmpty
                  ? NetworkImage('${ApiProvider.imageUrl}/${item.foto}')
                  : null,
              child: item.foto == null || item.foto!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey.shade600)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.whatsapp,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: [
                      _timeChip(Icons.login, item.jamMasuk, Colors.green),
                      const SizedBox(height: 8),
                      _timeChip(Icons.logout, item.jamKeluar, Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.status == 1 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeChip(IconData icon, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
