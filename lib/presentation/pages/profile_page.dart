import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../core/di/injection_container.dart';
import '../../core/native/native_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  int _clickCount = 0;
  bool _isLottiePlaying = false;

  // Data mahasiswa - hardcoded agar DEV dan PROD sama-sama berfungsi
  static const String _nim = '20123067';
  static const String _nama = 'Sandi Pranata';
  static const String _prodi = 'Teknik Informatika';
  static const String _semester = 'Semester 6';
  static const String _email = 'sandi.pranata@student.utd.ac.id';

  late String _flavor;
  late String _prodNim;
  late int _targetClicks;

  // Animasi untuk efek "ripple" saat foto diklik
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    _prodNim = const String.fromEnvironment('PROD_NIM', defaultValue: _nim);

    final lastChar = _prodNim.substring(_prodNim.length - 1);
    _targetClicks = int.tryParse(lastChar) ?? 7;
    if (_targetClicks == 0) _targetClicks = 10;

    // Animasi denyut (pulse) pada border foto profil
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animasi scale saat foto ditekan
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPhotoTapped() {
    if (_isLottiePlaying) return;

    // Animasi scale saat tap (tanpa await agar state langsung terupdate saat tap cepat)
    _scaleController.forward().then((_) => _scaleController.reverse());

    // Getaran haptic ringan
    HapticFeedback.lightImpact();

    setState(() => _clickCount++);

    if (_clickCount >= _targetClicks) {
      setState(() => _clickCount = 0);
      _playLottieAndTriggerNative();
    }
  }

  Future<void> _playLottieAndTriggerNative() async {
    setState(() => _isLottiePlaying = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => _LottieDialog(),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) Navigator.of(context).pop();
    setState(() => _isLottiePlaying = false);

    try {
      final nativeService = sl<NativeService>();
      final reversedNim = await nativeService.reverseNim(_prodNim);
      await nativeService.showToast('NIM Dibalik: $reversedNim');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Native Error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isProd = _flavor == 'prod';

    final Color primaryDark = isProd
        ? const Color(0xFF0A1628)
        : const Color(0xFF283593);
    final Color primaryLight = isProd
        ? const Color(0xFF1A3A6B)
        : const Color(0xFF3F51B5);
    final Color accent = isProd
        ? const Color(0xFF4A90D9)
        : const Color(0xFF7986CB);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ════════════════════════════════════════
          // HEADER — Gradient dramatis dengan foto profil besar
          // ════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryDark, primaryLight, accent.withOpacity(0.8)],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Lingkaran dekoratif di background
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  // Konten header: foto + nama
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Foto Profil dengan animasi pulse + tap scale ──
                          GestureDetector(
                            onTap: _onPhotoTapped,
                            child: AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_pulseAnimation, _scaleAnimation]),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Cincin luar (pulse)
                                      Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          width: 148,
                                          height: 148,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Cincin dalam dengan gradient
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.9),
                                              accent.withOpacity(0.7),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  primaryDark.withOpacity(0.5),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 60,
                                          backgroundColor: primaryLight,
                                          backgroundImage: const NetworkImage(
                                            'https://ui-avatars.com/api/?name=Sandi+Pranata&size=240&background=1A3A6B&color=fff&bold=true&font-size=0.4',
                                          ),
                                        ),
                                      ),
                                      // Badge progres klik
                                      if (_clickCount > 0)
                                        Positioned(
                                          bottom: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              '$_clickCount / $_targetClicks 👆',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nama
                          Text(
                            _nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // NIM Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              'NIM: $_nim',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ════════════════════════════════════════
          // BODY — Konten informasi
          // ════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Row ──
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.touch_app_rounded,
                        label: 'Target Klik',
                        value: '$_targetClicks×',
                        color: accent,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.layers_rounded,
                        label: 'Semester',
                        value: '6',
                        color: isProd ? const Color(0xFF1A3A6B) : const Color(0xFF3F51B5),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.developer_mode_rounded,
                        label: 'Mode',
                        value: _flavor.toUpperCase(),
                        color: isProd ? Colors.amber.shade700 : Colors.green.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Info Akademik ──
                  _SectionTitle(title: 'Informasi Akademik'),
                  const SizedBox(height: 12),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'Nama Lengkap',
                      value: _nama,
                      color: primaryLight,
                    ),
                    _InfoRow(
                      icon: Icons.badge_rounded,
                      label: 'NIM',
                      value: _nim,
                      color: primaryLight,
                    ),
                    _InfoRow(
                      icon: Icons.school_rounded,
                      label: 'Program Studi',
                      value: _prodi,
                      color: primaryLight,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Semester',
                      value: _semester,
                      color: primaryLight,
                    ),
                    _InfoRow(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: _email,
                      color: primaryLight,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── Tech Stack ──
                  _SectionTitle(title: 'Tech Stack Aplikasi'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Flutter', 'Clean Architecture', 'BLoC',
                      'Isar DB', 'Dio', 'go_router',
                      'get_it', 'MethodChannel', 'Mocktail',
                      'Kotlin', 'GitHub Actions',
                    ].map((tech) => _TechChip(label: tech, color: primaryLight)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Easter Egg Hint ──
                  _EasterEggCard(
                    targetClicks: _targetClicks,
                    isProd: isProd,
                    accent: accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════
// Dialog Lottie Fullscreen
// ════════════════════════════════════
class _LottieDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
            width: 280,
            height: 280,
            repeat: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              '🎉  Easter Egg Unlocked!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mengirim NIM ke Kotlin...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TechChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EasterEggCard extends StatelessWidget {
  final int targetClicks;
  final bool isProd;
  final Color accent;

  const _EasterEggCard({
    required this.targetClicks,
    required this.isProd,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.12),
            accent.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '🔐',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Easter Egg Rahasia',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap foto profil sebanyak $targetClicks kali berturut-turut untuk memicu animasi Lottie + Native Toast! 🎉',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
