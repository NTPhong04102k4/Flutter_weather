import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:weather/core/auth/auth_api_client.dart';
import 'package:weather/core/auth/auth_channel.dart';
import 'package:weather/core/auth/auth_exception.dart';
import 'package:weather/core/auth/models/auth_journey.dart';
import 'package:weather/core/auth/models/fr_node.dart';
import 'package:weather/core/auth/session_event_bus.dart';
import 'package:weather/core/auth/tenant_context.dart';

/// Channel ghi lại request cuối cùng để kiểm chứng header.
class _RecordingChannel implements AuthChannel {
  _RecordingChannel({this.error});

  final AuthException? error;
  static const String response = '{"ok":true}';

  String? lastUrl;
  String? lastMethod;
  String? lastBody;
  Map<String, String> lastHeaders = const {};

  @override
  Future<String> callEndpoint({
    required String url,
    required String method,
    required String body,
    required Map<String, String> headers,
  }) async {
    lastUrl = url;
    lastMethod = method;
    lastBody = body;
    lastHeaders = headers;

    final AuthException? failure = error;
    if (failure != null) {
      throw failure;
    }
    return response;
  }

  @override
  Future<String> getUserInfo() async => '{}';

  @override
  Future<String> login() async => '{}';

  @override
  Future<void> logout() async {}

  @override
  Future<String> next(String nodeJson) async => '{}';

  @override
  Future<void> start() async {}
}

void main() {
  const TenantContext tenant = TenantContext(
    tenantId: 'tenant-abc',
    appVersion: '1.2.3',
  );

  group('TenantContext', () {
    test('gắn header tenant và bỏ field null', () {
      final Map<String, String> headers = tenant.baseHeaders();

      expect(headers['TenantId'], 'tenant-abc');
      expect(headers['X-App-Version'], '1.2.3');
      expect(headers.containsKey('X-Device-Id'), isFalse);
    });

    test('ném lỗi rõ ràng khi quên cấu hình tenantId', () {
      const TenantContext empty = TenantContext(tenantId: '');

      expect(empty.isConfigured, isFalse);
      expect(empty.baseHeaders, throwsStateError);
    });
  });

  group('AuthApiClient', () {
    test('mọi request đều có header tenant + query được ghép đúng', () async {
      final channel = _RecordingChannel();
      final client = AuthApiClient(channel: channel, tenant: tenant);

      await client.get(
        'https://api.example.com/Users/profile',
        query: {'skip': 0, 'take': 20},
      );

      expect(channel.lastMethod, 'GET');
      expect(channel.lastUrl, contains('skip=0'));
      expect(channel.lastUrl, contains('take=20'));
      expect(channel.lastHeaders['TenantId'], 'tenant-abc');
      // Authorization KHÔNG do Dart gắn — native mới có token.
      expect(channel.lastHeaders.containsKey('Authorization'), isFalse);
    });

    test('POST tự thêm Content-Type và encode body', () async {
      final channel = _RecordingChannel();
      final client = AuthApiClient(channel: channel, tenant: tenant);

      await client.post(
        'https://api.example.com/Users',
        body: {'name': 'Phong'},
      );

      expect(channel.lastHeaders['Content-Type'], contains('application/json'));
      expect(jsonDecode(channel.lastBody!), {'name': 'Phong'});
    });

    test('correlationId đi vào header để dò log xuyên hệ thống', () async {
      final channel = _RecordingChannel();
      final client = AuthApiClient(channel: channel, tenant: tenant);

      await client.send(
        method: 'GET',
        url: 'https://api.example.com/ping',
        correlationId: 'req-42',
      );

      expect(channel.lastHeaders['X-Correlation-Id'], 'req-42');
    });

    test('401 từ native → phát SessionEvent.expired đúng một lần', () async {
      final channel = _RecordingChannel(
        error: const AuthException(
          AuthErrorKind.sessionExpired,
          'Phiên đăng nhập đã hết hạn.',
          statusCode: 401,
        ),
      );
      final bus = SessionEventBus();
      final events = <SessionEvent>[];
      final subscription = bus.stream.listen(events.add);

      final client = AuthApiClient(
        channel: channel,
        tenant: tenant,
        sessionEvents: bus,
      );

      await expectLater(
        client.get('https://api.example.com/Users/profile'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.requiresReLogin,
            'requiresReLogin',
            isTrue,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, [SessionEvent.expired]);

      await subscription.cancel();
      await bus.close();
    });
  });

  group('JourneyStep.parse', () {
    test('nhận diện LoginSuccess', () {
      final JourneyStep step = JourneyStep.parse('{"type":"LoginSuccess"}');

      expect(step, isA<JourneySuccess>());
    });

    test('nhận diện node cần nhập liệu', () {
      final JourneyStep step = JourneyStep.parse(
        jsonEncode({
          'authId': 'abc',
          'callbacks': [
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
        }),
      );

      expect(step, isA<JourneyNeedsInput>());
      final FRNode node = (step as JourneyNeedsInput).node;
      expect(node.authId, 'abc');
      expect(node.textInputs.single.prompt, 'Mật khẩu');
      expect(node.textInputs.single.isPassword, isTrue);
    });

    test('JSON rác → AuthException(parse), không phải FormatException', () {
      expect(
        () => JourneyStep.parse('<html>502 Bad Gateway</html>'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.kind,
            'kind',
            AuthErrorKind.parse,
          ),
        ),
      );
    });
  });

  group('FRNode.withAnswers', () {
    test('trả về node mới, giữ authId và không sửa node gốc', () {
      final FRNode original = FRNode.fromJson({
        'authId': 'keep-me',
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
        ],
      });

      final FRNode answered = original.withAnswers({0: 'phong'});

      expect(answered.authId, 'keep-me');
      expect(answered.callbacks.single.input.single.value, 'phong');
      // Node gốc bất biến — tránh bug khi form bị render lại.
      expect(original.callbacks.single.input.single.value, '');
    });
  });
}
