# 📘 Bài 02: Toán Tử & Luồng Điều Khiển Trong Dart

> **Mục tiêu**: Nắm vững tất cả toán tử, cấu trúc điều kiện, và vòng lặp trong Dart.

---

## 1. Toán Tử Số Học (Arithmetic Operators)

```dart
void main() {
  int a = 17;
  int b = 5;

  print(a + b);    // 22   — Cộng
  print(a - b);    // 12   — Trừ
  print(a * b);    // 85   — Nhân
  print(a / b);    // 3.4  — Chia (luôn trả về double!)
  print(a ~/ b);   // 3    — Chia lấy phần nguyên (integer division)
  print(a % b);    // 2    — Chia lấy phần dư (modulo)

  // Toán tử tăng/giảm
  int x = 10;
  x++;         // x = 11 (tăng 1)
  x--;         // x = 10 (giảm 1)
  ++x;         // x = 11 (tăng trước)
  --x;         // x = 10 (giảm trước)

  // Sự khác biệt prefix vs postfix
  int y = 5;
  print(y++);   // In 5 trước, rồi tăng y lên 6
  print(++y);   // Tăng y lên 7 trước, rồi in 7
}
```

> **Lưu ý**: Toán tử `/` trong Dart **luôn trả về `double`**, khác với nhiều ngôn ngữ khác. Dùng `~/` để chia lấy nguyên.

---

## 2. Toán Tử Gán (Assignment Operators)

```dart
void main() {
  int x = 10;

  x += 5;    // x = x + 5  → 15
  x -= 3;    // x = x - 3  → 12
  x *= 2;    // x = x * 2  → 24
  x ~/= 5;   // x = x ~/ 5 → 4
  x %= 3;    // x = x % 3  → 1

  // Null-aware assignment
  int? y;
  y ??= 10;   // y đang null → gán 10
  y ??= 20;   // y KHÔNG null (=10) → không gán
  print(y);   // 10
}
```

---

## 3. Toán Tử So Sánh (Comparison Operators)

```dart
void main() {
  int a = 10;
  int b = 20;

  print(a == b);   // false  — Bằng
  print(a != b);   // true   — Không bằng
  print(a > b);    // false  — Lớn hơn
  print(a < b);    // true   — Nhỏ hơn
  print(a >= b);   // false  — Lớn hơn hoặc bằng
  print(a <= b);   // true   — Nhỏ hơn hoặc bằng

  // So sánh Object
  var list1 = [1, 2, 3];
  var list2 = [1, 2, 3];
  print(list1 == list2);         // false! (so sánh reference, không phải nội dung)
  print(identical(list1, list2)); // false (không cùng object)

  // Muốn so sánh nội dung List → dùng package collection
  // import 'package:collection/collection.dart';
  // ListEquality().equals(list1, list2) → true
}
```

---

## 4. Toán Tử Logic (Logical Operators)

```dart
void main() {
  bool isAdult = true;
  bool hasLicense = false;

  // && — AND (và)
  print(isAdult && hasLicense);   // false (cả 2 phải true)

  // || — OR (hoặc)
  print(isAdult || hasLicense);   // true (1 trong 2 true là đủ)

  // ! — NOT (phủ định)
  print(!isAdult);                // false

  // Short-circuit evaluation (đánh giá ngắn mạch)
  // Dart dừng đánh giá ngay khi biết kết quả
  String? name;
  // name != null được đánh giá trước
  // Nếu false → không đánh giá name.length > 0 → tránh NullPointerException
  if (name != null && name.length > 0) {
    print('Có tên');
  }
}
```

---

## 5. Toán Tử Null-aware (Quan trọng! 🔥)

