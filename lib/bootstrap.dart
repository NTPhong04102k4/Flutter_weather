import 'package:flutter/widgets.dart';

import 'config/app_config.dart';
import 'core/core.dart';

/// Phần khởi tạo DÙNG CHUNG cho mọi entry point.
///
/// Tách ra đây để 3 file `main_*.dart` chỉ khác nhau đúng một dòng
/// ([Environment] truyền vào), tránh lặp code khởi tạo.
void bootstrap(Environment env) {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init(env);
  AppLogger.i('Khởi động môi trường: ${AppConfig.current.environment.name}');
}
