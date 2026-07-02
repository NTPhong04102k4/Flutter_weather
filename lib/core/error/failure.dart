/// Mô tả MỘT lỗi nghiệp vụ ở dạng "đã được dịch" để UI hiển thị.
///
/// Khác với [Exception] (ném ra và bắt), [Failure] là một GIÁ TRỊ:
/// nó được trả về trong [Result] và đi xuyên qua repository → provider → UI.
/// Nhờ vậy, UI không cần try/catch mà chỉ cần khớp (pattern match) trên kết quả.
///
/// Dùng `sealed` để khi `switch` trên [Failure], trình biên dịch BẮT BUỘC
/// xử lý đủ mọi loại lỗi — quên một case sẽ báo lỗi compile.
sealed class Failure {
  const Failure(this.message);

  /// Thông điệp thân thiện, sẵn sàng hiển thị cho người dùng.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Không có mạng / mất kết nối / DNS lỗi.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng.']);
}

/// Request quá thời gian chờ ([AppConstants.networkTimeout]).
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Yêu cầu quá thời gian chờ.']);
}

/// Server trả về mã lỗi (4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Không phân tích được dữ liệu trả về (JSON sai định dạng, thiếu field...).
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Dữ liệu trả về không hợp lệ.']);
}

/// Lỗi không xác định / không lường trước.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Đã có lỗi xảy ra.']);
}
