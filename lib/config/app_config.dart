/// Cấu hình theo môi trường (dev / staging / prod).
///
/// Mô hình: mỗi *entry point* (`main_dev.dart`, `main_staging.dart`,
/// `main_prod.dart`) gọi [AppConfig.init] đúng MỘT lần trước `runApp`,
/// chọn ra [Environment]. Sau đó mọi nơi trong app đọc [AppConfig.current].
///
/// Giá trị được biên dịch sẵn (compile-time) trong [_configs] nên type-safe,
/// không phụ thuộc file ngoài và không lộ secret. Nếu cần đổi giá trị mà
/// không build lại, có thể override bằng `--dart-define` (xem [_fromEnv]).
library;

/// Ba môi trường chuẩn của vòng đời phát triển.
enum Environment { dev, staging, prod }

/// Gói toàn bộ giá trị cấu hình của MỘT môi trường.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.showEnvBanner,
  });

  /// Môi trường hiện hành.
  final Environment environment;

  /// Tên hiển thị (có hậu tố Dev/Staging để phân biệt khi cài song song).
  final String appName;

  /// Base URL của backend RIÊNG của app (auth, lưu thành phố yêu thích...).
  ///
  /// Lưu ý: API thời tiết bên thứ ba (Open-Meteo) là cố định cho mọi môi
  /// trường nên vẫn đặt ở `AppConstants`, không nằm ở đây.
  final String apiBaseUrl;

  /// Bật log chi tiết (chỉ nên bật ở dev/staging).
  final bool enableLogging;

  /// Hiển thị dải băng góc màn hình báo môi trường (ẩn ở prod).
  final bool showEnvBanner;

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;
}

/// Bảng giá trị cố định cho từng môi trường.
const Map<Environment, EnvConfig> _configs = {
  Environment.dev: EnvConfig(
    environment: Environment.dev,
    appName: 'Weather Dev',
    apiBaseUrl: 'http://localhost:3000',
    enableLogging: true,
    showEnvBanner: true,
  ),
  Environment.staging: EnvConfig(
    environment: Environment.staging,
    appName: 'Weather Staging',
    apiBaseUrl: 'https://staging-api.weather.example.com',
    enableLogging: true,
    showEnvBanner: true,
  ),
  Environment.prod: EnvConfig(
    environment: Environment.prod,
    appName: 'Weather',
    apiBaseUrl: 'https://api.weather.example.com',
    enableLogging: false,
    showEnvBanner: false,
  ),
};

/// Điểm truy cập cấu hình toàn cục.
class AppConfig {
  const AppConfig._();

  static EnvConfig? _current;

  /// Khởi tạo cấu hình. Gọi đúng một lần ở entry point trước `runApp`.
  ///
  /// Cho phép override [apiBaseUrl] qua `--dart-define=API_URL=...` để đổi
  /// nhanh khi cần mà không phải sửa code.
  static void init(Environment env) {
    final base = _configs[env]!;
    _current = _fromEnv(base);
  }

  /// Cấu hình đang dùng. Ném [StateError] nếu quên gọi [init] (bắt lỗi sớm).
  static EnvConfig get current {
    final config = _current;
    if (config == null) {
      throw StateError(
        'AppConfig chưa được khởi tạo. Hãy gọi AppConfig.init(...) trong '
        'entry point (main_dev/staging/prod.dart) trước runApp().',
      );
    }
    return config;
  }

  /// `true` nếu đã [init] — hữu ích cho test/guard.
  static bool get isInitialized => _current != null;

  /// Áp các override từ `--dart-define` (nếu có) lên cấu hình gốc.
  static EnvConfig _fromEnv(EnvConfig base) {
    const apiUrlOverride = String.fromEnvironment('API_URL');
    return EnvConfig(
      environment: base.environment,
      appName: base.appName,
      apiBaseUrl: apiUrlOverride.isEmpty ? base.apiBaseUrl : apiUrlOverride,
      enableLogging: base.enableLogging,
      showEnvBanner: base.showEnvBanner,
    );
  }
}
