import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/satpam_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/user_model.dart';

class TamuController extends GetxController {
  var isLoading = false.obs;
  var tamuList = <TamuModel>[].obs;
  var satpamList = <SatpamModel>[].obs;
  var userList = <UserModel>[].obs;
  var isMoreDataAvailable = true.obs;
  var selectedSatpamId = RxnInt();
  var selectedUserId = RxnInt();

  final ApiProvider api = Get.find<ApiProvider>();

  int _page = 1;
  final int _limit = 20;

  // =========================
  // FILTER STATE
  // =========================
  var startDate = Rxn<String>(); // yyyy-MM-dd
  var endDate = Rxn<String>(); // yyyy-MM-dd'

  @override
  void onInit() {
    super.onInit();
    fetchSatpam();
    fetchUser();
    fetchTamu();
  }

  void onChangeSatpam(int? id) {
    selectedSatpamId.value = id;
    fetchTamu(); // reload
  }

  void onChangeUser(int? id) {
    selectedUserId.value = id;
    fetchTamu(); // reload
  }

  // =========================
  // APPLY FILTER (WAJIB DIPAKAI)
  // =========================
  void applyFilter({String? start, String? end, int? satpamId, int? userId}) {
    startDate.value = start;
    endDate.value = end;
    selectedSatpamId.value = satpamId;
    selectedUserId.value = userId;
    // 🔥 RESET PAGINATION
    _page = 1;
    tamuList.clear();
    isMoreDataAvailable.value = true;

    fetchTamu();
  }

  // =========================
  // CLEAR FILTER
  // =========================
  void clearFilter() {
    startDate.value = null;
    endDate.value = null;
    selectedSatpamId.value = null;
    selectedUserId.value = null;
    _page = 1;
    tamuList.clear();
    isMoreDataAvailable.value = true;

    fetchTamu();
  }

  // =========================
  // FETCH DATA
  // =========================
  Future<void> fetchTamu({bool loadMore = false}) async {
    if (isLoading.value) return;

    if (!loadMore) {
      _page = 1;
      tamuList.clear();
      isMoreDataAvailable.value = true;
    }

    if (!isMoreDataAvailable.value) return;

    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.bosTamu,
        data: {
          'comid': comid,
          'page': _page,
          'limit': _limit,

          // 🔍 FILTER PARAM
          if (startDate.value != null) 'start_date': startDate.value,
          if (endDate.value != null) 'end_date': endDate.value,
          if (selectedSatpamId.value != null)
            'satpam_id': selectedSatpamId.value,
          if (selectedUserId.value != null) 'user_id': selectedUserId.value,
        },
      );

      final body = response.data;

      if (body['success'] == true) {
        final pagination = body['data'];

        final List<dynamic> listData = pagination['data'];
        final int currentPage = pagination['current_page'];
        final int lastPage = pagination['last_page'];

        final fetchedData = listData
            .map((json) => TamuModel.fromJson(json))
            .toList();

        tamuList.addAll(fetchedData);

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

  Future<void> fetchUser() async {
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    final res = await api.post(ApiEndpoint.bosUser, data: {'comid': comid});

    if (res.data['success']) {
      userList.value = (res.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
    }
  }

  void refreshData() {
    _page = 1;
    tamuList.clear();
    isMoreDataAvailable.value = true;
    fetchTamu();
  }
}
