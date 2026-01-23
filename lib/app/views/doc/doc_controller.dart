import 'dart:async';
import 'dart:convert';
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
import 'package:qbsc_saas/app/models/box_option_model.dart';
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
  RxString totalEkor = ''.obs;
  RxString namaSupir = ''.obs;
  RxString nomorSegel = ''.obs;

  // ===== JENIS (1 male, 2 female) =====
  RxInt jenis = 1.obs;

  // ===== EKSPEDISI =====
  RxList ekspedisiList = [].obs; // isi: model dari Hive
  Rx<dynamic> ekspedisiTerpilih = Rx<dynamic>(null);

  final boxOptionList = <BoxOptionModel>[].obs;
  RxList<Map<String, dynamic>> docBoxOption = <Map<String, dynamic>>[].obs;

  final Map<int, TextEditingController> jumlahBoxCtrl = {};
  final Map<int, TextEditingController> isiBoxCtrl = {};
  // ===== TOTAL EKOR PER BOX =====
  final Map<int, RxInt> totalEkorMap = {};
  // ===== TOTAL GABUNGAN =====
  RxInt totalJumlahBox = 0.obs;
  RxInt totalEkorGabungan = 0.obs;

  // ===== FOTO =====
  // Rx<File?> foto = Rx<File?>(null);
  RxList<File> fotoList = <File>[].obs;

  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadEkspedisi();
    loadBoxOption();
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

    for (final c in jumlahBoxCtrl.values) {
      c.dispose();
    }
    for (final c in isiBoxCtrl.values) {
      c.dispose();
    }

    super.onClose();
  }

  void hitungTotalGabungan() {
    int jumlahBoxSum = 0;
    int totalEkorSum = 0;

    for (final item in docBoxOption) {
      jumlahBoxSum += (item['jumlah_box'] as int);
      totalEkorSum += (item['total_ekor'] as int);
    }

    totalJumlahBox.value = jumlahBoxSum;
    totalEkorGabungan.value = totalEkorSum;

    // sinkronkan ke input jumlahBox (string)
    jumlahBox.value = jumlahBoxSum.toString();
  }

  void initBoxController(BoxOptionModel box) {
    // init controller kalau belum ada
    jumlahBoxCtrl[box.id] ??= TextEditingController();
    isiBoxCtrl[box.id] ??= TextEditingController();
    totalEkorMap[box.id] ??= 0.obs;

    void hitung() {
      final j = int.tryParse(jumlahBoxCtrl[box.id]!.text) ?? 0;
      final i = int.tryParse(isiBoxCtrl[box.id]!.text) ?? 0;
      final total = j * i;

      totalEkorMap[box.id]!.value = total;
      hitungTotalGabungan();

      // update ke docBoxOption juga
      final index = docBoxOption.indexWhere((e) => e['jenis_id'] == box.id);

      if (index != -1) {
        docBoxOption[index]['jumlah_box'] = j;
        docBoxOption[index]['isi_box'] = i;
        docBoxOption[index]['total_ekor'] = total;
        docBoxOption.refresh();
      }
    }

    jumlahBoxCtrl[box.id]!.addListener(hitung);
    isiBoxCtrl[box.id]!.addListener(hitung);
  }

  Future<void> syncDocToServer() async {
    final box = Hive.box<DocModel>('doc');
    final unsynced = box.values.where((p) => p.isSynced == false).toList();

    if (unsynced.isEmpty) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    for (final doc in unsynced) {
      try {
        final formData = dio.FormData.fromMap({
          'uuid': doc.id,
          'tanggal': doc.tanggal,
          'input_date': doc.createdAt,
          'jam': doc.jam,
          'satpam_id': doc.satpamId,
          'jumlah': doc.jumlah,
          'total_ekor': doc.totalEkor,
          'nama_supir': doc.namaSupir,
          'nomor_segel': doc.nomorSegel,
          'ekspedisi_id': doc.ekspedisiId,
          'tujuan': doc.tujuan,
          'no_polisi': doc.noPolisi,
          'jenis': doc.jenis,
          'note': doc.note,
          'comid': doc.comid,

          // JSON STRING
          'doc_box_option': doc.docBoxOptionJson,
        });

        // ===== MULTI FOTO (🔥 KUNCI UTAMA) =====
        for (final path in doc.foto) {
          final file = File(path);
          if (file.existsSync()) {
            formData.files.add(
              MapEntry(
                'foto[]', // ⬅️ WAJIB foto[]
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: basename(file.path),
                ),
              ),
            );
          } else {
            print('❌ File tidak ditemukan: $path');
          }
        }

        print('📸 Foto dikirim: ${formData.files.length}');

        final response = await api.client.post(
          ApiEndpoint.syncDocReport,
          data: formData,
          options: dio.Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        if (response.data['success'] == true) {
          doc.isSynced = true;
          await doc.save();
          print('✅ Sync sukses: ${doc.id}');
        } else {
          print('❌ Sync gagal: ${response.data}');
        }
      } catch (e) {
        print('⚠️ Error sync ${doc.id}: $e');
      }
    }
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
    // return true;
  }

  // Text input
  void setJumlahBox(String v) => jumlahBox.value = v;
  void setTotalEkor(String v) => totalEkor.value = v;
  void setTujuan(String v) {
    tujuan.value = toTitleCase(v);
  }

  void setNamaSupir(String v) {
    namaSupir.value = toTitleCase(v);
  }

  void setNomorSegel(String v) {
    nomorSegel.value = toTitleCase(v);
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

  Future<void> loadBoxOption() async {
    final box = Hive.box<BoxOptionModel>('box_option');
    boxOptionList.value = box.values.toList();

    // init docBoxOption
    docBoxOption.value = boxOptionList.map((e) {
      return {
        "jenis_id": e.id,
        "jenis_name": e.jenisBox,
        "jumlah_box": 0,
        "isi_box": 0,
        "total_ekor": 0,
      };
    }).toList();
  }

  Future<void> pickFoto() async {
    if (fotoList.length >= 3) {
      Get.snackbar(
        'Batas foto',
        'Maksimal 3 foto saja',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isEmpty) return;

    for (final img in images) {
      if (fotoList.length >= 3) break;
      fotoList.add(File(img.path));
    }
  }

  Future<void> saveDoc() async {
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
      // foto: foto.value?.path ?? '',
      foto: fotoList.map((f) => f.path).toList(),
      docBoxOptionJson: jsonEncode(buildDocBoxOptionForSave()),
      comid: comId,
      createdAt: sekarang,
      namaSupir: namaSupir.value,
      nomorSegel: nomorSegel.value,
      totalEkor: int.parse(totalEkor.value),
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
    checkHive();
  }

  String formatJam(TimeOfDay tod) {
    return '${tod.hour.toString().padLeft(2, '0')}:'
        '${tod.minute.toString().padLeft(2, '0')}:00';
  }

  void removeFoto(int index) {
    fotoList.removeAt(index);
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

  List<Map<String, dynamic>> buildDocBoxOptionForSave() {
    int index = 1;

    return docBoxOption.map((e) {
      return {
        "id": index++,
        "option_id": e['jenis_id'].toString(),
        "option_name": e['jenis_name'],
        "jumlah_box": e['jumlah_box'].toString(),
        "isi": e['isi_box'].toString(),
        "total_ekor": e['total_ekor'].toString(),
      };
    }).toList();
  }

  void resetDocBoxOption() {
    for (final box in boxOptionList) {
      jumlahBoxCtrl[box.id]?.clear();
      isiBoxCtrl[box.id]?.clear();
      totalEkorMap[box.id]?.value = 0;
    }

    docBoxOption.assignAll(
      boxOptionList.map((e) {
        return {
          "jenis_id": e.id,
          "jenis_name": e.jenisBox,
          "jumlah_box": 0,
          "isi_box": 0,
          "total_ekor": 0,
        };
      }).toList(),
    );

    totalJumlahBox.value = 0;
    totalEkorGabungan.value = 0;
  }

  void clearForm() {
    // ===== TANGGAL & JAM =====
    tanggal.value = DateTime.now();
    jam.value = TimeOfDay.now();

    // ===== TEXT RX =====
    jumlahBox.value = '';
    tujuan.value = '';
    noPolisi.value = '';
    note.value = '';
    namaSupir.value = '';
    nomorSegel.value = '';
    totalEkor.value = '';

    // ===== TOTAL =====
    totalJumlahBox.value = 0;
    totalEkorGabungan.value = 0;

    // ===== JENIS =====
    jenis.value = 1;

    // ===== EKSPEDISI =====
    if (ekspedisiList.isNotEmpty) {
      ekspedisiTerpilih.value = ekspedisiList.first;
    }

    // ===== FOTO (🔥 PENTING) =====
    fotoList.clear();

    // ===== DOC BOX OPTION (🔥 PENTING) =====
    resetDocBoxOption();

    // ===== FORM UI =====
    formKey.currentState?.reset();
  }

  void checkHive() {
    final box = Hive.box<DocModel>('doc');

    for (var doc in box.values) {
      print('============= hive ===============');
      print('ID: ${doc.id}');
      print('docBoxOptionJson: ${doc.docBoxOptionJson}');
      print('foto: ${doc.foto}');
      print('nama supir: ${doc.namaSupir}');
      print('nomor segel: ${doc.nomorSegel}');
      print('total ekor: ${doc.totalEkor}');
      print('---');
    }
  }
}
