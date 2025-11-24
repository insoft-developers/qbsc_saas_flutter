import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/kejadian/kejadian_controller.dart';

class Kejadian extends StatelessWidget {
  const Kejadian({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(KejadianController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Laporkan Kejadian',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3C3535),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Laporan', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.toNamed('/laporan/kejadian');
        },
      ),
      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== NOTE =====================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Laporan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Laporan wajib diisi' : null,
                onChanged: c.setLaporan,
              ),
              const SizedBox(height: 20),

              // ===================== FOTO =====================
              const Text('Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: [
                    c.foto.value == null
                        ? Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Text('Belum ada foto'),
                          )
                        : Image.file(c.foto.value!, height: 150),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: c.pickFoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ambil Foto'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===================== BUTTON SIMPAN =====================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (c.validateForm()) {
                      c.saveSituasi();
                    } else {
                      Get.snackbar(
                        'Gagal',
                        'Masih ada data yang kosong',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
