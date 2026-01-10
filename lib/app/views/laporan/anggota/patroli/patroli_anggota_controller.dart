import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/lokasi_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/satpam_model.dart';

import 'package:url_launcher/url_launcher.dart';

class PatroliAnggotaController extends GetxController {
  var isLoading = false.obs;
  var patroliList = <PatroliModel>[].obs;
  var satpamList = <SatpamModel>[].obs;
  var lokasiList = <LokasiModel>[].obs;
  var isMoreDataAvailable = true.obs;
  var selectedSatpamId = RxnInt();
  var selectedLocationId = RxnInt();

  final ApiProvider api = Get.find<ApiProvider>();

  int _page = 1;
  final int _limit = 20;

  // =========================
  // FILTER STATE
  // =========================
  var startDate = Rxn<String>(); // yyyy-MM-dd
  var endDate = Rxn<String>(); // yyyy-MM-dd
  var namaSatpam = Rxn<String>();
  var namaLokasi = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchSatpam();
    fetchLokasi();
    fetchPatroli();
  }

  // =========================
  // APPLY FILTER (WAJIB DIPAKAI)
  // =========================
  void applyFilter({
    String? start,
    String? end,
    int? satpamId,
    int? locationId,
  }) {
    selectedSatpamId.value = satpamId;
    selectedLocationId.value = locationId;
    startDate.value = start;
    endDate.value = end;

    // 🔥 RESET PAGINATION
    _page = 1;
    patroliList.clear();
    isMoreDataAvailable.value = true;

    fetchPatroli();
  }

  // =========================
  // CLEAR FILTER
  // =========================
  void clearFilter() {
    startDate.value = null;
    endDate.value = null;
    selectedSatpamId.value = null; // ✅ GANTI INI
    selectedLocationId.value = null;

    _page = 1;
    patroliList.clear();
    isMoreDataAvailable.value = true;

    fetchPatroli();
  }

  void onChangeSatpam(int? id) {
    selectedSatpamId.value = id;
    fetchPatroli(); // reload
  }

  void onChangeLocation(int? id) {
    selectedLocationId.value = id;
    fetchPatroli(); // reload
  }

  // =========================
  // FETCH DATA
  // =========================
  Future<void> fetchPatroli({bool loadMore = false}) async {
    if (isLoading.value) return;

    if (!loadMore) {
      _page = 1;
      patroliList.clear();
      isMoreDataAvailable.value = true;
    }

    if (!isMoreDataAvailable.value) return;

    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.laporanAnggotaPatroli,
        data: {
          'comid': comid,
          'page': _page,
          'limit': _limit,

          // 🔍 FILTER PARAM
          if (startDate.value != null) 'start_date': startDate.value,
          if (endDate.value != null) 'end_date': endDate.value,
          if (selectedLocationId.value != null)
            'location_id': selectedLocationId.value,
          if (selectedSatpamId.value != null)
            'satpam_id': selectedSatpamId.value,
        },
      );

      final body = response.data;

      if (body['success'] == true) {
        final pagination = body['data'];

        final List<dynamic> listData = pagination['data'];
        final int currentPage = pagination['current_page'];
        final int lastPage = pagination['last_page'];

        final fetchedData = listData
            .map((json) => PatroliModel.fromJson(json))
            .toList();

        patroliList.addAll(fetchedData);

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

  Future<void> fetchSatpam() async {
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    final res = await api.post(ApiEndpoint.apiSatpam, data: {'comid': comid});

    if (res.data['success']) {
      satpamList.value = (res.data['data'] as List)
          .map((e) => SatpamModel.fromJson(e))
          .toList();
    }
  }

  Future<void> fetchLokasi() async {
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    final res = await api.post(ApiEndpoint.apiLokasi, data: {'comid': comid});

    if (res.data['success']) {
      lokasiList.value = (res.data['data'] as List)
          .map((e) => LokasiModel.fromJson(e))
          .toList();
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
    patroliList.clear();
    isMoreDataAvailable.value = true;

    fetchPatroli();
  }
}
