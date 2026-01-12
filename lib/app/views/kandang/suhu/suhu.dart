import 'dart:io';
import 'package:flutter/material.dart';
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

  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (pickedFile != null) {
      setState(() => imageFile = File(pickedFile.path));
    }
  }

  @override
  void dispose() {
    suhuController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// CEK LOKASI RINGAN (tanpa dialog berat)
  Future<bool> checkLocation() async {
    final pos = await controller.getCurrentPosition();
    if (pos == null) {
      Get.snackbar(
        'Lokasi Mati',
        'Aktifkan lokasi untuk menyimpan data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
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
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: size.width > 600 ? 420 : double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// INPUT SUHU (AUTOFOCUS → CEPAT)
                  TextFormField(
                    controller: suhuController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Suhu (°C)',
                      hintText: 'Contoh: 27.4',
                      prefixIcon: const Icon(
                        Icons.device_thermostat,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Angka tidak valid';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  /// CATATAN (OPSIONAL)
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan (opsional)',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// FOTO (OPSIONAL)
                  Row(
                    children: [
                      if (imageFile != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              imageFile!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Foto (opsional)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// SIMPAN CEPAT (OFFLINE FIRST)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'SIMPAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (!await checkLocation()) return;

                        final suhuText = suhuController.text.trim();

                        final suhu = suhuText.isEmpty
                            ? 0.0
                            : double.tryParse(suhuText) ?? 0.0;

                        controller.insertSuhu(
                          kandangId: widget.id,
                          satpamId: int.parse(AppPrefs.getUserId() ?? '0'),
                          temperature: suhu,
                          note: noteController.text,
                          foto: imageFile,
                        );

                        /// LANGSUNG KELUAR → UX CEPAT
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
