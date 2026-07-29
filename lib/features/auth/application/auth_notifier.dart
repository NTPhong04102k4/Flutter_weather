import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/core/auth/auth_channel.dart';
import 'package:weather/core/auth/auth_exception.dart';
import 'package:weather/core/auth/auth_providers.dart';
import 'package:weather/core/auth/models/auth_journey.dart';
import 'package:weather/core/auth/models/fr_node.dart';
import 'package:weather/core/auth/session_event_bus.dart';
import 'package:weather/core/utils/logger.dart';
import 'package:weather/features/auth/application/auth_state.dart';
import 'package:weather/features/auth/domain/auth_user.dart';

/// Điều phối viên (orchestrator) của flow đăng nhập/đăng xuất.
///
/// Chỉ làm ĐÚNG việc điều phối: gọi bridge → dịch kết quả → đổi state.
/// Không điều hướng, không hiện dialog — đó là việc của UI thông qua
/// `ref.listen(authProvider, ...)`. Nhờ vậy notifier test được không cần widget.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthChannel _channel;
  StreamSubscription<SessionEvent>? _sessionSubscription;

  @override
  AuthState build() {
    _channel = ref.watch(authChannelProvider);

    // Phiên hết hạn được phát từ AuthApiClient (khi nhận 401) — một chỗ duy
    // nhất trong app phản ứng với sự kiện đó là ở đây.
    _sessionSubscription = ref
        .watch(sessionEventBusProvider)
        .stream
        .listen(_onSessionEvent);
    ref.onDispose(() => _sessionSubscription?.cancel());

    // Khởi động SDK ngay khi provider được dựng. `unawaited` vì `build()` phải
    // trả về state đồng bộ.
    unawaited(start());

    return const AuthUnknown();
  }

  /// Khởi tạo SDK native rồi kiểm tra xem còn session cũ hợp lệ không.
  Future<void> start() async {
    state = const AuthBusy();
    try {
      await _channel.start();
      await _restoreSession();
    } on AuthException catch (e) {
      AppLogger.e('Khởi động SDK auth thất bại', e, null);
      state = AuthFailed(e.message);
    }
  }

  /// Bắt đầu journey đăng nhập.
  Future<void> login() async {
    state = const AuthBusy();
    await _advance(() => _channel.login(), operation: 'login');
  }

  /// Gửi câu trả lời của node hiện tại (map theo `_id` của callback).
  Future<void> submit(Map<int, String> answers) async {
    final AuthState current = state;
    if (current is! AuthNeedsInput) {
      AppLogger.w('submit() bị gọi khi không ở trạng thái nhập liệu.');
      return;
    }

    final FRNode answered = current.node.withAnswers(answers);
    state = AuthBusy(node: answered);

    await _advance(
      () => _channel.next(jsonEncode(answered.toJson())),
      operation: 'next',
      fallbackNode: current.node,
    );
  }

  /// Đăng xuất chủ động.
  Future<void> logout() async {
    state = const AuthBusy();
    try {
      await _channel.logout();
    } on AuthException catch (e) {
      // Logout lỗi vẫn phải coi như đã đăng xuất ở phía client: token native
      // có thể đã mất hiệu lực. Giữ user ở lại app mới là bug nguy hiểm.
      AppLogger.w('Logout native lỗi (vẫn xoá state cục bộ): $e');
    }
    state = const AuthUnauthenticated();
  }

  /// Chạy một bước journey (`login` hoặc `next`) và dịch kết quả sang state.
  Future<void> _advance(
    Future<String> Function() step, {
    required String operation,
    FRNode? fallbackNode,
  }) async {
    try {
      final String raw = await step();
      final JourneyStep result = JourneyStep.parse(raw, operation: operation);

      switch (result) {
        case JourneySuccess():
          await _loadUser();
        case JourneyNeedsInput(:final node):
          state = AuthNeedsInput(node);
      }
    } on AuthException catch (e) {
      AppLogger.e('Journey[$operation] lỗi', e, null);

      // Sai mật khẩu/OTP: giữ người dùng ở form, chỉ hiện lỗi. Hết phiên
      // journey: phải bắt đầu lại từ đầu.
      if (fallbackNode != null && !e.requiresReLogin) {
        state = AuthNeedsInput(fallbackNode, errorMessage: e.message);
      } else if (e.requiresReLogin) {
        state = AuthUnauthenticated(reason: e.message);
      } else {
        state = AuthFailed(e.message);
      }
    }
  }

  /// Đọc thông tin người dùng sau khi journey thành công.
  Future<void> _loadUser() async {
    try {
      final String raw = await _channel.getUserInfo();
      final Object? decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const AuthException(
          AuthErrorKind.parse,
          'Không đọc được thông tin người dùng.',
          operation: 'getUserInfo',
        );
      }

      state = AuthAuthenticated(AuthUser.fromJson(decoded));
    } on AuthException catch (e) {
      AppLogger.e('Lấy userinfo thất bại', e, null);
      state = AuthUnauthenticated(reason: e.message);
    } on FormatException catch (e) {
      AppLogger.e('userinfo không phải JSON hợp lệ', e, null);
      state = const AuthUnauthenticated(
        reason: 'Không đọc được thông tin người dùng.',
      );
    }
  }

  /// Thử dùng lại session còn lưu ở native (bỏ qua bước nhập lại mật khẩu).
  Future<void> _restoreSession() async {
    try {
      await _loadUser();
    } on AuthException catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  void _onSessionEvent(SessionEvent event) {
    switch (event) {
      case SessionEvent.expired:
        // Đã ở trạng thái chưa đăng nhập thì không phát lại (tránh dialog kép
        // khi nhiều request 401 cùng lúc).
        if (state is AuthUnauthenticated) {
          return;
        }
        state = const AuthUnauthenticated(
          reason: 'Phiên đăng nhập của bạn đã hết hạn.',
        );
      case SessionEvent.loggedOut:
        state = const AuthUnauthenticated();
    }
  }
}

/// Provider của tầng auth. UI dùng:
/// ```dart
/// final authState = ref.watch(authProvider);
/// ref.read(authProvider.notifier).login();
/// ```
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
