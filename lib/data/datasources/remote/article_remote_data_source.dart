import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;

  ArticleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ArticleModel>> getArticles() async {
    try {
      // Menggunakan API gratis NewsAPI. Endpoint top-headlines.
      // API Key sebaiknya disembunyikan, namun untuk contoh diletakkan di sini.
      final response = await dio.get('top-headlines?country=us&apiKey=YOUR_API_KEY');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['articles'];
        // Filter artikel yang removed atau title-nya kosong
        return jsonList
            .where((json) => json['title'] != null && json['title'] != '[Removed]')
            .map((json) => ArticleModel.fromJson(json))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
