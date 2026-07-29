import 'package:flutter/material.dart';

import 'package:weather/features/auth/presentation/login_page.dart';
import 'package:weather/features/home/presentation/home_page.dart';

/// Tên các route — tránh gõ chuỗi tay rải rác (dễ sai chính tả).
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
}

/// Bộ định tuyến tập trung của app.
///
/// [MaterialApp.onGenerateRoute] gọi [onGenerateRoute] mỗi khi điều hướng tới
/// một route có tên. Mỗi feature mới chỉ cần thêm một `case` ở đây.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _page(const HomePage(), settings);
      case AppRoutes.login:
        return _page(const LoginPage(), settings);
      default:
        return _page(_UnknownRoutePage(name: settings.name), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}

/// Màn hình dự phòng khi điều hướng tới route không tồn tại.
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy')),
      body: Center(child: Text('Route không tồn tại: ${name ?? '?'}')),
    );
  }
}
