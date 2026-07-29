/// Ngữ cảnh **tenant** (đơn vị/khách hàng) của phiên làm việc hiện tại.
///
/// ## `tenantId` là gì?
///
/// Backend là hệ **multi-tenant**: một cụm máy chủ + một database phục vụ
/// nhiều công ty. Cùng một endpoint `GET /Users/profile`, dữ liệu trả về phải
/// khác nhau tuỳ công ty nào đang gọi. Máy chủ phân biệt bằng header
/// `TenantId` — một GUID định danh công ty:
///
/// ```http
/// GET /Users/profile HTTP/1.1
/// Authorization: Bearer eyJhbGciOi...      ← AI đang gọi (do native gắn)
/// TenantId: 00000000-1111-2222-3333-...    ← DỮ LIỆU CỦA AI (do lớp này gắn)
/// ```
///
/// Hai header trả lời hai câu hỏi khác nhau và **do hai nơi khác nhau gắn**:
///  - `Authorization`: SDK ForgeRock ở native gắn, vì access token nằm trong
///    Keychain/Keystore và có thể cần refresh — Dart không được giữ token.
///  - `TenantId`: là **cấu hình ứng dụng**, không phải secret → thuộc về Dart.
///
/// ## Vì sao không hardcode như `app-hrm`?
///
/// Ở `app-hrm`, GUID tenant bị viết cứng ở **3 chỗ** trong Java và **2 chỗ**
/// trong Swift (`callEndpoint`, `uploadFiles`, `callChangePassword`). Hậu quả:
/// đổi tenant phải sửa native + build lại 2 nền tảng, và dev/staging/prod
/// dùng chung một GUID. Gom về [TenantContext] thì tenant là dữ liệu chạy
/// theo môi trường (`AppConfig`), native chỉ còn việc chuyển tiếp header.
class TenantContext {
  const TenantContext({
    required this.tenantId,
    this.headerName = defaultHeaderName,
    this.locale = 'vi-VN',
    this.appVersion,
    this.deviceId,
  });

  /// Tên header quy ước với backend (viết hoa/thường phải khớp gateway).
  static const String defaultHeaderName = 'TenantId';

  /// GUID định danh tenant. Lấy từ `AppConfig.current.tenantId`.
  final String tenantId;

  /// Cho phép đổi tên header mà không sửa call site (khi backend đổi quy ước).
  final String headerName;

  /// Ngôn ngữ mong muốn cho nội dung trả về (`Accept-Language`).
  final String locale;

  /// Phiên bản app — server dùng để bật/tắt tính năng, chẩn đoán lỗi.
  final String? appVersion;

  /// Định danh thiết bị (không phải secret) — phục vụ audit log.
  final String? deviceId;

  /// `true` nếu tenant đã được cấu hình hợp lệ.
  bool get isConfigured => tenantId.isNotEmpty;

  /// Bộ header GẮN VÀO MỌI REQUEST của app.
  ///
  /// Cố tình KHÔNG chứa `Authorization`: token do native quản lý (xem doc lớp).
  Map<String, String> baseHeaders() {
    if (!isConfigured) {
      throw StateError(
        'tenantId đang rỗng. Hãy cấu hình trong AppConfig hoặc truyền '
        '--dart-define=TENANT_ID=<guid> khi build.',
      );
    }

    return {
      headerName: tenantId,
      'Accept': 'application/json',
      'Accept-Language': locale,
      // `?value` (null-aware element): bỏ hẳn entry nếu giá trị null.
      'X-App-Version': ?appVersion,
      'X-Device-Id': ?deviceId,
    };
  }

  /// Ghép [baseHeaders] với header riêng của một request.
  ///
  /// [extra] được áp SAU nên có thể ghi đè (ví dụ đổi `Content-Type` khi gửi
  /// form), nhưng header tenant thì không nên ghi đè — đó là chủ đích.
  Map<String, String> headersFor({
    Map<String, String>? extra,
    String? correlationId,
  }) {
    return {
      ...baseHeaders(),
      'X-Correlation-Id': ?correlationId,
      ...?extra,
    };
  }

  TenantContext copyWith({
    String? tenantId,
    String? headerName,
    String? locale,
    String? appVersion,
    String? deviceId,
  }) {
    return TenantContext(
      tenantId: tenantId ?? this.tenantId,
      headerName: headerName ?? this.headerName,
      locale: locale ?? this.locale,
      appVersion: appVersion ?? this.appVersion,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
