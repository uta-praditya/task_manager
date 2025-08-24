import 'package:dio/dio.dart';

class HttpClient {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Dio createDio() {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));
  }
  
  static Dio createAuthenticatedDio(String token) {
    final dio = createDio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }
}