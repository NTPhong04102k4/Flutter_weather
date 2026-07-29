/// Phân loại sự cố của tầng auth/native bridge.
///
/// Native (ForgeRock SDK) chỉ trả về `PlatformException` với `code`/`message`
/// dạng CHUỖI TỰ DO, khác nhau giữa Android và iOS. [AuthErrorKind] là bảng
/// phân loại DUY NHẤT mà tầng trên được phép nhìn thấy — nhờ vậy UI không phải
/// đi so sánh chuỗi `'Token Error'`, `'Unauthorized'`... như code cũ.
enum AuthErrorKind {
  /// Phiên hết hạn / refresh token không còn hiệu lực → phải đăng nhập lại.
  sessionExpired,

  /// Có token nhưng không đủ quyền cho tài nguyên (403).
  forbidden,

  /// Mất mạng, DNS lỗi, không tới được máy chủ.
  network,

  /// Quá thời gian chờ.
  timeout,

  /// Máy chủ trả về 4xx/5xx (ngoài 401/403).
  server,

  /// Người dùng bấm huỷ (đóng WebView, huỷ sinh trắc học...).
  cancelled,

  /// Chưa cài/chưa đăng ký bridge native (chạy trên máy chưa có SDK).
  bridgeMissing,

  /// SDK native báo lỗi nội bộ (chưa init, cấu hình sai...).
  sdk,

  /// Không giải mã được payload JSON từ native.
  parse,

  /// Không xác định.
  unknown,
}

/// Lỗi đã được CHUẨN HOÁ của tầng auth.
///
/// Quy ước xuyên suốt project: `AuthChannel` và [AuthApiClient] chỉ ném
/// [AuthException]; không để `PlatformException` (kiểu của `dart:ui`) rò rỉ
/// lên feature. Repository sẽ dịch tiếp sang `Failure` nếu cần hiển thị.
class AuthException implements Exception {
  const AuthException(
    this.kind,
    this.message, {
    this.operation,
    this.nativeCode,
    this.statusCode,
    this.details,
  });

  /// Loại lỗi — tầng trên switch trên trường này.
  final AuthErrorKind kind;

  /// Thông điệp thân thiện, sẵn sàng hiển thị.
  final String message;

  /// Tên phương thức bridge đã gọi (`login`, `callEndpoint`...) — để log.
  final String? operation;

  /// `code` gốc từ native, giữ lại phục vụ debug.
  final String? nativeCode;

  /// Mã HTTP nếu lỗi phát sinh từ một request.
  final int? statusCode;

  /// Body/chi tiết gốc (có thể dài) — chỉ dùng cho log, KHÔNG hiện cho user.
  final String? details;

  /// `true` khi bắt buộc phải đưa người dùng về màn hình đăng nhập.
  bool get requiresReLogin => kind == AuthErrorKind.sessionExpired;

  @override
  String toString() =>
      'AuthException(${kind.name}${statusCode == null ? '' : ' $statusCode'}'
      '${operation == null ? '' : ' @$operation'}): $message';
}
