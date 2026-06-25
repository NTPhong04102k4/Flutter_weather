# 📘 Bài 05: Lập Trình Bất Đồng Bộ Trong Dart

> **Mục tiêu**: Hiểu `Future`, `async/await`, `Stream`, `Isolate`, và Event Loop — nền tảng quan trọng nhất của Dart/Flutter.

---

## 1. Tại Sao Cần Bất Đồng Bộ?

```
Đồng bộ (Synchronous):
  Task A ████████████████████ (3 giây)
  Task B                     ████████████ (2 giây)
  Task C                                  ████████ (1.5 giây)
  Tổng: 6.5 giây

Bất đồng bộ (Asynchronous):
  Task A ████████████████████ (3 giây)
  Task B ████████████         (2 giây)    ← chạy song song
  Task C ████████             (1.5 giây)  ← chạy song song
  Tổng: 3 giây (chỉ chờ task dài nhất)
```

**Khi nào cần bất đồng bộ?**
- Gọi API / HTTP request
- Đọc/ghi file
- Truy vấn database
- Timer / delay
- Animation chờ sự kiện

---

## 2. Event Loop — Cách Dart Xử Lý Bất Đồng Bộ

Dart là **single-threaded** (chỉ có 1 luồng chính), nhưng vẫn xử lý bất đồng bộ nhờ **Event Loop**.

```
┌─────────────────────────────────────────────┐
│               Event Loop                     │
│                                              │
│  1. Chạy code đồng bộ (main)                │
│  2. Kiểm tra Microtask Queue → chạy hết     │
│  3. Kiểm tra Event Queue → lấy 1 event      │
│  4. Quay lại bước 2                          │
│                                              │
│  ┌──────────────────┐  ┌─────────────────┐  │
│  │ Microtask Queue  │  │  Event Queue    │  │
│  │ (ưu tiên cao)    │  │ (ưu tiên thấp) │  │
│  │                  │  │                 │  │
│  │ • scheduleMicro  │  │ • Future        │  │
│  │ • then()         │  │ • Timer         │  │
│  │                  │  │ • I/O events    │  │
│  │                  │  │ • UI events     │  │
│  └──────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────┘
```

```dart
import 'dart:async';

void main() {
  print('1. Start');

  // Event Queue — sẽ chạy SAU microtask
  Future(() => print('4. Future (Event Queue)'));

  // Microtask Queue — ưu tiên hơn Event Queue
  scheduleMicrotask(() => print('3. Microtask'));

  // Future.microtask — cũng vào Microtask Queue
  Future.microtask(() => print('3b. Future.microtask'));

  print('2. End (synchronous code)');
}

// Output:
// 1. Start
// 2. End (synchronous code)     ← Đồng bộ chạy trước
// 3. Microtask                  ← Microtask Queue
// 3b. Future.microtask          ← Microtask Queue
// 4. Future (Event Queue)       ← Event Queue
```

---

## 3. Future<T> — Giá Trị Trong Tương Lai

### 3.1. Cơ bản

```dart
// Future giống Promise trong JavaScript
// Future<T> = "Lời hứa" sẽ trả về giá trị kiểu T trong tương lai

Future<String> fetchUserName() {
  // Giả lập gọi API mất 2 giây
  return Future.delayed(
    Duration(seconds: 2),
    () => 'Phong',
  );
}

void main() {
  print('Bắt đầu gọi API...');

  // Cách 1: Dùng then/catchError
  fetchUserName()
      .then((name) => print('Tên: $name'))
      .catchError((error) => print('Lỗi: $error'))
      .whenComplete(() => print('Hoàn tất'));

  print('Code này chạy NGAY (không chờ API)');
}

// Output:
// Bắt đầu gọi API...
// Code này chạy NGAY (không chờ API)
// (chờ 2 giây...)
// Tên: Phong
// Hoàn tất
```

### 3.2. Tạo Future

```dart
void main() {
  // Future.value — tạo Future với giá trị sẵn
  var instant = Future.value(42);

  // Future.error — tạo Future lỗi
  var failed = Future.error('Something went wrong');

  // Future.delayed — chờ rồi trả giá trị
  var delayed = Future.delayed(Duration(seconds: 1), () => 'Done');

  // Future() — chạy hàm bất đồng bộ
  var computed = Future(() {
    // Code nặng
    var sum = 0;
    for (var i = 0; i < 1000000; i++) sum += i;
    return sum;
  });
}
```

