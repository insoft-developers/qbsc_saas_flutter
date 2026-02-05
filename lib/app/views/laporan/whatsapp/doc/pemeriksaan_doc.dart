import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/doc/pemeriksaan_doc_controller.dart';

class PemeriksaanDoc extends StatefulWidget {
  final String tanggal;

  const PemeriksaanDoc({super.key, required this.tanggal});

  @override
  State<PemeriksaanDoc> createState() => _PemeriksaanDocState();
}

class _PemeriksaanDocState extends State<PemeriksaanDoc> {
  final controller = Get.put(PemeriksaanDocController());

  @override
  void initState() {
    super.initState();
    controller.loadDoc(widget.tanggal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          'DOC - ${widget.tanggal}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// SHARE ALL
      floatingActionButton: Obx(() {
        if (controller.waDocList.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          child: const Icon(Icons.share),
          onPressed: () {
            controller.shareAllDocToWhatsApp(
              controller.waDocList,
              widget.tanggal,
            );
          },
        );
      }),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.waDocList.isEmpty) {
          return const Center(child: Text('Data DOC tidak ditemukan'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.waDocList.length,
          itemBuilder: (_, i) {
            final doc = controller.waDocList[i];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER RINGKAS
                    Text(
                      '${doc.inputDate} : ${doc.supir} • ${doc.noPolisi}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${doc.ekspedisi} → ${doc.tujuan}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// BOX RINGKAS
                    ...doc.boxes
                        .where((b) => b.jumlahBox != '0')
                        .map(
                          (b) => Text(
                            '• ${b.name}: ${b.jumlahBox} box × ${b.isi} = ${b.totalEkor}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),

                    const SizedBox(height: 6),

                    /// TOTAL & SEGEL
                    Text(
                      'Total: ${doc.jumlahBox} Box | ${doc.totalEkor} ekor | Segel: ${doc.nomorSegel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    /// CATATAN
                    if (doc.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        doc.note,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],

                    /// FOTO MINI
                    if (doc.fotos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: doc.fotos.map((foto) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              'https://app.qbsc.cloud/storage/$foto',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
