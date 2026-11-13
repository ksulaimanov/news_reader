import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );

  // Логи запросов только в debug-режиме (assert не выполняется в release).
  assert(() {
    dio.interceptors.add(
      LogInterceptor(requestHeader: false, responseHeader: false, requestBody: false, responseBody: false),
    );
    return true;
  }());

  return dio;
}

/// Превращает DioException в понятное исключение приложения.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException('Превышено время ожидания ответа');
    case DioExceptionType.connectionError:
      return const NetworkException('Нет соединения с интернетом');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      return ServerException('Сервер вернул ошибку ($code)', statusCode: code);
    case DioExceptionType.cancel:
      return const NetworkException('Запрос отменён');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return NetworkException(e.message ?? 'Неизвестная сетевая ошибка');
  }
}
