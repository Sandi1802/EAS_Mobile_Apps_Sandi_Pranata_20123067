import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/local/article_local_data_source.dart';
import '../datasources/remote/article_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;
  final ArticleLocalDataSource localDataSource;

  ArticleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(Failure?, List<Article>?)> getArticles() async {
    List<ArticleModel> models = [];
    try {
      // 1. Coba ambil dari Remote
      models = await remoteDataSource.getArticles();
      // 2. Simpan ke Local (Cache)
      await localDataSource.cacheArticles(models);
    } on ServerException {
      try {
        // 3. Jika Remote gagal (offline), ambil dari Local
        models = await localDataSource.getCachedArticles();
        if (models.isEmpty) {
          return (const DatabaseFailure('Tidak ada data cache yang tersedia. Pastikan ada koneksi internet untuk fetch pertama.'), null);
        }
      } on DatabaseException {
        return (const DatabaseFailure('Gagal membaca data dari lokal database.'), null);
      }
    }

    // Mengambil NIM dari dart-define untuk kebutuhan sorting. Default '0' jika tidak ada.
    const String prodNim = String.fromEnvironment('PROD_NIM', defaultValue: '0');
    
    // Mendapatkan digit terakhir
    int lastDigit = 0;
    if (prodNim.isNotEmpty) {
      final lastChar = prodNim.substring(prodNim.length - 1);
      lastDigit = int.tryParse(lastChar) ?? 0;
    }

    // Melakukan Sorting di Repository (Sesuai aturan)
    // Aturan yang saya tetapkan:
    // Jika ganjil -> urutkan judul dari Z-A (Descending)
    // Jika genap -> urutkan judul dari A-Z (Ascending)
    
    if (lastDigit % 2 != 0) {
      // Ganjil: Descending
      models.sort((a, b) => b.title.compareTo(a.title));
    } else {
      // Genap: Ascending
      models.sort((a, b) => a.title.compareTo(b.title));
    }

    // Mapping Model ke Entity
    final entities = models.map((model) => model.toEntity()).toList();

    return (null, entities);
  }
}
