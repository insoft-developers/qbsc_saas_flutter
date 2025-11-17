import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qbsc_saas/app/models/doc_model.dart';
import 'package:qbsc_saas/app/models/ekspedisi_model.dart';

class DocReportController extends GetxController {
  late Box<DocModel> docBox;

  var docList = <DocModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    docBox = Hive.box<DocModel>('doc');
    loadData();

    docBox.listenable().addListener(loadData);
  }

  void loadData() {
    final list = docBox.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    docList.value = list;
  }

  @override
  void onClose() {
    docBox.listenable().removeListener(loadData);
    super.onClose();
  }
}
