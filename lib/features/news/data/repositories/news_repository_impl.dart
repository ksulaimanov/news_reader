import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remote);

  final NewsRemoteDataSource _remote;

  @override
  Future<Result<List<Article>>> getTopStories({int page = 0}) async {
    try {
      final articles = await _remote.getTopStories(
        page: page,
        pageSize: ApiConstants.pageSize,
      );
      return Success(articles);
    } on AppException catch (e) {
      return Failed(
        switch (e) {
          NetworkException() => NetworkFailure(e.message),
          ServerException() => ServerFailure(e.message),
          ParseException() => ParsingFailure(e.message),
        },
      );
    } catch (_) {
      return const Failed(UnknownFailure());
    }
  }
}