---

## 4. async / await — Viết Code Bất Đồng Bộ Như Đồng Bộ 🔥

```dart
// Đánh dấu hàm là async → trả về Future
Future<void> fetchData() async {
  print('1. Bắt đầu fetch...');

  // await = "chờ Future hoàn thành rồi mới chạy tiếp"
  String name = await fetchUserName();     // Chờ 2 giây
  print('2. Tên: $name');

  int age = await fetchUserAge(name);       // Chờ 1 giây
  print('3. Tuổi: $age');

  print('4. Hoàn tất!');
}

Future<String> fetchUserName() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Phong';
}

Future<int> fetchUserAge(String name) async {
  await Future.delayed(Duration(seconds: 1));
  return 25;
}

void main() async {
  await fetchData();
  print('5. Main hoàn tất');
}

// Output (theo thứ tự, chờ đúng thời gian):
// 1. Bắt đầu fetch...
// (chờ 2 giây)
// 2. Tên: Phong
// (chờ 1 giây)
// 3. Tuổi: 25
// 4. Hoàn tất!
// 5. Main hoàn tất
```

### So sánh then() vs async/await

```dart
// ❌ Callback hell với then()
void fetchDataWithThen() {
  fetchUserName()
      .then((name) {
        return fetchUserAge(name).then((age) {
          return fetchUserAddress(name).then((address) {
            print('$name, $age, $address');
          });
        });
      })
      .catchError((e) => print('Lỗi: $e'));
}

// ✅ Dễ đọc với async/await
Future<void> fetchDataWithAwait() async {
  try {
    var name = await fetchUserName();
    var age = await fetchUserAge(name);
    var address = await fetchUserAddress(name);
    print('$name, $age, $address');
  } catch (e) {
    print('Lỗi: $e');
  }
}
```

---

## 5. Chạy Song Song với Future.wait

```dart
Future<void> main() async {
  var stopwatch = Stopwatch()..start();

  // ❌ Tuần tự — mất 3 giây (1 + 1 + 1)
  var a = await fetchA();   // 1 giây
  var b = await fetchB();   // 1 giây
  var c = await fetchC();   // 1 giây

  // ✅ Song song — mất 1 giây (chờ task dài nhất)
  var results = await Future.wait([
    fetchA(),   // Bắt đầu ngay
    fetchB(),   // Bắt đầu ngay
    fetchC(),   // Bắt đầu ngay
  ]);
  print(results);   // [resultA, resultB, resultC]
  print('Thời gian: ${stopwatch.elapsedMilliseconds}ms');   // ~1000ms

  // Future.any — lấy kết quả ĐẦU TIÊN hoàn thành
  var fastest = await Future.any([
    fetchFromServer1(),   // 3 giây
    fetchFromServer2(),   // 1 giây ← nhanh nhất
    fetchFromServer3(),   // 2 giây
  ]);
  print(fastest);   // Kết quả từ server 2
}

Future<String> fetchA() => Future.delayed(Duration(seconds: 1), () => 'A');
Future<String> fetchB() => Future.delayed(Duration(seconds: 1), () => 'B');
Future<String> fetchC() => Future.delayed(Duration(seconds: 1), () => 'C');

Future<String> fetchFromServer1() => Future.delayed(Duration(seconds: 3), () => 'Server 1');
Future<String> fetchFromServer2() => Future.delayed(Duration(seconds: 1), () => 'Server 2');
Future<String> fetchFromServer3() => Future.delayed(Duration(seconds: 2), () => 'Server 3');
```

---

## 6. Stream<T> — Luồng Dữ Liệu Liên Tục

**Future** = 1 giá trị trong tương lai. **Stream** = nhiều giá trị theo thời gian.

```
Future<int>:   ─────────────[42]──→  (1 giá trị)
Stream<int>:   ──[1]──[2]──[3]──[4]──[5]──→  (nhiều giá trị)
```

### 6.1. Tạo Stream

