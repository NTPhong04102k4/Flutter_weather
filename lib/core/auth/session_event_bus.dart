import 'dart:async';

/// Sự kiện vòng đời phiên đăng nhập.
enum SessionEvent {
  /// Phiên hết hạn (native trả 401 / token không refresh được).
  expired,

  /// Người dùng chủ động đăng xuất.
  loggedOut,
}

/// Kênh phát sự kiện phiên, cắt vòng phụ thuộc giữa network và auth.
///
/// Vấn đề: [AuthApiClient] là nơi PHÁT HIỆN phiên hết hạn (nhận 401), nhưng
/// nơi XỬ LÝ lại là `AuthNotifier` (đổi state, điều hướng về login). Nếu client
/// gọi trực tiếp notifier thì hai lớp phụ thuộc vòng tròn nhau.
///
/// Cách giải: client chỉ `emit(SessionEvent.expired)`; notifier `listen`. Hai
/// bên không biết nhau — dễ test, dễ thay thế.
class SessionEventBus {
  final StreamController<SessionEvent> _controller =
      StreamController<SessionEvent>.broadcast();

  /// Luồng sự kiện (broadcast — nhiều nơi có thể nghe cùng lúc).
  Stream<SessionEvent> get stream => _controller.stream;

  /// Phát một sự kiện. Bỏ qua nếu bus đã đóng (tránh crash lúc dispose).
  void emit(SessionEvent event) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(event);
  }

  /// Đóng bus — gọi trong `ref.onDispose`.
  Future<void> close() => _controller.close();
}
