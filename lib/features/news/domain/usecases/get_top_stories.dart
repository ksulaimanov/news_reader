import '../../../../core/utils/result.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopStories {
  const GetTopStories(this._repository);

  final NewsRepository _repository;

  Future<Result<List<Article>>> call({int page = 0}) =>
      _repository.getTopStories(page: page);
}
