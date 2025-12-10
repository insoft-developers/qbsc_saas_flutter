import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class TamuController extends GetxController {
  final RxBool isLoading = false.obs;
  final ApiProvider api = Get.find<ApiProvider>();
  final RxBool isExist = false.obs;
  var scanList = <String, dynamic>{}.obs;
  final tamuList = List.empty().obs;

  RxString namaTamu = ''.obs;
  RxString jumlahTamu = ''.obs;
  RxString tujuan = ''.obs;
  RxString whatsapp = ''.obs;
  RxString catatan = ''.obs;

  // ===== FOTO =====
  Rx<File?> foto = Rx<File?>(null);
  final picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  bool validateForm() {
    return formKey.currentState!.validate();
  }

  Future<void> checkQRTamu(String qrcode) async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.checkQrTamu,
        data: {'comid': comid, 'qrcode': qrcode},
      );

      var body = response.data;
      if (body['success']) {
        isExist(true);
        scanList.value = body['data'];
      } else {
        isExist(false);
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      isExist(false);
      SnackbarHelper.error('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDataTamu(int id, String masuk) async {
    isLoading.value = true;
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');
    try {
      final response = await api.post(
        ApiEndpoint.saveDataTamu,
        data: {'id': id, 'satpam_id': satpamId, 'masuk': masuk},
      );
      var body = response.data;
      if (body['success']) {
        // SnackbarHelper.success('sukses', 'Sukses Simpan Data');
        Get.back();
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDataTamuManualInput() async {
    isLoading.value = true;
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    try {
      // ====== Convert ke FormData ======
      final formData = dio.FormData.fromMap({
        'satpam_id': satpamId,
        'nama_tamu': namaTamu.value,
        'jumlah_tamu': jumlahTamu.value,
        'tujuan': tujuan.value,
        'whatsapp': whatsapp.value,
        'catatan': catatan.value,
        'comid': comid,
        if (foto.value != null)
          'foto': await dio.MultipartFile.fromFile(
            foto.value!.path,
            filename: foto.value!.path.split('/').last,
          ),
      });

      final response = await api.post(
        ApiEndpoint.tambahDataTamu,
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      var body = response.data;

      if (body['success']) {
        SnackbarHelper.success('sukses', 'Sukses Tambah Data Tamu');
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusTamu(int id) async {
    isLoading.value = true;
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.updateStatusTamu,
        data: {'id': id, 'satpam_id': satpamId},
      );
      var body = response.data;
      if (body['success']) {
        SnackbarHelper.success('sukses', 'Sukses Simpan Data');
        // Get.back();
        getListTamu();
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getListTamu() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getListTamu,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        tamuList.value = body['data'];
        print(tamuList);
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      isExist(false);
      SnackbarHelper.error('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void setJumlahTamu(String v) => jumlahTamu.value = v;
  void setTujuan(String v) {
    tujuan.value = toTitleCase(v);
  }

  void setNamaTamu(String v) {
    namaTamu.value = toTitleCase(v);
  }

  void setNote(String v) {
    catatan.value = toTitleCase(v);
  }

  void setWhatsapp(String v) => whatsapp.value = v;

  // Foto
  Future pickFoto() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      foto.value = File(img.path);
    }
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
