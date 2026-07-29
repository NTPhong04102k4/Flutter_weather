import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/core/core.dart';
import 'package:weather/features/auth/application/auth_notifier.dart';
import 'package:weather/features/auth/application/auth_state.dart';

/// Màn hình đăng nhập — render ô nhập ĐỘNG theo node journey.
///
/// Điểm cần nhớ: form này không biết trước sẽ có mấy ô. Journey của AM quyết
/// định (username + password, thêm OTP, đổi mật khẩu lần đầu...). Đổi journey
/// trên AM thì UI tự đổi theo, không cần build lại app.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final Map<int, TextEditingController> _controllers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(FRCallback callback) {
    return _controllers.putIfAbsent(callback.id, TextEditingController.new);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final Map<int, String> answers = {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    ref.read(authProvider.notifier).submit(answers);
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SafeArea(child: _body(state)),
    );
  }

  Widget _body(AuthState state) {
    // `sealed class` → switch này buộc phải phủ hết mọi trạng thái; thêm state
    // mới mà quên xử lý là lỗi compile, không phải bug lúc chạy.
    return switch (state) {
      AuthUnknown() => const AppLoading(message: 'Đang khởi động...'),
      AuthBusy() => const AppLoading(message: 'Đang xử lý...'),
      AuthFailed(:final message) => AppErrorView(
        message: message,
        onRetry: () => ref.read(authProvider.notifier).start(),
      ),
      AuthUnauthenticated(:final reason) => _StartLoginView(
        reason: reason,
        onLogin: () => ref.read(authProvider.notifier).login(),
      ),
      AuthNeedsInput(:final node, :final errorMessage) => _journeyForm(
        node.textInputs,
        errorMessage,
      ),
      AuthAuthenticated(:final user) => _SignedInView(
        name: user.displayName,
        onLogout: () => ref.read(authProvider.notifier).logout(),
      ),
    };
  }

  Widget _journeyForm(List<FRCallback> inputs, String? errorMessage) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage),
            const SizedBox(height: 16),
          ],
          for (final callback in inputs) ...[
            TextFormField(
              controller: _controllerFor(callback),
              obscureText: callback.isPassword,
              enableSuggestions: !callback.isPassword,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: callback.prompt,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Vui lòng nhập ${callback.prompt.toLowerCase()}'
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _submit,
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}

/// Màn hình chờ trước khi bắt đầu journey (hoặc sau khi bị đẩy ra vì hết phiên).
class _StartLoginView extends StatelessWidget {
  const _StartLoginView({required this.onLogin, this.reason});

  final VoidCallback onLogin;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reason != null) ...[
              _ErrorBanner(message: reason!),
              const SizedBox(height: 24),
            ],
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hiển thị nhanh người dùng hiện tại (thay cho việc điều hướng ngay về home,
/// giúp dễ kiểm thử thủ công tầng auth).
class _SignedInView extends StatelessWidget {
  const _SignedInView({required this.name, required this.onLogout});

  final String name;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 56),
          const SizedBox(height: 16),
          Text('Xin chào $name'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
