import 'package:meta/meta.dart';

@immutable
abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class OcrFailure extends AppFailure {
  const OcrFailure(super.message);
}

class ParseFailure extends AppFailure {
  const ParseFailure(super.message);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

@immutable
class Result<T> {
  final T? data;
  final AppFailure? failure;

  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}
