import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/kandang/lampu/lampu_controller.dart';

class Lampu extends StatefulWidget {
  final int id;
  final String name;
  final bool isOn;

  const Lampu({
    super.key,
    required this.id,
    required this.name,
    this.isOn = false,
  });

  @override
  State<Lampu> createState() => _LampuState();
}

class _LampuState extends State<Lampu> {
  late bool isLampOn;
  final controller = Get.put(LampuController());
  final TextEditingController noteController = TextEditingController();
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    isLampOn = widget.isOn;
    checkLocationAndAlert();
    controller.init();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'LAMPU ${widget.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: screenWidth * 0.35,
                width: screenWidth * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLampOn
                      ? Colors.amber.shade400
                      : Colors.grey.shade300,
                  boxShadow: isLampOn
                      ? [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isLampOn
                      ? Icons.lightbulb_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: isLampOn
                      ? Colors.yellow.shade100
                      : Colors.grey.shade600,
                  size: screenWidth * 0.22,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                isLampOn ? 'Lampu Menyala' : 'Lampu Mati',
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.w700,
                  color: isLampOn
                      ? Colors.amber.shade700
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              SwitchListTile(
                title: Text(
                  'Status Lampu',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: isLampOn,
                activeColor: Colors.amber.shade600,
                inactiveThumbColor: Colors.grey.shade400,
                onChanged: (value) {
                  setState(() {
                    isLampOn = value;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Catatan
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Catatan (opsional)',
                  labelStyle: const TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note, color: Colors.blueGrey),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                ),
              ),

              const SizedBox(height: 16),

              // Ambil foto
              Column(
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
                ],
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final note = noteController.text.trim();
                    final foto = imageFile;

                    await controller.insertLampu(
                      kandangId: widget.id,
                      satpamId: int.parse(AppPrefs.getUserId() ?? '0'),
                      note: note,
                      foto: foto,
                      comId: int.parse(AppPrefs.getComId() ?? '0'),
                      isLampuOn: isLampOn,
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

                    noteController.clear();
                    setState(() => imageFile = null);
                    Future.delayed(const Duration(milliseconds: 800), () {
                      Navigator.of(context).pop();
                    });
                  },
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'Simpan Status',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
