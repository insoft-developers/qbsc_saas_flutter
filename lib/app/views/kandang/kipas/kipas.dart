import 'dart:io';
import 'package:flutter/material.dart';
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
      imageQuality: 70,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (pickedFile != null) {
      setState(() => imageFile = File(pickedFile.path));
    }
  }

  void toggleKipas(int index) {
    controller.toggleKipas(index);
  }

  /// LOKASI CEPAT (NON BLOCKING)
  Future<bool> checkLocationFast() async {
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
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            /// INFO
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Kipas: ${controller.kipasCount.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.wind_power_rounded),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// GRID KIPAS (LEBIH KECIL & RINGAN)
            ///
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.hidupkanSemua,
                    icon: const Icon(
                      Icons.power,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Hidup Semua',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.matikanSemua,
                    icon: const Icon(
                      Icons.power_off,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Mati Semua',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.kipasCount.value,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600
                      ? 7
                      : screenWidth > 400
                      ? 5
                      : 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  return Obx(() {
                    final aktif = controller.kipasStatus[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // lebih kecil
                        color: aktif
                            ? Colors.green.shade600
                            : Colors.grey.shade200,
                        boxShadow: [
                          BoxShadow(
                            color: aktif
                                ? Colors.greenAccent.withOpacity(0.3)
                                : Colors.black12,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => controller.toggleKipas(index),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                aktif ? Icons.air_rounded : Icons.air_outlined,
                                size: screenWidth * 0.075, // lebih kecil
                                color: aktif ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'K${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.03,
                                  color: aktif ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                aktif ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.025,
                                  color: aktif
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),

            const SizedBox(height: 12),

            /// CATATAN
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// FOTO
            Row(
              children: [
                if (imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        imageFile!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Foto'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// SIMPAN CEPAT
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (!await checkLocationFast()) return;

                  controller.insertKipas(
                    kandangId: widget.id,
                    satpamId: int.parse(AppPrefs.getUserId() ?? '0'),
                    note: noteController.text.trim(),
                    foto: imageFile,
                    comId: int.parse(AppPrefs.getComId() ?? '0'),
                  );

                  /// LANGSUNG KELUAR
                  Navigator.pop(context);
                },
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
