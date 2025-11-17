import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/doc/doc_report_controller.dart';

class DocReport extends StatelessWidget {
  const DocReport({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocReportController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan DOC Keluar',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.docList.isEmpty) {
          return const Center(child: Text('Belum ada data doc keluar'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.docList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lokasi = controller.docList[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                onTap: () {},
                title: Text(
                  lokasi.tanggal,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam: ${lokasi.jam} | Satpam: ${lokasi.satpamId.toString()}',
                    ),
                    const SizedBox(height: 2),
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
