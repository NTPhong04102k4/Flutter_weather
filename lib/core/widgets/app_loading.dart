import 'package:flutter/material.dart';

/// Trạng thái đang tải dùng chung — căn giữa, kèm nhãn tuỳ chọn.
///
/// Dùng ở mọi nơi cần loading để giao diện đồng nhất, thay vì lặp lại
/// `Center(child: CircularProgressIndicator())` khắp nơi.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
