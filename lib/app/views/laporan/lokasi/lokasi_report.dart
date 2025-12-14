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
          padding: const EdgeInsets.all(12),
          itemCount: controller.lokasiList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lokasi = controller.lokasiList[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                onTap: () => openMaps(lokasi.latitude, lokasi.longitude),
                title: Text(
                  lokasi.namaLokasi,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${lokasi.id} | Kode: ${lokasi.qrcode}'),
                    const SizedBox(height: 2),
                    Text('Lat: ${lokasi.latitude}, Lng: ${lokasi.longitude}'),
                  ],
                ),
                leading: const Icon(Icons.location_on, color: Colors.blue),
                trailing: const Icon(Icons.map, color: Colors.green),
              ),
            );
          },
        );
      }),
    );
  }
}
