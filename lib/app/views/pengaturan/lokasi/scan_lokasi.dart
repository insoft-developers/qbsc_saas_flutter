import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_controller.dart';

// ignore: must_be_immutable
class ScanLokasi extends StatefulWidget {
  String locationName;
  String qrcode;
  ScanLokasi({super.key, required this.locationName, required this.qrcode});

  @override
  State<ScanLokasi> createState() => _ScanLokasiState();
}

class _ScanLokasiState extends State<ScanLokasi> {
  bool isScanning = true;
  bool isFlashOn = false;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final lokasiController = Get.put(LokasiController());

  Future<Position?> getCurrentLocation(BuildContext context) async {
    // Cek permission lokasi
    var status = await Permission.location.status;

    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak!')));
        return null;
      }
    }

    // Cek apakah GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Tampilkan dialog untuk buka pengaturan lokasi
      bool openSettings =
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Aktifkan GPS'),
              content: const Text(
                'GPS belum aktif. Harap aktifkan GPS untuk melanjutkan.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            ),
          ) ??
          false;

      if (openSettings) {
        AppSettings.openAppSettings();
      }

      return null;
    }

    // Ambil lokasi saat ini
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && isScanning) {
        setState(() {
          isScanning = false;
        });

        bool isMatch = code == widget.qrcode;
        if (isMatch) {
          Position? pos = await getCurrentLocation(context);
          if (pos != null) {
            await lokasiController.updateLocationCoordinates(
              code,
              pos.latitude.toString(),
              pos.longitude.toString(),
            );
          } else {
            _showMessage("Gagal ambil lokasi", Colors.red);
          }
        } else {
          _showMessage("Qrcode tidak cocok", Colors.red);
        }
      }
    }
  }

  void _showMessage(String message, Color warna) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: warna,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final overlaySize = width * 0.6;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.locationName.toString()),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),

          // semi-transparent overlay hanya di luar kotak scan
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.srcOver,
            ),
            child: Center(
              child: Container(
                width: overlaySize,
                height: overlaySize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // tombol scan lagi bisa ditaruh di bawah overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = true;
                  });
                },
                child: const Text('Scan Lagi'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
