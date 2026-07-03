# 📘 Bài 03: Hàm & Lập Trình Hướng Đối Tượng (OOP) Trong Dart

> **Mục tiêu**: Nắm vững cách viết hàm, xây dựng class, và các tính chất OOP trong Dart.

---

## PHẦN A: HÀM (FUNCTIONS)

## 1. Khai Báo Hàm Cơ Bản

```dart
// Cú pháp đầy đủ
ReturnType functionName(ParameterType param) {
  // body
  return value;
}

// Ví dụ
int add(int a, int b) {
  return a + b;
}

// Hàm không trả về giá trị
void greet(String name) {
  print('Xin chào $name!');
}

void main() {
  int result = add(3, 5);
  print(result);   // 8
  greet('Phong');  // Xin chào Phong!
}
```

---

## 2. Arrow Function (Hàm mũi tên)

Khi thân hàm chỉ có **1 biểu thức**, dùng `=>` cho gọn:

```dart
// Đầy đủ
int add(int a, int b) {
  return a + b;
}

// Arrow function — tương đương
int add(int a, int b) => a + b;

// Ví dụ khác
String greeting(String name) => 'Xin chào $name!';
bool isEven(int n) => n % 2 == 0;
void log(String msg) => print('[LOG] $msg');
```

---

## 3. Tham Số (Parameters)

### 3.1. Positional Parameters (Tham số vị trí)

```dart
// Bắt buộc — phải truyền đủ, đúng thứ tự
String fullName(String first, String last) {
  return '$first $last';
}

void main() {
  print(fullName('Nguyễn', 'Phong'));   // Nguyễn Phong
  // fullName('Phong');  // ❌ Lỗi — thiếu tham số
}
```

### 3.2. Optional Positional Parameters `[]`

```dart
// Đặt trong [] — có thể bỏ qua
String greet(String name, [String? title, String suffix = '!']) {
  if (title != null) {
    return 'Xin chào $title $name$suffix';
  }
  return 'Xin chào $name$suffix';
}

void main() {
  print(greet('Phong'));                    // Xin chào Phong!
  print(greet('Phong', 'Anh'));            // Xin chào Anh Phong!
  print(greet('Phong', 'Anh', '.'));       // Xin chào Anh Phong.
}
```

### 3.3. Named Parameters `{}` (Rất phổ biến trong Flutter!)

```dart
// Đặt trong {} — truyền theo tên, thứ tự tùy ý
void createUser({
  required String name,        // required — bắt buộc phải truyền
  required String email,
  int age = 0,                 // Có giá trị mặc định
  String? phone,               // Optional — có thể null
}) {
  print('Name: $name, Email: $email, Age: $age, Phone: $phone');
}

void main() {
  createUser(
    name: 'Phong',
    email: 'phong@email.com',
  );
  // Name: Phong, Email: phong@email.com, Age: 0, Phone: null

  createUser(
    email: 'phong@email.com',   // Thứ tự tùy ý
    name: 'Phong',
    age: 25,
    phone: '0901234567',
  );
}
```

> 💡 **Trong Flutter**, hầu hết Widget constructor đều dùng Named Parameters. Ví dụ: `Text('Hello', style: TextStyle(fontSize: 16))`.

### 3.4. Kết hợp Positional + Named

```dart
// Positional trước, Named sau
void fetchData(
  String url,                     // Positional (bắt buộc)
  {
    Map<String, String>? headers, // Named (optional)
    Duration? timeout,
  }
) {
  print('Fetching $url');
}

void main() {
  fetchData(
    'https://api.example.com/data',
    headers: {'Authorization': 'Bearer token123'},
    timeout: Duration(seconds: 30),
  );
}
```

---

## 4. First-class Functions & Higher-order Functions

Trong Dart, hàm là **first-class citizen** — có thể gán vào biến, truyền làm tham số, hoặc trả về từ hàm khác.

