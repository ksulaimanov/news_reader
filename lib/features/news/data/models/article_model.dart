import '../../../../core/error/exceptions.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.author,
    required super.score,
    required super.commentsCount,
    required super.publishedAt,
    super.url,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! int || title is! String) {
      throw const ParseException('Некорректный формат статьи');
    }

    final time = json['time'];
    return ArticleModel(
      id: id,
      title: title,
      author: (json['by'] as String?) ?? 'unknown',
      score: (json['score'] as num?)?.toInt() ?? 0,
      commentsCount: (json['descendants'] as num?)?.toInt() ?? 0,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
        (time is num ? time.toInt() : 0) * 1000,
        isUtc: true,
      ),
      url: json['url'] as String?,
    );
  }
}
