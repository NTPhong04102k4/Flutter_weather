import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:weather/core/auth/auth_exception.dart';
import 'package:weather/core/utils/logger.dart';

/// Hợp đồng (contract) giữa Dart và bridge native ForgeRock.
///
/// Đây là **ranh giới duy nhất** được phép biết tới `MethodChannel`. Tách thành
/// `abstract interface` để:
///  - Test/dev chạy được KHÔNG cần SDK native (dùng `FakeAuthChannel`).
///  - Đổi engine IAM (ForgeRock → Keycloak/Entra) chỉ cần một implementation mới.
///
/// Mọi method đều trả về chuỗi JSON thô — việc dịch sang model là của lớp trên.
abstract interface class AuthChannel {
  /// Khởi tạo SDK native (đọc cấu hình AM, dựng session manager).
  Future<void> start();

  /// Bắt đầu journey đăng nhập. Trả về JSON `LoginSuccess` hoặc node đầu tiên.
  Future<String> login();

  /// Gửi node đã điền để đi bước tiếp theo.
  Future<String> next(String nodeJson);

  /// Xoá session + token ở native.
  Future<void> logout();

  /// Lấy thông tin người dùng từ endpoint `userinfo` của AM.
  Future<String> getUserInfo();

  /// Gọi API nghiệp vụ **qua native**, để SDK tự gắn `Authorization` + cookie.
  ///
  /// [headers] là các header do Dart quyết định (tenant, locale, correlation
  /// id...) — native chỉ chuyển tiếp, không tự bịa thêm.
  Future<String> callEndpoint({
    required String url,
    required String method,
    required String body,
    required Map<String, String> headers,
  });
}

/// Cài đặt thật: nói chuyện với `FRAuthSampleBridge` (Java/Swift) qua
/// `MethodChannel`.
///
/// Toàn bộ giá trị của lớp này nằm ở hàm [_translate]: biến `PlatformException`
/// với `code`/`message` dạng chuỗi tự do — khác nhau giữa Android/iOS — thành
/// [AuthException] có kiểu. Đây chính là "lớp xử lí" mà nếu gọi `MethodChannel`
/// trực tiếp từ UI thì mỗi màn hình sẽ phải tự viết lại.
class MethodChannelAuthChannel implements AuthChannel {
  const MethodChannelAuthChannel({
    MethodChannel channel = const MethodChannel(channelName),
  }) : _channel = channel;

  /// Tên channel — PHẢI khớp hằng số khai báo ở Java/Swift.
  static const String channelName = 'forgerock.com/SampleBridge';

  final MethodChannel _channel;

  @override
  Future<void> start() => _invokeVoid('frAuthStart');

  @override
  Future<String> login() => _invokeString('login');

  @override
  Future<String> next(String nodeJson) => _invokeString('next', nodeJson);

  @override
  Future<void> logout() => _invokeVoid('logout');

  @override
  Future<String> getUserInfo() => _invokeString('getUserInfo');

  @override
  Future<String> callEndpoint({
    required String url,
    required String method,
    required String body,
    required Map<String, String> headers,
  }) {
    // Hợp đồng vị trí: [url, method, body, headersJson].
    // Native đọc phần tử thứ 4 nếu có → tương thích ngược với bridge cũ
    // (bridge chưa cập nhật vẫn chạy, chỉ là không nhận được header từ Dart).
    return _invokeString('callEndpoint', <String>[
      url,
      method,
      body,
      jsonEncode(headers),
    ]);
  }

  Future<void> _invokeVoid(String method, [Object? arguments]) async {
    await _guard(method, () => _channel.invokeMethod<void>(method, arguments));
  }

  Future<String> _invokeString(String method, [Object? arguments]) async {
    final String? result = await _guard(
      method,
      () => _channel.invokeMethod<String>(method, arguments),
    );

    if (result == null) {
      throw AuthException(
        AuthErrorKind.parse,
        'Native không trả về dữ liệu.',
        operation: method,
      );
    }
    return result;
  }

  /// Bọc mọi lần gọi bridge: log + chuẩn hoá lỗi về [AuthException].
  Future<T> _guard<T>(String operation, Future<T> Function() run) async {
    try {
      return await run();
    } on PlatformException catch (e) {
      final AuthException translated = _translate(operation, e);
      AppLogger.e('Bridge[$operation] thất bại', translated, null);
      throw translated;
    } on MissingPluginException {
      throw AuthException(
        AuthErrorKind.bridgeMissing,
        'Thiếu bridge native cho auth. Kiểm tra khai báo MethodChannel.',
        operation: operation,
      );
    }
  }

  /// Bản đồ lỗi native → [AuthErrorKind].
  ///
  /// Nguồn dữ liệu để lập bảng này là code bridge thật:
  ///  - iOS ném `code = 'Token Error' | 'Unauthorized' | 'API_ERROR'`.
  ///  - Android ném `code = 'ERROR'`, thông tin thật nằm trong `details`.
  AuthException _translate(String operation, PlatformException e) {
    final String code = e.code;
    final String details = e.details?.toString() ?? '';
    final String message = e.message ?? '';
    final String haystack = '$code $details $message'.toLowerCase();

    if (code == 'Token Error' ||
        haystack.contains('unauthorized') ||
        haystack.contains('401')) {
      return AuthException(
        AuthErrorKind.sessionExpired,
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        operation: operation,
        nativeCode: code,
        statusCode: 401,
        details: details,
      );
    }

    if (haystack.contains('forbidden') || haystack.contains('403')) {
      return AuthException(
        AuthErrorKind.forbidden,
        'Bạn không có quyền thực hiện thao tác này.',
        operation: operation,
        nativeCode: code,
        statusCode: 403,
        details: details,
      );
    }

    if (haystack.contains('timed out') || haystack.contains('timeout')) {
      return AuthException(
        AuthErrorKind.timeout,
        'Máy chủ phản hồi quá chậm. Vui lòng thử lại.',
        operation: operation,
        nativeCode: code,
        details: details,
      );
    }

    if (haystack.contains('cancel')) {
      return AuthException(
        AuthErrorKind.cancelled,
        'Thao tác đã bị huỷ.',
        operation: operation,
        nativeCode: code,
        details: details,
      );
    }

    if (haystack.contains('unable to resolve host') ||
        haystack.contains('network') ||
        haystack.contains('socket')) {
      return AuthException(
        AuthErrorKind.network,
        'Không có kết nối mạng.',
        operation: operation,
        nativeCode: code,
        details: details,
      );
    }

    return AuthException(
      AuthErrorKind.sdk,
      message.isEmpty ? 'Lỗi hệ thống xác thực.' : message,
      operation: operation,
      nativeCode: code,
      details: details,
    );
  }
}
