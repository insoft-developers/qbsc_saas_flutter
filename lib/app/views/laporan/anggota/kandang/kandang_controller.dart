import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/kandang_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/satpam_model.dart';

class KandangController extends GetxController {
  var satpamList = <SatpamModel>[].obs;
  var kandangList = <KandangModel>[].obs;

  var selectedSatpamId = RxnInt();
  var selectedKandangId = RxnInt();

  // =========================
  // FILTER STATE
  // =========================
  var startDate = Rxn<String>(); // yyyy-MM-dd
  var endDate = Rxn<String>(); // yyyy-MM-dd
  var namaSatpam = Rxn<String>();
  var namaKandang = Rxn<String>();

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> fetchSatpam() async {
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    final res = await api.post(ApiEndpoint.apiSatpam, data: {'comid': comid});

    if (res.data['success']) {
      satpamList.value = (res.data['data'] as List)
          .map((e) => SatpamModel.fromJson(e))
          .toList();
    }
  }

  Future<void> fetchKandang() async {
    int comid = int.parse(AppPrefs.getComId() ?? '0');

    final res = await api.post(ApiEndpoint.kandangList, data: {'comid': comid});

    if (res.data['success']) {
      kandangList.value = (res.data['data'] as List)
          .map((e) => KandangModel.fromJson(e))
          .toList();
    }
  }
}
