import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';

class TambahTamu extends StatelessWidget {
  const TambahTamu({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TamuController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Tambah Data Tamu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3C3535),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Laporan', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.toNamed('/laporan/tamu');
        },
      ),
      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Informasi Tamu"),

              _inputField(
                label: "Nama Tamu",
                icon: Icons.person_outline,
                onChanged: c.setNamaTamu,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tamu wajib diisi' : null,
              ),

              _inputField(
                label: "Jumlah Tamu",
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                onChanged: c.setJumlahTamu,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Jumlah tamu wajib diisi' : null,
              ),

              _inputField(
                label: "Tujuan",
                icon: Icons.flag_outlined,
                onChanged: c.setTujuan,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tujuan wajib diisi' : null,
              ),

              _inputField(
                label: "No Whatsapp",
                icon: Icons.chat_bubble,
                keyboardType: TextInputType.number,
                onChanged: c.setWhatsapp,
                validator: (v) =>
                    v == null || v.isEmpty ? 'No whatsapp wajib diisi' : null,
              ),

              _inputField(
                label: "Catatan",
                icon: Icons.note_outlined,
                maxLines: 3,
                onChanged: c.setNote,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Catatan wajib diisi' : null,
              ),

              const SizedBox(height: 28),
              _sectionTitle("Foto Identitas"),

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
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Belum ada foto',
                                style: TextStyle(color: Colors.black54),
                              ),
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
                        label: const Text("Ambil Foto"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isLoading.value
                        ? null
                        : () {
                            if (c.validateForm()) {
                              c.saveDataTamuManualInput();
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
                            'SIMPAN DATA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
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

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}

Widget _inputField({
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    ),
  );
}
