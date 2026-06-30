import '../../core/error/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<(Failure?, List<Article>?)> getArticles();
}
