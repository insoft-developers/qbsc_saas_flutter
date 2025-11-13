import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/kandang_model.dart';

class KandangController extends GetxController {
  var kandangList = <KandangModel>[].obs;
  late Box<KandangModel> _kandangBox;

  @override
  void onInit() {
    super.onInit();
    _kandangBox = Hive.box<KandangModel>('kandang');
    loadKandangs();

    // auto listen perubahan di Hive
    _kandangBox.watch().listen((event) {
      loadKandangs();
    });
  }

  void loadKandangs() {
    kandangList.value = _kandangBox.values.toList();
  }
}