```dart
void main() {
  // --- ?. (Null-aware member access) ---
  String? name;
  print(name?.length);        // null (không crash)
  print(name?.toUpperCase()); // null

  // Chain nhiều lần
  String? result = name?.trim()?.toUpperCase();

  // --- ?? (If-null / Null coalescing) ---
  String? input;
  String display = input ?? 'Giá trị mặc định';
  print(display);   // 'Giá trị mặc định'

  // Chain ?? nhiều lần
  String? a;
  String? b;
  String c = 'fallback';
  String value = a ?? b ?? c;   // Lấy giá trị non-null đầu tiên

  // --- ??= (Null-aware assignment) ---
  String? city;
  city ??= 'Hà Nội';   // Gán chỉ khi null

  // --- ?[] (Null-aware index) ---
  List<int>? numbers;
  int? first = numbers?[0];   // null (không crash)

  // --- ...? (Null-aware spread) ---
  List<int>? extras;
  List<int> all = [1, 2, ...?extras];   // [1, 2] — bỏ qua nếu null
}
```

---

## 6. Toán Tử Điều Kiện (Conditional Operators)

```dart
void main() {
  int age = 20;

  // Ternary operator (toán tử 3 ngôi)
  String status = age >= 18 ? 'Người lớn' : 'Trẻ em';
  print(status);   // 'Người lớn'

  // Nested ternary (nên hạn chế — khó đọc)
  String category = age < 13
      ? 'Trẻ em'
      : age < 18
          ? 'Thiếu niên'
          : 'Người lớn';
}
```

---

## 7. Toán Tử Bitwise (Ít dùng, tham khảo)

```dart
void main() {
  int a = 5;   // 0101 trong binary
  int b = 3;   // 0011 trong binary

  print(a & b);    // 1  — AND (0001)
  print(a | b);    // 7  — OR  (0111)
  print(a ^ b);    // 6  — XOR (0110)
  print(~a);       // -6 — NOT
  print(a << 1);   // 10 — Shift left (1010)
  print(a >> 1);   // 2  — Shift right (0010)
  print(a >>> 1);  // 2  — Unsigned shift right
}
```

---

## 8. Cascade Operator (`..` và `?..`)

Cho phép gọi nhiều method/set nhiều property trên cùng 1 object mà không cần lặp lại tên biến.

```dart
class User {
  String name = '';
  int age = 0;
  String email = '';

  void greet() => print('Xin chào, tôi là $name');
}

void main() {
  // ❌ Không dùng cascade — lặp lại "user" nhiều lần
  var user1 = User();
  user1.name = 'Phong';
  user1.age = 25;
  user1.email = 'phong@email.com';
  user1.greet();

  // ✅ Dùng cascade — gọn hơn, dễ đọc hơn
  var user2 = User()
    ..name = 'Phong'
    ..age = 25
    ..email = 'phong@email.com'
    ..greet();

  // ?.. — Null-aware cascade
  User? user3;
  user3
    ?..name = 'Minh'
    ..age = 30;   // Chỉ thực hiện nếu user3 != null
}
```

---

## 9. Spread Operator (`...` và `...?`)

```dart
void main() {
  // Spread — "trải" các phần tử ra
  var list1 = [1, 2, 3];
  var list2 = [0, ...list1, 4, 5];
  print(list2);   // [0, 1, 2, 3, 4, 5]

  // Null-aware spread
  List<int>? maybeNull;
  var safe = [1, 2, ...?maybeNull];   // [1, 2]

  // Dùng với Set và Map
  var set1 = {1, 2};
  var set2 = {0, ...set1, 3};   // {0, 1, 2, 3}

  var map1 = {'a': 1};
  var map2 = {'b': 2, ...map1};  // {'b': 2, 'a': 1}
}
```

---

## 10. Cấu Trúc Điều Kiện

### 10.1. `if / else if / else`

