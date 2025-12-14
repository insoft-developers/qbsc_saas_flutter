import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/snackbar_helper.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = <String, dynamic>{}.obs;

  final imagePath = "".obs; // foto lokal kamera
  final api = Get.find<ApiProvider>();

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }

  Future<void> getProfileData() async {
    isLoading.value = true;
    int satpamId = int.parse(AppPrefs.getUserId() ?? '0');

    try {
      final response = await api.post(
        ApiEndpoint.getProfileData,
        data: {"satpam_id": satpamId},
      );

      if (response.data['success']) {
        profileData.value = response.data['data'];
      } else {
        SnackbarHelper.error("Warning", "Data tidak ditemukan");
      }
    } catch (e) {
      SnackbarHelper.error("Warning", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile(String name, String whatsapp) async {
    isLoading.value = true;

    try {
      final FormData formData = FormData.fromMap({
        "satpam_id": profileData['id'],
        "name": name,
        "whatsapp": whatsapp,
      });

      final response = await api.post(
        ApiEndpoint.updateSatpamProfile,
        data: formData,
      );

      if (response.data['success']) {
        SnackbarHelper.success("Sukses", "Profil berhasil diperbarui");
        getProfileData();
      } else {
        SnackbarHelper.error("Gagal", response.data['message']);
      }
    } catch (e) {
      SnackbarHelper.error("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
