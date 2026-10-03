/// An expected operation outcome. Programming errors are not failure values.
sealed class Result<T, F> {
  const Result();
}

final class Success<T, F> extends Result<T, F> {
  const Success(this.value);

  final T value;
}

final class Failure<T, F> extends Result<T, F> {
  const Failure(this.failure);

  final F failure;
}
