/// Hằng số toàn cục của app — gom về một chỗ để dễ chỉnh sửa.
///
/// Quy ước: KHÔNG hardcode URL / timeout / key rải rác trong feature.
/// Mọi giá trị "magic" nên khai báo ở đây.
class AppConstants {
  const AppConstants._();

  /// Tên app (hiển thị, log).
  static const String appName = 'Personal Internal';

  /// Base URL của API thời tiết.
  ///
  /// Dùng Open-Meteo: miễn phí, không cần API key — hợp cho mục đích học.
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';

  /// API tra cứu toạ độ theo tên thành phố (geocoding).
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1';

  /// Thời gian chờ tối đa cho một request mạng.
  static const Duration networkTimeout = Duration(seconds: 15);
}
