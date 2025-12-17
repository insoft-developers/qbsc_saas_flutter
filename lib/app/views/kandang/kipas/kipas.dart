import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'kipas_controller.dart';

class Kipas extends StatefulWidget {
  final int id;
  final String name;
  final int jumlahKipas;

  const Kipas({
    super.key,
    required this.id,
    required this.name,
    required this.jumlahKipas,
  });

  @override
  State<Kipas> createState() => _KipasState();
}

class _KipasState extends State<Kipas> {
  final controller = Get.put(KipasController());
  File? imageFile;
  final ImagePicker picker = ImagePicker();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    checkLocationAndAlert();
    controller.initKipas(widget.jumlahKipas);
    super.initState();
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

  void toggleKipas(index) {
    controller.toggleKipas(index);
    setState(() {});
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'KIPAS ${widget.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        'Total Kipas: ${controller.kipasCount.value}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.wind_power_rounded,
                      size: screenWidth * 0.07,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ GridView non-scrollable agar ikut scroll bareng halaman
            Obx(() {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.kipasCount.value,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600
                      ? 6
                      : screenWidth > 400
                      ? 4
                      : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final aktif = controller.kipasStatus[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: aktif
                          ? Colors.green.shade600
                          : Colors.grey.shade200,
                      boxShadow: [
                        BoxShadow(
                          color: aktif
                              ? Colors.greenAccent.withOpacity(0.3)
                              : Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => toggleKipas(index),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              aktif ? Icons.air_rounded : Icons.air_outlined,
                              size: screenWidth * 0.09,
                              color: aktif ? Colors.white : Colors.black54,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'K${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.035,
                                color: aktif ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              aktif ? 'ON' : 'OFF',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: aktif ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

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

            // Tombol simpan
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final note = noteController.text.trim();
                          final foto = imageFile;

                          await controller.insertKipas(
                            kandangId: widget.id,
                            satpamId: int.parse(AppPrefs.getUserId() ?? '0'),
                            note: note,
                            foto: foto,
                            comId: int.parse(AppPrefs.getComId() ?? '0'),
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

                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.of(context).pop();
                          });
                        },
                        icon: const Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Simpan Status',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
