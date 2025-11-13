import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/kandang_model.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  late Box<LocationModel> _box;

  final RxBool kandangLoading = false.obs;
  final RxList<KandangModel> kandangs = <KandangModel>[].obs;
  late Box<KandangModel> _boxKandang;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _box = Hive.box<LocationModel>(
      'locations',
    ); // ✅ box yang sudah dibuka di main.dart
    _boxKandang = Hive.box<KandangModel>('kandang');
    await getDataLocation();
    await getDataKandang();
    await cekDataHive(); // panggil setelah ambil data
  }

  // Fetch dari server
  Future<void> getDataLocation() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getDataLocation,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> list = body['data'];
        final List<LocationModel> locationList = list
            .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // 🟢 Ganti clear dengan overwrite manual biar gak hapus total
        await _box.clear();
        await _box.addAll(locationList);

        locations.assignAll(locationList);

        print('✅ Sukses: diambil dari server dan disimpan di Hive');
        print('Jumlah data disimpan: ${_box.length}');
      } else {
        Get.snackbar('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _box.values.toList();
      locations.assignAll(local);
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDataKandang() async {
    kandangLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      kandangLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getDataKandang,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> list = body['data'];
        final List<KandangModel> kandangList = list
            .map((e) => KandangModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // 🟢 Ganti clear dengan overwrite manual biar gak hapus total
        await _boxKandang.clear();
        await _boxKandang.addAll(kandangList);

        kandangs.assignAll(kandangList);

        print('✅ Sukses: diambil dari server dan disimpan di Hive');
        print('Jumlah data disimpan: ${_boxKandang.length}');
      } else {
        Get.snackbar('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _boxKandang.values.toList();
      kandangs.assignAll(local);
      Get.snackbar('Error', e.toString());
    } finally {
      kandangLoading.value = false;
    }
  }

  Future<void> cekDataHive() async {
    final box = Hive.box<LocationModel>(
      'locations',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK DATA DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, Nama: ${item.namaLokasi}, QR: ${item.qrcode}, LAT: ${item.latitude.toString()}, LNG: ${item.longitude.toString()}',
      );
    }

    final boxKandang = Hive.box<KandangModel>(
      'kandang',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK DATA KANDANG DI HIVE ===');
    print('Total data: ${boxKandang.length}');
    for (var itemK in boxKandang.values) {
      print(
        'ID: ${itemK.id}, Nama: ${itemK.name}, CD: ${itemK.code}, TEMP: ${itemK.stdTemp.toString()}, FAN: ${itemK.fanAmount.toString()}',
      );
    }
  }
}
