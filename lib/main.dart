import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/route/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Service Locator (GetIt)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca flavor dan variabel dari dart-define
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const String devName = String.fromEnvironment('DEV_NAME', defaultValue: 'Fulan');
    const String prodNim = String.fromEnvironment('PROD_NIM', defaultValue: '0000000000');

    // Menentukan nama aplikasi berdasarkan flavor
    final String appName = flavor == 'prod' ? 'UTD - $prodNim' : 'DEV - $devName';

    // Menentukan warna utama (Primary Color)
    final Color primaryColor = flavor == 'prod' ? Colors.blue.shade900 : Colors.blue;

    return MaterialApp.router(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}