```dart
// Cách 1: Stream.periodic — phát giá trị đều đặn
void main() {
  var stream = Stream.periodic(
    Duration(seconds: 1),
    (count) => count,
  ).take(5);   // Lấy 5 giá trị rồi dừng

  stream.listen(
    (value) => print('Giá trị: $value'),
    onDone: () => print('Stream hoàn tất'),
    onError: (e) => print('Lỗi: $e'),
  );
}

// Cách 2: async* generator — tùy chỉnh logic
Stream<int> countDown(int from) async* {
  for (int i = from; i >= 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;   // "yield" = phát 1 giá trị ra stream
  }
}

// Cách 3: Stream.fromIterable
var stream3 = Stream.fromIterable([1, 2, 3, 4, 5]);

// Cách 4: Stream.fromFuture
var stream4 = Stream.fromFuture(fetchUserName());

// Cách 5: Stream.fromFutures
var stream5 = Stream.fromFutures([fetchA(), fetchB(), fetchC()]);
```

### 6.2. Lắng nghe Stream

```dart
void main() async {
  var stream = countDown(5);

  // Cách 1: listen (callback)
  stream.listen(
    (value) => print('Đếm: $value'),
    onDone: () => print('Xong!'),
    onError: (error) => print('Lỗi: $error'),
    cancelOnError: false,  // true = hủy stream khi có lỗi
  );

  // Cách 2: await for (chặn — blocking)
  var stream2 = countDown(3);
  await for (var value in stream2) {
    print('Await for: $value');
  }
  print('Stream 2 xong');

  // Cách 3: Chuyển thành Future
  var stream3 = Stream.fromIterable([1, 2, 3, 4, 5]);
  var list = await stream3.toList();
  print(list);   // [1, 2, 3, 4, 5]
}
```

### 6.3. Stream Operators

```dart
void main() async {
  var numbers = Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

  // Giống List nhưng cho Stream
  numbers
      .where((n) => n.isEven)
      .map((n) => n * 10)
      .listen(print);   // 20, 40, 60, 80, 100

  // first, last, length
  var stream = Stream.fromIterable([10, 20, 30]);
  print(await stream.first);      // 10
  // print(await stream.length);  // 3 — cần stream mới (đã consumed)

  // distinct — loại bỏ giá trị trùng liên tiếp
  var dupes = Stream.fromIterable([1, 1, 2, 2, 3, 1, 1]);
  var unique = dupes.distinct();
  await unique.forEach(print);   // 1, 2, 3, 1

  // expand — trải phẳng
  var nested = Stream.fromIterable([[1, 2], [3, 4]]);
  var flat = nested.expand((list) => list);
  await flat.forEach(print);   // 1, 2, 3, 4
}
```

### 6.4. StreamController — Tạo Stream Tùy Chỉnh

```dart
import 'dart:async';

void main() {
  // Single-subscription stream (chỉ 1 listener)
  var controller = StreamController<String>();

  // Thêm dữ liệu vào stream
  controller.sink.add('Hello');
  controller.sink.add('World');
  controller.sink.addError('Oops!');

  // Lắng nghe
  controller.stream.listen(
    (data) => print('Data: $data'),
    onError: (e) => print('Error: $e'),
    onDone: () => print('Done!'),
  );

  controller.sink.add('Goodbye');
  controller.close();   // Đóng stream → trigger onDone

  // --- Broadcast stream (nhiều listener) ---
  var broadcast = StreamController<int>.broadcast();

  broadcast.stream.listen((n) => print('Listener 1: $n'));
  broadcast.stream.listen((n) => print('Listener 2: $n'));

  broadcast.add(1);
  // Listener 1: 1
  // Listener 2: 1

  broadcast.add(2);
  // Listener 1: 2
  // Listener 2: 2

  broadcast.close();
}
```

### 6.5. StreamSubscription — Quản Lý Subscription

```dart
import 'dart:async';

void main() {
  var stream = Stream.periodic(Duration(seconds: 1), (i) => i);

  StreamSubscription<int> subscription = stream.listen((value) {
    print('Giá trị: $value');
  });

  // Tạm dừng
  Future.delayed(Duration(seconds: 3), () {
    subscription.pause();
    print('⏸️ Tạm dừng');
  });

  // Tiếp tục
  Future.delayed(Duration(seconds: 5), () {
    subscription.resume();
    print('▶️ Tiếp tục');
  });

  // Hủy hoàn toàn
  Future.delayed(Duration(seconds: 7), () {
    subscription.cancel();
    print('⏹️ Đã hủy');
  });
}
```

---

## 7. Completer — Tạo Future Thủ Công

```dart
import 'dart:async';

Future<String> fetchWithCompleter() {
  var completer = Completer<String>();

  // Giả lập logic phức tạp
  Timer(Duration(seconds: 2), () {
    // Quyết định complete hay error
    bool success = true;
    if (success) {
      completer.complete('Dữ liệu thành công');
    } else {
      completer.completeError('Có lỗi xảy ra');
    }
  });

  return completer.future;   // Trả về Future để caller await
}

void main() async {
  var result = await fetchWithCompleter();
  print(result);   // Dữ liệu thành công
}
```

