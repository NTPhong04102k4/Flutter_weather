import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/network/api_exception.dart';

/// Lớp bọc (wrapper) mỏng quanh `package:http`.
///
/// Trách nhiệm:
///  - Ghép base URL + path + query thành [Uri].
///  - Áp timeout chung ([AppConstants.networkTimeout]).
///  - Giải mã JSON và kiểm tra status code.
///  - Chuẩn hoá mọi sự cố thành [ApiException] để tầng trên xử lý đồng nhất.
///
/// KHÔNG chứa logic nghiệp vụ (không biết "weather" là gì) — đó là việc của
/// repository ở tầng feature. Đây thuần tuý là tầng truyền tải.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  /// Gửi GET tới [baseUrl]/[path] và trả về JSON đã giải mã (Map hoặc List).
  ///
  /// Ném [ApiException] khi: mất mạng, timeout, status ngoài 2xx, hoặc JSON lỗi.
  Future<dynamic> getJson(
    String baseUrl,
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(baseUrl, path, queryParameters);

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConstants.networkTimeout);

      return _decode(response);
    } on SocketException {
      throw const ApiException('Không có kết nối mạng.');
    } on TimeoutException {
      throw const ApiException('Yêu cầu quá thời gian chờ.');
    } on http.ClientException catch (e) {
      throw ApiException('Lỗi kết nối: ${e.message}');
    }
  }

  /// Ghép URI an toàn, ép mọi giá trị query về String.
  Uri _buildUri(
    String baseUrl,
    String path,
    Map<String, dynamic>? queryParameters,
  ) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final base = Uri.parse(baseUrl);

    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((s) => s.isNotEmpty),
        ...normalizedPath.split('/').where((s) => s.isNotEmpty),
      ],
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );
  }

  /// Kiểm tra status code và giải mã body JSON.
  dynamic _decode(http.Response response) {
    final code = response.statusCode;

    if (code < 200 || code >= 300) {
      throw ApiException('Máy chủ trả về lỗi ($code).', statusCode: code);
    }

    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  /// Giải phóng kết nối khi không dùng nữa.
  void close() => _client.close();
}
