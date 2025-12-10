import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';
import 'package:shimmer/shimmer.dart';

class DaftarTamu extends StatefulWidget {
  const DaftarTamu({super.key});

  @override
  State<DaftarTamu> createState() => _DaftarTamuState();
}

class _DaftarTamuState extends State<DaftarTamu> {
  final TamuController _tamu = Get.put(TamuController());

  @override
  void initState() {
    super.initState();
    _tamu.getListTamu();
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
          'Daftar Tamu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => _tamu.getListTamu(),
          child: ListView.builder(
            padding: EdgeInsets.all(cardPadding),
            itemCount: _tamu.isLoading.value ? 5 : _tamu.tamuList.length,
            itemBuilder: (context, index) {
              if (_tamu.isLoading.value) {
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
                // ignore: non_constant_identifier_names
                final DaftarTamu = _tamu.tamuList[index];
                String isStatus = '';
                Color isWarna = Colors.amber;
                if (DaftarTamu['is_status'] == 1) {
                  isStatus = 'Appointment';
                  isWarna = Colors.blue;
                } else if (DaftarTamu['is_status'] == 2) {
                  isStatus = 'Tiba';
                  isWarna = Colors.green;
                } else if (DaftarTamu['is_status'] == 3) {
                  isStatus = 'Pulang';
                  isWarna = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Get.defaultDialog(
                        title: "Tamu Pulang",
                        middleText: "Simpan data tamu pulang ..?",
                        textCancel: "Batal",
                        textConfirm: "Ya",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          // controller.deleteLaporanDoc(index);
                          _tamu.updateStatusTamu(DaftarTamu['id']);
                          Get.back();
                          Get.snackbar(
                            'Berhasil',
                            'Data tamu berhasil disimpan',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
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
                            padding: const EdgeInsets.all(10),
                            child: DaftarTamu['foto'] == null
                                ? const SizedBox()
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      "${ApiProvider.imageUrl}/${DaftarTamu['foto'].toString()}",
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DaftarTamu['nama_tamu'],
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Tujuan ${DaftarTamu['tujuan']}",
                                  style: TextStyle(fontSize: fontSize - 2),
                                ),
                                Text(
                                  "Catatan : ${DaftarTamu['catatan']}",
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Status : $isStatus \n${DaftarTamu['arrive_at'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    color: isWarna,
                                  ),
                                ),
                              ],
                            ),
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
