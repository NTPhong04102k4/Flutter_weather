/// Người dùng đã đăng nhập, dựng từ payload `userinfo` của ForgeRock AM.
///
/// AM trả về rất nhiều claim tuỳ cấu hình journey; ở đây chỉ giữ những gì UI
/// thực sự dùng. Thêm claim mới thì thêm field — không truyền `Map` thô lên UI.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      // AM dùng `sub` (subject) làm id chuẩn OIDC.
      id: (json['sub'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['preferred_username'] ?? '').toString(),
      email: json['email'] as String?,
    );
  }

  final String id;
  final String name;
  final String? email;

  /// Tên hiển thị fallback về email/id nếu journey không trả `name`.
  String get displayName {
    if (name.isNotEmpty) {
      return name;
    }
    return email ?? id;
  }
}