```dart
void main() {
  // Gán hàm vào biến
  var multiply = (int a, int b) => a * b;
  print(multiply(3, 4));   // 12

  // Kiểu Function
  int Function(int, int) operation = multiply;
  print(operation(5, 6));   // 30

  // Truyền hàm làm tham số (Higher-order function)
  var numbers = [3, 1, 4, 1, 5, 9];
  numbers.sort((a, b) => a.compareTo(b));
  print(numbers);   // [1, 1, 3, 4, 5, 9]

  // Trả hàm từ hàm
  var adder = makeAdder(10);
  print(adder(5));    // 15
  print(adder(20));   // 30
}

// Hàm trả về hàm (Closure)
Function makeAdder(int addend) {
  return (int value) => value + addend;
}
```

---

## 5. Anonymous Functions & Closures

```dart
void main() {
  // Anonymous function (hàm không tên)
  var list = [1, 2, 3];

  // Dạng đầy đủ
  list.forEach((item) {
    print('Giá trị: $item');
  });

  // Dạng arrow
  list.forEach((item) => print('Giá trị: $item'));

  // Closure — hàm "bắt" biến từ scope bên ngoài
  int counter = 0;
  var increment = () {
    counter++;   // Truy cập biến counter từ scope ngoài
    return counter;
  };
  print(increment());   // 1
  print(increment());   // 2
  print(increment());   // 3
}
```

---

## 6. Tear-offs

```dart
void main() {
  var numbers = [1, -2, 3, -4, 5];

  // ❌ Dài dòng
  var positives1 = numbers.where((n) => n.isNegative);

  // ✅ Tear-off — truyền reference tới method
  numbers.forEach(print);   // Thay vì (item) => print(item)

  // Tear-off với named function
  bool isPositive(int n) => n > 0;
  var positives = numbers.where(isPositive);
  print(positives.toList());   // [1, 3, 5]
}
```

---

## PHẦN B: LẬP TRÌNH HƯỚNG ĐỐI TƯỢNG (OOP)

## 7. Class Cơ Bản

```dart
class Person {
  // Properties (thuộc tính)
  String name;
  int age;

  // Constructor (hàm khởi tạo)
  Person(this.name, this.age);

  // Method (phương thức)
  void introduce() {
    print('Tôi là $name, $age tuổi');
  }

  // toString — hiển thị khi print object
  @override
  String toString() => 'Person($name, $age)';
}

void main() {
  var person = Person('Phong', 25);
  person.introduce();        // Tôi là Phong, 25 tuổi
  print(person);             // Person(Phong, 25)
  print(person.name);        // Phong
  person.age = 26;           // Thay đổi property
}
```

---

## 8. Constructors (Hàm Khởi Tạo)

### 8.1. Default Constructor

```dart
class Point {
  double x;
  double y;

  // Cách 1: Constructor đầy đủ
  // Point(double x, double y) {
  //   this.x = x;
  //   this.y = y;
  // }

  // Cách 2: Syntactic sugar (gọn hơn!) — Dart tự gán this.x, this.y
  Point(this.x, this.y);
}
```

### 8.2. Named Constructor

```dart
class Point {
  double x;
  double y;

  Point(this.x, this.y);

  // Named constructor — tên tùy chọn
  Point.origin()
      : x = 0,
        y = 0;

  Point.fromJson(Map<String, double> json)
      : x = json['x']!,
        y = json['y']!;

  @override
  String toString() => 'Point($x, $y)';
}

void main() {
  var p1 = Point(3, 4);
  var p2 = Point.origin();
  var p3 = Point.fromJson({'x': 1.5, 'y': 2.5});

  print(p1);   // Point(3.0, 4.0)
  print(p2);   // Point(0.0, 0.0)
  print(p3);   // Point(1.5, 2.5)
}
```

### 8.3. Initializer List

```dart
class Rectangle {
  final double width;
  final double height;
  final double area;

  // Initializer list — tính toán TRƯỚC khi body chạy
  Rectangle(this.width, this.height)
      : assert(width > 0),          // Kiểm tra debug-time
        assert(height > 0),
        area = width * height;      // Tính area từ width, height

  @override
  String toString() => 'Rectangle(${width}x$height, area=$area)';
}

void main() {
  var rect = Rectangle(5, 3);
  print(rect);   // Rectangle(5.0x3.0, area=15.0)
}
```

### 8.4. Factory Constructor

