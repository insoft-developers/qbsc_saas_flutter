import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/pengaturan/profil/profil_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController c = Get.put(ProfileController());
  final TextEditingController nameC = TextEditingController();
  final TextEditingController badgeC = TextEditingController();
  final TextEditingController waC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Pengaturan Profil",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        /// Set input setelah data load
        nameC.text = c.profileData['name']?.toString() ?? "";
        badgeC.text = c.profileData['badge_id']?.toString() ?? "";
        waC.text = c.profileData['whatsapp']?.toString() ?? "";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==================== HEADER FOTO ====================
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Info',
                    'Foto profil hanya dapat diubah oleh Administrator',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Obx(() {
                  final faceUrl = c.profileData['face_photo_path'];
                  ImageProvider? imgProvider;

                  if (c.imagePath.value.isNotEmpty) {
                    imgProvider = FileImage(File(c.imagePath.value));
                  } else if (faceUrl != null && faceUrl.toString().isNotEmpty) {
                    imgProvider = NetworkImage(
                      "${ApiProvider.imageUrl}/$faceUrl",
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imgProvider,
                      child: imgProvider == null
                          ? const Icon(Icons.person, size: 36)
                          : null,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              Text(
                "Informasi Profil",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 30),

              // ==================== FORM CARD ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nama
                    TextField(
                      controller: nameC,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Badge ID
                    TextField(
                      controller: badgeC,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Badge ID",
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // WhatsApp
                    TextField(
                      controller: waC,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "WhatsApp",
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================== BUTTON ====================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    c.saveProfile(nameC.text.trim(), waC.text.trim());
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "QBSC Versi ${ApiProvider.appVersion}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
