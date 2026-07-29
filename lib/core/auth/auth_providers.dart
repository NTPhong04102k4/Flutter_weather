import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/config/app_config.dart';
import 'package:weather/core/auth/auth_api_client.dart';
import 'package:weather/core/auth/auth_channel.dart';
import 'package:weather/core/auth/fake_auth_channel.dart';
import 'package:weather/core/auth/session_event_bus.dart';
import 'package:weather/core/auth/tenant_context.dart';

/// Ngữ cảnh tenant, dựng từ cấu hình môi trường đang chạy.
///
/// Vì là `Provider`, mọi nơi (client, notifier, test) đều nhận CÙNG một
/// instance — không còn cảnh mỗi nơi tự đọc config rồi tự ghép header.
final tenantContextProvider = Provider<TenantContext>((ref) {
  return TenantContext(tenantId: AppConfig.current.tenantId);
});

/// Bridge tới engine IAM. Ở dev có thể thay bằng [FakeAuthChannel].
///
/// Đây là điểm "cắm/rút" của toàn bộ tầng auth: đổi ForgeRock sang engine khác
/// chỉ cần override provider này.
final authChannelProvider = Provider<AuthChannel>((ref) {
  if (AppConfig.current.useFakeAuthBridge) {
    return FakeAuthChannel();
  }
  return const MethodChannelAuthChannel();
});

/// Kênh sự kiện phiên — nghe ở tầng auth, phát ở tầng network.
final sessionEventBusProvider = Provider<SessionEventBus>((ref) {
  final bus = SessionEventBus();
  ref.onDispose(bus.close);
  return bus;
});

/// Client cho API nội bộ cần đăng nhập (đã có tenant + token).
///
/// Feature nào cần gọi API nội bộ thì `ref.read(authApiClientProvider)` —
/// không cần biết tới `MethodChannel`, token hay header tenant.
final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(
    channel: ref.watch(authChannelProvider),
    tenant: ref.watch(tenantContextProvider),
    sessionEvents: ref.watch(sessionEventBusProvider),
  );
});
