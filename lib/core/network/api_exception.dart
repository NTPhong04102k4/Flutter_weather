/// Exception nội bộ của tầng network.
///
/// [ApiClient] NÉM exception này khi có sự cố. Tầng repository sẽ BẮT nó và
/// dịch sang [Failure] (giá trị) trước khi trả lên UI — xem `failure.dart`.
/// Nhờ tách bạch: network "ném", repository "dịch", UI chỉ "đọc giá trị".
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// Mã HTTP nếu có (null với lỗi mạng / parse).
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(${statusCode ?? '-'}): $message';
}
