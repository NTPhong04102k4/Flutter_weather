import 'dart:convert';

import 'package:weather/core/auth/auth_exception.dart';
import 'package:weather/core/auth/models/fr_node.dart';

/// Kết quả của MỘT lần gọi `login` / `next` tới bridge native.
///
/// Native trả về **một chuỗi JSON duy nhất** cho cả hai trường hợp:
///  - `{"type":"LoginSuccess", ...}` → đăng nhập xong.
///  - `{"authId":"...","callbacks":[...]}` → còn bước nữa, cần nhập tiếp.
///
/// Code cũ phải tự `jsonDecode` rồi `if (response['type'] == 'LoginSuccess')`
/// ở MỌI chỗ gọi. [JourneyStep] gói việc đó lại một lần: nhờ `sealed`, khi
/// `switch` trên kết quả trình biên dịch BẮT BUỘC xử lý đủ các trường hợp.
sealed class JourneyStep {
  const JourneyStep();

  /// Phân tích chuỗi JSON thô từ native thành bước journey có kiểu.
  ///
  /// Ném [AuthException] với [AuthErrorKind.parse] nếu payload không hợp lệ —
  /// tuyệt đối không để `FormatException` rò lên UI.
  factory JourneyStep.parse(String rawJson, {String? operation}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      throw AuthException(
        AuthErrorKind.parse,
        'Dữ liệu đăng nhập trả về không hợp lệ.',
        operation: operation,
        details: '${e.message} | $rawJson',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw AuthException(
        AuthErrorKind.parse,
        'Dữ liệu đăng nhập trả về không hợp lệ.',
        operation: operation,
        details: rawJson,
      );
    }

    if (decoded['type'] == 'LoginSuccess') {
      return JourneySuccess(sessionToken: decoded['sessionToken'] as String?);
    }

    if (decoded['callbacks'] != null || decoded['authId'] != null) {
      return JourneyNeedsInput(FRNode.fromJson(decoded));
    }

    throw AuthException(
      AuthErrorKind.parse,
      'Không nhận diện được bước đăng nhập.',
      operation: operation,
      details: rawJson,
    );
  }
}

/// Journey kết thúc thành công — token đã nằm trong secure storage của native.
class JourneySuccess extends JourneyStep {
  const JourneySuccess({this.sessionToken});

  /// Chỉ có khi native được bật trả token (mặc định `null` — Dart KHÔNG cần).
  final String? sessionToken;
}

/// Journey còn cần người dùng nhập thêm ([node] chứa các ô nhập).
class JourneyNeedsInput extends JourneyStep {
  const JourneyNeedsInput(this.node);

  final FRNode node;
}
