import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/location_model.dart';

class LokasiReportController extends GetxController {
  late Box<LocationModel> lokasiBox;

  var lokasiList = <LocationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    lokasiBox = Hive.box<LocationModel>('locations');
    loadLokasi();

    lokasiBox.listenable().addListener(loadLokasi);
  }

  void loadLokasi() {
    final list = lokasiBox.values.toList()
      ..sort((a, b) => a.namaLokasi.compareTo(b.namaLokasi));
    lokasiList.value = list;
  }

  @override
  void onClose() {
    lokasiBox.listenable().removeListener(loadLokasi);
    super.onClose();
  }
}
