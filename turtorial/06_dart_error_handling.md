# 📘 Bài 06: Xử Lý Lỗi & Exception Trong Dart

> **Mục tiêu**: Nắm vững cách xử lý lỗi, tạo custom exceptions, và best practices.

---

## 1. Error vs Exception

```
Error vs Exception trong Dart:

┌──────────────┐    ┌───────────────────┐
│    Error     │    │    Exception      │
│ (Lỗi nghiêm │    │ (Lỗi có thể xử   │
│  trọng, KHÔNG│    │  lý, NÊN catch)   │
│  nên catch)  │    │                   │
├──────────────┤    ├───────────────────┤
│ StackOverflow│    │ FormatException   │
│ OutOfMemory  │    │ IOException       │
│ StateError   │    │ HttpException     │
│ TypeError    │    │ TimeoutException  │
└──────────────┘    └───────────────────┘
```

---

## 2. try / catch / finally

```dart
void main() {
  // Cơ bản
  try {
    int result = 10 ~/ 0;   // Chia cho 0
    print(result);
  } catch (e) {
    print('Lỗi: $e');   // Lỗi: IntegerDivisionByZeroException
  }

  // Catch với stack trace
  try {
    var list = [1, 2, 3];
    print(list[10]);   // RangeError
  } catch (e, stackTrace) {
    print('Lỗi: $e');
    print('Stack trace:\n$stackTrace');
  }

  // on — catch kiểu lỗi cụ thể
  try {
    var number = int.parse('abc');
  } on FormatException catch (e) {
    print('Lỗi format: $e');
  } on TypeError catch (e) {
    print('Lỗi kiểu: $e');
  } catch (e) {
    print('Lỗi khác: $e');   // Catch-all
  }

  // finally — LUÔN chạy, dù có lỗi hay không
  try {
    print('Mở file...');
    // readFile();
    print('Đọc xong');
  } catch (e) {
    print('Lỗi: $e');
  } finally {
    print('Đóng file (luôn chạy)');
  }
}
```

---

## 3. throw & rethrow

```dart
// throw — ném exception
void validateAge(int age) {
  if (age < 0) {
    throw ArgumentError('Tuổi không thể âm: $age');
  }
  if (age > 150) {
    throw RangeError('Tuổi không hợp lệ: $age');
  }
}

// throw Exception
void login(String email, String password) {
  if (email.isEmpty) {
    throw Exception('Email không được trống');
  }
  if (password.length < 6) {
    throw FormatException('Mật khẩu phải >= 6 ký tự');
  }
}

// rethrow — ném lại lỗi sau khi xử lý
void fetchData() {
  try {
    // Gọi API...
    throw Exception('Network error');
  } catch (e) {
    print('Log lỗi: $e');   // Xử lý (log)
    rethrow;                  // Ném lại cho caller xử lý tiếp
  }
}

void main() {
  try {
    validateAge(-5);
  } on ArgumentError catch (e) {
    print('Lỗi: $e');
  }

  try {
    fetchData();
  } catch (e) {
    print('Caller nhận lỗi: $e');
  }
}
```

---

## 4. Custom Exception

```dart
// Tạo Exception class riêng
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? endpoint;

  ApiException({
    required this.statusCode,
    required this.message,
    this.endpoint,
  });

  @override
  String toString() => 'ApiException($statusCode): $message'
      '${endpoint != null ? ' at $endpoint' : ''}';

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final Map<String, String> errors;
  ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: $errors';
}

// Sử dụng
Future<Map<String, dynamic>> fetchUser(int id) async {
  // Giả lập response
  int statusCode = 404;

  if (statusCode == 401) {
    throw ApiException(
      statusCode: 401,
      message: 'Token hết hạn',
      endpoint: '/api/users/$id',
    );
  }
  if (statusCode == 404) {
    throw ApiException(
      statusCode: 404,
      message: 'Không tìm thấy user',
      endpoint: '/api/users/$id',
    );
  }

  return {'id': id, 'name': 'Phong'};
}

void main() async {
  try {
    var user = await fetchUser(999);
    print(user);
  } on ApiException catch (e) {
    if (e.isNotFound) {
      print('User không tồn tại');
    } else if (e.isUnauthorized) {
      print('Vui lòng đăng nhập lại');
    } else {
      print('Lỗi API: $e');
    }
  } on NetworkException catch (e) {
    print('Không có kết nối: $e');
  } catch (e) {
    print('Lỗi không xác định: $e');
  }
}
```

---

## 5. Xử Lý Lỗi Với async/await

