import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/laporan/ekspedisi/ekspedisi_report_controller.dart';

class EkspedisiReport extends StatelessWidget {
  const EkspedisiReport({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EkspedisiReportController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporan Data Ekspedisi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.ekspedisiList.isEmpty) {
          return const Center(child: Text('Belum ada data ekspedisi'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.ekspedisiList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lokasi = controller.ekspedisiList[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                onTap: () {},
                title: Text(
                  lokasi.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${lokasi.id} | Kode: ${lokasi.code}'),
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
