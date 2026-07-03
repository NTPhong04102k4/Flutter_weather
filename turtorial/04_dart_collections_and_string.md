# 📘 Bài 04: Collections & Xử Lý Chuỗi/Số Trong Dart

> **Mục tiêu**: Thành thạo `List`, `Set`, `Map` và các kỹ thuật xử lý dữ liệu.

---

## PHẦN A: COLLECTIONS

## 1. List<T> — Danh Sách (Mảng)

### 1.1. Tạo List

```dart
void main() {
  // Khai báo với kiểu cụ thể
  List<int> numbers = [1, 2, 3, 4, 5];
  List<String> names = ['Phong', 'Minh', 'Hoa'];

  // Type inference
  var scores = [90, 85, 78, 95];     // List<int>
  var mixed = [1, 'hello', true];    // List<Object>

  // List rỗng
  var emptyList = <int>[];           // Cách 1
  List<int> emptyList2 = [];         // Cách 2

  // List với kích thước cố định
  var fixedList = List<int>.filled(5, 0);      // [0, 0, 0, 0, 0]
  var generated = List<int>.generate(5, (i) => i * 2);  // [0, 2, 4, 6, 8]

  // Const list — bất biến
  const constList = [1, 2, 3];
  // constList.add(4);  // ❌ Runtime Error!

  // Unmodifiable list — bất biến từ list có sẵn
  var original = [1, 2, 3];
  var unmodifiable = List.unmodifiable(original);
  // unmodifiable.add(4);  // ❌ Runtime Error!
}
```

### 1.2. CRUD Operations

```dart
void main() {
  var fruits = ['Táo', 'Cam', 'Xoài'];

  // CREATE — Thêm phần tử
  fruits.add('Nho');                      // Thêm cuối: [Táo, Cam, Xoài, Nho]
  fruits.addAll(['Dưa', 'Ổi']);          // Thêm nhiều: [..., Dưa, Ổi]
  fruits.insert(0, 'Lê');                // Thêm ở vị trí 0: [Lê, Táo, ...]
  fruits.insertAll(2, ['Mít', 'Bưởi']); // Thêm nhiều ở vị trí 2

  // READ — Đọc
  print(fruits[0]);              // Phần tử đầu tiên
  print(fruits.first);           // Phần tử đầu tiên
  print(fruits.last);            // Phần tử cuối cùng
  print(fruits.length);          // Số phần tử
  print(fruits.isEmpty);         // true/false
  print(fruits.contains('Táo')); // true
  print(fruits.indexOf('Cam'));  // Vị trí đầu tiên (hoặc -1)

  // UPDATE — Cập nhật
  fruits[0] = 'Dứa';            // Thay đổi phần tử ở index 0
  fruits.replaceRange(0, 2, ['A', 'B']);  // Thay thế range

  // DELETE — Xóa
  fruits.remove('Cam');          // Xóa theo giá trị (phần tử đầu tiên khớp)
  fruits.removeAt(0);            // Xóa theo index
  fruits.removeLast();           // Xóa phần tử cuối
  fruits.removeWhere((f) => f.startsWith('D'));  // Xóa theo điều kiện
  fruits.clear();                // Xóa hết
}
```

### 1.3. Duyệt & Tìm Kiếm

```dart
void main() {
  var numbers = [3, 1, 4, 1, 5, 9, 2, 6, 5];

  // Duyệt
  for (var n in numbers) { print(n); }
  numbers.forEach(print);

  // Tìm kiếm
  print(numbers.contains(5));             // true
  print(numbers.indexOf(5));              // 4 (vị trí đầu tiên)
  print(numbers.lastIndexOf(5));          // 8 (vị trí cuối)
  print(numbers.any((n) => n > 8));       // true (có ít nhất 1 phần tử > 8)
  print(numbers.every((n) => n > 0));     // true (mọi phần tử > 0)

  // firstWhere / lastWhere — tìm phần tử
  var firstEven = numbers.firstWhere((n) => n.isEven);
  print(firstEven);   // 4

  // Nếu không tìm thấy → cung cấp orElse
  var found = numbers.firstWhere(
    (n) => n > 100,
    orElse: () => -1,
  );
  print(found);   // -1
}
```

### 1.4. Functional Methods (map, where, reduce,...) 🔥

