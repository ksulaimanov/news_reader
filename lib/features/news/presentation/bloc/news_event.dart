import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// Первая загрузка. Используется и для кнопки «Повторить» после ошибки.
final class NewsStarted extends NewsEvent {
  const NewsStarted();
}

/// Pull-to-refresh. [completer] нужен, чтобы RefreshIndicator знал,
/// когда скрыть спиннер.
final class NewsRefreshed extends NewsEvent {
  const NewsRefreshed({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}

/// Догрузка следующей страницы при прокрутке вниз.
final class NewsLoadMoreRequested extends NewsEvent {
  const NewsLoadMoreRequested();
}
