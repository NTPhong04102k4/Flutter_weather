# 📘 Bài 01: Kiểu Dữ Liệu & Khai Báo Biến Trong Dart

> **Mục tiêu**: Hiểu tất cả kiểu dữ liệu trong Dart, cách khai báo biến, và Null Safety.

---

## 1. Tổng Quan Kiểu Dữ Liệu

Trong Dart, **mọi thứ đều là object** (kể cả số nguyên `int`). Dart là ngôn ngữ **strongly typed** — mỗi biến đều có kiểu dữ liệu xác định.

```
Kiểu dữ liệu trong Dart
├── Numbers (Số)
│   ├── int     — Số nguyên
│   ├── double  — Số thực (dấu phẩy động)
│   └── num     — Kiểu cha của int và double
├── String      — Chuỗi ký tự
├── bool        — Giá trị logic (true/false)
├── List<T>     — Danh sách (mảng)
├── Set<T>      — Tập hợp (không trùng lặp)
├── Map<K,V>    — Bảng ánh xạ key-value
├── Runes       — Unicode characters
├── Symbol      — Ký hiệu (ít dùng)
├── Null        — Giá trị null
├── dynamic     — Kiểu động (bất kỳ)
├── Object      — Kiểu cha của mọi object
└── void        — Không trả về giá trị
└── var, final, const — Khai báo biến (sẽ học sau)
└── Object?     — Kiểu có thể null (sẽ học sau)
└── Never       — Kiểu không bao giờ trả về giá trị
└── ?           — Toán tử null-aware (sẽ học sau)
└── ??          — Toán tử null-aware (sẽ học sau)
└── ??=         — Toán tử null-aware (sẽ học sau)
└── !           — Toán tử null-aware (sẽ học sau)
└── ?.          — Toán tử null-aware (sẽ học sau)
└── ?:          — Toán tử null-aware (sẽ học sau)

check biến _variable và variable 

```

---

## 2. Kiểu Số (Numbers)

### 2.1. `int` — Số nguyên

```dart
void main() {
  int age = 25;
  int temperature = -10;
  int hexValue = 0xFF;        // Hệ 16: 255
  int bigNumber = 1000000;
  int readable = 1_000_000;   // Dart cho phép dùng _ để dễ đọc

  print(age);           // 25
  print(hexValue);      // 255
  print(readable);      // 1000000
}
```

> **Lưu ý**: Trên web (compile to JS), `int` có phạm vi từ `-2^53` đến `2^53`. Trên native (mobile/desktop), phạm vi là `-2^63` đến `2^63 - 1`.

### 2.2. `double` — Số thực

```dart
void main() {
  double price = 99.99;
  double pi = 3.14159;
  double exponent = 1.5e3;   // 1500.0 (ký hiệu khoa học)
  double negative = -0.5;

  print(price);      // 99.99
  print(exponent);   // 1500.0

  // ⚠️ Lưu ý: double có sai số floating-point
  print(0.1 + 0.2);           // 0.30000000000000004
  print(0.1 + 0.2 == 0.3);   // false !!!
}
```

### 2.3. `num` — Kiểu cha

```dart
void main() {
  num value1 = 42;      // Có thể gán int
  num value2 = 3.14;    // Có thể gán double

  // num chấp nhận cả int lẫn double
  // Hữu ích khi hàm cần nhận cả 2 loại số
}

double calculateDiscount(num price, num percent) {
  return price * percent / 100;  // Tự động tính toán
}
```

### 2.4. Các phương thức hữu ích của Number

```dart
void main() {
  // --- Chuyển đổi ---
  int a = 42;
  double b = a.toDouble();          // int → double: 42.0
  int c = 3.99.toInt();             // double → int: 3 (cắt phần thập phân)
  int d = 3.99.round();             // Làm tròn: 4
  int e = 3.99.ceil();              // Làm tròn lên: 4
  int f = 3.99.floor();             // Làm tròn xuống: 3

  // --- Parse từ String ---
  int parsed = int.parse('123');            // '123' → 123
  double parsed2 = double.parse('3.14');    // '3.14' → 3.14
  int? tryParsed = int.tryParse('abc');     // null (không throw exception)

  // --- Format ---
  double price = 1234.5678;
  print(price.toStringAsFixed(2));    // "1234.57" (2 số thập phân)
  print(price.toStringAsFixed(0));    // "1235"

  // --- Kiểm tra ---
  print(42.isEven);      // true (số chẵn)
  print(42.isOdd);       // false (số lẻ)
  print(0.0.isNaN);      // false
  print(double.infinity.isInfinite);  // true
  print((-5).abs());     // 5 (giá trị tuyệt đối)
}
```

