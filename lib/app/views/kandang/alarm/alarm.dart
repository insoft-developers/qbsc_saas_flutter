import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/kandang/alarm/alarm_controller.dart';

class Alarm extends StatefulWidget {
  final int id;
  final String name;
  final bool isOn;

  const Alarm({
    super.key,
    required this.id,
    required this.name,
    this.isOn = false,
  });

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  late bool alarmOn;
  final controller = Get.put(AlarmController());
  final TextEditingController noteController = TextEditingController();
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    alarmOn = widget.isOn;
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
          'ALARM ${widget.name}',
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
              Icon(
                alarmOn ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                color: alarmOn ? Colors.redAccent : Colors.grey.shade400,
                size: screenWidth * 0.35,
              ),
              const SizedBox(height: 30),
              Text(
                alarmOn ? 'Alarm Aktif' : 'Alarm Nonaktif',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.w700,
                  color: alarmOn ? Colors.redAccent : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              SwitchListTile(
                title: Text(
                  'Status Alarm',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: alarmOn,
                activeColor: Colors.redAccent,
                inactiveThumbColor: Colors.grey.shade400,
                onChanged: (value) {
                  setState(() {
                    alarmOn = value;
                  });
                },
              ),
              const SizedBox(height: 16),

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

                    await controller.insertAlarm(
                      kandangId: widget.id,
                      satpamId: int.parse(AppPrefs.getUserId() ?? '0'),
                      note: note,
                      foto: foto,
                      comId: int.parse(AppPrefs.getComId() ?? '0'),
                      isAlarmOn: alarmOn,
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
