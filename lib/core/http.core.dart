import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpClient {
  static final HttpClient _httpClient = HttpClient._();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static const _storage = FlutterSecureStorage();

  HttpClient._();

  factory HttpClient() => _httpClient;

  Future<void> authorize() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _dio.interceptors.clear();
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
        ),
      );
    }
  }

  Future<void> unauthorize() async {
    await _storage.delete(key: 'access_token');
    _dio.interceptors.clear();
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(url, queryParameters: queryParams);
  }

  Future<Response> post(String url, {Map<String, dynamic>? data}) async {
    return await _dio.post(url, data: data);
  }

  Future<Response> patch(String url, {Map<String, dynamic>? data}) async {
    return await _dio.patch(url, data: data);
  }

  Future<Response> delete(String url) async {
    return await _dio.delete(url);
  }
}