```dart
void main() {
  int score = 85;

  if (score >= 90) {
    print('Xuất sắc');
  } else if (score >= 80) {
    print('Giỏi');
  } else if (score >= 65) {
    print('Khá');
  } else if (score >= 50) {
    print('Trung bình');
  } else {
    print('Yếu');
  }

  // If trong collection (collection if)
  bool showAdmin = true;
  var menu = [
    'Trang chủ',
    'Hồ sơ',
    if (showAdmin) 'Quản trị',   // Chỉ thêm vào nếu true
  ];
  print(menu);   // ['Trang chủ', 'Hồ sơ', 'Quản trị']
}
```

### 10.2. `switch / case`

```dart
void main() {
  String grade = 'B';

  switch (grade) {
    case 'A':
      print('Xuất sắc');
      break;
    case 'B':
      print('Giỏi');
      break;
    case 'C':
      print('Khá');
      break;
    case 'D':
    case 'E':       // Gộp case — D hoặc E đều in "Yếu"
      print('Yếu');
      break;
    default:
      print('Không hợp lệ');
  }
}
```

### 10.3. Switch Expression (Dart 3.0+) 🔥

```dart
void main() {
  String grade = 'B';

  // Switch expression — trả về giá trị trực tiếp
  String result = switch (grade) {
    'A' => 'Xuất sắc',
    'B' => 'Giỏi',
    'C' => 'Khá',
    'D' || 'E' => 'Yếu',    // OR pattern
    _ => 'Không hợp lệ',    // _ = default
  };
  print(result);   // 'Giỏi'

  // Switch expression với pattern matching
  Object value = 42;
  String type = switch (value) {
    int n when n > 0 => 'Số dương: $n',
    int n when n < 0 => 'Số âm: $n',
    int() => 'Số không',
    String s => 'Chuỗi: $s',
    _ => 'Kiểu khác',
  };
  print(type);   // 'Số dương: 42'
}
```

### 10.4. Pattern Matching (Dart 3.0+) 🔥

```dart
void main() {
  // Destructuring với pattern matching
  var point = (3, 5);
  var (x, y) = point;
  print('x=$x, y=$y');   // x=3, y=5

  // Pattern matching với if-case
  var json = {'name': 'Phong', 'age': 25};
  if (json case {'name': String name, 'age': int age}) {
    print('$name, $age tuổi');   // 'Phong, 25 tuổi'
  }

  // Switch với sealed class (exhaustive matching)
  // Xem thêm ở bài OOP
}
```

---

## 11. Vòng Lặp (Loops)

### 11.1. `for` — Vòng lặp cổ điển

```dart
void main() {
  // for cơ bản
  for (int i = 0; i < 5; i++) {
    print('Lần $i');   // 0, 1, 2, 3, 4
  }

  // for giảm dần
  for (int i = 5; i > 0; i--) {
    print(i);   // 5, 4, 3, 2, 1
  }

  // for nhảy bước
  for (int i = 0; i < 20; i += 3) {
    print(i);   // 0, 3, 6, 9, 12, 15, 18
  }

  // Nested for (vòng lặp lồng nhau)
  for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 3; j++) {
      print('($i, $j)');
    }
  }
}
```

### 11.2. `for-in` — Duyệt collection

```dart
void main() {
  var fruits = ['Táo', 'Cam', 'Xoài'];

  for (var fruit in fruits) {
    print(fruit);   // Táo, Cam, Xoài
  }

  // Duyệt Map
  var scores = {'Toán': 90, 'Lý': 85, 'Hóa': 88};
  for (var entry in scores.entries) {
    print('${entry.key}: ${entry.value}');
  }

  // Collection for — tạo list mới từ vòng lặp
  var numbers = [1, 2, 3, 4, 5];
  var doubled = [for (var n in numbers) n * 2];
  print(doubled);   // [2, 4, 6, 8, 10]

  // Kết hợp collection if + for
  var result = [
    for (var n in numbers)
      if (n.isEven) n * 10,
  ];
  print(result);   // [20, 40]
}
```

### 11.3. `while` và `do-while`

