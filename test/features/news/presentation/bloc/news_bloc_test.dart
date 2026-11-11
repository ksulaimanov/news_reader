import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/core/error/failures.dart';
import 'package:news_reader/core/utils/result.dart';
import 'package:news_reader/features/news/domain/entities/article.dart';
import 'package:news_reader/features/news/domain/usecases/get_top_stories.dart';
import 'package:news_reader/features/news/presentation/bloc/news_bloc.dart';
import 'package:news_reader/features/news/presentation/bloc/news_event.dart';
import 'package:news_reader/features/news/presentation/bloc/news_state.dart';

class MockGetTopStories extends Mock implements GetTopStories {}

void main() {
  late MockGetTopStories getTopStories;

  final article1 = Article(
    id: 1,
    title: 'First',
    author: 'a',
    score: 10,
    commentsCount: 1,
    publishedAt: DateTime.utc(2026, 11, 11),
  );
  final article2 = Article(
    id: 2,
    title: 'Second',
    author: 'b',
    score: 20,
    commentsCount: 2,
    publishedAt: DateTime.utc(2026, 11, 11),
  );

  setUp(() {
    getTopStories = MockGetTopStories();
  });

  group('NewsStarted', () {
    blocTest<NewsBloc, NewsState>(
      'emits [loading, success] when loading succeeds',
      build: () {
        when(() => getTopStories(page: 0)).thenAnswer(
          (_) async => Success<List<Article>>([article1]),
        );
        return NewsBloc(getTopStories);
      },
      act: (bloc) => bloc.add(const NewsStarted()),
      expect: () => [
        const NewsState(status: NewsStatus.loading),
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
        ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'emits [loading, failure] when loading fails',
      build: () {
        when(() => getTopStories(page: 0)).thenAnswer(
          (_) async => const Failed<List<Article>>(NetworkFailure()),
        );
        return NewsBloc(getTopStories);
      },
      act: (bloc) => bloc.add(const NewsStarted()),
      expect: () => [
        const NewsState(status: NewsStatus.loading),
        const NewsState(
          status: NewsStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );
  });

  group('NewsLoadMoreRequested', () {
    blocTest<NewsBloc, NewsState>(
      'appends the next page',
      build: () {
        when(() => getTopStories(page: 1)).thenAnswer(
          (_) async => Success<List<Article>>([article2]),
        );
        return NewsBloc(getTopStories);
      },
      seed: () => NewsState(
        status: NewsStatus.success,
        articles: [article1],
        nextPage: 1,
      ),
      act: (bloc) => bloc.add(const NewsLoadMoreRequested()),
      expect: () => [
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
          isLoadingMore: true,
        ),
        NewsState(
          status: NewsStatus.success,
          articles: [article1, article2],
          nextPage: 2,
        ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'marks the end when the page is empty',
      build: () {
        when(() => getTopStories(page: 1)).thenAnswer(
          (_) async => const Success<List<Article>>([]),
        );
        return NewsBloc(getTopStories);
      },
      seed: () => NewsState(
        status: NewsStatus.success,
        articles: [article1],
        nextPage: 1,
      ),
      act: (bloc) => bloc.add(const NewsLoadMoreRequested()),
      expect: () => [
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
          isLoadingMore: true,
        ),
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 2,
          hasReachedEnd: true,
        ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'keeps loaded articles when loading more fails',
      build: () {
        when(() => getTopStories(page: 1)).thenAnswer(
          (_) async => const Failed<List<Article>>(ServerFailure()),
        );
        return NewsBloc(getTopStories);
      },
      seed: () => NewsState(
        status: NewsStatus.success,
        articles: [article1],
        nextPage: 1,
      ),
      act: (bloc) => bloc.add(const NewsLoadMoreRequested()),
      expect: () => [
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
          isLoadingMore: true,
        ),
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
          failure: const ServerFailure(),
        ),
      ],
    );
  });

  group('NewsRefreshed', () {
    blocTest<NewsBloc, NewsState>(
      'replaces the list and resets pagination',
      build: () {
        when(() => getTopStories(page: 0)).thenAnswer(
          (_) async => Success<List<Article>>([article2]),
        );
        return NewsBloc(getTopStories);
      },
      seed: () => NewsState(
        status: NewsStatus.success,
        articles: [article1],
        nextPage: 3,
        hasReachedEnd: true,
      ),
      act: (bloc) => bloc.add(const NewsRefreshed()),
      expect: () => [
        NewsState(
          status: NewsStatus.success,
          articles: [article2],
          nextPage: 1,
        ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'keeps the old list and completes the completer when refresh fails',
      build: () {
        when(() => getTopStories(page: 0)).thenAnswer(
          (_) async => const Failed<List<Article>>(NetworkFailure()),
        );
        return NewsBloc(getTopStories);
      },
      seed: () => NewsState(
        status: NewsStatus.success,
        articles: [article1],
        nextPage: 1,
      ),
      act: (bloc) async {
        final completer = Completer<void>();
        bloc.add(NewsRefreshed(completer: completer));
        await completer.future;
      },
      expect: () => [
        NewsState(
          status: NewsStatus.success,
          articles: [article1],
          nextPage: 1,
          failure: const NetworkFailure(),
        ),
      ],
    );
  });
}
