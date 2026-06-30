import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_articles.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticles getArticles;

  ArticleBloc({required this.getArticles}) : super(ArticleInitial()) {
    on<FetchArticlesEvent>((event, emit) async {
      emit(ArticleLoading());

      final result = await getArticles(NoParams());
      final failure = result.$1;
      final data = result.$2;

      if (failure != null) {
        emit(ArticleError(message: failure.message));
      } else if (data != null) {
        emit(ArticleLoaded(articles: data));
      } else {
        emit(ArticleError(message: 'Unknown Error'));
      }
    });
  }
}
