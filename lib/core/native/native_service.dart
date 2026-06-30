import 'package:flutter/services.dart';

class NativeService {
  // Pastikan nama channel SAMA PERSIS dengan yang ada di MainActivity.kt
  static const MethodChannel _channel = MethodChannel('com.diginews.native/channel');

  /// Mengirimkan String NIM ke Kotlin untuk dibalik.
  /// Menerima kembali hasil (String) dari Kotlin.
  Future<String> reverseNim(String nim) async {
    try {
      final String result = await _channel.invokeMethod('reverseString', {'nim': nim});
      return result;
    } on PlatformException catch (e) {
      throw Exception("Gagal membalikkan NIM: '${e.message}'.");
    }
  }

  /// Mengirimkan perintah ke Kotlin untuk menampilkan Native Toast.
  Future<void> showToast(String message) async {
    try {
      await _channel.invokeMethod('showToast', {'message': message});
    } on PlatformException catch (e) {
      throw Exception("Gagal menampilkan toast: '${e.message}'.");
    }
  }
}
