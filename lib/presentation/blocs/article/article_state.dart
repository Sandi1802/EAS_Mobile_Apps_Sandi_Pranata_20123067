import 'package:flutter/foundation.dart';
import '../../../domain/entities/article.dart';

@immutable
abstract class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;

  ArticleLoaded({required this.articles});
}

class ArticleError extends ArticleState {
  final String message;

  ArticleError({required this.message});
}
