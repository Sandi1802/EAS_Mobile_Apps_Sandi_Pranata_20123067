import 'package:dio/dio.dart';
import 'dio_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        // Kita menggunakan NewsAPI gratis sebagai contoh (bisa diganti sesuai kebutuhan)
        baseUrl: 'https://newsapi.org/v2/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Menambahkan custom interceptor
    dio.interceptors.add(DioInterceptor());
  }
}