---

## 8. Isolate — Xử Lý Song Song Thật Sự

Dart single-threaded, nhưng **Isolate** cho phép chạy code trên thread riêng biệt.

```dart
import 'dart:isolate';

// Hàm chạy trong Isolate riêng — PHẢI là top-level hoặc static
int heavyComputation(int n) {
  // Tính toán nặng (ví dụ: Fibonacci)
  int fib(int n) => n <= 1 ? n : fib(n - 1) + fib(n - 2);
  return fib(n);
}

void main() async {
  print('Bắt đầu tính toán nặng...');

  // Cách 1: Isolate.run (Dart 2.19+) — đơn giản nhất
  int result = await Isolate.run(() => heavyComputation(40));
  print('Kết quả: $result');

  // Cách 2: compute (Flutter) — wrapper đơn giản
  // int result = await compute(heavyComputation, 40);

  print('UI vẫn mượt mà! 🎉');
}
```

### Isolate với giao tiếp 2 chiều

```dart
import 'dart:isolate';

void workerIsolate(SendPort sendPort) {
  var receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is int) {
      // Tính toán nặng
      var result = message * message;
      sendPort.send(result);
    }
  });
}

void main() async {
  var receivePort = ReceivePort();
  await Isolate.spawn(workerIsolate, receivePort.sendPort);

  // Lấy SendPort của worker
  SendPort workerSendPort = await receivePort.first as SendPort;

  // Giao tiếp 2 chiều
  var responsePort = ReceivePort();
  workerSendPort.send(42);

  // Chờ kết quả...
}
```

> 💡 **Trong Flutter**, dùng `compute()` function — wrapper đơn giản hơn `Isolate.run()`.

---

## 9. Timer

```dart
import 'dart:async';

void main() {
  // Timer one-shot — chạy 1 lần sau delay
  Timer(Duration(seconds: 2), () {
    print('⏰ 2 giây đã trôi qua!');
  });

  // Timer.periodic — lặp đi lặp lại
  int count = 0;
  var timer = Timer.periodic(Duration(seconds: 1), (timer) {
    count++;
    print('Tick $count');
    if (count >= 5) {
      timer.cancel();   // Dừng timer
      print('Timer đã dừng');
    }
  });

  // Kiểm tra timer
  print('Timer đang chạy: ${timer.isActive}');
}
```

---

## 10. So Sánh Với JavaScript

| Khái niệm | JavaScript | Dart |
|:-----------|:-----------|:-----|
| Giá trị tương lai | `Promise` | `Future` |
| Chờ kết quả | `await` | `await` |
| Hàm bất đồng bộ | `async function` | `Future<T> fn() async` |
| Luồng dữ liệu | `Observable` (RxJS) | `Stream` |
| Song song thật sự | `Web Worker` | `Isolate` |
| Chờ nhiều Promise | `Promise.all()` | `Future.wait()` |
| Lấy nhanh nhất | `Promise.race()` | `Future.any()` |
| setTimeout | `setTimeout` | `Timer` / `Future.delayed` |
| setInterval | `setInterval` | `Timer.periodic` |

---

## 📝 Bài Tập Thực Hành

### Bài 1: async/await cơ bản
Viết 3 hàm async giả lập:
- `fetchUser()` → chờ 1 giây → trả `User(name, age)`
- `fetchPosts(userId)` → chờ 2 giây → trả `List<Post>`
- `fetchComments(postId)` → chờ 1 giây → trả `List<Comment>`

Gọi tuần tự và in kết quả.

### Bài 2: Future.wait
Sửa bài 1 để fetch `posts` và `comments` song song (thay vì tuần tự).

### Bài 3: StreamController
Tạo `StreamController<String>` mô phỏng chat:
- Thêm tin nhắn mỗi giây
- Listener in ra tin nhắn
- Sau 5 tin nhắn → đóng stream

### Bài 4: Countdown Timer
Dùng `Stream` + `async*` tạo đồng hồ đếm ngược từ 10 đến 0, mỗi giây phát 1 giá trị.

---

> **Bài tiếp theo**: [06 - Xử lý lỗi & Exception](./06_dart_error_handling.md)
