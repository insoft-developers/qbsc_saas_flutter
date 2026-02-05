import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/kandang/kandang_wa_controller.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/kandang/kandang_wa_model.dart';

class KandangWa extends StatefulWidget {
  final String tanggal;
  final String jam;
  const KandangWa({super.key, required this.tanggal, required this.jam});

  @override
  State<KandangWa> createState() => _KandangWaState();
}

class _KandangWaState extends State<KandangWa> {
  final controller = Get.put(KandangWaController());

  @override
  void initState() {
    super.initState();
    controller.ambilDataWhatsapp(widget.tanggal, widget.jam);
  }

  Color _statusColor(String status) {
    return status.toLowerCase() == 'on' || status == '1'
        ? Colors.green
        : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          '${widget.tanggal} - ${widget.jam}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.share),
        onPressed: () => controller.shareToWhatsAppCompact(
          controller.waKandangList,
          Fungsi.getNamaHari(widget.tanggal),
          widget.tanggal,
          widget.jam,
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.waKandangList.isEmpty) {
          return const Center(
            child: Text('Tidak ada data', style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.waKandangList.length,
          itemBuilder: (context, index) {
            final KandangWaModel kandang = controller.waKandangList[index];

            return Card(
              elevation: 3,
              shadowColor: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris nama + gambar kecil
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kandang.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (kandang.kipasImage.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              kandang.kipasImage,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'No Image',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Baris info singkat
                    Text(
                      'S:${kandang.suhu}°C | K:${kandang.kipas} | A:${kandang.alarm} | L:${kandang.lampu}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
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
}
