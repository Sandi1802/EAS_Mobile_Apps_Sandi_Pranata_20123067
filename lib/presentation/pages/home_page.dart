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
    // Membaca flavor
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    return BlocProvider(
      create: (_) => sl<ArticleBloc>()..add(FetchArticlesEvent()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'DigiNews',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: flavor == 'prod' ? Colors.amber : Colors.greenAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                flavor.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                context.push('/profile');
              },
            ),
          ],
        ),
        body: BlocBuilder<ArticleBloc, ArticleState>(
          builder: (context, state) {
            if (state is ArticleLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ArticleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ArticleBloc>().add(FetchArticlesEvent());
                      },
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              );
            } else if (state is ArticleLoaded) {
              final articles = state.articles;
              if (articles.isEmpty) {
                return const Center(child: Text('Tidak ada berita.'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ArticleBloc>().add(FetchArticlesEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: articles[index]);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
