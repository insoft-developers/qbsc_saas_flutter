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
        backgroundColor: Colors.white,
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
                  child: Text('Belum ada data laporan suhu.'),
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
          title: "Hapus Laporan",
          middleText: "Yakin ingin menghapus laporan ini?",
          textCancel: "Batal",
          textConfirm: "Hapus",
          confirmTextColor: Colors.white,
          onConfirm: () {
            onDelete();
            Get.back();
            Get.snackbar(
              'Dihapus',
              'Laporan berhasil dihapus',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tanggal • $jam',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SyncBadge(isSynced: isSynced),
                ],
              ),

              const SizedBox(height: 12),

              // ===== BODY =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: location,
                        ),

                        _InfoRow(
                          icon: Icons.notes_rounded,
                          text: catatan.isNotEmpty
                              ? catatan
                              : 'Tidak ada catatan',
                        ),
                      ],
                    ),
                  ),

                  // FOTO
                  if (fotoFile != null)
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          fotoFile,
                          width: size.width * 0.2,
                          height: size.width * 0.2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),

              // ===== ACTION =====
              if (!isSynced) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: onSync,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sync Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FBF71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isSynced;

  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_off,
            size: 14,
            color: isSynced ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Tersinkron' : 'Local',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSynced ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
