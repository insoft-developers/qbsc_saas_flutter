import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart'; // <-- pastikan AppPrefs punya getMaxDistance()

class Patroli extends StatefulWidget {
  const Patroli({super.key});

  @override
  State<Patroli> createState() => _PatroliState();
}

class _PatroliState extends State<Patroli> {
  bool _isScanning = true;
  bool _torchOn = false;
  String? _lastScanned;
  late Box<LocationModel> _box;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    _box = await Hive.openBox<LocationModel>('locations');
  }

  Future<double> _getDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan lokasi belum aktif'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code != _lastScanned) {
        setState(() {
          _lastScanned = code;
          _isScanning = false;
        });

        final match = _box.values.firstWhereOrNull((loc) => loc.qrcode == code);

        if (match != null) {
          final pos = await _getCurrentPosition();
          if (pos == null) {
            setState(() => _isScanning = true);
            return;
          }

          // Ambil maxDistance dari SharedPreferences (String → double)
          final maxDistanceString = await AppPrefs.getMaxDistance();
          final maxDistance = double.tryParse(maxDistanceString ?? '0') ?? 0.0;

          final distance = await _getDistance(
            pos.latitude,
            pos.longitude,
            match.latitude,
            match.longitude,
          );

          if (distance > maxDistance) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lokasi terlalu jauh dari titik patroli!\n'
                  'Jarak: ${distance.toStringAsFixed(1)} m '
                  '(Maks: ${maxDistance.toStringAsFixed(1)} m)',
                ),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lokasi valid:\n${match.namaLokasi}\n'
                  'Jarak: ${distance.toStringAsFixed(1)} m',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code tidak ditemukan di database lokal'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

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
          if (_isScanning)
            MobileScanner(controller: _controller, onDetect: _onDetect)
          else
            const Center(
              child: Text(
                'QR Code sudah discan',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
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
