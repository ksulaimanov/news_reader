import '../error/failures.dart';

/// Результат операции: данные или Failure.
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Failed<T>(:final failure) => onFailure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
