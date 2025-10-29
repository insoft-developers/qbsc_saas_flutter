import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:qbsc_saas/app/data/api_endpoint.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:camera/camera.dart'; // supaya bisa pakai XFile

class FaceService extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<void> verifyFace(XFile imageFile) async {
    try {
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      final response = await _api.client.post(
        ApiEndpoint.verifyFace,
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        print("Verification Result: ${response.data}");
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Face verification failed: $e");
    }
  }
}
