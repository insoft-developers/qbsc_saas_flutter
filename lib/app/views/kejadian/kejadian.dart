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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== SECTION =====================
              const Text(
                'Detail Kejadian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),

              // ===================== LAPORAN =====================
              TextFormField(
                maxLines: 4,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kejadian',
                  hintText:
                      'Jelaskan kejadian yang terjadi secara singkat dan jelas',
                  prefixIcon: const Icon(Icons.report_problem_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Laporan wajib diisi' : null,
                onChanged: c.setLaporan,
              ),

              const SizedBox(height: 24),

              // ===================== FOTO =====================
              const Text(
                'Dokumentasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Obx(
                () => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      c.foto.value == null
                          ? Container(
                              height: 160,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Belum ada foto kejadian'),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                c.foto.value!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: c.pickFoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Ambil Foto'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ===================== BUTTON SIMPAN =====================
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isLoading.value
                        ? null
                        : () {
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SIMPAN LAPORAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
