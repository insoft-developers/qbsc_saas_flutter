import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class TamuController extends GetxController {
  final RxBool isLoading = false.obs;
  final ApiProvider api = Get.find<ApiProvider>();
  final RxBool isExist = false.obs;
  var scanList = <String, dynamic>{}.obs;

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
        print('data scan list');
        print(scanList);
      } else {
        isExist(false);
        Get.snackbar('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      isExist(false);
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
