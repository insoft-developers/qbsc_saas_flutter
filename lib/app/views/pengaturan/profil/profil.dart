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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Pengaturan Profil",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        /// Set input value setelah data profile berhasil load
        nameC.text = c.profileData['name']?.toString() ?? "";
        badgeC.text = c.profileData['badge_id']?.toString() ?? "";
        waC.text = c.profileData['whatsapp']?.toString() ?? "";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==================== FOTO PROFIL ====================
              GestureDetector(
                onTap: c.pickImage,
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

                  return CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: imgProvider,
                    child: imgProvider == null
                        ? const Icon(Icons.camera_alt, size: 32)
                        : null,
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Nama
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: "Nama",
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
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // WhatsApp
              TextField(
                controller: waC,
                decoration: const InputDecoration(
                  labelText: "WhatsApp",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    c.saveProfile(nameC.text.trim(), waC.text.trim());
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
