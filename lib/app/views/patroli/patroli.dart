import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qbsc_saas/app/models/patroli_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/patroli/patroli_controller.dart';

class Patroli extends StatefulWidget {
  final int id;
  final int locationId;
  final String locationName;
  final String jamAwal;
  final String jamAkhir;
  const Patroli({
    super.key,
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.jamAwal,
    required this.jamAkhir,
  });

  @override
  State<Patroli> createState() => _PatroliState();
}

class _PatroliState extends State<Patroli> {
  final patroliController = Get.put(PatroliController());
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _isHiveReady = false;

  bool _torchOn = false;
  String? _lastScanned;

  late Box<LocationModel> _box;
  Box<PatroliModel>? _boxPatroli;
  double _maxDistance = 0.0;
  late String _loginUserId;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  @override
  void initState() {
    super.initState();
    _openHiveBox();
    _loadMaxDistance();
    _loginUserId = AppPrefs.getUserId() ?? '0';
  }

  Future<void> _loadMaxDistance() async {
    final maxDistanceString = AppPrefs.getMaxDistance();
    setState(() {
      _maxDistance = double.tryParse(maxDistanceString ?? '0') ?? 0.0;
    });
  }

  Future<void> _openHiveBox() async {
    try {
      final locationBox = await Hive.openBox<LocationModel>('locations');

      final patroliBox = await Hive.openBox<PatroliModel>('patroli');

      if (!mounted) return;

      setState(() {
        _box = locationBox;
        _boxPatroli = patroliBox;
        _isHiveReady = true;
      });
    } catch (e, stackTrace) {
      debugPrint('Gagal membuka Hive: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data lokasi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<double> _getDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Future<Position?> _getAccuratePosition() async {
    try {
      // 1️⃣ Pastikan GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS Tidak aktif'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return null;
      }

      // 2️⃣ Cek permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission Ditolak'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission Denied Forever'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return null;
      }

      // 3️⃣ Coba akurasi tertinggi dulu
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        debugPrint("BestForNavigation gagal, fallback ke HIGH");
      }

      // 4️⃣ Fallback ke HIGH (lebih stabil)
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint("Error ambil lokasi: $e");
      return null;
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // Jangan proses apabila Hive belum siap atau scan lain sedang diproses
    if (!_isHiveReady || _isProcessing || !mounted) {
      return;
    }

    final String? code = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .firstWhereOrNull((value) => value != null && value.isNotEmpty);

    if (code == null) return;

    setState(() {
      _isProcessing = true;
      _isScanning = false;
      _lastScanned = code;
    });

    // Hentikan kamera sementara agar onDetect tidak terpanggil berkali-kali
    try {
      await _controller.stop();
    } catch (e) {
      debugPrint('Scanner gagal dihentikan: $e');
    }

    try {
      final match = _box.values.firstWhereOrNull(
        (loc) => loc.qrcode.trim() == code,
      );

      // QR tidak ditemukan
      if (match == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'QR Code tidak ditemukan atau lokasi dinonaktifkan',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );

        return;
      }

      // Cek kesesuaian lokasi lebih dahulu sebelum mengambil GPS
      if (match.id != widget.locationId) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'QR Code tidak sesuai dengan lokasi patroli ini!\n'
                'Lokasi scan: ${match.namaLokasi}\n'
                'Lokasi patroli: ${widget.locationName}',
              ),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );

        return;
      }

      // Ambil posisi pengguna
      final Position? pos = await _getAccuratePosition();

      if (!mounted) return;

      if (pos == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Posisi tidak berhasil diperoleh. Silakan scan ulang.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );

        return;
      }

      final double distance = await _getDistance(
        pos.latitude,
        pos.longitude,
        match.latitude,
        match.longitude,
      );

      if (!mounted) return;

      double? overrideDistance;

      if (distance > _maxDistance) {
        final bool lanjut = await _confirmJarakTerlaluJauh(distance);

        if (!mounted || !lanjut) {
          return;
        }

        overrideDistance = distance;
      }

      if (!mounted) return;

      // Dialog ditunggu sampai pengguna menutup atau menyimpan
      await _showKondisiDialog(match, pos, overrideDistance);
    } catch (e, stackTrace) {
      debugPrint('Error proses QR Code: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan saat memproses QR Code: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
      }
    } finally {
      // Bagian ini selalu dijalankan:
      // QR salah, GPS gagal, pengguna batal, maupun dialog selesai.
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isScanning = true;
          _lastScanned = null;
        });

        try {
          await _controller.start();
        } catch (e) {
          debugPrint('Scanner gagal dijalankan kembali: $e');
        }
      }
    }
  }

  Future<bool> _confirmJarakTerlaluJauh(double distance) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Jarak Terlalu Jauh'),
            content: Text(
              'Jarak kamu ${distance.toStringAsFixed(1)} meter\n'
              'Maksimal ${_maxDistance.toStringAsFixed(1)} meter\n\n'
              'Apakah ingin tetap melanjutkan patroli?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Ya, Lanjutkan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showKondisiDialog(
    LocationModel lokasi,
    Position pos,
    double? overrideDistance,
  ) async {
    final TextEditingController kondisiController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    File? _fotoFile;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Isi Kondisi di ${lokasi.namaLokasi}'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: kondisiController,
                      decoration: const InputDecoration(
                        labelText: 'Kondisi lokasi',
                        hintText: 'Contoh: aman, lampu mati, rusak, dsb.',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    // Preview foto kalau ada
                    _fotoFile != null
                        ? Column(
                            children: [
                              Image.file(_fotoFile!, height: 150),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setStateDialog(() => _fotoFile = null);
                                },
                                child: const Text('Hapus Foto'),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? foto = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 70,
                              );
                              if (foto != null) {
                                setStateDialog(() {
                                  _fotoFile = File(foto.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Ambil Foto (Opsional)'),
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final kondisi = kondisiController.text.trim();
                    if (kondisi.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Isi kondisi dulu sebelum simpan'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    String? userId = AppPrefs.getUserId();

                    final note = overrideDistance != null
                        ? '${kondisiController.text}\n'
                              '[JARAK: ${overrideDistance.toStringAsFixed(1)} m]'
                        : kondisiController.text;

                    await patroliController.savePatroliLocal(
                      locationId: lokasi.id.toString(),
                      locationCode: lokasi.qrcode,
                      satpamId: userId!,
                      latitude: pos.latitude,
                      longitude: pos.longitude,
                      note: note,
                      comid: lokasi.comid.toString(),
                      photoPath: _fotoFile?.path, // bisa null, opsional
                      jadwalId: widget.id,
                      jamAwal: widget.jamAwal,
                      jamAkhir: widget.jamAkhir,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data patroli disimpan ke lokal'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualDialog(LocationModel lokasi) {
    final TextEditingController kondisiController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    File? _fotoFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Laporan ${lokasi.namaLokasi} tidak bisa di scan'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: kondisiController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan tidak bisa scan',
                        hintText: 'Contoh: hujan, barcode rusak, dsb.',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    // Preview foto kalau ada
                    _fotoFile != null
                        ? Column(
                            children: [
                              Image.file(_fotoFile!, height: 150),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setStateDialog(() => _fotoFile = null);
                                },
                                child: const Text('Hapus Foto'),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? foto = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 70,
                              );
                              if (foto != null) {
                                setStateDialog(() {
                                  _fotoFile = File(foto.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Bukti Foto'),
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _isScanning = true);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final kondisi = kondisiController.text.trim();
                    if (kondisi.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Isi kondisi dulu sebelum simpan'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // ✅ VALIDASI FOTO WAJIB
                    if (_fotoFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto bukti wajib diupload'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    String? userId = AppPrefs.getUserId();

                    final note =
                        '${kondisiController.text}\n'
                        '[TDK BS SCAN]';

                    await patroliController.savePatroliLocal(
                      locationId: lokasi.id.toString(),
                      locationCode: lokasi.qrcode,
                      satpamId: userId!,
                      latitude:
                          0.0, // karena tidak bisa scan, kita set lat/lng ke 0
                      longitude: 0.0,
                      note: note,
                      comid: lokasi.comid.toString(),
                      photoPath: _fotoFile?.path, // bisa null, opsional
                      jadwalId: widget.id,
                      jamAwal: widget.jamAwal,
                      jamAkhir: widget.jamAkhir,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data patroli disimpan ke lokal'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() => _isScanning = true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
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
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: Text(
          'Scan ${widget.locationName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (!_isHiveReady || _isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      !_isHiveReady
                          ? 'Menyiapkan data lokasi...'
                          : 'Memeriksa QR Code dan posisi...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final lokasi = _box.values.firstWhereOrNull(
                      (loc) => loc.id == widget.locationId,
                    );

                    if (lokasi == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Lokasi tidak ditemukan"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    _showManualDialog(lokasi);
                  },
                  icon: const Icon(Icons.location_off_outlined),
                  label: const Text('Tidak bisa Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
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
              ],
            ),
          ),
          Positioned(
            top: 100,
            right: 8,
            bottom: 100,
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _boxPatroli == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ValueListenableBuilder(
                      valueListenable: _boxPatroli!.listenable(),
                      builder: (context, Box<PatroliModel> box, _) {
                        if (box.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum scan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        final now = DateTime.now();
                        final today =
                            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                        final yesterdayDate = now.subtract(
                          const Duration(days: 1),
                        );
                        final yesterday =
                            '${yesterdayDate.year}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

                        final items =
                            box.values
                                .where(
                                  (e) =>
                                      e.satpamId ==
                                          _loginUserId && // ✅ FILTER COMID
                                      (e.tanggal == today ||
                                          e.tanggal == yesterday),
                                )
                                .toList()
                              ..sort((a, b) {
                                final aDateTime = DateTime.parse(
                                  '${a.tanggal} ${a.jam}',
                                );
                                final bDateTime = DateTime.parse(
                                  '${b.tanggal} ${b.jam}',
                                );
                                return bDateTime.compareTo(aDateTime);
                              });

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            String namaLokasi = patroliController.getNamaLokasi(
                              item.locationId.toString(),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaLokasi,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${item.tanggal} - ${item.jam}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
