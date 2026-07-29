/// Một cặp `name`/`value` trong `input`/`output` của callback ForgeRock.
///
/// `value` là `Object?` chứ không phải `String` vì AM có thể trả về số, bool
/// hoặc list (ví dụ `ChoiceCallback`).
class FRField {
  const FRField({required this.name, required this.value});

  factory FRField.fromJson(Map<String, dynamic> json) => FRField(
    name: json['name'] as String? ?? '',
    value: json['value'],
  );

  final String name;
  final Object? value;

  /// Trả về bản sao với giá trị mới (giữ tính bất biến — immutable).
  FRField withValue(Object? newValue) => FRField(name: name, value: newValue);

  Map<String, Object?> toJson() => {'name': name, 'value': value};
}

/// Một *callback* của journey ForgeRock — tương ứng MỘT ô nhập trên UI.
///
/// AM mô tả bước đăng nhập theo dạng dữ liệu: `output` là những gì server
/// muốn hiển thị (nhãn ô nhập), `input` là chỗ client điền câu trả lời rồi
/// gửi lại nguyên vẹn qua `next`.
class FRCallback {
  const FRCallback({
    required this.type,
    required this.id,
    required this.output,
    required this.input,
  });

  factory FRCallback.fromJson(Map<String, dynamic> json) {
    return FRCallback(
      type: json['type'] as String? ?? '',
      id: json['_id'] as int? ?? 0,
      output: _fields(json['output']),
      input: _fields(json['input']),
    );
  }

  /// Loại callback: `NameCallback`, `PasswordCallback`, `ChoiceCallback`...
  final String type;

  /// Thứ tự callback trong node (`_id` của AM).
  final int id;

  /// Dữ liệu server gửi xuống (nhãn, danh sách chọn...).
  final List<FRField> output;

  /// Dữ liệu client điền vào và gửi lên.
  final List<FRField> input;

  /// Ô nhập mật khẩu → UI phải bật `obscureText`.
  bool get isPassword => type == 'PasswordCallback';

  /// Có phải ô nhập text (tên đăng nhập / mật khẩu / OTP) hay không.
  bool get isTextInput =>
      isPassword || type == 'NameCallback' || type == 'StringAttributeInputCallback';

  /// Nhãn hiển thị. Ưu tiên field `prompt`, không có thì lấy output đầu tiên.
  String get prompt {
    for (final field in output) {
      if (field.name == 'prompt') {
        return field.value?.toString() ?? '';
      }
    }
    return output.isEmpty ? '' : output.first.value?.toString() ?? '';
  }

  /// Điền câu trả lời vào `input[0]` và trả về callback MỚI.
  ///
  /// Code cũ (GetX) sửa trực tiếp `frCallback.input[0].value = ...` — dễ sinh
  /// bug khi cùng một node bị render lại. Ở đây node là bất biến: mỗi lần trả
  /// lời tạo ra một node mới.
  FRCallback withAnswer(Object? answer) {
    final List<FRField> updated = input.isEmpty
        ? [FRField(name: 'IDToken${id + 1}', value: answer)]
        : [input.first.withValue(answer), ...input.skip(1)];

    return FRCallback(type: type, id: id, output: output, input: updated);
  }

  Map<String, Object?> toJson() => {
    'type': type,
    '_id': id,
    'output': output.map((f) => f.toJson()).toList(),
    'input': input.map((f) => f.toJson()).toList(),
  };

  static List<FRField> _fields(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((e) => FRField.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
