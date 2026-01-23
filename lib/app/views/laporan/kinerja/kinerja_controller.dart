import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class KinerjaController extends GetxController {
  final ApiProvider api = Get.find<ApiProvider>();
  var kinerjaData = List.empty().obs;
  var isLoading = false.obs;

  @override
  onInit() {
    super.onInit();
    kinerjaSatpam();
  }

  Future<void> kinerjaSatpam() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      SnackbarHelper.error('Error', 'Com id tidak ditemukan');
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.kinerjaSatpam,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        kinerjaData.value = body['data'];
      } else {}
    } catch (e) {
      // SnackbarHelper.error('Error', 'Offline');
    } finally {
      isLoading.value = false;
    }
  }
}
