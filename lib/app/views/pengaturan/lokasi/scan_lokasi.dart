import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_controller.dart';

// ignore: must_be_immutable
class ScanLokasi extends StatefulWidget {
  int locationId;
  String locationName;
  String qrcode;

  ScanLokasi({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.qrcode,
  });

  @override
  State<ScanLokasi> createState() => _ScanLokasiState();
}

class _ScanLokasiState extends State<ScanLokasi> {
  bool isScanning = true;
  bool isFlashOn = false;

  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final lokasiController = Get.put(LokasiController());
  final TextEditingController namaLokasiController = TextEditingController();

  // ===================== LOCATION =====================
  Future<Position?> getCurrentLocation(BuildContext context) async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        _showMessage('Izin lokasi ditolak', Colors.red);
        return null;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool openSettings =
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Aktifkan GPS'),
              content: const Text('GPS belum aktif. Harap aktifkan GPS.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            ),
          ) ??
          false;

      if (openSettings) {
        await Geolocator.openLocationSettings();
      }
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ===================== SCAN =====================
  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning) return;

    setState(() => isScanning = false); // 🔴 HENTIKAN SCAN LANGSUNG

    final String? code = capture.barcodes.first.rawValue;
    if (code == null) {
      _showMessage('QR tidak terbaca', Colors.red);
      return;
    }

    if (code != widget.qrcode) {
      _showMessage('QR Code tidak cocok', Colors.red);
      return;
    }

    final pos = await getCurrentLocation(context);
    if (pos == null) return;

    _showInputNamaLokasi(
      code: code,
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
  }

  // ===================== INPUT NAMA LOKASI =====================
  void _showInputNamaLokasi({
    required String code,
    required double latitude,
    required double longitude,
  }) {
    namaLokasiController.text = widget.locationName;

    Get.defaultDialog(
      title: 'Nama Lokasi',
      content: Column(
        children: [
          TextFormField(
            controller: namaLokasiController,
            decoration: const InputDecoration(
              labelText: 'Nama Lokasi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lat: $latitude\nLong: $longitude',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await lokasiController.updateLocationCoordinates(
          widget.locationId,
          code,
          latitude.toString(),
          longitude.toString(),
          namaLokasiController.text.trim(),
        );

        Get.back();
        _showMessage('Lokasi berhasil diperbarui', Colors.green);

        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.pop(context);
        });
      },
    );
  }

  // ===================== SCAN ULANG =====================
  void _scanUlang() {
    setState(() => isScanning = true);
  }

  void _showMessage(String message, Color warna) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final overlaySize = width * 0.6;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.locationName),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              scannerController.toggleTorch();
              setState(() => isFlashOn = !isFlashOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: isScanning ? _onDetect : null,
          ),

          // Overlay kotak scan
          Center(
            child: Container(
              width: overlaySize,
              height: overlaySize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // ===================== TOMBOL SCAN ULANG =====================
          if (!isScanning)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _scanUlang,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scan Ulang',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
