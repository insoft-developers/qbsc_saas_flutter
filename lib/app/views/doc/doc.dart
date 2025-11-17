import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doc_controller.dart';

class Doc extends StatelessWidget {
  const Doc({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DocController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Catat DOC',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== TANGGAL =====================
              const Text(
                'Tanggal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: c.tanggal.value == null
                        ? ''
                        : '${c.tanggal.value!.year}-${c.tanggal.value!.month.toString().padLeft(2, '0')}-${c.tanggal.value!.day.toString().padLeft(2, '0')}',
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  validator: (v) =>
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
              const SizedBox(height: 20),

              // ===================== JAM =====================
              const Text('Jam', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(
                () => TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: c.jam.value == null
                        ? ''
                        : c.jam.value!.format(context),
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (v) =>
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
              const SizedBox(height: 20),

              // ===================== JUMLAH BOX =====================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Jumlah Box',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Jumlah box wajib diisi';
                  return null;
                },
                onChanged: c.setJumlahBox,
              ),
              const SizedBox(height: 20),

              // ===================== EKSPEDISI =====================
              const Text(
                'Ekspedisi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: c.ekspedisiTerpilih.value,
                  items: c.ekspedisiList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Pilih ekspedisi' : null,
                  onChanged: (v) => c.setEkspedisi(v),
                ),
              ),
              const SizedBox(height: 20),

              // ===================== TUJUAN =====================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tujuan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tujuan wajib diisi' : null,
                onChanged: c.setTujuan,
              ),
              const SizedBox(height: 20),

              // ===================== NO POLISI =====================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'No Polisi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'No polisi wajib diisi' : null,
                onChanged: c.setNoPolisi,
              ),
              const SizedBox(height: 20),

              // ===================== JENIS =====================
              const Text(
                'Jenis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(
                () => DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: c.jenis.value,
                  validator: (v) => v == null ? 'Pilih jenis' : null,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Male')),
                    DropdownMenuItem(value: 2, child: Text('Female')),
                  ],
                  onChanged: (v) => c.setJenis(v!),
                ),
              ),
              const SizedBox(height: 20),

              // ===================== NOTE =====================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Note wajib diisi' : null,
                onChanged: c.setNote,
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
