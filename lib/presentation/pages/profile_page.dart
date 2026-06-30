import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/di/injection_container.dart';
import '../../core/native/native_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _clickCount = 0;
  bool _isLottiePlaying = false;
  
  late String _prodNim;
  late int _targetClicks;
  late String _flavor;
  late String _devName;

  @override
  void initState() {
    super.initState();
    // Mengambil nilai environment variables
    _flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    _devName = const String.fromEnvironment('DEV_NAME', defaultValue: 'Fulan');
    _prodNim = const String.fromEnvironment('PROD_NIM', defaultValue: '0000000000');

    // Menentukan target klik dari digit terakhir NIM
    if (_prodNim.isNotEmpty) {
      final lastChar = _prodNim.substring(_prodNim.length - 1);
      _targetClicks = int.tryParse(lastChar) ?? 0;
    } else {
      _targetClicks = 0;
    }

    // Jika digit terakhir adalah 0, kita jadikan 10 klik (karena 0 klik tidak mungkin 트리거)
    if (_targetClicks == 0) {
      _targetClicks = 10;
    }
  }

  void _onPhotoTapped() async {
    if (_isLottiePlaying) return;

    setState(() {
      _clickCount++;
    });

    if (_clickCount >= _targetClicks) {
      // Reset hitungan
      _clickCount = 0;
      
      // Tampilkan animasi fullscreen
      _playLottieAndTriggerNative();
    }
  }

  Future<void> _playLottieAndTriggerNative() async {
    setState(() {
      _isLottiePlaying = true;
    });

    // Menampilkan Dialog Lottie Fullscreen (Barrier Dismissible false)
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        return Center(
          // Gunakan aset lottie gratis dari url atau assets. 
          // Di sini menggunakan URL sebagai contoh agar praktis.
          child: Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json', 
            width: 300,
            height: 300,
            repeat: true,
          ),
        );
      },
    );

    // Tunggu 3 detik sesuai spesifikasi
    await Future.delayed(const Duration(seconds: 3));

    // Tutup dialog lottie
    if (mounted) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLottiePlaying = false;
    });

    // --- MENGGUNAKAN METHOD CHANNEL NATIVE ---
    try {
      final nativeService = sl<NativeService>();
      
      // 1. Flutter mengirim NIM ke Kotlin dan menerima balikan String yang dibalik
      final reversedNim = await nativeService.reverseNim(_prodNim);
      
      // 2. Flutter menyuruh Kotlin menampilkan Toast menggunakan String yang dibalik tersebut
      await nativeService.showToast("NIM Dibalik: $reversedNim");
    } catch (e) {
      // Jika terjadi error (misalnya dijalankan di iOS / Desktop yang belum di-setup)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About / Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _onPhotoTapped,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://avatars.githubusercontent.com/u/1?v=4', // Placeholder Profile Picture
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_clickCount > 0)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_clickCount / $_targetClicks',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _flavor == 'prod' ? 'Mahasiswa' : 'Developer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _flavor == 'prod' ? 'NIM: $_prodNim' : 'Nama: $_devName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Klik foto profil berkali-kali untuk melihat easter egg animasi Lottie dan memicu Native Toast MethodChannel!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
