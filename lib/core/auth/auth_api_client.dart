import 'dart:convert';

import 'package:weather/core/auth/auth_channel.dart';
import 'package:weather/core/auth/auth_exception.dart';
import 'package:weather/core/auth/session_event_bus.dart';
import 'package:weather/core/auth/tenant_context.dart';
import 'package:weather/core/utils/logger.dart';

/// Client cho **API nội bộ cần đăng nhập** — đi qua bridge native, không qua
/// `package:http`.
///
/// So với [ApiClient] (dùng cho API công khai như Open-Meteo), lớp này khác ở
/// một điểm mấu chốt: request KHÔNG do Dart phát ra. Dart chỉ mô tả request
/// (url, method, body, header), native mới thực sự gửi — vì access token nằm
/// trong Keychain/Keystore do SDK ForgeRock quản lý, và chỉ SDK biết khi nào
/// phải refresh token.
///
/// Trách nhiệm của lớp này:
///  1. Ghép URL + query an toàn.
///  2. Bơm header tenant (xem [TenantContext]) vào MỌI request — một chỗ duy nhất.
///  3. Giải mã JSON, chuẩn hoá lỗi về [AuthException].
///  4. Phát [SessionEvent.expired] khi phiên hết hạn để tầng auth phản ứng.
class AuthApiClient {
  AuthApiClient({
    required AuthChannel channel,
    required TenantContext tenant,
    SessionEventBus? sessionEvents,
  }) : _channel = channel,
       _tenant = tenant,
       _sessionEvents = sessionEvents;

  final AuthChannel _channel;
  final TenantContext _tenant;
  final SessionEventBus? _sessionEvents;

  /// GET — [query] được ép về String và encode đúng chuẩn.
  Future<Object?> get(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    return send(method: 'GET', url: url, query: query, headers: headers);
  }

  /// POST với body JSON.
  Future<Object?> post(
    String url, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    return send(
      method: 'POST',
      url: url,
      body: body,
      query: query,
      headers: headers,
    );
  }

  /// PUT với body JSON.
  Future<Object?> put(
    String url, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    return send(
      method: 'PUT',
      url: url,
      body: body,
      query: query,
      headers: headers,
    );
  }

  /// DELETE.
  Future<Object?> delete(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    return send(method: 'DELETE', url: url, query: query, headers: headers);
  }

  /// Điểm vào duy nhất của mọi request có xác thực.
  ///
  /// [correlationId] (nếu truyền) sẽ đi vào header `X-Correlation-Id`, giúp dò
  /// một request xuyên qua log của app ↔ gateway ↔ service.
  Future<Object?> send({
    required String method,
    required String url,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? correlationId,
  }) async {
    final String finalUrl = _withQuery(url, query);
    final String encodedBody = body == null ? '' : jsonEncode(body);
    final Map<String, String> finalHeaders = _tenant.headersFor(
      extra: {
        if (body != null) 'Content-Type': 'application/json; charset=utf-8',
        ...?headers,
      },
      correlationId: correlationId,
    );

    AppLogger.i('→ $method $finalUrl');

    try {
      final String raw = await _channel.callEndpoint(
        url: finalUrl,
        method: method,
        body: encodedBody,
        headers: finalHeaders,
      );

      return _decode(raw, method: method, url: finalUrl);
    } on AuthException catch (e) {
      // Một chỗ duy nhất phát hiện phiên hết hạn cho toàn bộ app — thay vì
      // mỗi provider tự bắt lỗi rồi tự hiện dialog "đăng nhập lại".
      if (e.requiresReLogin) {
        _sessionEvents?.emit(SessionEvent.expired);
      }
      rethrow;
    }
  }

  /// Ghép query string vào URL đã có sẵn (giữ nguyên query cũ nếu có).
  String _withQuery(String url, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) {
      return url;
    }

    final Uri uri = Uri.parse(url);
    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            ...query.map((key, value) => MapEntry(key, '$value')),
          },
        )
        .toString();
  }

  /// Giải mã body JSON; body rỗng (204 No Content) trả về `null`.
  Object? _decode(String raw, {required String method, required String url}) {
    if (raw.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(raw);
    } on FormatException catch (e) {
      throw AuthException(
        AuthErrorKind.parse,
        'Dữ liệu trả về không hợp lệ.',
        operation: '$method $url',
        details: '${e.message} | $raw',
      );
    }
  }
}