```dart
void main() {
  // while — kiểm tra điều kiện TRƯỚC khi lặp
  int count = 0;
  while (count < 3) {
    print('while: $count');
    count++;
  }

  // do-while — thực hiện ÍT NHẤT 1 lần, rồi kiểm tra
  int x = 10;
  do {
    print('do-while: $x');   // In 1 lần dù x >= 3
    x++;
  } while (x < 3);
}
```

### 11.4. `forEach`

```dart
void main() {
  var fruits = ['Táo', 'Cam', 'Xoài'];

  // forEach — gọn nhưng KHÔNG thể break/continue
  fruits.forEach((fruit) {
    print(fruit);
  });

  // Arrow function
  fruits.forEach((fruit) => print(fruit));

  // Tear-off (gọn nhất)
  fruits.forEach(print);
}
```

### 11.5. `break`, `continue`, và Labels

```dart
void main() {
  // break — thoát khỏi vòng lặp
  for (int i = 0; i < 10; i++) {
    if (i == 5) break;   // Dừng khi i = 5
    print(i);   // 0, 1, 2, 3, 4
  }

  // continue — bỏ qua lần lặp hiện tại
  for (int i = 0; i < 5; i++) {
    if (i == 2) continue;   // Bỏ qua i = 2
    print(i);   // 0, 1, 3, 4
  }

  // Labels — đặt tên cho vòng lặp, break/continue chính xác
  outerLoop:
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (i == 1 && j == 1) {
        break outerLoop;   // Thoát khỏi OUTER loop
      }
      print('($i, $j)');
    }
  }
  // Output: (0,0) (0,1) (0,2) (1,0)
}
```

### 11.6. Tổng hợp các loại vòng `for`

| Loại | Cú pháp | Khi nào dùng |
|:--|:--|:--|
| `for` cổ điển | `for (init; cond; step)` | Cần chỉ số `i`, bước nhảy, đếm ngược |
| `for-in` | `for (var x in iterable)` | Duyệt List/Set/Map.entries, không cần index |
| `for-in` + `.entries` | `for (var e in map.entries)` | Duyệt `Map` theo key/value |
| `for-in` + `.indexed` | `for (var (i, x) in list.indexed)` | Cần **cả index lẫn giá trị** (Dart 3.0+) |
| Collection `for` | `[for (var x in xs) x * 2]` | Sinh List/Set/Map mới ngay khi khai báo |
| `forEach` | `xs.forEach((x) { ... })` | Ngắn gọn, nhưng **không** dùng được `break`/`continue`/`await` |
| `await for` | `await for (var x in stream)` | Duyệt `Stream` bất đồng bộ ([Bài 05](./05_dart_async_programming.md)) |

```dart
void main() {
  var fruits = ['Táo', 'Cam', 'Xoài'];

  // .indexed — lấy cả index lẫn value (Dart 3.0+), thay cho asMap()
  for (var (index, fruit) in fruits.indexed) {
    print('$index: $fruit');   // 0: Táo, 1: Cam, 2: Xoài
  }
}
```

---

## 12. Các Từ Khoá Điều Khiển Khác (ngoài `switch/case`)

Ngoài `if`, `switch`, vòng lặp, Dart còn một số từ khoá điều khiển luồng quan trọng:

```dart
import 'dart:async';

// return — trả về giá trị và thoát khỏi hàm
int add(int a, int b) {
  return a + b;   // dừng hàm ngay tại đây
}

// assert — kiểm tra điều kiện (CHỈ chạy ở debug mode, bị bỏ qua khi release)
void setAge(int age) {
  assert(age >= 0, 'Tuổi không được âm');   // crash sớm khi dev sai
}

// throw / rethrow — ném lỗi (chi tiết ở Bài 06)
void checkPositive(int n) {
  if (n < 0) throw ArgumentError('n phải >= 0');
}

// yield / yield* — sinh giá trị cho generator (Iterable/Stream)
Iterable<int> countTo(int n) sync* {
  for (int i = 1; i <= n; i++) {
    yield i;          // "nhả" ra 1 giá trị mỗi vòng
  }
}

Stream<int> asyncCount(int n) async* {
  for (int i = 1; i <= n; i++) {
    yield i;          // nhả giá trị cho Stream
  }
}

void main() async {
  print(countTo(3).toList());   // [1, 2, 3]
}
```

