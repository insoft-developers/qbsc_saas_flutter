import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Patroli extends StatefulWidget {
  const Patroli({super.key});

  @override
  State<Patroli> createState() => _PatroliState();
}

class _PatroliState extends State<Patroli> {
  bool _isScanning = true;
  bool _torchOn = false;
  String? _lastScanned;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code != _lastScanned) {
        setState(() {
          _lastScanned = code;
          _isScanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code terdeteksi: $code'),
            backgroundColor: Colors.green,
          ),
        );

        // Setelah berhasil scan, kembali ke halaman sebelumnya
        // Future.delayed(const Duration(seconds: 2), () {
        //   Get.back(result: code);
        // });
        break;
      }
    }
  }

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Patroli - Scan QR Code'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Kamera scanner
          if (_isScanning)
            MobileScanner(controller: _controller, onDetect: _onDetect)
          else
            const Center(
              child: Text(
                'QR Code sudah discan',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

          // Frame scanner (kotak putih)
          IgnorePointer(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Tombol Flash di kanan atas
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: _toggleTorch,
              icon: Icon(
                _torchOn ? Icons.flash_on : Icons.flash_off,
                color: _torchOn ? Colors.yellowAccent : Colors.white,
                size: 28,
              ),
            ),
          ),

          // Tombol ulangi scan di bawah
          Positioned(
            bottom: 30,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isScanning = true;
                  _lastScanned = null;
                });
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
