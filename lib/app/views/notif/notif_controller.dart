import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/notif/notif_model.dart';

class NotifController extends GetxController {
  var isLoading = false.obs;
  var notifList = <NotifModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    fetchNotif();
    super.onInit();
  }

  Future<void> fetchNotif() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getNotifList,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        notifList.value = listData
            .map((json) => NotifModel.fromJson(json))
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
}
