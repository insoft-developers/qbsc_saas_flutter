import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/kandang/suhu/suhu_controller.dart';

class Suhu extends StatefulWidget {
  final int id;
  final String name;
  const Suhu({super.key, required this.id, required this.name});

  @override
  State<Suhu> createState() => _SuhuState();
}

class _SuhuState extends State<Suhu> {
  final SuhuController controller = Get.put(SuhuController());

  final TextEditingController suhuController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  // Ambil foto dari kamera
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    suhuController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Cek lokasi, jika mati tampilkan dialog buka pengaturan
  Future<bool> checkLocationAndAlert() async {
    final position = await controller.getCurrentPosition();
    if (position == null) {
      Get.defaultDialog(
        title: "Lokasi Tidak Aktif",
        middleText: "Silahkan aktifkan lokasi untuk menyimpan data.",
        actions: [
          TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: const Text("Buka Pengaturan"),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ],
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          'SUHU ${widget.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width > 600 ? 500 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Input Data Kandang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input suhu
                    TextFormField(
                      controller: suhuController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Suhu Terdeteksi (°C)',
                        hintText: 'Contoh: 27.4',
                        labelStyle: const TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.device_thermostat,
                          color: Colors.orange,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan suhu yang terdeteksi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Input Catatan
                    TextFormField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        labelStyle: const TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.note,
                          color: Colors.blueGrey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tombol ambil foto + preview
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (imageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              imageFile!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Ambil Foto (opsional)'),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Tombol simpan
                    Obx(
                      () => controller.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.amber,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: size.height * 0.065,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    60,
                                    53,
                                    53,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                ),
                                icon: const Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                label: const Text(
                                  'SIMPAN DATA',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final canSave = await checkLocationAndAlert();
                                  if (!canSave) return;

                                  final suhu = double.parse(
                                    suhuController.text.trim(),
                                  );
                                  final note = noteController.text.trim();
                                  final foto = imageFile;

                                  await controller.insertSuhu(
                                    kandangId: widget.id,
                                    satpamId: int.parse(
                                      AppPrefs.getUserId() ?? '0',
                                    ),
                                    temperature: suhu,
                                    note: note,
                                    foto: foto,
                                  );

                                  Get.snackbar(
                                    'Tersimpan',
                                    'Data berhasil disimpan ke lokal',
                                    backgroundColor: Colors.green.shade600,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                  );

                                  suhuController.clear();
                                  noteController.clear();
                                  setState(() => imageFile = null);

                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Tampilan suhu terbaca
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Suhu Terbaca dari Sensor:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${suhuController.text.isEmpty ? "--" : suhuController.text}°C',
                            style: TextStyle(
                              fontSize: size.width * 0.12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
