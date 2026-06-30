import 'package:flutter/material.dart';

class AppTheme {
  // Mencegah class ini di-instansiasi secara langsung
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Menggunakan desain Material 3 terbaru [cite: 82]
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal, // Warna utama aplikasi adalah Teal [cite: 85]
        brightness: Brightness.light, // Tema terang [cite: 86]
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true, // Judul AppBar otomatis di tengah [cite: 88]
        elevation: 0, // Menghilangkan bayangan di bawah AppBar [cite: 89]
        backgroundColor: Colors.teal, // Warna latar belakang AppBar [cite: 90]
        foregroundColor: Colors.white, // Warna teks/ikon di AppBar [cite: 91]
      ),
    );
  }
}