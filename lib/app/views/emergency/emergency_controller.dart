import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/emergency/emergency_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<EmergencyModel> daruratList = <EmergencyModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    ambilData();
    super.onInit();
  }

  void ambilData() async {
    await kontakDarurat();
  }

  Future<void> kontakDarurat() async {
    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.emergency,
        data: {'comid': comid},
      );
      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        daruratList.value = listData
            .map((json) => EmergencyModel.fromJson(json))
            .toList();
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String normalizeWa(String number) {
    number = number.replaceAll(RegExp(r'\D'), ''); // hilangkan spasi / simbol

    if (number.startsWith("0")) {
      return "62" + number.substring(1);
    }
    if (number.startsWith("62")) {
      return number;
    }
    return number; // fallback
  }

  Future<void> callWhatsApp(String number) async {
    final wa = normalizeWa(number);
    final url = Uri.parse("whatsapp://send?phone=$wa&text=");

    // trik untuk open WA dulu lalu user klik call manual
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Tidak bisa membuka WhatsApp';
    }
  }
}
