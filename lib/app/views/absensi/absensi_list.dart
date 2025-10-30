import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/absensi/absensi.dart';
import 'package:qbsc_saas/app/views/absensi/absensi_card.dart';

class AbsensiList extends StatefulWidget {
  const AbsensiList({super.key});

  @override
  State<AbsensiList> createState() => _AbsensiListState();
}

class _AbsensiListState extends State<AbsensiList> {
  final AbsenController absenController = Get.find<AbsenController>();

  @override
  void initState() {
    absenController.getDataAbsensi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    String absenStatus = '';
    if (absenController.absenData['status'] == 1) {
      absenStatus = 'masuk';
    } else if (absenController.absenData['status'] == 2) {
      absenStatus = 'pulang';
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Absensi Hari Ini',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kartu informasi absensi
              Obx(
                () => AbsensiCard(
                  status: absenStatus.toLowerCase(),
                  jamMasuk: Fungsi.formatToTime(
                    absenController.absenData['jam_masuk'].toString(),
                  ),
                  jamKeluar: Fungsi.formatToTime(
                    absenController.absenData['jam_keluar'].toString(),
                  ),
                  tanggal: Fungsi.tanggalIndo(
                    absenController.absenData['tanggal'].toString(),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => Absensi(absenModel: 'masuk'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Absen Masuk",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Keluar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => Absensi(absenModel: 'pulang'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Absen Keluar",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
