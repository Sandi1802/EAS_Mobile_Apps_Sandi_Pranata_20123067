import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart' as di;
import 'core/route/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const String devName = String.fromEnvironment('DEV_NAME', defaultValue: 'Dev');
    const String prodNim = String.fromEnvironment('PROD_NIM', defaultValue: '20123067');

    final String appTitle = flavor == 'prod' ? 'UTD - $prodNim' : 'DEV - $devName';

    // PROD: Biru Gelap (sesuai spesifikasi PDF)
    // DEV: Indigo/ungu profesional
    final Color seedColor = flavor == 'prod'
        ? const Color(0xFF0A1628) // Dark Navy Blue untuk PROD
        : const Color(0xFF3F51B5); // Indigo untuk DEV

    return MaterialApp.router(
      title: appTitle,
      // Hilangkan banner DEBUG di pojok kanan atas
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        // Gunakan Google Fonts agar tampilan lebih profesional
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}