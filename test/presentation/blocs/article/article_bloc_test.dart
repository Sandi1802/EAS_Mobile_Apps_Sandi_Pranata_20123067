import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_apps/core/error/failures.dart';
import 'package:mobile_apps/core/usecases/usecase.dart';
import 'package:mobile_apps/domain/entities/article.dart';
import 'package:mobile_apps/domain/usecases/get_articles.dart';
import 'package:mobile_apps/presentation/blocs/article/article_bloc.dart';
import 'package:mobile_apps/presentation/blocs/article/article_event.dart';
import 'package:mobile_apps/presentation/blocs/article/article_state.dart';

class MockGetArticles extends Mock implements GetArticles {}

// Perlu mendaftarkan tipe fallback untuk NoParams agar any() bisa bekerja
class FakeNoParams extends Fake implements NoParams {}

void main() {
  late ArticleBloc bloc;
  late MockGetArticles mockGetArticles;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetArticles = MockGetArticles();
    bloc = ArticleBloc(getArticles: mockGetArticles);
  });

  tearDown(() {
    bloc.close();
  });

  group('ArticleBloc', () {
    // Dummy Article sudah menyertakan field url yang baru
    final tArticle = Article(
      title: 'Title',
      description: 'Desc',
      urlToImage: 'Img',
      publishedAt: 'Date',
      url: 'https://example.com',
    );
    final List<Article> tArticles = [tArticle];

    test('state awal harus ArticleInitial', () {
      expect(bloc.state, isA<ArticleInitial>());
    });

    test('harus memancarkan [ArticleLoading, ArticleLoaded] ketika data berhasil diambil', () async {
      // arrange — return type harus (Failure?, List<Article>?)
      when(() => mockGetArticles(any()))
          .thenAnswer((_) async => (null, tArticles) as (Failure?, List<Article>?));

      // assert later
      final expected = [
        isA<ArticleLoading>(),
        isA<ArticleLoaded>(),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(FetchArticlesEvent());
    });

    test('harus memancarkan [ArticleLoading, ArticleError] ketika terjadi kegagalan', () async {
      // arrange
      when(() => mockGetArticles(any()))
          .thenAnswer((_) async => (const ServerFailure('Server Error'), null));

      // assert later
      final expected = [
        isA<ArticleLoading>(),
        isA<ArticleError>(),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(FetchArticlesEvent());
    });
  });
}
