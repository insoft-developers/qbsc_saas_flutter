import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_controller.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/scan_lokasi.dart';
import 'package:shimmer/shimmer.dart';

class Lokasi extends StatefulWidget {
  const Lokasi({super.key});

  @override
  State<Lokasi> createState() => _LokasiState();
}

class _LokasiState extends State<Lokasi> {
  final lokasiController = Get.put(LokasiController());

  @override
  void initState() {
    super.initState();
    lokasiController.fetchLokasi();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final cardPadding = isTablet ? 24.0 : 16.0;
    final iconSize = isTablet ? 48.0 : 36.0;
    final fontSize = isTablet ? 18.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Pengaturan Lokasi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => lokasiController.fetchLokasi(),
          child: ListView.builder(
            padding: EdgeInsets.all(cardPadding),
            itemCount: lokasiController.isLoading.value
                ? 5
                : lokasiController.lokasiList.length,
            itemBuilder: (context, index) {
              if (lokasiController.isLoading.value) {
                // shimmer skeleton
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: fontSize,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: width * 0.5,
                                  height: fontSize - 2,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(width: 16, height: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // list lokasi normal
                final lokasi = lokasiController.lokasiList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () => ScanLokasi(
                          locationId: lokasi.id,
                          locationName: lokasi.namaLokasi,
                          qrcode: lokasi.qrcode,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.indigo,
                              size: iconSize,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lokasi.namaLokasi,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'QR: ${lokasi.qrcode}\nLat: ${lokasi.latitude.toString()}, Long: ${lokasi.longitude.toString()}',
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