---

## 3. Kiểu Chuỗi (String)

### 3.1. Khai báo String

```dart
void main() {
  // Dùng nháy đơn hoặc nháy kép đều được
  String name1 = 'Phong';
  String name2 = "Phong";

  // Chuỗi nhiều dòng — dùng 3 dấu nháy
  String multiLine = '''
    Đây là chuỗi
    nhiều dòng
    trong Dart
  ''';

  String multiLine2 = """
    Cũng là chuỗi
    nhiều dòng
  """;

  // Raw string — không xử lý escape characters
  String path = r'C:\Users\phong\Documents';  // r'' = raw string
  print(path);  // C:\Users\phong\Documents (không bị lỗi \U, \p, \D)
}
```

### 3.2. String Interpolation (Nội suy chuỗi)

```dart
void main() {
  String name = 'Phong';
  int age = 25;

  // Cách 1: Dùng $ cho biến đơn giản
  print('Xin chào $name, bạn $age tuổi');

  // Cách 2: Dùng ${} cho biểu thức
  print('Năm sau bạn ${age + 1} tuổi');
  print('Tên viết HOA: ${name.toUpperCase()}');

  // ❌ SAI — Đừng dùng + để nối chuỗi khi có thể dùng interpolation
  print('Xin chào ' + name + ', bạn ' + age.toString() + ' tuổi');

  // ✅ ĐÚNG — Dùng interpolation (dễ đọc hơn, hiệu quả hơn)
  print('Xin chào $name, bạn $age tuổi');
}
```

### 3.3. Các phương thức String thường dùng

```dart
void main() {
  String text = '  Hello, Dart World!  ';

  // --- Cắt, tách ---
  print(text.trim());                    // 'Hello, Dart World!' (bỏ khoảng trắng 2 đầu)
  print(text.trimLeft());               // 'Hello, Dart World!  '
  print('Hello, Dart'.substring(7));     // 'Dart' (từ index 7 đến hết)
  print('Hello, Dart'.substring(0, 5)); // 'Hello' (từ 0 đến 4)
  print('a,b,c'.split(','));            // ['a', 'b', 'c']

  // --- Tìm kiếm ---
  print('Hello'.contains('ell'));        // true
  print('Hello'.startsWith('He'));       // true
  print('Hello'.endsWith('lo'));         // true
  print('Hello'.indexOf('l'));           // 2 (vị trí đầu tiên)
  print('Hello'.lastIndexOf('l'));       // 3 (vị trí cuối cùng)

  // --- Thay thế ---
  print('Hello World'.replaceAll('l', 'L'));     // 'HeLLo WorLd'
  print('Hello World'.replaceFirst('l', 'L'));   // 'HeLlo World'

  // --- Chuyển đổi ---
  print('hello'.toUpperCase());          // 'HELLO'
  print('HELLO'.toLowerCase());          // 'hello'

  // --- Thông tin ---
  print('Hello'.length);                 // 5
  print(''.isEmpty);                     // true
  print('Hi'.isNotEmpty);               // true

  // --- Khác ---
  print('Ha' * 3);                       // 'HaHaHa' (lặp lại)
  print('Hello'.padLeft(10, '*'));       // '*****Hello'
  print('Hello'.padRight(10, '-'));      // 'Hello-----'
  print('Hello'[0]);                     // 'H' (truy cập ký tự theo index)
}
```

---

## 4. Kiểu Boolean (`bool`)

```dart
void main() {
  bool isLoggedIn = true;
  bool isAdmin = false;

  // Dart KHÔNG tự chuyển đổi kiểu khác sang bool như JavaScript
  // ❌ SAI trong Dart:
  // if (1) { ... }         // Lỗi! 1 không phải bool
  // if ('hello') { ... }   // Lỗi! String không phải bool
  // if (null) { ... }      // Lỗi! null không phải bool

  // ✅ ĐÚNG — phải so sánh tường minh
  int count = 1;
  if (count > 0) {
    print('Có dữ liệu');
  }

  String? name;
  if (name != null && name.isNotEmpty) {
    print('Tên: $name');
  }
}
```

