import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/article.dart';

enum NewsStatus { initial, loading, success, failure }

class NewsState extends Equatable {
  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.nextPage = 0,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final NewsStatus status;
  final List<Article> articles;

  /// Номер следующей страницы для загрузки.
  final int nextPage;
  final bool hasReachedEnd;
  final bool isLoadingMore;

  /// При status == failure — ошибка первой загрузки (экран ошибки).
  /// При status == success — ошибка догрузки или обновления
  /// (список остаётся, внизу кнопка «Повторить» / SnackBar).
  final Failure? failure;

  NewsState copyWith({
    NewsStatus? status,
    List<Article>? articles,
    int? nextPage,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      nextPage: nextPage ?? this.nextPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [status, articles, nextPage, hasReachedEnd, isLoadingMore, failure];
}
