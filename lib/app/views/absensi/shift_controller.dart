import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/absensi/shift_model.dart';

class ShiftController extends GetxController {
  var isLoading = false.obs;
  var shiftList = <ShiftModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    getDataShift();
  }

  Future<void> getDataShift() async {
    isLoading.value = true;

    String comid = AppPrefs.getComId().toString();

    if (comid.isNotEmpty) {
      try {
        final response = await api.post(
          ApiEndpoint.getDataShift,
          data: {'comid': comid},
        );

        var result = response.data;
        if (result['success']) {
          shiftList.value = result['data']
              .map<ShiftModel>((e) => ShiftModel.fromJson(e))
              .toList();
        }
      } on DioException catch (e) {
        Get.snackbar(
          'Gagal',
          e.response?.data['message'] ?? 'Terjadi kesalahan saat mengirim',
        );
      } catch (e) {
        Get.snackbar('Error', e.toString());
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'User id tidak ditemukan');
    }
  }
}
