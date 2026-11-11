import 'package:equatable/equatable.dart';

/// Ошибки, которые видит BLoC и UI. Сообщения безопасны для показа.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения с интернетом']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера. Попробуйте позже']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Не удалось обработать данные']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Что-то пошло не так']);
}