```dart
class Logger {
  final String name;
  static final Map<String, Logger> _cache = {};

  // Private constructor
  Logger._internal(this.name);

  // Factory constructor — có thể trả về instance đã tồn tại
  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }
  // putIfAbsent: nếu key chưa có → tạo mới, nếu có rồi → trả về cái cũ
}

void main() {
  var logger1 = Logger('UI');
  var logger2 = Logger('UI');
  print(identical(logger1, logger2));   // true — cùng 1 instance!
}
```

### 8.5. Const Constructor

```dart
class ImmutablePoint {
  final double x;
  final double y;

  // const constructor — tạo compile-time constant
  const ImmutablePoint(this.x, this.y);
}

void main() {
  // const tạo canonical instance
  const p1 = ImmutablePoint(1, 2);
  const p2 = ImmutablePoint(1, 2);
  print(identical(p1, p2));   // true — cùng 1 object!

  // Không const → 2 object khác nhau
  var p3 = ImmutablePoint(1, 2);
  var p4 = ImmutablePoint(1, 2);
  print(identical(p3, p4));   // false
}
```

> 💡 **Trong Flutter**, nhiều Widget dùng `const` constructor để tối ưu rebuild: `const Text('Hello')`, `const SizedBox(height: 10)`.

---

## 9. Getter & Setter

```dart
class Circle {
  double radius;

  Circle(this.radius);

  // Getter — truy cập như property, không cần ()
  double get area => 3.14159 * radius * radius;
  double get circumference => 2 * 3.14159 * radius;

  // Setter — gán giá trị với validation
  set diameter(double value) {
    assert(value > 0, 'Đường kính phải > 0');
    radius = value / 2;
  }
}

void main() {
  var c = Circle(5);
  print(c.area);            // 78.53975 (gọi như property)
  print(c.circumference);   // 31.4159

  c.diameter = 20;          // Gán qua setter
  print(c.radius);          // 10.0
}
```

---

## 10. Access Modifiers (Phạm vi truy cập)

Dart **không có** `public`, `private`, `protected`. Thay vào đó dùng quy ước `_` (underscore):

```dart
class BankAccount {
  String owner;           // Public — truy cập từ bất kỳ đâu
  double _balance;        // Private — chỉ truy cập trong CÙNG FILE (library)

  BankAccount(this.owner, this._balance);

  // Public method
  void deposit(double amount) {
    _validateAmount(amount);
    _balance += amount;
  }

  // Private method
  void _validateAmount(double amount) {
    if (amount <= 0) throw ArgumentError('Số tiền phải > 0');
  }

  // Getter cho balance (read-only từ bên ngoài)
  double get balance => _balance;
}

void main() {
  var account = BankAccount('Phong', 1000);
  account.deposit(500);
  print(account.balance);    // 1500.0
  // account._balance;       // ⚠️ Truy cập được trong cùng file!
  // Nhưng từ file khác → Lỗi!
}
```

> **Lưu ý**: `_` là private **ở cấp library (file)**, không phải cấp class. Trong cùng 1 file, bạn vẫn truy cập được `_balance`.

---

## 11. Static Members

```dart
class MathHelper {
  // Static property — thuộc về CLASS, không thuộc instance
  static const double pi = 3.14159;
  static int _callCount = 0;

  // Static method
  static double circleArea(double radius) {
    _callCount++;
    return pi * radius * radius;
  }

  static int get callCount => _callCount;

  // ❌ Static method KHÔNG thể truy cập instance members
  // static void wrong() {
  //   print(this.something);  // Lỗi!
  // }
}

void main() {
  // Gọi qua tên class, KHÔNG cần tạo instance
  print(MathHelper.pi);                  // 3.14159
  print(MathHelper.circleArea(5));       // 78.53975
  print(MathHelper.callCount);           // 1
}
```

---

## 12. Kế Thừa (Inheritance) — `extends`

