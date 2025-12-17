import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

// ignore: must_be_immutable
class Absensi extends StatefulWidget {
  String absenModel;
  int shiftId;
  Absensi({super.key, required this.absenModel, required this.shiftId});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;

  bool _isFaceDetected = false;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController.initialize();
      setState(() => _isCameraInitialized = true);

      _startFaceDetectionLoop();
    } catch (e) {
      if (kDebugMode) print("Camera init error: $e");
    }
  }

  Future<void> _startFaceDetectionLoop() async {
    while (mounted) {
      if (_isProcessing) {
        await Future.delayed(const Duration(milliseconds: 400));
        continue;
      }
      _isProcessing = true;

      try {
        final XFile? xfile = await _takePicture();
        if (xfile != null) {
          final File file = File(xfile.path);
          final inputImage = InputImage.fromFile(file);
          final faces = await _faceDetector.processImage(inputImage);

          if (faces.isNotEmpty) {
            _isFaceDetected = true;
          } else {
            _isFaceDetected = false;
          }

          setState(() {});
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) print("Face detection error: $e");
      } finally {
        _isProcessing = false;
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  Future<XFile?> _takePicture() async {
    if (!_cameraController.value.isInitialized) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await _cameraController.takePicture();
      await file.saveTo(filePath);
      return XFile(filePath);
    } catch (e) {
      if (kDebugMode) print("Error taking picture: $e");
      return null;
    }
  }

  Future<void> _verifyFace() async {
    if (!_isFaceDetected || _isVerifying) return;

    setState(() => _isVerifying = true);
    try {
      final String? userId = AppPrefs.getUserId();

      if (userId != null && userId.isNotEmpty) {
        final XFile? image = await _cameraController.takePicture();
        if (image == null) return;

        final position = await _getCurrentLocation();
        if (position == null) return;

        final posLatStr = AppPrefs.getLatitude() ?? '0.0';
        final posLngStr = AppPrefs.getLongitude() ?? '0.0';
        final maxDistStr = AppPrefs.getMaxDistance() ?? '50';

        final posLat = double.tryParse(posLatStr) ?? 0.0;
        final posLng = double.tryParse(posLngStr) ?? 0.0;
        final maxDistance = double.tryParse(maxDistStr) ?? 50.0;

        final distanceInMeters = Geolocator.distanceBetween(
          posLat,
          posLng,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters > maxDistance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Jarak terlalu jauh dari pos absen (${distanceInMeters.toStringAsFixed(2)} m)",
              ),
            ),
          );
          setState(() => _isVerifying = false);
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiProvider.baseUrl}/verify_face"),
        );
        request.fields['user_id'] = userId;
        request.fields['absen_model'] = widget.absenModel;
        request.fields['latitude'] = position.latitude.toString();
        request.fields['longitude'] = position.longitude.toString();
        request.fields['shift_id'] = widget.shiftId.toString();

        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );

        var response = await request.send();
        final respString = await response.stream.bytesToString();
        final data = jsonDecode(respString);

        if (kDebugMode) print("Server response: $data");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal memverifikasi')),
        );

        if (data['success']) {
          Future.delayed(const Duration(seconds: 1), () {
            Get.back(result: true);
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID tidak ada')));
      }
    } catch (e) {
      if (kDebugMode) print("Verifikasi error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal memverifikasi Wajah atau Tekan Tombol Lakukan Absensi agak lama",
          ),
        ),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan aktifkan lokasi terlebih dahulu"),
        ),
      );
      await Geolocator.openLocationSettings();
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.",
          ),
        ),
      );
      await Geolocator.openAppSettings();
      return null;
    }

    try {
      final freshPosition =
          await Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 0,
            ),
          ).first.timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException("Timeout ambil posisi"),
          );

      return freshPosition;
    } catch (e) {
      if (kDebugMode) print("Fallback ambil lokasi: $e");
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_cameraController),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Frame tanpa liveness
                Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isFaceDetected ? Colors.green : Colors.redAccent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _isFaceDetected
                      ? "Wajah terdeteksi ✅"
                      : "Arahkan wajah ke kamera",
                  style: TextStyle(
                    color: _isFaceDetected ? Colors.green : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isFaceDetected ? _verifyFace : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFaceDetected
                        ? Colors.blue
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Lakukan Absensi"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
