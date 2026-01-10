import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/controllers/auth_controller.dart';

class Paket extends StatelessWidget {
  const Paket({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthController());

    return WillPopScope(
      onWillPop: () async {
        await auth.logout();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF3C3535),
          elevation: 0,
          title: const Text(
            'Informasi Aplikasi',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                /// IMAGE (PLACEHOLDER)
                Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Image.asset(
                    'assets/images/maintenance.png', // 🔁 ganti nanti
                    fit: BoxFit.contain,
                  ),
                ),

                /// CARD INFORMASI
                Card(
                  elevation: 6,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Akses Aplikasi Terhenti",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Saat ini terdapat kendala pada akun atau sistem aplikasi Anda.\n\n"
                          "Silakan menghubungi Administrator untuk mendapatkan bantuan "
                          "dan mengaktifkan kembali akses aplikasi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// BUTTON LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C3535),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await auth.logout();
                    },
                    child: const Text(
                      "Keluar dari Aplikasi",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// FOOTER TEXT
                const Text(
                  "QBSC SaaS System",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