```dart
void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // map — biến đổi mỗi phần tử → trả về Iterable mới
  var doubled = numbers.map((n) => n * 2).toList();
  print(doubled);   // [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

  // where — lọc phần tử theo điều kiện
  var evens = numbers.where((n) => n.isEven).toList();
  print(evens);   // [2, 4, 6, 8, 10]

  // reduce — gộp tất cả thành 1 giá trị
  var sum = numbers.reduce((total, n) => total + n);
  print(sum);   // 55

  // fold — giống reduce nhưng có giá trị khởi tạo
  var sumWithInit = numbers.fold<int>(100, (total, n) => total + n);
  print(sumWithInit);   // 155

  // expand — trải phẳng (flatMap)
  var nested = [[1, 2], [3, 4], [5, 6]];
  var flat = nested.expand((list) => list).toList();
  print(flat);   // [1, 2, 3, 4, 5, 6]

  // take / skip — lấy/bỏ n phần tử đầu
  print(numbers.take(3).toList());     // [1, 2, 3]
  print(numbers.skip(7).toList());     // [8, 9, 10]
  print(numbers.takeWhile((n) => n < 5).toList());  // [1, 2, 3, 4]

  // Chaining — kết hợp nhiều method
  var result = numbers
      .where((n) => n.isOdd)       // Lọc số lẻ: [1, 3, 5, 7, 9]
      .map((n) => n * n)            // Bình phương: [1, 9, 25, 49, 81]
      .where((n) => n > 10)         // Lọc > 10: [25, 49, 81]
      .toList();
  print(result);   // [25, 49, 81]
}
```

### 1.5. Sắp xếp

```dart
void main() {
  // Sort tại chỗ (mutate list gốc)
  var numbers = [3, 1, 4, 1, 5, 9];
  numbers.sort();
  print(numbers);   // [1, 1, 3, 4, 5, 9]

  // Sort giảm dần
  numbers.sort((a, b) => b.compareTo(a));
  print(numbers);   // [9, 5, 4, 3, 1, 1]

  // Sort object phức tạp
  var users = [
    {'name': 'Phong', 'age': 25},
    {'name': 'An', 'age': 30},
    {'name': 'Minh', 'age': 20},
  ];
  users.sort((a, b) => (a['age'] as int).compareTo(b['age'] as int));
  print(users);   // Sắp xếp theo age tăng dần

  // reversed — tạo Iterable ngược (KHÔNG mutate)
  var original = [1, 2, 3];
  var reversed = original.reversed.toList();
  print(reversed);    // [3, 2, 1]
  print(original);    // [1, 2, 3] — không đổi
}
```

### 1.6. Spread & Collection if/for

```dart
void main() {
  // Spread operator
  var list1 = [1, 2, 3];
  var list2 = [0, ...list1, 4, 5];   // [0, 1, 2, 3, 4, 5]

  // Null-aware spread
  List<int>? maybeNull;
  var safe = [1, 2, ...?maybeNull, 3];   // [1, 2, 3]

  // Collection if
  bool isVip = true;
  var menu = [
    'Trang chủ',
    'Hồ sơ',
    if (isVip) 'VIP Lounge',
  ];

  // Collection for
  var numbers = [1, 2, 3];
  var squares = [for (var n in numbers) n * n];   // [1, 4, 9]

  // Kết hợp
  var items = [
    for (var n in numbers)
      if (n.isOdd) 'Số lẻ: $n',
  ];
  print(items);   // ['Số lẻ: 1', 'Số lẻ: 3']
}
```

---

## 2. Set<T> — Tập Hợp (Không Trùng Lặp)

```dart
void main() {
  // Tạo Set
  var fruits = <String>{'Táo', 'Cam', 'Xoài'};
  Set<int> numbers = {1, 2, 3, 4, 5};

  // ⚠️ {} trống là Map, không phải Set!
  var emptySet = <int>{};       // ✅ Set rỗng
  Set<int> emptySet2 = {};      // ✅ Set rỗng
  // var wrong = {};             // ❌ Đây là Map!

  // Thêm phần tử
  fruits.add('Nho');
  fruits.add('Táo');           // Không thêm (đã tồn tại)
  fruits.addAll(['Dưa', 'Ổi']);
  print(fruits);   // {Táo, Cam, Xoài, Nho, Dưa, Ổi}

  // Xóa
  fruits.remove('Cam');
  fruits.removeWhere((f) => f.length > 3);

  // Kiểm tra
  print(fruits.contains('Táo'));   // true
  print(fruits.length);

  // Set operations (rất hữu ích!)
  var a = {1, 2, 3, 4, 5};
  var b = {4, 5, 6, 7, 8};

  print(a.union(b));           // {1, 2, 3, 4, 5, 6, 7, 8}  — Hợp
  print(a.intersection(b));    // {4, 5}                      — Giao
  print(a.difference(b));      // {1, 2, 3}                   — Hiệu (a - b)

  // Loại bỏ trùng lặp từ List
  var listWithDupes = [1, 2, 2, 3, 3, 3, 4];
  var unique = listWithDupes.toSet().toList();
  print(unique);   // [1, 2, 3, 4]
}
```

