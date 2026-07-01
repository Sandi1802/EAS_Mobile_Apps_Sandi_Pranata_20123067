import '../../domain/entities/article.dart';
import 'package:isar/isar.dart';

part 'article_model.g.dart'; // Dibutuhkan untuk Isar

@collection
class ArticleModel {
  Id id = Isar.autoIncrement; // Isar ID

  late String title;
  late String description;
  late String urlToImage;
  late String publishedAt;
  late String url; // URL ke artikel asli

  ArticleModel();

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final model = ArticleModel()
      ..title = json['title'] ?? 'No Title'
      ..description = json['description'] ?? 'No Description'
      ..urlToImage = json['urlToImage'] ?? ''
      ..publishedAt = json['publishedAt'] ?? ''
      ..url = json['url'] ?? '';
    return model;
  }

  Article toEntity() {
    return Article(
      title: title,
      description: description,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      url: url,
    );
  }
}