```dart
// Lớp cha (Parent / Base / Super class)
class Animal {
  String name;
  int age;

  Animal(this.name, this.age);

  void eat() => print('$name đang ăn');
  void sleep() => print('$name đang ngủ');

  @override
  String toString() => 'Animal($name, $age tuổi)';
}

// Lớp con (Child / Derived / Sub class)
class Dog extends Animal {
  String breed;

  // Constructor gọi super() để khởi tạo lớp cha
  Dog(String name, int age, this.breed) : super(name, age);

  // Override method — ghi đè hành vi lớp cha
  @override
  void eat() {
    super.eat();   // Gọi method gốc của lớp cha
    print('$name ăn xương');
  }

  // Method riêng của Dog
  void bark() => print('$name: Gâu gâu!');

  @override
  String toString() => 'Dog($name, $age tuổi, giống $breed)';
}

class Cat extends Animal {
  Cat(String name, int age) : super(name, age);

  void meow() => print('$name: Meo meo!');
}

void main() {
  var dog = Dog('Buddy', 3, 'Corgi');
  dog.eat();     // Buddy đang ăn → Buddy ăn xương
  dog.bark();    // Buddy: Gâu gâu!
  dog.sleep();   // Buddy đang ngủ (kế thừa từ Animal)

  // Polymorphism — biến kiểu cha chứa object kiểu con
  Animal myPet = Dog('Max', 2, 'Husky');
  myPet.eat();      // Max đang ăn → Max ăn xương (gọi Dog.eat)
  // myPet.bark();   // ❌ Lỗi! Animal không có bark()
}
```

---

## 13. Lớp Trừu Tượng (Abstract Class)

Không thể tạo instance trực tiếp, chỉ để **kế thừa**.

```dart
abstract class Shape {
  // Abstract method — KHÔNG có body, lớp con PHẢI override
  double area();
  double perimeter();

  // Concrete method — CÓ body, lớp con kế thừa hoặc override
  void printInfo() {
    print('Diện tích: ${area()}, Chu vi: ${perimeter()}');
  }
}

class Circle extends Shape {
  double radius;
  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;

  @override
  double perimeter() => 2 * 3.14159 * radius;
}

class Rectangle extends Shape {
  double width, height;
  Rectangle(this.width, this.height);

  @override
  double area() => width * height;

  @override
  double perimeter() => 2 * (width + height);
}

void main() {
  // var shape = Shape();  // ❌ Lỗi! Không thể tạo instance abstract class

  Shape circle = Circle(5);
  Shape rect = Rectangle(4, 6);

  circle.printInfo();   // Diện tích: 78.53975, Chu vi: 31.4159
  rect.printInfo();     // Diện tích: 24.0, Chu vi: 20.0

  // Polymorphism với List
  List<Shape> shapes = [Circle(3), Rectangle(2, 5), Circle(7)];
  for (var shape in shapes) {
    shape.printInfo();   // Mỗi shape gọi đúng method của nó
  }
}
```

---

## 14. Interface — `implements`

Dart **không có keyword `interface`**. Mọi class đều có thể dùng làm interface.

```dart
// "Interface" — chỉ là class bình thường
class Printable {
  void printData() {
    print('Printing...');
  }
}

class Saveable {
  void save() {
    print('Saving...');
  }
}

// implements — PHẢI override TẤT CẢ method (kể cả có body)
class Document implements Printable, Saveable {
  String content;
  Document(this.content);

  @override
  void printData() => print('In tài liệu: $content');

  @override
  void save() => print('Lưu tài liệu: $content');
}

void main() {
  var doc = Document('Hello World');
  doc.printData();   // In tài liệu: Hello World
  doc.save();        // Lưu tài liệu: Hello World
}
```

### `extends` vs `implements`

| | `extends` | `implements` |
|:--|:---------|:------------|
| Số lượng | Chỉ 1 class | Nhiều class |
| Kế thừa body | ✅ Có | ❌ Không (phải override hết) |
| Dùng `super` | ✅ Được | ❌ Không |
| Mục đích | Kế thừa + mở rộng | Đảm bảo "hợp đồng" (contract) |

---

## 15. Mixins — `with`

Mixin cho phép **chia sẻ code giữa nhiều class** mà không cần kế thừa.

