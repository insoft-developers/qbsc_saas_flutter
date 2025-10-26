import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ApiProvider extends GetxService {
  // Base URL statis (bisa diganti kapan saja kalau perlu)
  static const String baseUrl = "https://example.com/api";

  late dio.Dio _dio;

  // Inisialisasi Dio
  Future<ApiProvider> init() async {
    dio.BaseOptions options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio = dio.Dio(options);

    // Tambahkan Interceptor untuk debugging
    _dio.interceptors.add(
      dio.LogInterceptor(requestBody: true, responseBody: true),
    );

    return this;
  }

  // GET request
  Future<dio.Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: query);
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dio.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler sederhana
  Exception _handleError(dio.DioException e) {
    if (e.response != null) {
      return Exception("Error ${e.response?.statusCode}: ${e.response?.data}");
    } else {
      return Exception("Network error: ${e.message}");
    }
  }
}
