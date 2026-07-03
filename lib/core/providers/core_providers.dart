import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/core/network/api_client.dart';

/// Cung cấp một [ApiClient] dùng chung cho toàn app (dependency injection).
///
/// Mọi repository ở tầng feature sẽ `ref.watch(apiClientProvider)` để lấy
/// client thay vì tự khởi tạo `http.Client` — nhờ vậy dễ thay thế bằng bản
/// giả lập (mock) khi viết test.
///
/// `ref.onDispose` đảm bảo đóng kết nối khi provider bị huỷ.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});
