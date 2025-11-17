import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';
import 'package:qbsc_saas/app/models/location_model.dart';

class EkspedisiReportController extends GetxController {
  late Box<EkspedisiModel> ekspedisiBox;

  var ekspedisiList = <EkspedisiModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ekspedisiBox = Hive.box<EkspedisiModel>('ekspedisi');
    loadEkspedisi();

    ekspedisiBox.listenable().addListener(loadEkspedisi);
  }

  void loadEkspedisi() {
    final list = ekspedisiBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    ekspedisiList.value = list;
  }

  @override
  void onClose() {
    ekspedisiBox.listenable().removeListener(loadEkspedisi);
    super.onClose();
  }
}
