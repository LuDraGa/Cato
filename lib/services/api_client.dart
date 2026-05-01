import 'package:dio/dio.dart';

Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://localhost.invalid/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );
}
