import 'package:flutter/foundation.dart';

import 'package:weather/config/app_config.dart';

/// Logger tối giản, TÔN TRỌNG cấu hình môi trường.
///
/// Chỉ in log khi [EnvConfig.enableLogging] bật (dev/staging) — ở prod sẽ
/// im lặng, tránh rò rỉ thông tin và giảm nhiễu. Thay cho `print()` rải rác.
class AppLogger {
  const AppLogger._();

  static bool get _enabled =>
      AppConfig.isInitialized && AppConfig.current.enableLogging;

  /// Log thông tin.
  static void i(Object? message) => _log('ℹ️', message);

  /// Log cảnh báo.
  static void w(Object? message) => _log('⚠️', message);

  /// Log lỗi kèm error/stackTrace tuỳ chọn.
  static void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log('⛔', message);
    if (error != null) _log('⛔', error);
    if (stackTrace != null) _log('⛔', stackTrace);
  }

  static void _log(String tag, Object? message) {
    if (!_enabled) return;
    // debugPrint tự throttle khi log dài, tránh mất dòng trên Android.
    debugPrint('$tag [${AppConfig.current.environment.name}] $message');
  }
}
