import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doc_controller.dart';

class Doc extends StatelessWidget {
  const Doc({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DocController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Catat DOC',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3C3535),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Laporan', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.toNamed('/laporan/doc');
        },
      ),

      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section("Waktu & Tanggal"),

              Obx(
                () => _readOnlyField(
                  label: "Tanggal",
                  icon: Icons.date_range,
                  value: c.tanggal.value == null
                      ? ''
                      : '${c.tanggal.value!.year}-${c.tanggal.value!.month.toString().padLeft(2, '0')}-${c.tanggal.value!.day.toString().padLeft(2, '0')}',
                  validator: (_) =>
                      c.tanggal.value == null ? 'Tanggal harus diisi' : null,
                  onTap: () async {
                    final hasil = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (hasil != null) c.setTanggal(hasil);
                  },
                ),
              ),

              Obx(
                () => _readOnlyField(
                  label: "Jam",
                  icon: Icons.access_time,
                  value: c.jam.value == null
                      ? ''
                      : c.jam.value!.format(context),
                  validator: (_) =>
                      c.jam.value == null ? 'Jam harus diisi' : null,
                  onTap: () async {
                    final hasil = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (hasil != null) c.setJam(hasil);
                  },
                ),
              ),

              _section("Informasi Pengiriman"),

              Obx(
                () => Column(
                  children: c.boxOptionList.map((box) {
                    c.initBoxController(box);
                    final jumlahCtrl = c.jumlahBoxCtrl[box.id];
                    final isiCtrl = c.isiBoxCtrl[box.id];

                    int totalEkor() {
                      final j = int.tryParse(jumlahCtrl?.text ?? '0') ?? 0;
                      final i = int.tryParse(isiCtrl?.text ?? '0') ?? 0;
                      return j * i;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.jenisBox,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: jumlahCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah Box',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: isiCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Isi / Box',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Obx(
                              () => Text(
                                'Total Ekor: ${c.totalEkorMap[box.id]?.value ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              _input(
                label: "Jumlah Total Box",
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Jumlah total box wajib diisi'
                    : null,
                onChanged: c.setJumlahBox,
              ),

              _input(
                label: "Jumlah Total Ekor",
                icon: Icons.calculate_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Jumlah total ekor wajib diisi'
                    : null,
                onChanged: c.setTotalEkor,
              ),

              Obx(
                () => _dropdown(
                  hint: "Pilih Ekspedisi",
                  icon: Icons.local_shipping_outlined,
                  value: c.ekspedisiTerpilih.value,
                  items: c.ekspedisiList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Pilih ekspedisi' : null,
                  onChanged: c.setEkspedisi,
                ),
              ),

              _input(
                label: "Tujuan",
                icon: Icons.flag_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tujuan wajib diisi' : null,
                onChanged: c.setTujuan,
              ),

              _input(
                label: "Nama Supir",
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama supir wajib diisi' : null,
                onChanged: c.setNamaSupir,
              ),

              _input(
                label: "No Polisi",
                icon: Icons.confirmation_number_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'No polisi wajib diisi' : null,
                onChanged: c.setNoPolisi,
              ),

              _input(
                label: "Nomor Segel",
                icon: Icons.shield_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nomor segel wajib diisi' : null,
                onChanged: c.setNomorSegel,
              ),

              // Obx(
              //   () => _dropdown(
              //     hint: "Jenis DOC",
              //     icon: Icons.pets_outlined,
              //     value: c.jenis.value,
              //     items: const [
              //       DropdownMenuItem(value: 1, child: Text('Male')),
              //       DropdownMenuItem(value: 2, child: Text('Female')),
              //     ],
              //     validator: (v) => v == null ? 'Pilih jenis' : null,
              //     onChanged: (v) => c.setJenis(v!),
              //   ),
              // ),
              _input(
                label: "Catatan",
                icon: Icons.note_outlined,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Note wajib diisi' : null,
                onChanged: c.setNote,
              ),

              _section("Dokumentasi"),

              Obx(
                () => _photoPicker(
                  images: c.fotoList,
                  onPick: c.pickFoto,
                  onRemove: c.removeFoto,
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
                              c.saveDoc();
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

Widget _section(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 14, top: 10),
  child: Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
);

Widget _input({
  required String label,
  required IconData icon,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: TextFormField(
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
    ),
  ),
);

Widget _readOnlyField({
  required String label,
  required IconData icon,
  required String value,
  FormFieldValidator<String>? validator,
  required VoidCallback onTap,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: TextFormField(
    readOnly: true,
    controller: TextEditingController(text: value),
    validator: validator,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);

Widget _dropdown<T>({
  required String hint,
  required IconData icon,
  required T value,
  required List<DropdownMenuItem<T>> items,
  FormFieldValidator<T>? validator,
  ValueChanged<T?>? onChanged,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: DropdownButtonFormField<T>(
    value: value,
    items: items,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);

Widget _photoPicker({
  required List<File> images,
  required VoidCallback onPick,
  required Function(int) onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        children: List.generate(images.length, (i) {
          return Stack(
            children: [
              Image.file(images[i], width: 80, height: 80, fit: BoxFit.cover),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ],
          );
        }),
      ),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.photo),
        label: const Text('Tambah Foto'),
      ),
    ],
  );
}
