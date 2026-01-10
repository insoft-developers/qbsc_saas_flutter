import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/location_model.dart';
import 'package:qbsc_saas/app/views/jadwal/patroli/jadwal_patroli_model.dart';

class JadwalPatroliController extends GetxController {
  late Box<JadwalPatroliModel> jadwalBox;
  late Box<LocationModel> lokasiBox;

  var jadwalPatroliList = <JadwalPatroliModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    jadwalBox = Hive.box<JadwalPatroliModel>('jadwal_patroli');
    lokasiBox = Hive.box<LocationModel>('locations');
    loadJadwalPatroli();

    jadwalBox.listenable().addListener(loadJadwalPatroli);
  }

  String getNamaLokasi(String locationId) {
    try {
      final lokasi = lokasiBox.values.firstWhere(
        (loc) => loc.id.toString() == locationId,
      );
      return lokasi.namaLokasi;
    } catch (_) {
      return '-';
    }
  }

  void loadJadwalPatroli() {
    final list = jadwalBox.values.toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
    jadwalPatroliList.value = list;
  }

  @override
  void onClose() {
    jadwalBox.listenable().removeListener(loadJadwalPatroli);
    super.onClose();
  }
}
