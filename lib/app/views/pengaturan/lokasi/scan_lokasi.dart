import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ignore: must_be_immutable
class ScanLokasi extends StatefulWidget {
  String locationName;
  ScanLokasi({super.key, required this.locationName});

  @override
  State<ScanLokasi> createState() => _ScanLokasiState();
}

class _ScanLokasiState extends State<ScanLokasi> {
  bool isScanning = true;
  bool isFlashOn = false;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && isScanning) {
        setState(() {
          isScanning = false;
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('QR Code Terbaca'),
            content: Text('Isi QR: $code'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isScanning = true;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
          // Optional: semi-transparent overlay
          Container(color: Colors.black.withOpacity(0.3)),
        ],
      ),
    );
  }
}
