import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/services/location_tracking_service.dart';
import 'package:qbsc_saas/app/views/jadwal/patroli/jadwal_patroli_controller.dart';
import 'package:qbsc_saas/app/views/patroli/patroli.dart';

class JadwalPatroli extends StatefulWidget {
  const JadwalPatroli({super.key});

  @override
  State<JadwalPatroli> createState() => _JadwalPatroliState();
}

class _JadwalPatroliState extends State<JadwalPatroli> {
  final JadwalPatroliController controller = Get.put(JadwalPatroliController());
  final LocationTrackingService _trackingService = LocationTrackingService();

  @override
  initState() {
    super.initState();
    _trackingService.startTracking();
    print('mulai tracking lokasi satpam');
  }

  @override
  void dispose() {
    print("stop tracking lokasi satpam");
    _trackingService.stopTracking();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Jadwal Patroli Satpam',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Bersihkan Check',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetIsCheckedJadwalPatroli();
            },
          ),
        ],
      ),

      body: Obx(() {
        if (controller.jadwalPatroliList.isEmpty) {
          return const Center(child: Text('Belum ada jadwal patroli aktif'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.jadwalPatroliList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final jadwal = controller.jadwalPatroliList[index];
            final namaLokasi = controller.getNamaLokasi(
              jadwal.locationId.toString(),
            );

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.to(
                      () => Patroli(
                        id: jadwal.id,
                        locationId: jadwal.locationId,
                        locationName: namaLokasi,
                        jamAwal: jadwal.jamAwal,
                        jamAkhir: jadwal.jamAkhir,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // ===== ICON =====
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade400,
                                Colors.indigo.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ===== TEXT =====
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaLokasi,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.watch,
                                    text: jadwal.jamAwal,
                                  ),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    icon: Icons.watch,
                                    text: jadwal.jamAkhir,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ===== ACTION =====
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: jadwal.isChecked
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            jadwal.isChecked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: jadwal.isChecked
                                ? Colors.green
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void showResetChecklistDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Apakah Anda yakin ingin mereset semua checklist patroli?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // tutup dialog
            },
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back(); // tutup dialog dulu
              Get.find<JadwalPatroliController>().resetIsCheckedJadwalPatroli();
              Get.snackbar(
                'Berhasil',
                'Semua checklist patroli telah direset',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
