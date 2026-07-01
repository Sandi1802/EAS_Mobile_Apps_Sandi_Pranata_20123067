import 'package:dio/dio.dart';
import 'dio_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        // Menggunakan Mock API yang berformat persis seperti NewsAPI agar tidak perlu API Key
        // Ini memastikan aplikasi berjalan 100% tanpa error 401 Unauthorized
        baseUrl: 'https://saurav.tech/NewsAPI/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Menambahkan custom interceptor
    dio.interceptors.add(DioInterceptor());
  }
}
