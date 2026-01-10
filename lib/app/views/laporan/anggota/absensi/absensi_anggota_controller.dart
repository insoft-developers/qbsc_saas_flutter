import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absensi/absensi_anggota_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AbsensiAnggotaController extends GetxController {
  var isLoading = false.obs;
  var absensiList = <AbsensiAnggotaModel>[].obs;
  final errorMessage = ''.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    getDataAbsensi();
  }

  // =========================
  // CLEAR FILTER
  // =========================
  void clearFilter() {
    absensiList.clear();

    getDataAbsensi();
  }

  // =========================
  // FETCH DATA
  // =========================
  Future<void> getDataAbsensi() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.laporanAnggotaAbsensi,
        data: {'comid': comid},
      );

      final body = response.data;

      if (body['success'] == true) {
        final listData = body['data'] as List;

        absensiList.value = listData
            .map((json) => AbsensiAnggotaModel.fromJson(json))
            .toList();
      } else {
        errorMessage.value = 'Gagal memuat data absensi';
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/@$lat,$lng,20z');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Tidak bisa membuka Google Maps';
    }
  }

  Future<void> refreshData() async {
    await getDataAbsensi();
  }

  String normalizeWa(String number) {
    number = number.replaceAll(RegExp(r'\D'), ''); // hilangkan spasi / simbol

    if (number.startsWith("0")) {
      return "62${number.substring(1)}";
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
