/// Barrel export của feature auth.
///
/// Feature khác chỉ cần `import 'package:weather/features/auth/auth_module.dart';`
/// là có `authProvider`, `AuthState` và `LoginPage`. Hạ tầng (bridge native,
/// tenant, client) nằm ở `package:weather/core/auth/*` và được nối qua
/// `core_providers`.
library;

export 'application/auth_notifier.dart';
export 'application/auth_state.dart';
export 'domain/auth_user.dart';
export 'presentation/login_page.dart';

/// Hằng số route của feature.
class AuthModule {
  const AuthModule._();

  static const String loginRoute = '/login';
}
