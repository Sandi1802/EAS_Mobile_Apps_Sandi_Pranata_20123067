import 'package:isar/isar.dart';
import '../../../core/error/exceptions.dart';
import '../../models/article_model.dart';

abstract class ArticleLocalDataSource {
  Future<List<ArticleModel>> getCachedArticles();
  Future<void> cacheArticles(List<ArticleModel> articles);
}

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  final Isar isar;

  ArticleLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    try {
      return await isar.articleModels.where().findAll();
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    try {
      await isar.writeTxn(() async {
        await isar.articleModels.clear(); // Hapus cache lama
        await isar.articleModels.putAll(articles); // Simpan cache baru
      });
    } catch (e) {
      throw DatabaseException();
    }
  }
}
