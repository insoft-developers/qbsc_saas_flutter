import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lokasi_report_controller.dart';

class LokasiReport extends StatelessWidget {
  const LokasiReport({super.key});

  Future<void> openMaps(double lat, double lng) async {
    final Uri googleMapsAppUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final Uri googleMapsWebUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      // Paksa mode aplikasi eksternal
      final canLaunchApp = await canLaunchUrl(googleMapsAppUri);
      if (canLaunchApp) {
        await launchUrl(googleMapsAppUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Kalau gagal, fallback ke browser
      final canLaunchWeb = await canLaunchUrl(googleMapsWebUri);
      if (canLaunchWeb) {
        await launchUrl(googleMapsWebUri, mode: LaunchMode.externalApplication);
        return;
      }

      Get.snackbar('Error', 'Tidak dapat membuka Google Maps');
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka Maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LokasiReportController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan Data Lokasi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.lokasiList.isEmpty) {
          return const Center(child: Text('Belum ada data lokasi'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.lokasiList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final lokasi = controller.lokasiList[index];

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
                  onTap: () => openMaps(lokasi.latitude, lokasi.longitude),
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
                                lokasi.namaLokasi,
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
                                    icon: Icons.tag,
                                    text: 'ID ${lokasi.id}',
                                  ),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    icon: Icons.qr_code_rounded,
                                    text: lokasi.qrcode,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Icon(
                                    Icons.my_location_rounded,
                                    size: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${lokasi.latitude}, ${lokasi.longitude}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
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
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.map_rounded,
                            size: 20,
                            color: Colors.indigo.shade700,
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
}
