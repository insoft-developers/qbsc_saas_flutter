import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';

class TamuScan extends StatefulWidget {
  const TamuScan({super.key});

  @override
  State<TamuScan> createState() => _TamuScanState();
}

class _TamuScanState extends State<TamuScan> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  final TamuController _tamu = Get.put(TamuController());

  bool isFlashOn = false;
  bool isProcessing = false;
  String? scanResult;

  /// Ketika barcode terdeteksi
  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          isProcessing = true;
          scanResult = code;
        });

        await controller.stop();
        _tamu.checkQRTamu(code);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlaySize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C3535),
        title: const Text(
          'Scan Tamu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() => isFlashOn = !isFlashOn);
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            /// Kamera aktif jika belum ada hasil scan
            if (!_tamu.isExist.value)
              MobileScanner(controller: controller, onDetect: _onDetect),

            /// Kotak overlay (hanya ketika sedang scan)
            if (!_tamu.isExist.value)
              Center(
                child: Container(
                  width: overlaySize,
                  height: overlaySize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),

            /// Tampilkan hasil scan
            if (_tamu.isExist.value && scanResult != null)
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          "${ApiProvider.imageUrl}/${_tamu.scanList['foto']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40),
                          loadingBuilder: (context, child, loading) {
                            if (loading == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),

                        const SizedBox(height: 12),
                        const Text(
                          "Data Tamu",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          _tamu.scanList['nama_tamu'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        SelectableText(
                          "(${_tamu.scanList['jumlah_tamu']} Orang)",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SelectableText(
                          "Bertujuan untuk ${_tamu.scanList['tujuan']}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SelectableText(
                          "Whatsapp: ${_tamu.scanList['whatsapp']}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SelectableText(
                          "Catatan: ${_tamu.scanList['catatan']}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Obx(() {
                          return ElevatedButton(
                            onPressed: _tamu.isLoading.value
                                ? null
                                : () {
                                    String isMasuk =
                                        _tamu.scanList['is_status'] == 1
                                        ? 'masuk'
                                        : 'pulang';

                                    _tamu.saveDataTamu(
                                      _tamu.scanList['id'],
                                      isMasuk,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _tamu.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _tamu.scanList['is_status'] == 1
                                        ? 'Masuk'
                                        : 'Pulang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
