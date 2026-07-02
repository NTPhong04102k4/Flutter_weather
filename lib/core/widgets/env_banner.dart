import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../theme/app_colors.dart';

/// Bọc app bằng dải băng góc màn hình báo môi trường (DEV / STAGING).
///
/// Dùng cho [MaterialApp.builder]. Ở prod ([EnvConfig.showEnvBanner] = false)
/// sẽ trả về [child] nguyên vẹn, không có băng.
class EnvBanner extends StatelessWidget {
  const EnvBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.current;
    if (!config.showEnvBanner) return child;

    return Banner(
      message: config.environment.name.toUpperCase(),
      location: BannerLocation.topStart,
      color: config.isStaging ? AppColors.warning : AppColors.error,
      child: child,
    );
  }
}