---

## 3. Map<K, V> — Bảng Ánh Xạ Key-Value

```dart
void main() {
  // Tạo Map
  Map<String, int> ages = {
    'Phong': 25,
    'Minh': 30,
    'Hoa': 22,
  };

  var scores = <String, List<int>>{
    'Toán': [90, 85, 95],
    'Lý': [80, 75, 88],
  };

  // READ
  print(ages['Phong']);        // 25 (nullable! trả về int?)
  print(ages['Unknown']);      // null
  print(ages.containsKey('Phong'));    // true
  print(ages.containsValue(30));      // true
  print(ages.keys.toList());          // ['Phong', 'Minh', 'Hoa']
  print(ages.values.toList());        // [25, 30, 22]
  print(ages.entries.toList());       // [MapEntry(Phong: 25), ...]
  print(ages.length);                 // 3

  // CREATE / UPDATE
  ages['An'] = 28;                    // Thêm mới
  ages['Phong'] = 26;                 // Cập nhật
  ages.putIfAbsent('Phong', () => 99); // Không ghi đè (Phong đã tồn tại)
  ages.update('Minh', (old) => old + 1);  // 30 → 31
  ages.addAll({'Lan': 20, 'Tú': 23});

  // DELETE
  ages.remove('Hoa');
  ages.removeWhere((key, value) => value < 25);

  // Duyệt Map
  ages.forEach((key, value) {
    print('$key: $value tuổi');
  });

  for (var entry in ages.entries) {
    print('${entry.key}: ${entry.value}');
  }

  // Map.map — biến đổi
  var upperNames = ages.map((key, value) {
    return MapEntry(key.toUpperCase(), value);
  });
}
```

### Nested Map (JSON-like)

```dart
void main() {
  // Cấu trúc giống JSON
  Map<String, dynamic> user = {
    'name': 'Phong',
    'age': 25,
    'address': {
      'city': 'Hà Nội',
      'district': 'Cầu Giấy',
    },
    'hobbies': ['Code', 'Game', 'Music'],
  };

  // Truy cập nested
  String city = (user['address'] as Map<String, dynamic>)['city'];
  print(city);   // Hà Nội

  List<String> hobbies = user['hobbies'] as List<String>;
  print(hobbies[0]);   // Code
}
```

---

## PHẦN B: XỬ LÝ CHUỖI

## 4. String Methods Nâng Cao

```dart
void main() {
  // --- Regex ---
  var text = 'Số điện thoại: 0901234567, email: phong@test.com';

  // Kiểm tra pattern
  var phoneRegex = RegExp(r'\d{10}');
  print(phoneRegex.hasMatch(text));    // true

  // Tìm tất cả matches
  var matches = phoneRegex.allMatches(text);
  for (var match in matches) {
    print('Tìm thấy: ${match.group(0)}');   // 0901234567
  }

  // Extract email
  var emailRegex = RegExp(r'[\w.-]+@[\w.-]+\.\w+');
  var emailMatch = emailRegex.firstMatch(text);
  print('Email: ${emailMatch?.group(0)}');   // phong@test.com

  // Replace với regex
  var censored = text.replaceAll(RegExp(r'\d'), '*');
  print(censored);   // Số điện thoại: **********, email: phong@test.com

  // --- StringBuffer (hiệu quả khi nối nhiều chuỗi) ---
  var buffer = StringBuffer();
  for (int i = 0; i < 5; i++) {
    buffer.write('Item $i');
    if (i < 4) buffer.write(', ');
  }
  print(buffer.toString());   // Item 0, Item 1, Item 2, Item 3, Item 4

  // --- Split & Join ---
  var csv = 'Phong,25,Hà Nội';
  var parts = csv.split(',');
  print(parts);   // ['Phong', '25', 'Hà Nội']

  var joined = parts.join(' | ');
  print(joined);   // Phong | 25 | Hà Nội

  // --- Rune & Unicode ---
  var emoji = '🇻🇳';
  print(emoji.runes.toList());   // Unicode code points
  print(String.fromCharCode(65));   // 'A'
}
```