> - `sync*` + `yield` → tạo `Iterable` (lazy). `async*` + `yield` → tạo `Stream`. Xem [Bài 05](./05_dart_async_programming.md).
> - `try` / `catch` / `on` / `finally` / `rethrow` → xử lý lỗi, xem [Bài 06](./06_dart_error_handling.md).

### Bảng tra cứu từ khoá Dart (Keywords)

| Nhóm | Từ khoá |
|:--|:--|
| Khai báo biến | `var` · `final` · `const` · `late` · `dynamic` · `void` |
| Kiểu & lớp | `class` · `enum` · `extension` · `typedef` · `mixin` · `abstract` · `interface` · `base` · `sealed` · `Function` |
| Kế thừa | `extends` · `implements` · `with` · `on` · `super` · `this` · `covariant` |
| Điều kiện/lặp | `if` · `else` · `switch` · `case` · `default` · `for` · `in` · `while` · `do` · `break` · `continue` |
| Pattern (Dart 3) | `when` · `_` (wildcard) · `\|\|` · `&&` (trong pattern) |
| Rẽ nhánh/lỗi | `return` · `throw` · `rethrow` · `try` · `catch` · `on` · `finally` · `assert` |
| Bất đồng bộ | `async` · `await` · `async*` · `await for` · `sync*` · `yield` · `yield*` |
| Kiểm tra kiểu | `is` · `is!` · `as` |
| Khác | `new` (không cần nữa) · `factory` · `get` · `set` · `static` · `external` · `required` |

---

## 13. Bảng Tổng Hợp Toán Tử

| Loại | Toán tử | Ví dụ |
|:-----|:--------|:------|
| Số học | `+  -  *  /  ~/  %` | `17 ~/ 5 → 3` |
| Tăng/giảm | `++  --` | `x++`, `--y` |
| Gán | `=  +=  -=  *=  ~/=  %=  ??=` | `x ??= 10` |
| So sánh | `==  !=  >  <  >=  <=` | `a >= b` |
| Logic | `&&  \|\|  !` | `a && b` |
| Null-aware | `?.  ??  ??=  ?[]  ...?` | `name?.length ?? 0` |
| Kiểu | `is  is!  as` | `x is String` |
| Cascade | `..  ?..` | `obj..a = 1..b = 2` |
| Spread | `...  ...?` | `[...list1, ...?list2]` |
| Bitwise | `&  \|  ^  ~  <<  >>  >>>` | `a & b` |
| Điều kiện | `? :` | `x > 0 ? 'yes' : 'no'` |

---

## 📝 Bài Tập Thực Hành

### Bài 1: FizzBuzz
In các số từ 1 đến 100:
- Chia hết cho 3: in "Fizz"
- Chia hết cho 5: in "Buzz"
- Chia hết cho cả 3 và 5: in "FizzBuzz"
- Còn lại: in số đó

### Bài 2: Bảng cửu chương
In bảng cửu chương từ 2 đến 9 dùng nested loop.

### Bài 3: Null-aware operators
Viết hàm `getDisplayName` nhận `String? firstName`, `String? lastName`, `String? nickname` và trả về:
- Nếu có nickname → trả nickname
- Nếu có firstName + lastName → trả "firstName lastName"
- Nếu chỉ có firstName → trả firstName
- Còn lại → trả "Anonymous"

### Bài 4: Switch Expression
Viết switch expression chuyển đổi HTTP status code (200, 201, 400, 401, 403, 404, 500) thành message tiếng Việt.

---

> **Bài tiếp theo**: [03 - Hàm & Lập trình hướng đối tượng](./03_dart_functions_and_oop.md)