> ⚠️ **Khác biệt với JavaScript**: Dart **không có** khái niệm "truthy/falsy". Chỉ `true` và `false` là giá trị boolean hợp lệ.

---

## 5. Kiểu `Null` và `undefined`

### Dart KHÔNG có `undefined`

```dart
void main() {
  // Trong JavaScript:
  //   let x;          → x = undefined
  //   let y = null;   → y = null
  //   (undefined ≠ null)

  // Trong Dart:
  //   KHÔNG CÓ undefined
  //   Chỉ có null
  //   Mọi biến PHẢI được khởi tạo trước khi sử dụng (trừ nullable)

  // ❌ Lỗi — biến chưa khởi tạo
  // int x;
  // print(x);  // Error: Non-nullable variable must be assigned

  // ✅ Đúng — khai báo nullable với dấu ?
  int? x;       // x = null
  print(x);     // null
}
```

---

## 6. Null Safety (Quan trọng! 🔥)

Dart 3.x sử dụng **Sound Null Safety** — biến mặc định **không thể null** trừ khi khai báo rõ ràng.

### 6.1. Non-nullable vs Nullable

```dart
void main() {
  // Non-nullable — KHÔNG thể gán null
  String name = 'Phong';
  // name = null;  // ❌ Lỗi compile-time!

  // Nullable — CÓ THỂ gán null (thêm ? sau kiểu)
  String? nickname;       // = null mặc định
  nickname = 'Phong Pro';
  nickname = null;        // ✅ OK
}
```

### 6.2. Null-aware operators

```dart
void main() {
  String? name;

  // --- ?. (Null-aware access) ---
  // Gọi method chỉ khi không null, nếu null → trả về null
  print(name?.toUpperCase());    // null (không bị crash)
  name = 'Phong';
  print(name?.toUpperCase());    // 'PHONG'

  // --- ?? (Null coalescing) ---
  // Dùng giá trị mặc định nếu null
  String? input;
  String display = input ?? 'Chưa nhập';
  print(display);    // 'Chưa nhập'

  // --- ??= (Null-aware assignment) ---
  // Gán giá trị CHỈ KHI biến đang null
  String? city;
  city ??= 'Hà Nội';    // city đang null → gán 'Hà Nội'
  print(city);           // 'Hà Nội'
  city ??= 'Sài Gòn';   // city KHÔNG null → không gán
  print(city);           // 'Hà Nội'

  // --- ! (Null assertion / Bang operator) ---
  // Khẳng định biến KHÔNG null (nguy hiểm nếu dùng sai!)
  String? value = 'Hello';
  String nonNull = value!;   // ✅ OK — value có giá trị
  print(nonNull);            // 'Hello'

  // ⚠️ CẢNH BÁO: Nếu value = null → Runtime Exception!
  // String? nullValue;
  // String crash = nullValue!;  // 💥 Null check operator used on a null value
}
```

### 6.3. `late` keyword

```dart
class UserProfile {
  // late = "Tôi hứa sẽ khởi tạo trước khi sử dụng"
  late String name;
  late int age;

  // Lazy initialization — chỉ tính khi truy cập lần đầu
  late final String greeting = _computeGreeting();

  String _computeGreeting() {
    print('Đang tính greeting...');  // Chỉ in 1 lần
    return 'Xin chào, $name!';
  }

  void init(String name, int age) {
    this.name = name;
    this.age = age;
  }
}

void main() {
  var profile = UserProfile();
  // print(profile.name);  // ❌ LateInitializationError!
  profile.init('Phong', 25);
  print(profile.name);     // ✅ 'Phong'
  print(profile.greeting); // 'Đang tính greeting...' rồi 'Xin chào, Phong!'
  print(profile.greeting); // 'Xin chào, Phong!' (không tính lại)
}
```

---

## 7. Khai Báo Biến

### 7.1. Khai báo với kiểu cụ thể

```dart
void main() {
  int age = 25;
  double price = 99.99;
  String name = 'Phong';
  bool isActive = true;
  List<int> numbers = [1, 2, 3];
  Map<String, int> scores = {'math': 90, 'english': 85};
}
```

### 7.2. `var` — Type Inference (Suy luận kiểu)

