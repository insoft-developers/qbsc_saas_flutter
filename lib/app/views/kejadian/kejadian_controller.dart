import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/situasi_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:uuid/uuid.dart';

class KejadianController extends GetxController {
  late StreamSubscription _connectivitySubscription;
  Timer? _periodicSyncTimer;
  final ApiProvider api = Get.find<ApiProvider>();

  RxBool isLoading = false.obs;
  late Box<SituasiModel> boxSituasi;

  final formKey = GlobalKey<FormState>();

  RxString laporan = ''.obs;
  Rx<File?> foto = Rx<File?>(null);
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    boxSituasi = Hive.box<SituasiModel>('situasi');

    syncToServer();

    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      status,
    ) {
      // ignore: unrelated_type_equality_checks
      if (status != ConnectivityResult.none) {
        syncToServer();
      }
    });

    // Jalankan sync otomatis setiap 5 menit (backup)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      syncToServer();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

  Future<void> syncToServer() async {
    final box = Hive.box<SituasiModel>('situasi');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) {
      print("Tidak ada data doc yang perlu di-sync.");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Tidak ada koneksi, sync ditunda.");
      return;
    }

    print("Mulai sync ${unsynced.length} data ke server...");

    int sukses = 0;
    int gagal = 0;

    for (var p in unsynced) {
      try {
        // Siapkan FormData
        final formData = dio.FormData.fromMap({
          'uuid': p.id,
          'tanggal': p.createdAt,
          'satpam_id': p.satpamId,
          'laporan': p.laporan,
          'comid': p.comid,
          if (p.foto != null && File(p.foto!).existsSync())
            'foto': await dio.MultipartFile.fromFile(
              p.foto!,
              filename: basename(p.foto!),
            ),
        });

        // Kirim ke server
        final response = await api.client.post(
          ApiEndpoint.laporanSituasi,
          data: formData,
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        final body = response.data;
        if (body['success'] == true) {
          p.isSynced = true;
          await p.save();
          sukses++;
          print('✅ Sync sukses untuk ID: ${p.id}');
        } else {
          gagal++;
          print('❌ Sync gagal untuk ID: ${p.id} - ${body['message']}');
        }
      } catch (e) {
        gagal++;
        print('⚠️ Gagal sync ID: ${p.id} - $e');
        continue;
      }
    }

    print('=== HASIL SYNC ===');
    print('Sukses: $sukses');
    print('Gagal: $gagal');
    print('Total: ${unsynced.length}');
  }

  bool validateForm() {
    return formKey.currentState!.validate();
  }

  void setLaporan(String v) {
    laporan.value = toTitleCase(v);
  }

  // Foto
  Future pickFoto() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      foto.value = File(img.path);
    }
  }

  Future<void> saveSituasi() async {
    // ambil lokasi
    isLoading(true);

    final uuid = const Uuid().v4();
    int satpamId = int.parse(AppPrefs.getUserId() ?? '');
    int comId = int.parse(AppPrefs.getComId() ?? '');
    String sekarang = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final model = SituasiModel(
      id: uuid,
      createdAt: sekarang,
      satpamId: satpamId,
      laporan: laporan.value,
      foto: foto.value?.path ?? '',
      comid: comId,
    );

    await boxSituasi.add(model);
    cekHive();
    isLoading(false);
    clearForm();
    Get.snackbar(
      'Berhasil',
      'Data berhasil disimpan!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> cekHive() async {
    final box = Hive.box<SituasiModel>(
      'situasi',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK  SITUASI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, tanggal: ${item.createdAt}, laporan: ${item.laporan}, satpam: ${item.satpamId}, foto: ${item.foto}, comid: ${item.comid.toString()}',
      );
    }
  }

  String formatJam(TimeOfDay tod) {
    return '${tod.hour.toString().padLeft(2, '0')}:'
        '${tod.minute.toString().padLeft(2, '0')}:00';
  }

  void clearForm() {
    laporan.value = '';
    foto.value = null;
    formKey.currentState?.reset();
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
