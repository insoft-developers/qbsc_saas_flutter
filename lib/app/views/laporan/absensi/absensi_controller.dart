import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/absensi/absensi_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AbsensiController extends GetxController {
  var isLoading = false.obs;
  var absensiList = <AbsensiModel>[].obs;
  var isMoreDataAvailable = true.obs;

  final ApiProvider api = Get.find<ApiProvider>();

  int _page = 1;
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    getDataAbsensi();
  }

  // =========================
  // CLEAR FILTER
  // =========================
  void clearFilter() {
    _page = 1;
    absensiList.clear();
    isMoreDataAvailable.value = true;

    getDataAbsensi();
  }

  // =========================
  // FETCH DATA
  // =========================
  Future<void> getDataAbsensi({bool loadMore = false}) async {
    if (isLoading.value) return;

    if (!loadMore) {
      _page = 1;
      absensiList.clear();
      isMoreDataAvailable.value = true;
    }

    if (!isMoreDataAvailable.value) return;

    isLoading.value = true;
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.laporanAbsensi,
        data: {'satpam_id': satpamId, 'page': _page, 'limit': _limit},
      );

      final body = response.data;

      if (body['success'] == true) {
        final pagination = body['data'];

        final List<dynamic> listData = pagination['data'];
        final int currentPage = pagination['current_page'];
        final int lastPage = pagination['last_page'];

        final fetchedData = listData
            .map((json) => AbsensiModel.fromJson(json))
            .toList();

        absensiList.addAll(fetchedData);

        // 🔥 STOP INFINITE SCROLL
        if (currentPage >= lastPage) {
          isMoreDataAvailable.value = false;
        } else {
          _page++;
        }
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
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

  void refreshData() {
    _page = 1;
    absensiList.clear();
    isMoreDataAvailable.value = true;

    getDataAbsensi();
  }
}
