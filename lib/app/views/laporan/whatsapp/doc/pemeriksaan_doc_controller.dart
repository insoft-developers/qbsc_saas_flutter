import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/doc/pemeriksaan_doc_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PemeriksaanDocController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<PemeriksaanDocModel> waDocList = <PemeriksaanDocModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> loadDoc(tanggal) async {
    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.whatsappDoc,
        data: {'comid': comid, 'satpam_id': satpamId, 'tanggal': tanggal},
      );
      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        waDocList.value = listData
            .map((json) => PemeriksaanDocModel.fromJson(json))
            .toList();
      } else {
        SnackbarHelper.error('Warning', 'Data tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.error('Warning', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shareAllDocToWhatsApp(
    List<PemeriksaanDocModel> docs,
    String tanggal,
  ) async {
    await initializeDateFormatting('id_ID', null);

    String pesan = 'PEMERIKSAAN DOC\n\n';

    for (var doc in docs) {
      DateTime dt = DateTime.parse(doc.tanggal);
      String tanggalFormat = DateFormat('d MMMM yyyy', 'id_ID').format(dt);

      pesan += 'Hari    : ${doc.hari}\n';
      pesan += 'Tanggal : $tanggalFormat\n';
      pesan += 'Supir   : ${doc.supir}\n';
      pesan += 'NoPol   : ${doc.noPolisi}\n';
      pesan += 'Ekpdsi  : ${doc.ekspedisi}\n';
      pesan += 'Tujuan  : ${doc.tujuan}\n';

      pesan += 'DETAIL BOX:\n';
      for (var box in doc.boxes) {
        if (box.jumlahBox == '0') continue;
        pesan +=
            '- ${box.name}: ${box.jumlahBox} box × ${box.isi} = ${box.totalEkor}\n';
      }

      pesan +=
          'TOTAL : ${_formatNumber(doc.jumlahBox)} box | ${_formatNumber(doc.totalEkor)} ekor\n';
      pesan += 'SEGEL : ${doc.nomorSegel}\n';

      if (doc.note.isNotEmpty) {
        pesan += 'Catatan: ${doc.note}\n';
      }

      if (doc.fotos.isNotEmpty) {
        pesan += 'Foto:\n';
        for (var foto in doc.fotos) {
          pesan += '${ApiProvider.imageUrl}/$foto\n';
        }
      }

      pesan += '----------------------\n\n';
    }

    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(pesan)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak bisa membuka WhatsApp');
    }
  }

  String _formatNumber(int value) {
    return NumberFormat('#,###', 'id_ID').format(value);
  }
}
