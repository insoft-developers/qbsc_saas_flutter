import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/patroli/patroli_wa_controller.dart';

class PatroliWaPage extends StatefulWidget {
  final String tanggal;

  const PatroliWaPage({super.key, required this.tanggal});

  @override
  State<PatroliWaPage> createState() => _PatroliWaPageState();
}

class _PatroliWaPageState extends State<PatroliWaPage> {
  final controller = Get.put(PatroliWaController());

  @override
  void initState() {
    super.initState();
    controller.loadPatroli(widget.tanggal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          'Patroli - ${widget.tanggal}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// SHARE ALL
      floatingActionButton: Obx(() {
        if (controller.waPatroliList.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          child: const Icon(Icons.share),
          onPressed: () {
            controller.shareAllpatToWhatsApp(
              controller.waPatroliList,
              widget.tanggal,
            );
          },
        );
      }),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.waPatroliList.isEmpty) {
          return const Center(child: Text('Data Patroli tidak ditemukan'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.waPatroliList.length,
          itemBuilder: (_, i) {
            final doc = controller.waPatroliList[i];

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
                      '${doc.tanggal} - ${doc.jam}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      doc.locationName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 6),

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
                    if (doc.foto.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          '${ApiProvider.imageUrl}/${doc.foto}',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
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
