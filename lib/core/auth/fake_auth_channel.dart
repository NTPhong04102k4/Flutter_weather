import 'dart:convert';

import 'package:weather/core/auth/auth_channel.dart';
import 'package:weather/core/auth/auth_exception.dart';

/// Bản giả lập [AuthChannel] — chạy được khi CHƯA có bridge native.
///
/// Đây là lợi ích cụ thể nhất của việc đặt một interface trước `MethodChannel`:
///  - Chạy app trên simulator/emulator chưa cài SDK ForgeRock.
///  - Viết unit test cho `AuthNotifier` mà không cần thiết bị thật.
///  - Demo UI journey (nhập username → password) khi backend chưa sẵn sàng.
///
/// Journey giả lập gồm 1 node với 2 callback (NameCallback + PasswordCallback),
/// đúng hình dạng JSON mà AM trả về thật.
class FakeAuthChannel implements AuthChannel {
  FakeAuthChannel({
    this.validUsername = 'demo',
    this.validPassword = 'demo123',
    this.latency = const Duration(milliseconds: 350),
  });

  final String validUsername;
  final String validPassword;

  /// Độ trễ giả lập, để thấy được trạng thái loading trên UI.
  final Duration latency;

  bool _authenticated = false;

  @override
  Future<void> start() => Future<void>.delayed(latency);

  @override
  Future<String> login() async {
    await Future<void>.delayed(latency);
    _authenticated = false;

    return jsonEncode({
      'authId': 'fake-auth-id',
      'authServiceId': 'Login',
      'stage': null,
      'header': 'Đăng nhập',
      'description': 'Bridge giả lập (chưa gắn ForgeRock native).',
      'callbacks': [
        {
          'type': 'NameCallback',
          '_id': 0,
          'output': [
            {'name': 'prompt', 'value': 'Tên đăng nhập'},
          ],
          'input': [
            {'name': 'IDToken1', 'value': ''},
          ],
        },
        {
          'type': 'PasswordCallback',
          '_id': 1,
          'output': [
            {'name': 'prompt', 'value': 'Mật khẩu'},
          ],
          'input': [
            {'name': 'IDToken2', 'value': ''},
          ],
        },
      ],
    });
  }

  @override
  Future<String> next(String nodeJson) async {
    await Future<void>.delayed(latency);

    final Map<String, dynamic> node =
        jsonDecode(nodeJson) as Map<String, dynamic>;
    final List<Object?> callbacks = node['callbacks'] as List<Object?>;
    final List<String> answers = callbacks
        .whereType<Map<String, dynamic>>()
        .map(
          (c) =>
              ((c['input'] as List<Object?>).first as Map<String, dynamic>)['value']
                  ?.toString() ??
              '',
        )
        .toList();

    final bool ok =
        answers.length >= 2 &&
        answers[0] == validUsername &&
        answers[1] == validPassword;

    if (!ok) {
      throw const AuthException(
        AuthErrorKind.sdk,
        'Tên đăng nhập hoặc mật khẩu không đúng.',
        operation: 'next',
      );
    }

    _authenticated = true;
    return jsonEncode({'type': 'LoginSuccess'});
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(latency);
    _authenticated = false;
  }

  @override
  Future<String> getUserInfo() async {
    await Future<void>.delayed(latency);
    if (!_authenticated) {
      throw const AuthException(
        AuthErrorKind.sessionExpired,
        'Chưa đăng nhập.',
        operation: 'getUserInfo',
      );
    }

    return jsonEncode({
      'sub': 'fake-user-id',
      'name': 'Người dùng Demo',
      'email': 'demo@example.com',
    });
  }

  @override
  Future<String> callEndpoint({
    required String url,
    required String method,
    required String body,
    required Map<String, String> headers,
  }) async {
    await Future<void>.delayed(latency);
    if (!_authenticated) {
      throw const AuthException(
        AuthErrorKind.sessionExpired,
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        operation: 'callEndpoint',
        statusCode: 401,
      );
    }

    // Phản chiếu lại request để test kiểm chứng header tenant đã được gắn.
    return jsonEncode({
      'echo': {'url': url, 'method': method, 'headers': headers},
    });
  }
}
