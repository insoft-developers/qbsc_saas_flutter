import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';
import 'package:qbsc_saas/app/views/laporan/whatsapp/patroli/patroli_wa_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PatroliWaController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<PatroliWaModel> waPatroliList = <PatroliWaModel>[].obs;

  final ApiProvider api = Get.find<ApiProvider>();

  Future<void> loadPatroli(tanggal) async {
    isLoading.value = true;
    int comid = int.parse(AppPrefs.getComId() ?? '0');
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.whatsappPatroli,
        data: {'comid': comid, 'satpam_id': satpamId, 'tanggal': tanggal},
      );
      var body = response.data;
      if (body['success']) {
        final List<dynamic> listData = body['data'];
        waPatroliList.value = listData
            .map((json) => PatroliWaModel.fromJson(json))
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

  Future<void> shareAllpatToWhatsApp(
    List<PatroliWaModel> patrolis,
    String tanggal,
  ) async {
    await initializeDateFormatting('id_ID', null);

    String pesan = 'LAPORAN PATROLI\n\n';

    for (var pat in patrolis) {
      DateTime dt = DateTime.parse(pat.tanggal);
      String tanggalFormat = DateFormat('d MMMM yyyy', 'id_ID').format(dt);

      pesan += 'Hari    : ${pat.hari}\n';
      pesan += 'Tanggal : $tanggalFormat - ${pat.jam}\n';
      pesan += 'Lokasi   : ${pat.locationName}\n';
      pesan += 'Jadwal   : ${pat.jamAwalPatroli} - ${pat.jamAkhirPatroli}\n';
      pesan += 'Map   : ${pat.locationUrl}\n';

      if (pat.note.isNotEmpty) {
        pesan += 'Catatan: ${pat.note}\n';
      }

      if (pat.foto.isNotEmpty) {
        pesan += 'Foto:\n';
        pesan += '${ApiProvider.imageUrl}/${pat.foto}\n';
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
