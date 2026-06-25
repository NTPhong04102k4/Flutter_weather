# 📘 Bài 07: Race Condition & Search Cache Trong Dart

> **Mục tiêu**: Hiểu và giải quyết race condition, implement debounce/throttle, và search cache.

---

## 1. Race Condition Là Gì?

Race condition xảy ra khi **kết quả phụ thuộc vào thứ tự hoàn thành** của các tác vụ bất đồng bộ.

```
Ví dụ: User gõ "abc" trong search bar

Thời gian →
Gõ "a"  ──→ Request 1 ──────────────────→ Response 1 (kết quả cho "a")
Gõ "ab" ──→ Request 2 ──────→ Response 2 (kết quả cho "ab")
Gõ "abc"──→ Request 3 ────→ Response 3 (kết quả cho "abc")

Thứ tự response nhận được: 3 → 2 → 1 ← SAI!
                                        ↑ Response cuối cùng là cho "a"
                                          nhưng user đang muốn kết quả "abc"!
```

### Ví dụ Race Condition

```dart
String _lastQuery = '';
List<String> _results = [];

Future<void> search(String query) async {
  _lastQuery = query;

  // Giả lập API - thời gian response ngẫu nhiên
  var results = await fakeSearchApi(query);

  // ⚠️ RACE CONDITION: Response cũ có thể đến SAU response mới
  // Khi "abc" response trước "a", nhưng "a" response đến sau
  // → _results bị ghi đè bằng kết quả của "a" (sai!)
  _results = results;
  print('Hiển thị kết quả cho: $query');
}

Future<List<String>> fakeSearchApi(String query) async {
  // Thời gian ngẫu nhiên: "a" có thể mất 3s, "abc" chỉ mất 1s
  var delay = query.length == 1 ? 3 : 1;
  await Future.delayed(Duration(seconds: delay));
  return ['$query result 1', '$query result 2'];
}
```

---

## 2. Giải Quyết Race Condition

### 2.1. Kiểm tra query mới nhất

```dart
class SearchService {
  String _lastQuery = '';

  Future<List<String>> search(String query) async {
    _lastQuery = query;   // Lưu query mới nhất

    var results = await fakeSearchApi(query);

    // ✅ Kiểm tra: query này có còn là mới nhất không?
    if (query != _lastQuery) {
      print('⚠️ Bỏ qua kết quả cũ cho: "$query"');
      return [];   // Bỏ qua kết quả cũ
    }

    return results;
  }
}
```

### 2.2. CancelableOperation (package async)

```dart
// pubspec.yaml: dependencies: async: ^2.11.0
import 'package:async/async.dart';

class SearchService {
  CancelableOperation<List<String>>? _currentOperation;

  Future<List<String>> search(String query) async {
    // Hủy request trước đó
    _currentOperation?.cancel();

    // Tạo operation mới
    _currentOperation = CancelableOperation.fromFuture(
      fakeSearchApi(query),
      onCancel: () => print('❌ Đã hủy search cho: "$query"'),
    );

    try {
      // Chờ kết quả (nếu bị cancel → throw)
      var results = await _currentOperation!.value;
      return results;
    } catch (e) {
      return [];   // Bị cancel
    }
  }

  void dispose() {
    _currentOperation?.cancel();
  }
}
```

---

## 3. Debounce — Chờ User Ngừng Gõ

Debounce = **chờ user ngừng gõ một khoảng thời gian** trước khi thực hiện action.

```
User gõ: h → he → hel → hell → hello
                                     ↑
                              Chờ 300ms không gõ thêm
                              → MỚI gọi API search("hello")

Thay vì gọi 5 lần API, chỉ gọi 1 lần!
```

### Implement Debounce

```dart
import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Chạy [action] sau [delay].
  /// Nếu gọi lại trước khi hết delay → reset timer.
  void run(void Function() action) {
    _timer?.cancel();   // Hủy timer cũ
    _timer = Timer(delay, action);   // Tạo timer mới
  }

  void cancel() {
    _timer?.cancel();
  }

  bool get isActive => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

// Sử dụng trong Flutter
// class _SearchPageState extends State<SearchPage> {
//   final _debouncer = Debouncer(delay: Duration(milliseconds: 500));
//   final _controller = TextEditingController();
//
//   void _onSearchChanged(String query) {
//     _debouncer.run(() {
//       // Chỉ gọi API sau khi user ngừng gõ 500ms
//       _performSearch(query);
//     });
//   }
//
//   @override
//   void dispose() {
//     _debouncer.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
// }
```

