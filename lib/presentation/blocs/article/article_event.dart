import 'package:flutter/foundation.dart';

@immutable
abstract class ArticleEvent {}

class FetchArticlesEvent extends ArticleEvent {}
