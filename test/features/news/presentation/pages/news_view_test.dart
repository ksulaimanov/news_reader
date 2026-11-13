import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/core/error/failures.dart';
import 'package:news_reader/features/news/domain/entities/article.dart';
import 'package:news_reader/features/news/presentation/bloc/news_bloc.dart';
import 'package:news_reader/features/news/presentation/bloc/news_event.dart';
import 'package:news_reader/features/news/presentation/bloc/news_state.dart';
import 'package:news_reader/features/news/presentation/pages/news_page.dart';

class MockNewsBloc extends MockBloc<NewsEvent, NewsState>
    implements NewsBloc {}

void main() {
  late MockNewsBloc bloc;

  final article = Article(
    id: 1,
    title: 'First story',
    author: 'tester',
    score: 42,
    commentsCount: 7,
    publishedAt: DateTime.utc(2026, 11, 13),
    url: 'https://example.com/story',
  );

  setUpAll(() {
    registerFallbackValue(const NewsStarted());
  });

  setUp(() {
    bloc = MockNewsBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<NewsBloc>.value(
        value: bloc,
        child: const NewsView(),
      ),
    );
  }

  testWidgets('shows a progress indicator while loading', (tester) async {
    when(() => bloc.state)
        .thenReturn(const NewsState(status: NewsStatus.loading));

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows article cards when loaded', (tester) async {
    when(() => bloc.state).thenReturn(
      NewsState(
        status: NewsStatus.success,
        articles: [article],
        nextPage: 1,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('First story'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('shows the end marker when all pages are loaded', (tester) async {
    when(() => bloc.state).thenReturn(
      NewsState(
        status: NewsStatus.success,
        articles: [article],
        nextPage: 2,
        hasReachedEnd: true,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Вы дочитали до конца'), findsOneWidget);
  });

  testWidgets('shows error view and retries on button tap', (tester) async {
    when(() => bloc.state).thenReturn(
      const NewsState(
        status: NewsStatus.failure,
        failure: NetworkFailure(),
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Нет соединения с интернетом'), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    verify(() => bloc.add(const NewsStarted())).called(1);
  });
}
