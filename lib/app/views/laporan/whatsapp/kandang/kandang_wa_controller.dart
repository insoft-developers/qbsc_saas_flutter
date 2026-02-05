import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/kandang/kandang_wa_model.dart';
import 'package:url_launcher/url_launcher.dart';

class KandangWaController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<KandangWaModel> waKandangList = <KandangWaModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> ambilDataWhatsapp(tanggal, jam) async {
    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.whatsappKandang,
        data: {
          'comid': comid,
          'satpam_id': satpamId,
          'tanggal': tanggal,
          'jam': jam,
        },
      );
      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        waKandangList.value = listData
            .map((json) => KandangWaModel.fromJson(json))
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

  Future<void> shareToWhatsAppCompact(
    List<KandangWaModel> list,
    String hari,
    String tanggalYMD,
    String jam,
  ) async {
    if (list.isEmpty) return;

    await initializeDateFormatting('id_ID', null);

    DateTime dt = DateTime.parse(tanggalYMD);
    String tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    String namaHari = DateFormat('EEEE', 'id_ID').format(dt);

    String pesan = 'LAPORAN KONTROL SUHU,KIPAS,ALARM,LAMPU\n';
    pesan += 'Hari: $namaHari\n';
    pesan += 'Tanggal: $tanggal\n';
    pesan += 'Jam: $jam\n\n';

    /// ======================
    /// DATA KANDANG
    /// ======================
    for (var k in list) {
      if ((k.suhu == '-' || k.suhu.isEmpty) &&
          (k.kipas == '-' || k.kipas.isEmpty) &&
          (k.alarm == '-' || k.alarm.isEmpty) &&
          (k.lampu == '-' || k.lampu.isEmpty)) {
        continue;
      }

      final kipasClean = k.kipas.replaceAll(',', '');
      pesan += '${k.name}= ${k.suhu}|$kipasClean|${k.alarm}|${k.lampu}\n';
    }

    /// ======================
    /// LINK GAMBAR (DI BAWAH)
    /// ======================
    pesan += '\nFOTO KANDANG:\n';

    for (var k in list) {
      if (k.kipasImage.isNotEmpty) {
        pesan += '${k.name}: ${k.kipasImage}\n';
      }
    }

    final Uri url = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(pesan)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak bisa membuka WhatsApp');
    }
  }
}
