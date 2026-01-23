import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/models/box_option_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/models/kandang_model.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/jadwal/patroli/jadwal_patroli_model.dart';
import 'package:qbsc_saas/app/views/paket.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  late Box<LocationModel> _box;
  RxInt unreadCount = 0.obs;
  var runningText = 'QBSC Running Text'.obs;
  var rtStatus = false.obs;
  var adminWhatsapp = ''.obs;

  final RxBool kandangLoading = false.obs;
  final RxList<KandangModel> kandangs = <KandangModel>[].obs;
  late Box<KandangModel> _boxKandang;

  final RxBool ekspedisiLoading = false.obs;
  final RxList<EkspedisiModel> ekspedisi = <EkspedisiModel>[].obs;
  late Box<EkspedisiModel> _boxEkspedisi;

  final RxList<JadwalPatroliModel> jadwalPatroli = <JadwalPatroliModel>[].obs;
  late Box<JadwalPatroliModel> _boxJadwalPatroli;

  final RxList<BoxOptionModel> boxOptions = <BoxOptionModel>[].obs;
  late Box<BoxOptionModel> _boxBoxOption;

  final ApiProvider api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    _initAndLoad();
  }

  void setCount(int count) {
    unreadCount.value = count;
  }

  void increment() {
    unreadCount.value++;
  }

  void clear() {
    unreadCount.value = 0;
  }

  Future<void> _initAndLoad() async {
    _box = Hive.box<LocationModel>(
      'locations',
    ); // ✅ box yang sudah dibuka di main.dart
    _boxKandang = Hive.box<KandangModel>('kandang');
    _boxEkspedisi = Hive.box<EkspedisiModel>('ekspedisi');
    _boxJadwalPatroli = Hive.box<JadwalPatroliModel>('jadwal_patroli');
    _boxBoxOption = Hive.box<BoxOptionModel>('box_option');
    await getDataLocation();
    await getDataKandang();
    await getDataEkspedisi();
    await getJadwalPatroli();
    await cekDataHive();
    await getDataBoxOption();

    // panggil setelah ambil data
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
      } else {
        SnackbarHelper.error('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _box.values.toList();
      locations.assignAll(local);
      // SnackbarHelper.error('Error', 'Offline');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDataEkspedisi() async {
    ekspedisiLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getDataEkspedisi,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> list = body['data'];
        final List<EkspedisiModel> ekspedisiList = list
            .map((e) => EkspedisiModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // 🟢 Ganti clear dengan overwrite manual biar gak hapus total
        await _boxEkspedisi.clear();
        await _boxEkspedisi.addAll(ekspedisiList);

        ekspedisi.assignAll(ekspedisiList);
      } else {
        SnackbarHelper.error('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _boxEkspedisi.values.toList();
      ekspedisi.assignAll(local);
      // SnackbarHelper.error('Error', 'Offline');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDataBoxOption() async {
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.getDataJenisBox,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> list = body['data'];
        final List<BoxOptionModel> boxOptionList = list
            .map((e) => BoxOptionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // 🟢 Ganti clear dengan overwrite manual biar gak hapus total
        await _boxBoxOption.clear();
        await _boxBoxOption.addAll(boxOptionList);

        boxOptions.assignAll(boxOptionList);
      } else {
        SnackbarHelper.error('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _boxEkspedisi.values.toList();
      ekspedisi.assignAll(local);
      // SnackbarHelper.error('Error', 'Offline');
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
      } else {
        SnackbarHelper.error('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _boxKandang.values.toList();
      kandangs.assignAll(local);
      // SnackbarHelper.error('Error', 'Offline');
    } finally {
      kandangLoading.value = false;
    }
  }

  Future<void> cekDataHive() async {
    final box = Hive.box<JadwalPatroliModel>(
      'jadwal_patroli',
    ); // ✅ pakai box yang sudah dibuka
    print('=== CEK DATA DI HIVE ===');
    print('Total data: ${box.length}');
    for (var item in box.values) {
      print(
        'ID: ${item.id}, Code: ${item.locationId}, Name: ${item.patroliId}, Check: ${item.isChecked.toString()}',
      );
    }
  }

  Future<void> checkPaket() async {
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      SnackbarHelper.error('Error', 'Com id tidak ditemukan');
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.checkPaket,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
      } else {
        Get.to(() => Paket());
      }
    } catch (e) {
      // SnackbarHelper.error('Error', 'Offline');
    } finally {}
  }

  Future<void> setRunningText() async {
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      SnackbarHelper.error('Error', 'Com id tidak ditemukan');
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.runningText,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        rtStatus(true);
        runningText.value = body['data'] ?? 'QBSC';
        adminWhatsapp.value = body['whatsapp'];
      } else {
        rtStatus(false);
        adminWhatsapp.value = body['whatsapp'];
      }
    } catch (e) {
      // SnackbarHelper.error('Error', 'Offline');
      rtStatus(false);
    } finally {}
  }

  Future<void> getJadwalPatroli() async {
    isLoading.value = true;
    String comid = AppPrefs.getComId().toString();

    if (comid.isEmpty) {
      Get.snackbar('Error', 'Com id tidak ditemukan');
      isLoading.value = false;
      return;
    }

    try {
      final response = await api.post(
        ApiEndpoint.jadwalPatroliPerusahaan,
        data: {'comid': comid},
      );

      var body = response.data;
      if (body['success']) {
        final List<dynamic> list = body['data'];
        final List<JadwalPatroliModel> jadwalPatroliList = list
            .map((e) => JadwalPatroliModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // 🟢 Ganti clear dengan overwrite manual biar gak hapus total
        await _boxJadwalPatroli.clear();
        await _boxJadwalPatroli.addAll(jadwalPatroliList);

        jadwalPatroli.assignAll(jadwalPatroliList);
      } else {
        SnackbarHelper.error('Gagal', 'Data tidak ada');
      }
    } catch (e) {
      final local = _boxJadwalPatroli.values.toList();
      jadwalPatroli.assignAll(local);
      // SnackbarHelper.error('Error', 'Offline');
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

  Future<void> callWhatsApp() async {
    final wa = normalizeWa(adminWhatsapp.value);
    final url = Uri.parse("whatsapp://send?phone=$wa&text=");

    // trik untuk open WA dulu lalu user klik call manual
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Tidak bisa membuka WhatsApp';
    }
  }
}
