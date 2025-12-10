import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';

class Paket extends StatelessWidget {
  const Paket({super.key});

  @override
  Widget build(BuildContext context) {
    final _auth = Get.put(AuthController());
    return WillPopScope(
      onWillPop: () async {
        await _auth.logout(); // logout saat tombol back
        return false; // cegah default back
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF3C3535),
          title: const Text(
            'Hubungi Administrator',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // CARD INFORMASI
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Maaf, Terdapat kendala pada aplikasi anda",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Silahkan menghubungi administrator anda untuk bisa menggunakan aplikasi ini kembali. terima kasih.",
                        style: TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