```dart
void main() {
  var name = 'Phong';      // Dart tự suy luận: String
  var age = 25;             // Dart tự suy luận: int
  var prices = [1.5, 2.3]; // Dart tự suy luận: List<double>

  // Sau khi suy luận, KHÔNG thể đổi kiểu
  // name = 123;  // ❌ Lỗi! name đã là String

  name = 'Minh';  // ✅ OK — vẫn là String

  // var không khai báo giá trị → kiểu dynamic
  var something;           // dynamic
  something = 'Hello';    // OK
  something = 123;        // OK — dynamic cho phép đổi kiểu
}
```

### 7.3. `dynamic` — Kiểu động

```dart
void main() {
  dynamic value = 'Hello';
  print(value.runtimeType);   // String

  value = 42;
  print(value.runtimeType);   // int

  value = true;
  print(value.runtimeType);   // bool

  // ⚠️ dynamic tắt type checking → dễ gây lỗi runtime
  // dynamic x = 'Hello';
  // print(x.nonExistentMethod());  // 💥 Runtime Error (không có lỗi compile-time)
}
```

> **Quy tắc**: Hạn chế dùng `dynamic`. Ưu tiên khai báo kiểu cụ thể hoặc dùng `var`.

### 7.4. `Object` vs `dynamic`

```dart
void main() {
  Object obj = 'Hello';     // Object là kiểu cha của mọi thứ
  // obj.toUpperCase();      // ❌ Lỗi compile-time! Object không có toUpperCase

  dynamic dyn = 'Hello';
  dyn.toUpperCase();         // ✅ Compile OK (nhưng nếu gọi sai → runtime error)

  // Object an toàn hơn dynamic vì compiler vẫn kiểm tra
  if (obj is String) {
    print(obj.toUpperCase());  // ✅ Sau khi check type → có thể dùng method
  }
}
```

### 7.5. `final` — Gán một lần, không thể thay đổi

```dart
void main() {
  final String name = 'Phong';
  // name = 'Minh';  // ❌ Lỗi! final không thể gán lại

  final age = 25;     // Có thể bỏ kiểu, Dart tự suy luận

  // ⚠️ final chỉ ngăn GÁN LẠI, không ngăn thay đổi nội dung
  final List<int> numbers = [1, 2, 3];
  numbers.add(4);      // ✅ OK — thay đổi nội dung list
  // numbers = [5, 6]; // ❌ Lỗi — không thể gán list mới

  // final có thể gán giá trị tại runtime
  final now = DateTime.now();  // ✅ Giá trị được xác định khi chạy
}
```

### 7.6. `const` — Hằng số compile-time

```dart
void main() {
  const double pi = 3.14159;
  const String appName = 'Weather App';
  // pi = 3.14;  // ❌ Lỗi!

  // const PHẢI biết giá trị tại compile-time
  // const now = DateTime.now();  // ❌ Lỗi! DateTime.now() chỉ biết khi runtime

  // const list — toàn bộ list bất biến (immutable)
  const List<int> numbers = [1, 2, 3];
  // numbers.add(4);     // ❌ Runtime Error! Không thể thay đổi const list
  // numbers = [5, 6];   // ❌ Compile Error! Không thể gán lại

  // const tạo "canonical instance" — tiết kiệm bộ nhớ
  const a = [1, 2, 3];
  const b = [1, 2, 3];
  print(identical(a, b));  // true — cùng 1 object trong bộ nhớ!
}
```

### 7.7. So sánh `var` vs `final` vs `const`

| Đặc điểm | `var` | `final` | `const` |
|:---------|:-----:|:-------:|:-------:|
| Gán lại giá trị | ✅ Được | ❌ Không | ❌ Không |
| Thay đổi nội dung (mutate) | ✅ Được | ✅ Được | ❌ Không |
| Giá trị xác định khi nào | Runtime | Runtime | Compile-time |
| Ví dụ | `var x = 1;` | `final x = DateTime.now();` | `const x = 3.14;` |

> **Quy tắc vàng**: Ưu tiên dùng `const` > `final` > `var`. Dùng cái nào nghiêm ngặt nhất có thể.

---

## 8. `typedef` — Định nghĩa alias cho kiểu

