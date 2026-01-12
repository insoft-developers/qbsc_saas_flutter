import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/pengaturan/lokasi/lokasi_model.dart';

class LokasiController extends GetxController {
  var lokasiList = <LokasiModel>[].obs;
  var isLoading = false.obs;
  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> fetchLokasi() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getDataLocation,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        lokasiList.value = listData
            .map((json) => LokasiModel.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLocationCoordinates(
    int id,
    String qrcode,
    String lat,
    String lng,
    String namaLokasi,
  ) async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    if (qrcode.isEmpty) {
      Get.snackbar('Error', 'Qrcode tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.updateLocationCoordinates,
        data: {
          'id': id,
          'comid': comid,
          'qrcode': qrcode,
          'lat': lat,
          'lng': lng,
          'nama_lokasi': namaLokasi,
        },
      );

      var body = response.data;
      if (body['success']) {
        fetchLokasi();
        Get.back();
        Get.snackbar(
          'Berhasil',
          'Update data berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar('Gagal', body['message'].toString());
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
