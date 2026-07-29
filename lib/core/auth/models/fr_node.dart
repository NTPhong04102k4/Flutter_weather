import 'package:weather/core/auth/models/fr_callback.dart';

/// Một *node* của journey ForgeRock: một bước trong luồng đăng nhập.
///
/// Vòng đời: native trả node → Dart render `callbacks` thành các ô nhập →
/// người dùng điền → gửi TRỌN node (đã điền `input`) lại qua `next`. Các field
/// `authId`, `authServiceId` là con trỏ trạng thái của AM: **phải giữ nguyên**,
/// nếu làm mất journey sẽ bị coi là hết hạn.
class FRNode {
  const FRNode({
    required this.callbacks,
    this.authId,
    this.authServiceId,
    this.stage,
    this.header,
    this.description,
  });

  factory FRNode.fromJson(Map<String, dynamic> json) {
    final Object? rawCallbacks = json['callbacks'];
    final List<FRCallback> callbacks = rawCallbacks is List
        ? rawCallbacks
              .whereType<Map<Object?, Object?>>()
              .map((e) => FRCallback.fromJson(e.cast<String, dynamic>()))
              .toList()
        : const [];

    return FRNode(
      callbacks: callbacks,
      authId: json['authId'] as String?,
      authServiceId: json['authServiceId'] as String?,
      stage: json['stage'] as String?,
      header: json['header'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Danh sách ô nhập của bước hiện tại.
  final List<FRCallback> callbacks;

  /// Token trạng thái journey của AM — bắt buộc gửi lại nguyên vẹn.
  final String? authId;

  /// Id của journey (`Login`, `ResetPassword`...).
  final String? authServiceId;

  /// Tên bước, do journey của AM đặt (dùng để đổi UI theo bước).
  final String? stage;

  /// Tiêu đề / mô tả do AM cấu hình.
  final String? header;
  final String? description;

  /// Chỉ những callback cần render ô nhập text.
  List<FRCallback> get textInputs =>
      callbacks.where((c) => c.isTextInput).toList();

  /// Gán câu trả lời theo `_id` của callback, trả về node MỚI.
  FRNode withAnswers(Map<int, String> answersByCallbackId) {
    return FRNode(
      callbacks: callbacks
          .map(
            (c) => answersByCallbackId.containsKey(c.id)
                ? c.withAnswer(answersByCallbackId[c.id])
                : c,
          )
          .toList(),
      authId: authId,
      authServiceId: authServiceId,
      stage: stage,
      header: header,
      description: description,
    );
  }

  Map<String, Object?> toJson() => {
    'authId': authId,
    'authServiceId': authServiceId,
    'stage': stage,
    'header': header,
    'description': description,
    'callbacks': callbacks.map((c) => c.toJson()).toList(),
  };
}
