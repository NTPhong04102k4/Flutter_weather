import 'package:weather/core/error/failure.dart';

/// Kiểu trả về an toàn: HOẶC dữ liệu thành công ([Ok]) HOẶC lỗi ([Err]).
///
/// Thay cho việc ném exception xuyên nhiều tầng, repository trả về `Result<T>`.
/// UI/provider dùng pattern matching để xử lý gọn cả hai nhánh:
///
/// ```dart
/// final result = await repo.fetchWeather(city);
/// switch (result) {
///   case Ok(:final value):   showWeather(value);
///   case Err(:final failure): showError(failure.message);
/// }
/// ```
///
/// `sealed` đảm bảo chỉ có đúng hai trường hợp [Ok] và [Err].
sealed class Result<T> {
  const Result();

  /// Tạo nhánh thành công.
  const factory Result.ok(T value) = Ok<T>;

  /// Tạo nhánh lỗi.
  const factory Result.err(Failure failure) = Err<T>;

  /// `true` nếu là [Ok].
  bool get isOk => this is Ok<T>;

  /// Lấy giá trị nếu thành công, ngược lại trả về `null`.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Biến đổi giá trị bên trong khi thành công, giữ nguyên lỗi.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };

  /// Gập hai nhánh về một giá trị duy nhất.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };
}

/// Nhánh thành công, mang theo [value].
class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

/// Nhánh lỗi, mang theo [failure].
class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
