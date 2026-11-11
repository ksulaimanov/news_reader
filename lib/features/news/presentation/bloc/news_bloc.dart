import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_top_stories.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc(this._getTopStories) : super(const NewsState()) {
    on<NewsStarted>(_onStarted);
    on<NewsRefreshed>(_onRefreshed);
    // Пока страница грузится, повторные запросы игнорируем.
    on<NewsLoadMoreRequested>(_onLoadMoreRequested, transformer: droppable());
  }

  final GetTopStories _getTopStories;

  Future<void> _onStarted(NewsStarted event, Emitter<NewsState> emit) async {
    emit(const NewsState(status: NewsStatus.loading));

    final result = await _getTopStories(page: 0);
    switch (result) {
      case Success(:final data):
        emit(
          NewsState(
            status: NewsStatus.success,
            articles: data,
            nextPage: 1,
            hasReachedEnd: data.isEmpty,
          ),
        );
      case Failed(:final failure):
        emit(NewsState(status: NewsStatus.failure, failure: failure));
    }
  }

  Future<void> _onRefreshed(
    NewsRefreshed event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final result = await _getTopStories(page: 0);
      switch (result) {
        case Success(:final data):
          emit(
            NewsState(
              status: NewsStatus.success,
              articles: data,
              nextPage: 1,
              hasReachedEnd: data.isEmpty,
            ),
          );
        case Failed(:final failure):
          // Если список уже есть, оставляем его и показываем ошибку поверх.
          emit(
            state.articles.isEmpty
                ? NewsState(status: NewsStatus.failure, failure: failure)
                : state.copyWith(failure: failure),
          );
      }
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMoreRequested(
    NewsLoadMoreRequested event,
    Emitter<NewsState> emit,
  ) async {
    if (state.status != NewsStatus.success ||
        state.hasReachedEnd ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearFailure: true));

    final result = await _getTopStories(page: state.nextPage);
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            articles: [...state.articles, ...data],
            nextPage: state.nextPage + 1,
            hasReachedEnd: data.isEmpty,
            isLoadingMore: false,
          ),
        );
      case Failed(:final failure):
        emit(state.copyWith(isLoadingMore: false, failure: failure));
    }
  }
}
