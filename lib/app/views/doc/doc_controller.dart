import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/models/doc_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:uuid/uuid.dart';

class DocController extends GetxController {
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
  void setTujuan(String v) => tujuan.value = v;
  void setNoPolisi(String v) => noPolisi.value = v;
  void setNote(String v) => note.value = v;

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
      noPolisi: noPolisi.value,
      jenis: jenis.value,
      note: note.value,
      foto: foto.value?.path ?? '',
      comid: comId,
      createdAt: sekarang,
    );

    await boxDoc.add(model);
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
    final box = Hive.box<DocModel>('doc'); // ✅ pakai box yang sudah dibuka
    print('=== CEK  DOC HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, tanggal: ${item.tanggal}, jam: ${item.jam}, satpam: ${item.satpamId}, jumlah: ${item.jumlah.toString()}, eks: ${item.ekspedisiId.toString()}, tujuan: ${item.tujuan}, nopol: ${item.noPolisi}, jenis: ${item.jenis.toString()}, note: ${item.note}, foto: ${item.foto}, comid: ${item.comid.toDouble()}, created_at: ${item.createdAt}',
      );
    }
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
}