### Debounce với async (trả về Future)

```dart
import 'dart:async';

class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;
  CancelableOperation? _lastOperation;

  AsyncDebouncer({this.delay = const Duration(milliseconds: 300)});

  Future<T?> run<T>(Future<T> Function() action) async {
    _timer?.cancel();
    _lastOperation?.cancel();

    final completer = Completer<T?>();

    _timer = Timer(delay, () async {
      try {
        _lastOperation = CancelableOperation.fromFuture(action());
        final result = await _lastOperation!.value;
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
    _lastOperation?.cancel();
  }
}
```

---

## 4. Throttle — Giới Hạn Tần Suất

Throttle = **chỉ cho phép action chạy 1 lần trong khoảng thời gian nhất định**.

```
Debounce:  ─x─x─x─x─x─────[action]  (chờ ngừng gõ)
Throttle:  ─[action]─x─x─x─[action]  (cứ mỗi N ms chạy 1 lần)
```

```dart
import 'dart:async';

class Throttler {
  final Duration interval;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({this.interval = const Duration(milliseconds: 300)});

  void run(void Function() action) {
    if (_isThrottled) return;   // Đang trong thời gian chờ → bỏ qua

    action();   // Chạy ngay
    _isThrottled = true;

    _timer = Timer(interval, () {
      _isThrottled = false;   // Hết thời gian chờ → cho phép chạy lại
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Sử dụng: Nút bấm chống spam
// class _ButtonState extends State<...> {
//   final _throttler = Throttler(interval: Duration(seconds: 2));
//
//   void _onTap() {
//     _throttler.run(() {
//       // Chỉ gọi API tối đa 1 lần mỗi 2 giây
//       submitForm();
//     });
//   }
// }
```

### Khi nào dùng Debounce vs Throttle?

| Tình huống | Dùng | Lý do |
|:-----------|:-----|:------|
| Search bar (gõ chữ) | **Debounce** | Chờ user gõ xong |
| Scroll event (infinite scroll) | **Throttle** | Giới hạn tần suất check |
| Resize window | **Debounce** | Chờ resize xong |
| Nút submit form | **Throttle** | Chống double-click |
| Auto-save | **Debounce** | Chờ user ngừng edit |
| Mouse move tracking | **Throttle** | Giới hạn tần suất update |

---

## 5. Search Cache — Lưu Kết Quả Tìm Kiếm

### 5.1. Simple Cache

```dart
class SearchCache {
  final Map<String, List<String>> _cache = {};
  final int maxSize;
  final Duration expiry;
  final Map<String, DateTime> _timestamps = {};

  SearchCache({
    this.maxSize = 100,
    this.expiry = const Duration(minutes: 5),
  });

  /// Lấy từ cache (null nếu không có hoặc hết hạn)
  List<String>? get(String query) {
    var normalizedQuery = query.trim().toLowerCase();

    if (!_cache.containsKey(normalizedQuery)) return null;

    // Kiểm tra hết hạn
    var timestamp = _timestamps[normalizedQuery];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) > expiry) {
      _cache.remove(normalizedQuery);
      _timestamps.remove(normalizedQuery);
      return null;   // Cache expired
    }

    return _cache[normalizedQuery];
  }

  /// Lưu vào cache
  void set(String query, List<String> results) {
    var normalizedQuery = query.trim().toLowerCase();

    // Xóa cache cũ nhất nếu đầy
    if (_cache.length >= maxSize) {
      _evictOldest();
    }

    _cache[normalizedQuery] = results;
    _timestamps[normalizedQuery] = DateTime.now();
  }

  void _evictOldest() {
    if (_timestamps.isEmpty) return;
    var oldest = _timestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
    _cache.remove(oldest.key);
    _timestamps.remove(oldest.key);
  }

  void clear() {
    _cache.clear();
    _timestamps.clear();
  }

  int get size => _cache.length;
}
```

### 5.2. LRU Cache (Least Recently Used)

```dart
import 'dart:collection';

class LruCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LruCache({this.maxSize = 50});

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Di chuyển lên đầu (most recently used)
    var value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }

  void set(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Xóa phần tử cũ nhất (least recently used)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void clear() => _cache.clear();

  int get size => _cache.length;
}
```

---

## 6. Kết Hợp Tất Cả: Smart Search Service 🔥

