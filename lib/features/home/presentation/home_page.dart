import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../core/core.dart';

/// Màn hình chủ tạm thời — minh hoạ cách feature TIÊU THỤ tầng core.
///
/// Đây chưa phải feature thời tiết hoàn chỉnh, mà là điểm tựa cho thấy
/// core đã sẵn sàng: dùng [AppColors] cho nền, và [AppLoading]/[AppErrorView]
/// đã có sẵn để tái sử dụng khi cắm API thật vào.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = AppConfig.current;

    return Scaffold(
      appBar: AppBar(title: Text(config.appName)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyDayTop, AppColors.skyDayBottom],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wb_sunny, size: 96, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Core đã sẵn sàng ☀️',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'network · theme · error · router · widgets',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _ConfigRow(label: 'ENV', value: config.environment.name),
              _ConfigRow(label: 'API', value: config.apiBaseUrl),
              _ConfigRow(label: 'Logging', value: '${config.enableLogging}'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một dòng "nhãn: giá trị" để xem nhanh cấu hình môi trường đang chạy.
class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
