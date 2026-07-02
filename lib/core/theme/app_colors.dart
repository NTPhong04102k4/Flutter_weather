import 'package:flutter/material.dart';

/// Bảng màu của app.
///
/// Tách riêng màu khỏi [ThemeData] để tái sử dụng ở chỗ cần màu thủ công
/// (gradient, icon, biểu đồ...) mà không phụ thuộc context.
class AppColors {
  const AppColors._();

  /// Màu chủ đạo — dùng làm seed cho [ColorScheme].
  static const Color seed = Color(0xFF1E88E5);

  /// Màu nền cho card thời tiết ban ngày / ban đêm.
  static const Color skyDayTop = Color(0xFF4FC3F7);
  static const Color skyDayBottom = Color(0xFF1976D2);
  static const Color skyNightTop = Color(0xFF283593);
  static const Color skyNightBottom = Color(0xFF0D1333);

  /// Màu trạng thái.
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
}