```dart
import 'dart:async';

class SmartSearchService {
  final Debouncer _debouncer;
  final SearchCache _cache;
  String _lastQuery = '';
  bool _isLoading = false;

  // Callback để notify UI
  void Function(List<String> results)? onResults;
  void Function(bool isLoading)? onLoading;
  void Function(String error)? onError;

  SmartSearchService({
    Duration debounceDelay = const Duration(milliseconds: 300),
    int cacheSize = 100,
    Duration cacheExpiry = const Duration(minutes: 5),
  })  : _debouncer = Debouncer(delay: debounceDelay),
        _cache = SearchCache(maxSize: cacheSize, expiry: cacheExpiry);

  void search(String query) {
    var trimmed = query.trim();

    // Bỏ qua query trống
    if (trimmed.isEmpty) {
      onResults?.call([]);
      return;
    }

    // Debounce — chờ user ngừng gõ
    _debouncer.run(() => _performSearch(trimmed));
  }

  Future<void> _performSearch(String query) async {
    _lastQuery = query;

    // 1. Kiểm tra cache trước
    var cached = _cache.get(query);
    if (cached != null) {
      print('📦 Cache hit: "$query"');
      onResults?.call(cached);
      return;
    }

    // 2. Gọi API
    _isLoading = true;
    onLoading?.call(true);

    try {
      var results = await _callApi(query);

      // 3. Kiểm tra race condition
      if (query != _lastQuery) {
        print('⚠️ Bỏ qua kết quả cũ: "$query" (hiện tại: "$_lastQuery")');
        return;
      }

      // 4. Lưu cache
      _cache.set(query, results);

      // 5. Notify UI
      onResults?.call(results);
    } catch (e) {
      if (query == _lastQuery) {
        onError?.call('Lỗi tìm kiếm: $e');
      }
    } finally {
      _isLoading = false;
      onLoading?.call(false);
    }
  }

  Future<List<String>> _callApi(String query) async {
    print('🌐 API call: "$query"');
    await Future.delayed(Duration(milliseconds: 500));   // Giả lập
    return List.generate(5, (i) => '$query - Kết quả ${i + 1}');
  }

  void dispose() {
    _debouncer.dispose();
    _cache.clear();
  }
}

// === Sử dụng ===
void main() async {
  var searchService = SmartSearchService();

  searchService.onResults = (results) {
    print('📋 Kết quả: $results');
  };

  searchService.onLoading = (isLoading) {
    print(isLoading ? '⏳ Đang tải...' : '✅ Hoàn tất');
  };

  // Giả lập user gõ: f → fl → flu → flut → flutter
  for (var query in ['f', 'fl', 'flu', 'flut', 'flutter']) {
    searchService.search(query);
    await Future.delayed(Duration(milliseconds: 100));   // Gõ nhanh
  }

  // Chờ debounce + API
  await Future.delayed(Duration(seconds: 2));

  // Gõ lại "flutter" → cache hit!
  searchService.search('flutter');
  await Future.delayed(Duration(seconds: 1));

  searchService.dispose();
}
```

---

## 7. Mutex / Lock Pattern (Ngăn Concurrent Access)

```dart
import 'dart:async';

class Mutex {
  Completer<void>? _completer;

  Future<void> acquire() async {
    while (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer<void>();
  }

  void release() {
    var c = _completer;
    _completer = null;
    c?.complete();
  }

  /// Chạy [action] với lock
  Future<T> protect<T>(Future<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}

// Sử dụng — đảm bảo chỉ 1 request tại 1 thời điểm
class TokenRefresher {
  final _mutex = Mutex();
  String? _token;

  Future<String> getValidToken() async {
    return _mutex.protect(() async {
      if (_token == null || _isExpired(_token!)) {
        _token = await _refreshToken();
      }
      return _token!;
    });
  }

  bool _isExpired(String token) => false; // Kiểm tra thật
  Future<String> _refreshToken() async {
    await Future.delayed(Duration(seconds: 1));
    return 'new_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Debouncer
Implement `Debouncer` và test với 10 lần gọi liên tiếp (delay 50ms giữa mỗi lần).
Chỉ lần cuối mới được thực thi.

### Bài 2: Search với Cache
Tạo search service có cache. Test:
1. Search "flutter" → API call
2. Search "flutter" lần 2 → cache hit (không gọi API)
3. Chờ cache expire → search lại → API call

### Bài 3: Race Condition
Tạo 3 Future với delay ngẫu nhiên. Đảm bảo chỉ kết quả của request MỚI NHẤT được sử dụng.

---

> **Bài tiếp theo**: [08 - Widget cơ bản trong Flutter](./08_flutter_widget_basics.md)
