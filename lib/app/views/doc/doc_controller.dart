import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/doc_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:uuid/uuid.dart';

class DocController extends GetxController {
  late StreamSubscription _connectivitySubscription;
  Timer? _periodicSyncTimer;
  final ApiProvider api = Get.find<ApiProvider>();

  RxBool isLoading = false.obs;
  late Box<DocModel> boxDoc;

  final formKey = GlobalKey<FormState>();

  // ===== INPUT DATE & TIME =====
  Rx<DateTime?> tanggal = Rx<DateTime?>(DateTime.now());
  Rx<TimeOfDay?> jam = Rx<TimeOfDay?>(TimeOfDay.now());

  // ===== INPUT TEXT =====
  RxString jumlahBox = ''.obs;
  RxString tujuan = ''.obs;
  RxString noPolisi = ''.obs;
  RxString note = ''.obs;

  // ===== JENIS (1 male, 2 female) =====
  RxInt jenis = 1.obs;

  // ===== EKSPEDISI =====
  RxList ekspedisiList = [].obs; // isi: model dari Hive
  Rx<dynamic> ekspedisiTerpilih = Rx<dynamic>(null);

  // ===== FOTO =====
  Rx<File?> foto = Rx<File?>(null);
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadEkspedisi();
    boxDoc = Hive.box<DocModel>('doc');

    syncDocToServer();

    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      status,
    ) {
      // ignore: unrelated_type_equality_checks
      if (status != ConnectivityResult.none) {
        syncDocToServer();
      }
    });

    // Jalankan sync otomatis setiap 5 menit (backup)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      syncDocToServer();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

  Future<void> syncDocToServer() async {
    final box = Hive.box<DocModel>('doc');
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
          'tanggal': p.tanggal,
          'input_date': p.createdAt,
          'jam': p.jam,
          'satpam_id': p.satpamId,
          'jumlah': p.jumlah,
          'ekspedisi_id': p.ekspedisiId,
          'tujuan': p.tujuan,
          'no_polisi': p.noPolisi,
          'jenis': p.jenis,
          'note': p.note,
          'comid': p.comid,
          if (p.foto != null && File(p.foto!).existsSync())
            'foto': await dio.MultipartFile.fromFile(
              p.foto!,
              filename: basename(p.foto!),
            ),
        });

        // Kirim ke server
        final response = await api.client.post(
          ApiEndpoint.syncDocReport,
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

  // Date
  void setTanggal(DateTime value) {
    tanggal.value = value;
  }

  // Time
  void setJam(TimeOfDay value) {
    jam.value = value;
  }

  bool validateForm() {
    return formKey.currentState!.validate();
  }

  // Text input
  void setJumlahBox(String v) => jumlahBox.value = v;
  void setTujuan(String v) {
    tujuan.value = toTitleCase(v);
  }

  void setNote(String v) {
    note.value = toTitleCase(v);
  }

  void setNoPolisi(String v) => noPolisi.value = v;

  // Jenis
  void setJenis(int v) => jenis.value = v;

  // Ekspedisi
  void setEkspedisi(dynamic v) => ekspedisiTerpilih.value = v;

  Future loadEkspedisi() async {
    final box = Hive.box<EkspedisiModel>('ekspedisi');

    ekspedisiList.value = box.values.toList();

    if (ekspedisiList.isNotEmpty) {
      ekspedisiTerpilih.value = ekspedisiList.first;
    }
  }

  // Foto
  Future pickFoto() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      foto.value = File(img.path);
    }
  }

  Future<void> saveDoc() async {
    // ambil lokasi
    isLoading(true);

    final uuid = const Uuid().v4();
    int satpamId = int.parse(AppPrefs.getUserId() ?? '');
    int comId = int.parse(AppPrefs.getComId() ?? '');
    String sekarang = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final model = DocModel(
      id: uuid,
      tanggal: DateFormat('yyyy-MM-dd').format(tanggal.value!),
      jam: formatJam(jam.value!),
      satpamId: satpamId,
      jumlah: int.parse(jumlahBox.value),
      ekspedisiId: ekspedisiTerpilih.value.id,
      tujuan: tujuan.value,
      noPolisi: noPolisi.value.toUpperCase(),
      jenis: jenis.value,
      note: note.value,
      foto: foto.value?.path ?? '',
      comid: comId,
      createdAt: sekarang,
    );

    await boxDoc.add(model);

    clearForm();
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading(false);
    Get.snackbar(
      'Berhasil',
      'Data berhasil disimpan!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  String formatJam(TimeOfDay tod) {
    return '${tod.hour.toString().padLeft(2, '0')}:'
        '${tod.minute.toString().padLeft(2, '0')}:00';
  }

  void clearForm() {
    // reset tanggal dan jam ke null
    tanggal.value = null;
    jam.value = null;

    // reset text input
    jumlahBox.value = '';
    tujuan.value = '';
    noPolisi.value = '';
    note.value = '';

    // reset jenis
    jenis.value = 1;

    // reset ekspedisi
    if (ekspedisiList.isNotEmpty) {
      ekspedisiTerpilih.value = ekspedisiList.first;
    } else {
      ekspedisiTerpilih.value = null;
    }

    // reset foto
    foto.value = null;

    // penting: reset form textfields
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