```dart
// Tạo tên gọi tắt cho kiểu phức tạp
typedef StringList = List<String>;
typedef JsonMap = Map<String, dynamic>;
typedef CompareFunction = int Function(int a, int b);

void main() {
  StringList names = ['Phong', 'Minh', 'Hoa'];
  JsonMap user = {'name': 'Phong', 'age': 25};

  CompareFunction ascending = (a, b) => a.compareTo(b);
  print([3, 1, 2]..sort(ascending));  // [1, 2, 3]
}
```

---

## 9. `enum` — Kiểu liệt kê

```dart
// Enum cơ bản
enum Status { active, inactive, pending }

// Enhanced enum (Dart 2.17+) — enum mạnh mẽ hơn
enum Planet {
  mercury(diameter: 4879, moons: 0),
  venus(diameter: 12104, moons: 0),
  earth(diameter: 12756, moons: 1),
  mars(diameter: 6792, moons: 2);

  final double diameter;
  final int moons;

  const Planet({required this.diameter, required this.moons});

  // Có thể có method
  bool get hasMoons => moons > 0;

  @override
  String toString() => 'Planet $name: diameter=$diameter km, moons=$moons';
}

void main() {
  // Enum cơ bản
  var status = Status.active;
  print(status.name);      // 'active'
  print(status.index);     // 0
  print(Status.values);    // [Status.active, Status.inactive, Status.pending]

  // Switch với enum — Dart cảnh báo nếu thiếu case
  switch (status) {
    case Status.active:
      print('Đang hoạt động');
      break;
    case Status.inactive:
      print('Ngừng hoạt động');
      break;
    case Status.pending:
      print('Đang chờ');
      break;
  }

  // Enhanced enum
  var myPlanet = Planet.earth;
  print(myPlanet);                  // Planet earth: diameter=12756.0 km, moons=1
  print(myPlanet.hasMoons);        // true
  print(Planet.mars.diameter);      // 6792.0
}
```

---

## 10. Type Testing & Casting

```dart
void main() {
  Object value = 'Hello Dart';

  // is — kiểm tra kiểu
  if (value is String) {
    // Sau "is String", Dart tự động cast → dùng được method của String
    print(value.toUpperCase());   // 'HELLO DART' — không cần cast thủ công!
  }

  // is! — kiểm tra KHÔNG phải kiểu đó
  if (value is! int) {
    print('Không phải số nguyên');
  }

  // as — ép kiểu (casting) — nguy hiểm nếu sai kiểu
  Object number = 42;
  int n = number as int;     // ✅ OK
  // String s = number as String;  // 💥 CastError!
}
```

---

## 11. Bảng Tổng Hợp

| Kiểu | Mô tả | Ví dụ | Nullable |
|:-----|:------|:------|:-----:|
| `int` | Số nguyên | `42`, `-10`, `0xFF` | `int?` |
| `double` | Số thực | `3.14`, `-0.5`, `1.5e3` | `double?` |
| `num` | Số (cha của int, double) | `42` hoặc `3.14` | `num?` |
| `String` | Chuỗi | `'Hello'`, `"World"` | `String?` |
| `bool` | Logic | `true`, `false` | `bool?` |
| `List<T>` | Danh sách | `[1, 2, 3]` | `List<T>?` |
| `Set<T>` | Tập hợp | `{1, 2, 3}` | `Set<T>?` |
| `Map<K,V>` | Key-Value | `{'a': 1}` | `Map<K,V>?` |
| `dynamic` | Kiểu động | bất kỳ | — |
| `void` | Không trả về | — | — |
| `Null` | Giá trị null | `null` | — |

---

## 📝 Bài Tập Thực Hành

### Bài 1: Khai báo biến
Khai báo các biến sau với kiểu phù hợp nhất:
- Tên người dùng (không thay đổi sau khi gán)
- Tuổi (có thể null nếu chưa nhập)
- Số dư tài khoản (có phần thập phân)
- Danh sách sở thích

### Bài 2: Null Safety
```dart
// Sửa code sau để không bị lỗi
void main() {
  String? name;
  print(name.length);  // Lỗi! Làm sao fix?
}
```

### Bài 3: const vs final
Giải thích tại sao đoạn code sau bị lỗi:
```dart
void main() {
  const time = DateTime.now();   // Lỗi gì? Tại sao?
  final list = const [1, 2, 3];
  list.add(4);                    // Lỗi gì? Tại sao?
}
```

---

> **Bài tiếp theo**: [02 - Toán tử & Luồng điều khiển](./02_dart_operators_and_control_flow.md)