```dart
// Mixin — dùng keyword "mixin"
mixin Swimming {
  void swim() => print('$runtimeType đang bơi 🏊');
}

mixin Flying {
  void fly() => print('$runtimeType đang bay 🦅');
}

mixin Running {
  int speed = 0;
  void run() => print('$runtimeType đang chạy với tốc độ $speed km/h 🏃');
}

// Dùng mixin với "with"
class Duck extends Animal with Swimming, Flying {
  Duck(String name) : super(name, 1);
}

class Dog2 extends Animal with Swimming, Running {
  Dog2(String name, int age) : super(name, age) {
    speed = 30;
  }
}

// Mixin on — giới hạn mixin chỉ dùng được với class cụ thể
mixin Domesticated on Animal {
  String? ownerName;
  void setOwner(String name) {
    ownerName = name;
    print('$this thuộc về $ownerName');
  }
}

class Pet extends Animal with Domesticated {
  Pet(String name, int age) : super(name, age);
}

void main() {
  var duck = Duck('Donald');
  duck.swim();   // Duck đang bơi 🏊
  duck.fly();    // Duck đang bay 🦅
  duck.eat();    // Donald đang ăn (kế thừa từ Animal)

  var dog = Dog2('Rex', 5);
  dog.swim();    // Dog2 đang bơi 🏊
  dog.run();     // Dog2 đang chạy với tốc độ 30 km/h 🏃
}
```

---

## 16. Extension Methods

Thêm method vào class **có sẵn** mà không cần sửa source code gốc.

```dart
// Extension trên String
extension StringExtension on String {
  // Viết hoa chữ cái đầu
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Kiểm tra email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  // Lặp lại n lần với separator
  String repeat(int times, {String separator = ''}) {
    return List.generate(times, (_) => this).join(separator);
  }
}

// Extension trên int
extension IntExtension on int {
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  bool get isAdult => this >= 18;
}

void main() {
  print('hello'.capitalize);              // Hello
  print('test@email.com'.isValidEmail);   // true
  print('Ha'.repeat(3, separator: ' '));  // Ha Ha Ha

  print(25.isAdult);       // true
  print(5.seconds);        // 0:00:05.000000
  print(2.minutes);        // 0:02:00.000000
}
```

---

## 17. Sealed Class (Dart 3.0+)

```dart
// Sealed class — hạn chế class nào có thể kế thừa
// Chỉ class trong CÙNG FILE mới có thể extends/implements
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final String error;
  Failure(this.error);
}

class Loading<T> extends Result<T> {}

void main() {
  Result<String> result = Success('Dữ liệu');

  // Exhaustive switch — Dart cảnh báo nếu thiếu case
  String message = switch (result) {
    Success(data: var d) => 'Thành công: $d',
    Failure(error: var e) => 'Lỗi: $e',
    Loading() => 'Đang tải...',
  };
  print(message);   // Thành công: Dữ liệu
}
```

### 17.1. Bộ từ khoá "class modifiers" (Dart 3.0+)

`sealed` chỉ là một trong nhóm từ khoá điều khiển **cách một class được kế thừa / triển khai**. Đặt trước `class`:

| Modifier | Cho `extends`? | Cho `implements`? | Ý nghĩa |
|:--|:--:|:--:|:--|
| *(không có)* | ✅ | ✅ | Mặc định — thoải mái kế thừa/triển khai |
| `abstract` | ✅ | ✅ | Không thể tạo instance trực tiếp |
| `base` | ✅ (cùng lib nếu ngoài) | ❌ | Buộc mọi lớp con phải `extends` (giữ được state/impl) |
| `interface` | ❌ (ngoài lib) | ✅ | Chỉ dùng làm interface — bên ngoài chỉ `implements` |
| `final` | ❌ | ❌ | "Đóng" hoàn toàn — không cho kế thừa/triển khai ở lib khác |
| `sealed` | ❌ (ngoài lib) | ❌ | Biết trước MỌI lớp con → `switch` exhaustive |
| `mixin class` | — | — | Vừa dùng như class, vừa dùng như mixin (`with`) |