---

## PHẦN C: XỬ LÝ SỐ

## 5. Math Library

```dart
import 'dart:math';

void main() {
  // Hằng số
  print(pi);        // 3.141592653589793
  print(e);         // 2.718281828459045
  print(sqrt2);     // 1.4142135623730951

  // Hàm toán học
  print(sqrt(16));           // 4.0
  print(pow(2, 10));         // 1024
  print(log(e));             // 1.0
  print(sin(pi / 2));        // 1.0
  print(cos(0));             // 1.0

  // Min / Max
  print(min(3, 7));          // 3
  print(max(3, 7));          // 7

  // Random
  var random = Random();
  print(random.nextInt(100));        // Số nguyên 0-99
  print(random.nextDouble());       // Số thực 0.0-1.0
  print(random.nextBool());         // true hoặc false

  // Random trong range
  int randomInRange(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
  print(randomInRange(10, 50));   // Số từ 10 đến 50

  // Format số
  double price = 1234567.89;
  print(price.toStringAsFixed(2));          // "1234567.89"
  print(price.toStringAsExponential(2));    // "1.23e+6"
  print(price.toStringAsPrecision(5));      // "1234600" (5 chữ số có nghĩa)
}
```

---

## 6. Iterable & Lazy Evaluation

```dart
void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // map(), where() trả về Iterable (LAZY — chưa tính ngay)
  var result = numbers
      .where((n) {
        print('Checking $n');   // Debug: xem thứ tự thực thi
        return n.isEven;
      })
      .map((n) {
        print('Mapping $n');
        return n * 10;
      });

  // Chưa in gì cả! Iterable chưa được evaluate

  print('--- Bắt đầu toList() ---');
  var list = result.toList();   // GIỜ mới evaluate
  print(list);   // [20, 40, 60, 80, 100]

  // first — chỉ evaluate đến phần tử đầu tiên thỏa mãn
  var firstEven = numbers.where((n) => n.isEven).first;
  print(firstEven);   // 2 (không cần duyệt hết list)
}
```

---

## 7. Bảng Tra Cứu Method (Cheat Sheet) 🔖

### 7.1. String methods

| Method | Mô tả | Ví dụ → Kết quả |
|:--|:--|:--|
| `.length` | Số ký tự | `'abc'.length` → `3` |
| `.isEmpty` / `.isNotEmpty` | Rỗng / không rỗng | `''.isEmpty` → `true` |
| `.toUpperCase()` / `.toLowerCase()` | Đổi hoa/thường | `'Hi'.toUpperCase()` → `'HI'` |
| `.trim()` / `.trimLeft()` / `.trimRight()` | Bỏ khoảng trắng | `' a '.trim()` → `'a'` |
| `.substring(s, [e])` | Cắt chuỗi con | `'Hello'.substring(1,3)` → `'el'` |
| `.split(sep)` | Tách thành List | `'a,b'.split(',')` → `['a','b']` |
| `.replaceAll(a, b)` / `.replaceFirst(a, b)` | Thay thế | `'aa'.replaceAll('a','b')` → `'bb'` |
| `.contains(s)` | Có chứa không | `'abc'.contains('b')` → `true` |
| `.startsWith(s)` / `.endsWith(s)` | Bắt đầu/kết thúc | `'abc'.startsWith('a')` → `true` |
| `.indexOf(s)` / `.lastIndexOf(s)` | Vị trí | `'aba'.indexOf('a')` → `0` |
| `.padLeft(n, c)` / `.padRight(n, c)` | Đệm ký tự | `'5'.padLeft(3,'0')` → `'005'` |
| `.compareTo(s)` | So sánh (sort) | `'a'.compareTo('b')` → `-1` |
| `.codeUnits` / `.runes` | Mã ký tự / Unicode | `'A'.codeUnits` → `[65]` |
| `int.parse(s)` / `int.tryParse(s)` | String → số | `int.parse('42')` → `42` |

### 7.2. List<T> methods (mảng / array)

