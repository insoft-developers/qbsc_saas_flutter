import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/notif/notif_controller.dart';
import 'package:qbsc_saas/app/views/notif/notif_detail.dart';
import 'package:shimmer/shimmer.dart';

class Notif extends StatelessWidget {
  const Notif({super.key});

  @override
  Widget build(BuildContext context) {
    final _notif = Get.put(NotifController());

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
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => _notif.fetchNotif(),
          child: ListView.builder(
            padding: EdgeInsets.all(cardPadding),
            itemCount: _notif.isLoading.value ? 5 : _notif.notifList.length,
            itemBuilder: (context, index) {
              if (_notif.isLoading.value) {
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
                final lokasi = _notif.notifList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Get.to(() => NotifDetail(data: lokasi));
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lokasi.judul,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  lokasi.pesan,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${lokasi.pengirim} - ${lokasi.waktu}',
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
