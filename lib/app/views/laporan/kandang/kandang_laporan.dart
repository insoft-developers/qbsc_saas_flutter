import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/kandang/kandang_laporan_controller.dart';

class KandangLaporan extends StatelessWidget {
  const KandangLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KandangLaporanController());
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3C3535),
          title: const Text(
            'Laporan Kandang',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Suhu'),
              Tab(text: 'Kipas'),
              Tab(text: 'Alarm'),
              Tab(text: 'Lampu'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ====== Tab 1: SUHU ======
            Obx(() {
              final list = controller.suhuList;
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data laporan suhu.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final fotoFile = controller.getFotoFile(data.foto);
                  final kandangName = controller.getKandangName(data.kandangId);

                  return _buildCard(
                    size: size,
                    title: kandangName ?? '-',
                    tanggal: data.tanggal,
                    jam: data.jam,
                    subtitle: 'Suhu: ${data.temperature} °C',
                    location:
                        '${data.latitude.toString()} - ${data.longitude.toString()}',
                    fotoFile: fotoFile,
                    isSynced: data.isSynced,
                    catatan: 'Catatan: ${data.note!}',
                    onSync: () => controller.syncSuhuData(data),
                    onDelete: () => controller.deleteLaporanSuhu(index),
                  );
                },
              );
            }),

            // ====== Tab 2: KIPAS ======
            Obx(() {
              final list = controller.kipasList;
              if (list.isEmpty) {
                return const Center(
                  child: Text('Belum ada data laporan kipas.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final fotoFile = controller.getFotoFile(data.foto);
                  final kandangName = controller.getKandangName(data.kandangId);
                  return _buildCard(
                    size: size,
                    title: kandangName ?? '-',
                    tanggal: data.tanggal,
                    jam: data.jam,
                    subtitle: 'Kipas: ${data.kipas}',
                    location:
                        '${data.latitude.toString()} - ${data.longitude.toString()}',
                    fotoFile: fotoFile,
                    isSynced: data.isSynced,
                    catatan: 'Catatan: ${data.note!}',
                    onSync: () => controller.syncKipasData(data),
                    onDelete: () => controller.deleteLaporanKipas(index),
                  );
                },
              );
            }),

            // ====== Tab 3: ALARM ======
            Obx(() {
              final list = controller.alarmList;
              if (list.isEmpty) {
                return const Center(
                  child: Text('Belum ada data laporan alarm.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final kandangName = controller.getKandangName(data.kandangId);
                  final fotoFile = controller.getFotoFile(data.foto);
                  return _buildCard(
                    size: size,
                    title: kandangName ?? '-',
                    tanggal: data.tanggal,
                    jam: data.jam,
                    subtitle: data.isAlarmOn ? 'Alarm: Hidup' : 'Alarm: Mati',
                    location:
                        '${data.latitude.toString()} - ${data.longitude.toString()}',
                    fotoFile: fotoFile,
                    isSynced: data.isSynced,
                    catatan: 'Catatan: ${data.note!}',
                    onSync: () => controller.syncAlarmData(data),
                    onDelete: () => controller.deleteLaporanAlarm(index),
                  );
                },
              );
            }),

            // ====== Tab 4: LAMPU ======
            Obx(() {
              final list = controller.lampuList;
              if (list.isEmpty) {
                return const Center(
                  child: Text('Belum ada data laporan lampu.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final kandangName = controller.getKandangName(data.kandangId);
                  final fotoFile = controller.getFotoFile(data.foto);
                  return _buildCard(
                    size: size,
                    title: kandangName ?? '-',
                    tanggal: data.tanggal,
                    jam: data.jam,
                    subtitle: data.isLampOn ? 'Lampu: Hidup' : 'Lampu: Mati',
                    location:
                        '${data.latitude.toString()} - ${data.longitude.toString()}',
                    catatan: 'Catatan: ${data.note!}',
                    fotoFile: fotoFile,
                    isSynced: data.isSynced,
                    onSync: () => controller.syncLampuData(data),
                    onDelete: () => controller.deleteLaporanLampu(index),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Size size,
    required String title,
    required String subtitle,
    required dynamic tanggal,
    required dynamic jam,
    required String location,
    required VoidCallback onDelete,
    required VoidCallback onSync,
    File? fotoFile,
    required bool isSynced,
    required String catatan,
  }) {
    return GestureDetector(
      onLongPress: () {
        Get.defaultDialog(
          title: "Hapus Data",
          middleText: "Yakin mau hapus laporan ini?",
          textCancel: "Batal",
          textConfirm: "Hapus",
          confirmTextColor: Colors.white,
          onConfirm: () {
            onDelete();
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: $tanggal $jam'),
              Text(subtitle),
              Text(location),
              Text(catatan),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      isSynced ? 'Synced' : 'Local',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: isSynced ? Colors.green : Colors.red,
                    avatar: Icon(
                      isSynced ? Icons.cloud_done : Icons.cloud_off,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: isSynced ? null : onSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.sync, color: Colors.white, size: 18),
                    label: const Text(
                      'Sync',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: fotoFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    fotoFile,
                    width: size.width * 0.18,
                    height: size.width * 0.18,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 40,
                ),
        ),
      ),
    );
  }
}