| Method | Mô tả | Ghi chú |
|:--|:--|:--|
| `.add(x)` / `.addAll(xs)` | Thêm cuối | mutate |
| `.insert(i, x)` / `.insertAll(i, xs)` | Thêm tại index | mutate |
| `.remove(x)` / `.removeAt(i)` / `.removeLast()` | Xoá | mutate |
| `.removeWhere((x) => …)` | Xoá theo điều kiện | mutate |
| `.clear()` | Xoá hết | mutate |
| `.sort([cmp])` / `.shuffle()` | Sắp xếp / xáo trộn | mutate |
| `[i]` · `.first` · `.last` · `.length` | Đọc | |
| `.indexOf(x)` / `.lastIndexOf(x)` / `.contains(x)` | Tìm | |
| `.firstWhere(f, {orElse})` / `.lastWhere` / `.indexWhere(f)` | Tìm theo điều kiện | |
| `.map(f)` | Biến đổi từng phần tử | → `Iterable` (lazy) |
| `.where(f)` | Lọc | → `Iterable` (lazy) |
| `.reduce(f)` / `.fold(init, f)` | Gộp về 1 giá trị | |
| `.any(f)` / `.every(f)` | Có/mọi phần tử thoả | → `bool` |
| `.expand(f)` | flatMap (trải phẳng) | |
| `.take(n)` / `.skip(n)` / `.takeWhile(f)` / `.skipWhile(f)` | Cắt đầu/cuối | |
| `.reversed` | Đảo ngược | → `Iterable`, KHÔNG mutate |
| `.sublist(s, [e])` / `.getRange(s, e)` | Cắt đoạn | |
| `.join([sep])` | Nối thành String | `[1,2].join('-')` → `'1-2'` |
| `.asMap()` / `.indexed` | Kèm index | `.indexed` = Dart 3.0+ |
| `.toList()` / `.toSet()` | Chuyển đổi | |

> ⚠️ `map`/`where`/`expand`/`take`... trả về **`Iterable` lazy** — nhớ `.toList()` khi cần List thật.

### 7.3. Set<T> methods

| Method | Mô tả |
|:--|:--|
| `.add(x)` / `.addAll(xs)` / `.remove(x)` | Thêm/xoá (bỏ qua trùng) |
| `.contains(x)` / `.length` | Kiểm tra |
| `.union(b)` | Hợp `a ∪ b` |
| `.intersection(b)` | Giao `a ∩ b` |
| `.difference(b)` | Hiệu `a − b` |
| `list.toSet()` | Loại bỏ phần tử trùng |

### 7.4. Map<K, V> methods

| Method | Mô tả | Ghi chú |
|:--|:--|:--|
| `map[key]` | Đọc giá trị | trả về `V?` (có thể null) |
| `map[key] = v` | Thêm/cập nhật | |
| `.putIfAbsent(k, () => v)` | Thêm nếu chưa có | không ghi đè |
| `.update(k, (old) => new, {ifAbsent})` | Cập nhật theo giá trị cũ | |
| `.remove(k)` / `.removeWhere((k,v) => …)` | Xoá | |
| `.containsKey(k)` / `.containsValue(v)` | Kiểm tra | |
| `.keys` / `.values` / `.entries` | Lấy tập key/value/cặp | → `Iterable` |
| `.forEach((k, v) => …)` | Duyệt | |
| `.map((k, v) => MapEntry(…))` | Biến đổi | → `Map` mới |
| `.length` / `.isEmpty` | Thông tin | |

---

## 📝 Bài Tập Thực Hành

### Bài 1: Xử lý List
Cho list `[15, 8, 23, 42, 4, 16, 7, 55, 3, 30]`:
- Lọc các số chẵn > 10
- Nhân đôi chúng
- Sắp xếp giảm dần
- In kết quả

### Bài 2: Map — Đếm từ
Cho chuỗi `"hello world hello dart hello world dart"`:
- Tách thành các từ
- Đếm số lần xuất hiện của mỗi từ → `Map<String, int>`
- In từ xuất hiện nhiều nhất

### Bài 3: Set — Loại bỏ trùng lặp
Cho 2 list sản phẩm yêu thích của 2 user:
- Tìm sản phẩm cả 2 đều thích (intersection)
- Tìm sản phẩm chỉ user1 thích (difference)
- Gộp tất cả sản phẩm không trùng (union)

### Bài 4: Regex
Viết hàm `extractUrls(String text)` trích xuất tất cả URL từ một đoạn text.

---

> **Bài tiếp theo**: [05 - Lập trình bất đồng bộ](./05_dart_async_programming.md)
