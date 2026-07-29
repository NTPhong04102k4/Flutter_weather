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
    required this.tenantId,
    required this.useFakeAuthBridge,
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

  /// GUID định danh tenant, gắn vào header `TenantId` của mọi request nội bộ.
  ///
  /// KHÔNG phải secret (chỉ định danh "dữ liệu của ai", không cấp quyền), nên
  /// để ở đây là an toàn. Mỗi môi trường một tenant riêng để dữ liệu test
  /// không lẫn vào tenant thật. Override khi build bằng
  /// `--dart-define=TENANT_ID=<guid>`. Xem `TenantContext`.
  final String tenantId;

  /// Dùng bridge auth giả lập thay cho SDK ForgeRock native.
  ///
  /// Bật ở dev để chạy/luyện UI journey khi máy chưa cài SDK. Ở prod luôn
  /// `false` — nếu bật nhầm, app sẽ "đăng nhập" bằng dữ liệu giả.
  final bool useFakeAuthBridge;

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
    // Placeholder — điền GUID tenant dev thật khi nối backend.
    tenantId: '11111111-1111-1111-1111-111111111111',
    useFakeAuthBridge: true,
  ),
  Environment.staging: EnvConfig(
    environment: Environment.staging,
    appName: 'Weather Staging',
    apiBaseUrl: 'https://staging-api.weather.example.com',
    enableLogging: true,
    showEnvBanner: true,
    tenantId: '22222222-2222-2222-2222-222222222222',
    useFakeAuthBridge: false,
  ),
  Environment.prod: EnvConfig(
    environment: Environment.prod,
    appName: 'Weather',
    apiBaseUrl: 'https://api.weather.example.com',
    enableLogging: false,
    showEnvBanner: false,
    // Cố tình để rỗng: prod BẮT BUỘC truyền qua
    // `--dart-define=TENANT_ID=<guid>`. Nếu quên, request đầu tiên sẽ ném
    // StateError ngay — tốt hơn là âm thầm gửi tenant sai.
    tenantId: '',
    useFakeAuthBridge: false,
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
    const tenantOverride = String.fromEnvironment('TENANT_ID');
    return EnvConfig(
      environment: base.environment,
      appName: base.appName,
      apiBaseUrl: apiUrlOverride.isEmpty ? base.apiBaseUrl : apiUrlOverride,
      enableLogging: base.enableLogging,
      showEnvBanner: base.showEnvBanner,
      tenantId: tenantOverride.isEmpty ? base.tenantId : tenantOverride,
      useFakeAuthBridge: base.useFakeAuthBridge,
    );
  }
}
