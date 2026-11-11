import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/article_model.dart';

abstract class NewsRemoteDataSource {
  /// Возвращает страницу топовых историй. [page] начинается с 0.
  /// Бросает [AppException] при любой ошибке.
  Future<List<ArticleModel>> getTopStories({
    int page = 0,
    int pageSize = ApiConstants.pageSize,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  NewsRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  List<int> _ids = [];

  @override
  Future<List<ArticleModel>> getTopStories({
    int page = 0,
    int pageSize = ApiConstants.pageSize,
  }) async {
    try {
      // Список id обновляем при первой странице (pull-to-refresh тоже page = 0).
      if (page == 0 || _ids.isEmpty) {
        _ids = await _fetchTopStoryIds();
      }

      final start = page * pageSize;
      if (start >= _ids.length) return [];
      final end = (start + pageSize).clamp(0, _ids.length);

      final items = await Future.wait(
        _ids.sublist(start, end).map(_fetchItem),
      );
      return items.whereType<ArticleModel>().toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Неожиданная ошибка: $e');
    }
  }

  Future<List<int>> _fetchTopStoryIds() async {
    final response = await _dio.get<List<dynamic>>(ApiConstants.topStories);
    final data = response.data;
    if (data == null) {
      throw const ServerException('Пустой ответ сервера');
    }
    return data.whereType<int>().toList();
  }

  /// null — если пост удалён, «мёртвый» или это не история.
  Future<ArticleModel?> _fetchItem(int id) async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.item(id));
    final json = response.data;
    if (json == null ||
        json['deleted'] == true ||
        json['dead'] == true ||
        json['type'] != 'story') {
      return null;
    }
    return ArticleModel.fromJson(json);
  }
}
