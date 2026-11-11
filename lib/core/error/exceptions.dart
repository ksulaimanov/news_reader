/// Исключения слоя data. Репозиторий (Шаг 3) превращает их в Failure.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Нет интернета, таймаут, обрыв соединения.
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Сервер ответил ошибкой (4xx/5xx) или неожиданным ответом.
class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

/// Ответ пришёл, но данные не соответствуют ожидаемому формату.
class ParseException extends AppException {
  const ParseException(super.message);
}
