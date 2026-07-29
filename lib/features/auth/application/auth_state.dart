import 'package:weather/core/auth/models/fr_node.dart';
import 'package:weather/features/auth/domain/auth_user.dart';

/// Trạng thái của tầng auth — `sealed` nên UI buộc phải xử lý đủ mọi nhánh.
///
/// So với `enum AuthStatus` + vài biến rời (`currentNode`, `user`, `errorMsg`)
/// như code cũ: ở đây dữ liệu ĐI KÈM trạng thái, nên không thể có tổ hợp vô
/// nghĩa kiểu "authenticated nhưng user == null".
sealed class AuthState {
  const AuthState();
}

/// Chưa biết — đang khởi động SDK / kiểm tra session cũ (màn splash).
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// Đang chờ native (start SDK, login, next, logout).
class AuthBusy extends AuthState {
  const AuthBusy({this.node});

  /// Node đang hiển thị (nếu có) — giữ lại để UI không bị nhảy về trắng khi
  /// đang gửi câu trả lời.
  final FRNode? node;
}

/// Journey cần người dùng nhập tiếp — [node] chứa danh sách ô nhập.
class AuthNeedsInput extends AuthState {
  const AuthNeedsInput(this.node, {this.errorMessage});

  final FRNode node;

  /// Lỗi của lần gửi trước (sai mật khẩu...) — hiển thị ngay trên form.
  final String? errorMessage;
}

/// Đã đăng nhập.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;
}

/// Chưa/không còn đăng nhập. [reason] khác `null` khi bị đẩy ra do hết phiên.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.reason});

  final String? reason;
}

/// Lỗi không thuộc journey (SDK chưa init, thiếu bridge, mất mạng lúc start).
class AuthFailed extends AuthState {
  const AuthFailed(this.message);

  final String message;
}