```dart
// Lỗi trong Future
Future<String> riskyOperation() async {
  await Future.delayed(Duration(seconds: 1));
  throw Exception('Có gì đó sai sai!');
}

void main() async {
  // Cách 1: try/catch
  try {
    var result = await riskyOperation();
    print(result);
  } catch (e) {
    print('Caught: $e');
  }

  // Cách 2: then/catchError (ít dùng với async/await)
  riskyOperation()
      .then((value) => print(value))
      .catchError((e) => print('Caught: $e'));

  // Xử lý lỗi trong Future.wait
  try {
    var results = await Future.wait([
      Future.value('OK'),
      Future.error('Fail'),
      Future.value('Also OK'),
    ]);
  } catch (e) {
    print('Một trong các Future bị lỗi: $e');
  }

  // Future.wait với eagerError: false — chờ TẤT CẢ hoàn thành
  try {
    var results = await Future.wait(
      [
        Future.value('OK'),
        Future.error('Fail 1'),
        Future.error('Fail 2'),
      ],
      eagerError: false,   // Chờ tất cả, collect tất cả lỗi
    );
  } catch (e) {
    print('Lỗi: $e');   // Chỉ throw lỗi đầu tiên
  }
}
```

---

## 6. assert — Kiểm Tra Debug-time

```dart
void main() {
  int age = -5;

  // assert CHỈ hoạt động trong DEBUG MODE
  // Trong release build → bị bỏ qua hoàn toàn
  assert(age >= 0, 'Tuổi phải >= 0, nhận được: $age');

  // Thường dùng trong constructor
}

class Temperature {
  final double celsius;

  Temperature(this.celsius)
      : assert(celsius >= -273.15, 'Nhiệt độ không thể dưới 0 tuyệt đối');

  double get fahrenheit => celsius * 9 / 5 + 32;
}
```

---

## 7. Result Pattern — Thay Thế Exception

Thay vì throw exception, trả về object `Result` chứa thành công hoặc thất bại.

```dart
// Sealed class Result
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String error;
  final int? code;
  const Failure(this.error, {this.code});
}

// Sử dụng
Future<Result<Map<String, dynamic>>> fetchUser(int id) async {
  try {
    await Future.delayed(Duration(seconds: 1));

    if (id <= 0) {
      return Failure('ID không hợp lệ', code: 400);
    }

    return Success({'id': id, 'name': 'Phong'});
  } catch (e) {
    return Failure('Lỗi kết nối: $e', code: 500);
  }
}

void main() async {
  var result = await fetchUser(1);

  // Exhaustive switch — không quên case nào
  switch (result) {
    case Success(data: var user):
      print('User: ${user['name']}');
    case Failure(error: var msg, code: var code):
      print('Lỗi ($code): $msg');
  }

  // Hoặc dùng if-case
  if (result case Success(data: var user)) {
    print('Thành công: $user');
  }
}
```

---

## 8. Best Practices

```dart
// ✅ 1. Catch kiểu cụ thể, không catch chung
try {
  // code
} on FormatException catch (e) {
  // Xử lý format error
} on IOException catch (e) {
  // Xử lý IO error
}
// ❌ Tránh: catch (e) {} — nuốt tất cả lỗi

// ✅ 2. Không bao giờ catch rỗng (swallow errors)
try {
  // code
} catch (e) {
  print('Error: $e');   // Ít nhất phải log
  // ❌ ĐỪNG: catch (e) {} — nuốt lỗi, rất khó debug
}

// ✅ 3. Dùng rethrow thay vì throw e
try {
  // code
} catch (e) {
  // rethrow;    // ✅ Giữ nguyên stack trace
  // throw e;    // ❌ Mất stack trace gốc
}

// ✅ 4. Dùng finally cho cleanup
StreamSubscription? subscription;
try {
  subscription = stream.listen(handleData);
} catch (e) {
  print('Error: $e');
} finally {
  subscription?.cancel();   // Luôn cleanup
}

// ✅ 5. Prefer Result pattern cho expected errors
// Dùng Exception cho unexpected errors (bugs)
// Dùng Result cho expected errors (validation, network)
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Custom Exception
Tạo `AuthException` với các factory constructors:
- `AuthException.invalidCredentials()`
- `AuthException.tokenExpired()`
- `AuthException.accountLocked(Duration remaining)`

### Bài 2: Error Handling Chain
Viết 3 hàm async: `connectDB()` → `queryData()` → `parseResult()`.
Mỗi hàm có thể throw exception khác nhau. Xử lý tất cả lỗi trong `main()`.

### Bài 3: Result Pattern
Implement `Result<T>` pattern cho form validation:
- Validate email, password, phone
- Trả `Success` hoặc `Failure` với thông báo lỗi cụ thể

---

> **Bài tiếp theo**: [07 - Race Condition & Search Cache](./07_dart_race_condition_and_cache.md)
