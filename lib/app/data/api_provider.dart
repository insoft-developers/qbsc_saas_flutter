import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class ApiProvider extends GetxService {
  static const String rootUrl = "http://192.168.100.3:8000";
  static const String imageUrl = "$rootUrl/storage";
  static const String baseUrl = "$rootUrl/api";
  late dio.Dio _dio;

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

    if (kDebugMode) {
      _dio.interceptors.add(
        dio.LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return this;
  }

  dio.Dio get client => _dio;

  Future<dio.Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: query);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dio.DioException e) {
    if (e.response != null) {
      return Exception("Error ${e.response?.statusCode}: ${e.response?.data}");
    } else {
      return Exception("Network error: ${e.message}");
    }
  }
}
