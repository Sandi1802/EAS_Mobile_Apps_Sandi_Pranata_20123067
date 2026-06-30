import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_apps/core/error/exceptions.dart';
import 'package:mobile_apps/data/datasources/remote/article_remote_data_source.dart';
import 'package:mobile_apps/data/models/article_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ArticleRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = ArticleRemoteDataSourceImpl(dio: mockDio);
  });

  group('ArticleRemoteDataSource', () {
    final tArticleJson = {
      'title': 'Test Title',
      'description': 'Test Description',
      'urlToImage': 'https://image.com/test.jpg',
      'publishedAt': '2023-01-01T00:00:00Z',
    };

    final tResponse = {
      'status': 'ok',
      'articles': [tArticleJson]
    };

    test('harus mengembalikan List<ArticleModel> ketika response code 200 (sukses)', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tResponse,
          statusCode: 200,
        ),
      );

      // act
      final result = await dataSource.getArticles();

      // assert
      expect(result, isA<List<ArticleModel>>());
      expect(result.first.title, 'Test Title');
      verify(() => mockDio.get(any())).called(1);
    });

    test('harus melempar ServerException ketika response code bukan 200 (gagal)', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
          statusMessage: 'Not Found',
        ),
      );

      // act
      final call = dataSource.getArticles;

      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}
