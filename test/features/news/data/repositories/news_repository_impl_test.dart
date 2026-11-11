import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/core/error/exceptions.dart';
import 'package:news_reader/core/error/failures.dart';
import 'package:news_reader/core/utils/result.dart';
import 'package:news_reader/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_reader/features/news/data/models/article_model.dart';
import 'package:news_reader/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_reader/features/news/domain/entities/article.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

void main() {
  late MockNewsRemoteDataSource dataSource;
  late NewsRepositoryImpl repository;

  final article = ArticleModel(
    id: 1,
    title: 'Test story',
    author: 'tester',
    score: 10,
    commentsCount: 2,
    publishedAt: DateTime.utc(2026, 11, 11),
    url: 'https://example.com',
  );

  setUp(() {
    dataSource = MockNewsRemoteDataSource();
    repository = NewsRepositoryImpl(dataSource);
  });

  void stubDataSource() => when(
        () => dataSource.getTopStories(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      );

  test('returns Success with articles', () async {
    stubDataSource().thenAnswer((_) async => [article]);

    final result = await repository.getTopStories();

    expect(result, isA<Success<List<Article>>>());
    expect((result as Success<List<Article>>).data, [article]);
  });

  test('maps NetworkException to NetworkFailure', () async {
    stubDataSource().thenThrow(const NetworkException('offline'));

    final result = await repository.getTopStories();

    expect(result, isA<Failed<List<Article>>>());
    expect((result as Failed<List<Article>>).failure, isA<NetworkFailure>());
  });

  test('maps ServerException to ServerFailure', () async {
    stubDataSource().thenThrow(const ServerException('500', statusCode: 500));

    final result = await repository.getTopStories();

    expect((result as Failed<List<Article>>).failure, isA<ServerFailure>());
  });

  test('maps unexpected errors to UnknownFailure', () async {
    stubDataSource().thenThrow(StateError('boom'));

    final result = await repository.getTopStories();

    expect((result as Failed<List<Article>>).failure, isA<UnknownFailure>());
  });
}
