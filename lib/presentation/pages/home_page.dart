import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection_container.dart';
import '../blocs/article/article_bloc.dart';
import '../blocs/article/article_event.dart';
import '../blocs/article/article_state.dart';
import '../widgets/article_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const String devName = String.fromEnvironment('DEV_NAME', defaultValue: 'Dev');
    const String prodNim = String.fromEnvironment('PROD_NIM', defaultValue: '');

    final String subtitle = flavor == 'prod' ? 'UTD - $prodNim' : 'DEV - $devName';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Warna AppBar sesuai flavor
    final Color navyBlue = flavor == 'prod'
        ? const Color(0xFF0A1628)
        : const Color(0xFF3F51B5);

    return BlocProvider(
      create: (_) => sl<ArticleBloc>()..add(FetchArticlesEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              // Tombol profile di kanan atas
              actions: [
                _FlavorBadge(flavor: flavor),
                IconButton(
                  icon: const Icon(Icons.account_circle_rounded, size: 28),
                  tooltip: 'Profil',
                  onPressed: () => context.push('/profile'),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DigiNews',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: flavor == 'prod'
                          ? [const Color(0xFF0A1628), const Color(0xFF1A3A6B)]
                          : [const Color(0xFF3F51B5), const Color(0xFF5C6BC0)],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.newspaper_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: BlocBuilder<ArticleBloc, ArticleState>(
            builder: (context, state) {
              if (state is ArticleLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat berita terkini...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              } else if (state is ArticleError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<ArticleBloc>().add(FetchArticlesEvent()),
                );
              } else if (state is ArticleLoaded) {
                final articles = state.articles;
                if (articles.isEmpty) {
                  return const Center(child: Text('Tidak ada berita tersedia.'));
                }
                return RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: () async {
                    context.read<ArticleBloc>().add(FetchArticlesEvent());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    itemCount: articles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Header section
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Text(
                                'Berita Terbaru',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${articles.length} artikel',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ArticleCard(article: articles[index - 1]);
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

/// Badge DEV / PROD di AppBar
class _FlavorBadge extends StatelessWidget {
  final String flavor;
  const _FlavorBadge({required this.flavor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: flavor == 'prod'
              ? const Color(0xFFFFD700) // Gold untuk PROD
              : const Color(0xFF00E676), // Green untuk DEV
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          flavor.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

/// Widget tampilan error yang informatif
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 56, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Koneksi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
