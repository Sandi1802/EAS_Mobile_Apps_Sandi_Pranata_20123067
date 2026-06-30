import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_apps/core/error/exceptions.dart';
import 'package:mobile_apps/data/datasources/local/article_local_data_source.dart';
import 'package:mobile_apps/data/datasources/remote/article_remote_data_source.dart';
import 'package:mobile_apps/data/models/article_model.dart';
import 'package:mobile_apps/data/repositories/article_repository_impl.dart';

class MockRemoteDataSource extends Mock implements ArticleRemoteDataSource {}
class MockLocalDataSource extends Mock implements ArticleLocalDataSource {}

void main() {
  late ArticleRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = ArticleRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('ArticleRepositoryImpl', () {
    final tArticleModel1 = ArticleModel()..title = 'A Title';
    final tArticleModel2 = ArticleModel()..title = 'Z Title';
    final tArticleModels = [tArticleModel2, tArticleModel1]; // Unsorted

    test('harus mengembalikan data dari remote dan menyimpannya ke local', () async {
      // arrange
      when(() => mockRemoteDataSource.getArticles())
          .thenAnswer((_) async => tArticleModels);
      when(() => mockLocalDataSource.cacheArticles(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.getArticles();

      // assert
      verify(() => mockRemoteDataSource.getArticles()).called(1);
      verify(() => mockLocalDataSource.cacheArticles(tArticleModels)).called(1);
      
      // Pada saat testing, PROD_NIM secara default adalah '0' (Genap),
      // Maka akan disorting secara Ascending (A-Z).
      expect(result.$2![0].title, 'A Title');
      expect(result.$2![1].title, 'Z Title');
    });

    test('harus mengambil data dari local (Isar) ketika remote melempar ServerException (Offline)', () async {
      // arrange
      when(() => mockRemoteDataSource.getArticles())
          .thenThrow(ServerException());
      when(() => mockLocalDataSource.getCachedArticles())
          .thenAnswer((_) async => tArticleModels);

      // act
      final result = await repository.getArticles();

      // assert
      verify(() => mockRemoteDataSource.getArticles()).called(1);
      verify(() => mockLocalDataSource.getCachedArticles()).called(1);
      
      // Tetap ter-sorting A-Z
      expect(result.$2![0].title, 'A Title');
    });
  });
}
