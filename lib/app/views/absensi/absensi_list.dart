import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qbsc_saas/app/controllers/absen_controller.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/absensi/absensi.dart';
import 'package:qbsc_saas/app/views/absensi/absensi_card.dart';

// ignore: must_be_immutable
class AbsensiList extends StatefulWidget {
  int shiftId;
  String shiftName;
  AbsensiList({super.key, required this.shiftId, required this.shiftName});

  @override
  State<AbsensiList> createState() => _AbsensiListState();
}

class _AbsensiListState extends State<AbsensiList> {
  final AbsenController absenController = Get.put(AbsenController());

  @override
  void initState() {
    absenController.getDataAbsensi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Absensi ${widget.shiftName}',
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
                  status: absenController.absenStatus.value,
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
                    if (absenController.absenStatus == 'masuk') {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            'Konfirmasi',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          content: const Text(
                            'Anda belum absen pulang.\n\n'
                            'Apakah anda ingin konfirmasi lupa absen pulang?',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                          actionsPadding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            16,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text(
                                'Tidak',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();

                                 absenController.lupaPulang(absenController.absenData['id']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Ya',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Get.to(
                        () => Absensi(
                          absenModel: 'masuk',
                          shiftId: widget.shiftId,
                        ),
                      )?.then((result) {
                        absenController.getDataAbsensi();
                      });
                    }
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
                    if (absenController.absenStatus == 'pulang') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda belum absen masuk')),
                      );
                    } else {
                      Get.to(
                        () => Absensi(
                          absenModel: 'pulang',
                          shiftId: widget.shiftId,
                        ),
                      )?.then((result) {
                        absenController.getDataAbsensi();
                      });
                    }
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