```dart
// interface class — bên ngoài file CHỈ được implements, không extends
interface class Logger {
  void log(String msg) => print(msg);
}

// base class — buộc lớp con phải extends (không cho implements từ lib khác)
base class Repository {
  void save() {}
}

// final class — chốt lại, không ai kế thừa được nữa
final class AppConfig {
  final String env;
  AppConfig(this.env);
}

// mixin class — dùng được cả 2 cách
mixin class Reusable {
  void reuse() => print('reused');
}

class A extends Reusable {}        // dùng như class cha
class B with Reusable {}           // dùng như mixin
```

> **Khi nào dùng gì?**
> - `sealed` → mô hình hoá tập hữu hạn trạng thái (`Result` = Success/Failure/Loading) và muốn `switch` bắt lỗi khi thiếu case.
> - `final` → API public bạn không muốn người khác kế thừa (dễ bảo trì).
> - `base` → muốn cho kế thừa nhưng cấm `implements` (bảo toàn logic nội bộ).
> - `interface` → chỉ định nghĩa "hợp đồng", để người khác `implements`.

---

## 18. Generics

```dart
// Generic class
class Box<T> {
  T value;
  Box(this.value);

  T getValue() => value;
}

// Generic với ràng buộc (bounded)
class NumberBox<T extends num> {
  T value;
  NumberBox(this.value);

  T double_() => (value * 2) as T;
}

// Generic function
T firstElement<T>(List<T> list) {
  return list.first;
}

// Generic với multiple type parameters
class Pair<K, V> {
  K key;
  V value;
  Pair(this.key, this.value);

  @override
  String toString() => 'Pair($key, $value)';
}

void main() {
  var stringBox = Box<String>('Hello');
  var intBox = Box<int>(42);
  var numBox = NumberBox<int>(5);

  print(stringBox.getValue());   // Hello
  print(intBox.getValue());      // 42
  print(numBox.double_());       // 10

  var name = firstElement(['Phong', 'Minh']);   // Type inference → String
  print(name);   // Phong

  var pair = Pair<String, int>('age', 25);
  print(pair);   // Pair(age, 25)
}
```

---

## 19. Operator Overloading

```dart
class Vector {
  final double x;
  final double y;

  const Vector(this.x, this.y);

  // Overload toán tử +
  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);

  // Overload toán tử -
  Vector operator -(Vector other) => Vector(x - other.x, y - other.y);

  // Overload toán tử *
  Vector operator *(double scalar) => Vector(x * scalar, y * scalar);

  // Overload toán tử ==
  @override
  bool operator ==(Object other) =>
      other is Vector && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  // Overload toán tử []
  double operator [](int index) {
    if (index == 0) return x;
    if (index == 1) return y;
    throw RangeError('Index $index out of range');
  }

  @override
  String toString() => 'Vector($x, $y)';
}

void main() {
  var v1 = Vector(1, 2);
  var v2 = Vector(3, 4);

  print(v1 + v2);       // Vector(4.0, 6.0)
  print(v1 - v2);       // Vector(-2.0, -2.0)
  print(v1 * 3);         // Vector(3.0, 6.0)
  print(v1 == Vector(1, 2));   // true
  print(v1[0]);          // 1.0
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Class BankAccount
Tạo class `BankAccount` với:
- Properties: `owner`, `_balance` (private)
- Methods: `deposit(amount)`, `withdraw(amount)`, `transfer(amount, targetAccount)`
- Getter: `balance`
- Validation: không cho rút quá số dư, số tiền phải > 0

### Bài 2: Kế thừa + Đa hình
Tạo abstract class `Vehicle` với method `fuelType()` và `maxSpeed()`.
Tạo các subclass: `Car`, `ElectricCar`, `Motorcycle`.
In thông tin tất cả vehicles trong `List<Vehicle>`.

### Bài 3: Mixin
Tạo mixins `Serializable` (có method `toJson()`) và `Validatable` (có method `validate()`).
Tạo class `UserForm` sử dụng cả 2 mixin.

### Bài 4: Extension Method
Viết extension trên `List<int>` thêm method:
- `sum` → tổng các phần tử
- `average` → trung bình
- `max` → giá trị lớn nhất

---

> **Bài tiếp theo**: [04 - Collections & Xử lý chuỗi/số](./04_dart_collections_and_string.md)
