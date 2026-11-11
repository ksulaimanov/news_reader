import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.score,
    required this.commentsCount,
    required this.publishedAt,
    this.url,
  });

  final int id;
  final String title;
  final String author;
  final int score;
  final int commentsCount;
  final DateTime publishedAt;

  /// У Ask HN / текстовых постов внешней ссылки нет.
  final String? url;

  @override
  List<Object?> get props =>
      [id, title, author, score, commentsCount, publishedAt, url];
}
