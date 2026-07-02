import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'core/core.dart';

/// Widget gốc của app — chỉ lo cấu hình toàn cục:
/// theme (sáng/tối), điều hướng, route khởi đầu và băng báo môi trường.
///
/// Mọi màn hình cụ thể nằm ở tầng feature và được nối qua [AppRouter].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.current.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Bọc toàn app bằng băng môi trường (tự ẩn ở prod).
      builder: (context, child) =>
          EnvBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
