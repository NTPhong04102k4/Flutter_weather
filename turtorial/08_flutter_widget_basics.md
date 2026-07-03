# 📘 Bài 08: Widget Cơ Bản Trong Flutter

> **Mục tiêu**: Hiểu Widget tree, StatelessWidget, StatefulWidget, Lifecycle, Hot Reload, và Key.

---

## 1. Mọi Thứ Trong Flutter Đều Là Widget

```
Flutter App = Cây Widget lồng nhau

MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text('Tiêu đề')
    └── Body
        └── Column
            ├── Text('Xin chào')
            ├── Image.network('...')
            └── ElevatedButton
                └── Text('Bấm tôi')
```

Flutter có **3 loại tree**:

```
Widget Tree          Element Tree         RenderObject Tree
(Blueprint)          (Instance)           (Layout & Paint)
┌──────────┐        ┌──────────┐         ┌──────────┐
│  Widget  │───────→│ Element  │────────→│  Render  │
│  (const, │        │ (mutable,│         │  Object  │
│  immutable)       │  lifecycle)        │ (size,   │
│           │        │          │         │  paint)  │
└──────────┘        └──────────┘         └──────────┘

Widget = Mô tả UI (class cấu hình, immutable)
Element = Instance thực tế, quản lý lifecycle
RenderObject = Tính toán layout + vẽ lên màn hình
```

---

## 2. StatelessWidget — Widget Không Có State

Dùng khi UI **không thay đổi** sau khi tạo (hoặc chỉ phụ thuộc vào props từ parent).

```dart
import 'package:flutter/material.dart';

class GreetingCard extends StatelessWidget {
  // Props — nhận từ parent
  final String name;
  final int age;
  final VoidCallback? onTap;

  // const constructor — tối ưu rebuild
  const GreetingCard({
    super.key,
    required this.name,
    required this.age,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // build() được gọi mỗi khi cần render/re-render
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text('Xin chào, $name!'),
        subtitle: Text('$age tuổi'),
        onTap: onTap,
      ),
    );
  }
}

// Sử dụng
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // const → Flutter skip rebuild nếu props không đổi
            const GreetingCard(name: 'Phong', age: 25),
            GreetingCard(
              name: 'Minh',
              age: 30,
              onTap: () => print('Tapped!'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. StatefulWidget — Widget Có State

Dùng khi UI **cần thay đổi** dựa trên tương tác user hoặc dữ liệu thay đổi.

```dart
import 'package:flutter/material.dart';

// StatefulWidget = 2 class:
// 1. Widget class (immutable) — chứa props
// 2. State class (mutable) — chứa state + build()

class CounterWidget extends StatefulWidget {
  final String title;
  final int initialValue;

  const CounterWidget({
    super.key,
    required this.title,
    this.initialValue = 0,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialValue;   // Truy cập props qua "widget."
  }

  void _increment() {
    setState(() {
      // setState thông báo Flutter: "State đã đổi, rebuild UI"
      _count++;
    });
  }

  void _decrement() {
    setState(() {
      _count--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.title, style: TextStyle(fontSize: 20)),
        Text(
          '$_count',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _decrement,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _increment,
            ),
          ],
        ),
      ],
    );
  }
}
```

### Quy tắc `setState()`

```dart
// ✅ ĐÚNG — thay đổi state BÊN TRONG setState
setState(() {
  _count++;
  _name = 'Phong';
});

// ✅ ĐÚNG — thay đổi trước, gọi setState để trigger rebuild
_count++;
setState(() {});   // Chỉ trigger rebuild

// ❌ SAI — KHÔNG gọi setState → UI không cập nhật
_count++;   // State đổi nhưng Flutter không biết

// ❌ SAI — KHÔNG async bên trong setState
setState(() async {   // ❌
  var data = await fetchData();
  _items = data;
});

// ✅ ĐÚNG — async bên ngoài setState
Future<void> _loadData() async {
  var data = await fetchData();
  setState(() {
    _items = data;   // Chỉ gán giá trị đồng bộ
  });
}
```

---

## 4. Lifecycle (Vòng Đời) của StatefulWidget 🔥

```
┌─────────────────────────────────────────────────┐
│           StatefulWidget Lifecycle                │
│                                                  │
│  createState()        ← Tạo State object         │
│       │                                          │
│       ▼                                          │
│  initState()          ← Khởi tạo (gọi 1 lần)    │
│       │                  - Khởi tạo biến         │
│       │                  - Subscribe stream       │
│       │                  - Gọi API lần đầu       │
│       ▼                                          │
│  didChangeDependencies() ← InheritedWidget đổi   │
│       │                    - Theme đổi            │
│       │                    - MediaQuery đổi       │
│       ▼                                          │
│  build()              ← Xây dựng UI              │
│       │                  (gọi nhiều lần)         │
│       │                                          │
│  ┌────┼──── (Khi parent rebuild với props mới)   │
│  │    ▼                                          │
│  │ didUpdateWidget()  ← Props từ parent thay đổi │
│  │    │                  - So sánh old vs new     │
│  │    ▼                  - Cập nhật state          │
│  │ build()            ← Rebuild UI                │
│  └────┘                                          │
│                                                  │
│  setState()           → Trigger build() lại      │
│       │                                          │
│       ▼                                          │
│  build()              ← Rebuild UI               │
│                                                  │
│  deactivate()         ← Widget bị remove tạm     │
│       │                                          │
│       ▼                                          │
│  dispose()            ← Cleanup (gọi 1 lần)     │
│                          - Cancel timer           │
│                          - Close stream           │
│                          - Dispose controller     │
└─────────────────────────────────────────────────┘
```

### Ví dụ thực tế

```dart
class LifecycleDemo extends StatefulWidget {
  final String userId;
  const LifecycleDemo({super.key, required this.userId});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  StreamSubscription? _subscription;
  Timer? _timer;
  List<String> _data = [];
  bool _isLoading = true;

  // 1️⃣ initState — gọi 1 lần khi State được tạo
  @override
  void initState() {
    super.initState();   // PHẢI gọi super.initState() đầu tiên
    print('1. initState');

    _controller = TextEditingController();
    _scrollController = ScrollController();

    // Gọi API lần đầu
    _loadData();

    // Subscribe stream
    _subscription = someStream.listen((data) {
      setState(() => _data.add(data));
    });

    // Timer
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  // 2️⃣ didChangeDependencies — khi InheritedWidget thay đổi
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('2. didChangeDependencies');

    // Truy cập Theme, MediaQuery, Provider ở đây
    var theme = Theme.of(context);
    var screenWidth = MediaQuery.of(context).size.width;
  }

  // 3️⃣ build — xây dựng UI (gọi nhiều lần)
  @override
  Widget build(BuildContext context) {
    print('3. build');
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _data.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_data[index]),
              ),
            ),
    );
  }

  // 4️⃣ didUpdateWidget — khi parent rebuild với props mới
  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('4. didUpdateWidget');

    // So sánh props cũ vs mới
    if (widget.userId != oldWidget.userId) {
      print('userId đổi: ${oldWidget.userId} → ${widget.userId}');
      _loadData();   // Load lại data cho user mới
    }
  }

  // 5️⃣ deactivate — widget bị remove khỏi tree (tạm thời)
  @override
  void deactivate() {
    print('5. deactivate');
    super.deactivate();
  }

  // 6️⃣ dispose — cleanup (gọi 1 lần khi widget bị hủy vĩnh viễn)
  @override
  void dispose() {
    print('6. dispose');

    _controller.dispose();         // Dispose TextEditingController
    _scrollController.dispose();   // Dispose ScrollController
    _subscription?.cancel();       // Cancel stream subscription
    _timer?.cancel();              // Cancel timer

    super.dispose();   // PHẢI gọi super.dispose() cuối cùng
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // await api.fetchData(widget.userId);
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _data = ['Item 1', 'Item 2', 'Item 3'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _refreshData() {
    print('Auto refresh...');
  }
}
```

---

## 5. Hot Reload vs Hot Restart 🔥

```
Hot Reload (⚡ < 1 giây):
├── Giữ nguyên STATE hiện tại
├── Chỉ rebuild widget tree với code mới
├── Chạy lại build() method
├── KHÔNG chạy lại initState(), main()
└── Dùng khi: sửa UI, thêm/xóa widget

Hot Restart (🔄 ~ 2-3 giây):
├── Reset TOÀN BỘ state
├── Chạy lại main() từ đầu
├── Chạy lại initState()
└── Dùng khi: đổi logic initState, thêm biến mới

Full Restart (🔁 ~ 10-30 giây):
├── Rebuild toàn bộ app
├── Compile lại native code
└── Dùng khi: thêm package, sửa native code (Android/iOS)
```

### Hot Reload KHÔNG hoạt động khi:

```dart
// 1. Thay đổi code trong main() — cần Hot Restart
void main() {
  // Thay đổi ở đây → Hot Restart
  runApp(MyApp());
}

// 2. Thay đổi initState — cần Hot Restart
@override
void initState() {
  super.initState();
  _count = 100;   // Đổi giá trị → Hot Restart mới có hiệu lực
}

// 3. Thay đổi enum, generic type — cần Hot Restart

// 4. Thêm/xóa package — cần Full Restart
```

---

## 6. Key — Quản Lý Identity Của Widget

### 6.1. Tại sao cần Key?

```dart
// ❌ Không có Key — Flutter có thể nhầm widget khi reorder
// Ví dụ: Reorder list items
Column(
  children: [
    // Nếu swap vị trí mà không có key → Flutter giữ state cũ ở vị trí cũ
    CounterWidget(title: 'A'),   // State: count = 5
    CounterWidget(title: 'B'),   // State: count = 10
  ],
)
// Sau khi swap → 'B' hiện ở trên nhưng count vẫn = 5 (state của 'A'!)

// ✅ Có Key — Flutter track đúng widget
Column(
  children: [
    CounterWidget(key: ValueKey('A'), title: 'A'),
    CounterWidget(key: ValueKey('B'), title: 'B'),
  ],
)
// Sau khi swap → state đi theo đúng widget
```

### 6.2. Các loại Key

```dart
// 1. ValueKey — dùng giá trị để phân biệt
ListView(
  children: users.map((user) =>
    UserTile(
      key: ValueKey(user.id),   // ID duy nhất
      user: user,
    ),
  ).toList(),
)

// 2. ObjectKey — dùng object reference
ObjectKey(myObject)

// 3. UniqueKey — tạo key duy nhất (mỗi lần build tạo key mới)
// ⚠️ Cẩn thận: đặt trong build() → mỗi lần rebuild tạo key mới → mất state
UniqueKey()

// 4. GlobalKey — truy cập State/RenderObject từ bất kỳ đâu
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(validator: (v) => v!.isEmpty ? 'Required' : null),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form hợp lệ
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### 6.3. Quy tắc dùng Key

```
Khi nào CẦN Key:
✅ List có thể reorder (drag & drop)
✅ List có thể thêm/xóa item ở giữa
✅ List items là StatefulWidget
✅ AnimatedList
✅ Form (GlobalKey<FormState>)

Khi nào KHÔNG cần Key:
❌ StatelessWidget đơn giản
❌ List cố định không thay đổi
❌ Column/Row với widgets cố định
```

---

## 7. BuildContext

```dart
@override
Widget build(BuildContext context) {
  // context = vị trí của widget này trong widget tree
  // Dùng để truy cập:

  // 1. Theme
  var theme = Theme.of(context);
  var primaryColor = theme.colorScheme.primary;

  // 2. MediaQuery — kích thước màn hình
  var screenWidth = MediaQuery.of(context).size.width;
  var padding = MediaQuery.of(context).padding;

  // 3. Navigator — chuyển trang
  // Navigator.of(context).push(...);

  // 4. Scaffold — SnackBar, Drawer
  // ScaffoldMessenger.of(context).showSnackBar(...);

  // 5. InheritedWidget / Provider
  // Provider.of<MyModel>(context);

  return Container();
}
```

---

## 8. Widget Hay Dùng — Layout Cơ Bản

```dart
Widget build(BuildContext context) {
  return Column(
    // Column = xếp widget theo chiều DỌC
    mainAxisAlignment: MainAxisAlignment.center,     // Canh giữa dọc
    crossAxisAlignment: CrossAxisAlignment.stretch,  // Kéo dài ngang

    children: [
      // --- Container ---
      Container(
        width: 200,
        height: 100,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Text('Container', style: TextStyle(color: Colors.white)),
      ),

      // --- Row = xếp ngang ---
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
        ],
      ),

      // --- SizedBox = spacer cố định ---
      SizedBox(height: 20),

      // --- Expanded = chiếm hết không gian còn lại ---
      Expanded(
        child: ListView(
          children: [
            ListTile(title: Text('Item 1')),
            ListTile(title: Text('Item 2')),
          ],
        ),
      ),

      // --- Flexible = chiếm theo tỷ lệ ---
      Row(
        children: [
          Flexible(flex: 2, child: Container(color: Colors.red, height: 50)),
          Flexible(flex: 1, child: Container(color: Colors.blue, height: 50)),
        ],
      ),

      // --- Stack = xếp chồng ---
      Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 200, height: 200, color: Colors.grey),
          Positioned(
            top: 10,
            right: 10,
            child: Icon(Icons.close, color: Colors.red),
          ),
          Text('Centered text'),
        ],
      ),

      // --- Wrap = tự xuống dòng ---
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          Chip(label: Text('Flutter')),
          Chip(label: Text('Dart')),
          Chip(label: Text('Mobile')),
          Chip(label: Text('iOS')),
          Chip(label: Text('Android')),
        ],
      ),
    ],
  );
}
```

---

## 9. Các "Từ Khoá" Mở Rộng Của Flutter 🔖

Flutter không thêm từ khoá mới vào Dart, nhưng có một bộ **định danh/quy ước xuất hiện dày đặc** mà bạn phải quen. Xem như "từ khoá của Flutter":

| Định danh | Bản chất | Vai trò |
|:--|:--|:--|
| `Widget` | class | Đơn vị UI cơ bản — mọi thứ đều là Widget |
| `StatelessWidget` / `StatefulWidget` | class | Widget không / có state |
| `State<T>` | class | Nơi giữ state cho `StatefulWidget` |
| `build(BuildContext context)` | method | Trả về cây widget để render — gọi mỗi lần rebuild |
| `BuildContext` | class | "Vị trí" của widget trong cây — dùng để tra Theme, Navigator... |
| `setState(() {...})` | method | Báo Flutter "state đổi → rebuild" |
| `super.key` / `Key` | tham số | Định danh widget giúp Flutter tái sử dụng đúng widget |
| `required` | từ khoá Dart | Tham số bắt buộc trong constructor widget |
| `const` (constructor) | từ khoá Dart | Widget bất biến → Flutter bỏ qua rebuild, tối ưu hiệu năng |
| `@override` | annotation | Ghi đè `build`, `initState`, `dispose`... |
| `child` / `children` | tham số | Widget con (một / nhiều) |
| `context` | biến | Thường là `BuildContext` được truyền vào `build` |
| `mounted` | getter | `true` nếu State còn trong cây — check trước `setState` sau `await` |

### Lifecycle & annotation hay gặp

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key, required this.title});   // const + super.key + required

  final String title;

  @override
  State<MyWidget> createState() => _MyWidgetState();  // @override
}

class _MyWidgetState extends State<MyWidget> {        // _ = private State
  @override
  void initState() {                                  // gọi 1 lần khi tạo
    super.initState();
  }

  @override
  void dispose() {                                    // dọn dẹp controller/timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {                // rebuild UI
    // widget.title → truy cập property của StatefulWidget từ State
    return Text(widget.title);
  }
}
```

> 💡 **`const` widget = tối ưu miễn phí**: khai báo widget `const` khi tất cả tham số là hằng → Flutter tái sử dụng instance cũ, không rebuild thừa.
>
> 💡 **`widget.` trong State**: bên trong `State`, truy cập property của `StatefulWidget` qua `widget.xxx` (vì chúng nằm ở 2 class khác nhau).

---

## 📝 Bài Tập Thực Hành

### Bài 1: Profile Card
Tạo `StatelessWidget` hiển thị profile card với: avatar, tên, email, và nút "Liên hệ".

### Bài 2: Todo Item
Tạo `StatefulWidget` hiển thị todo item với checkbox. Tap vào → toggle trạng thái hoàn thành.

### Bài 3: Lifecycle Logger
Tạo widget `LifecycleLogger` in ra console ở mỗi lifecycle method. Quan sát thứ tự gọi khi: mở app → tap button → navigate đi → navigate về.

### Bài 4: Stopwatch
Tạo đồng hồ bấm giờ với nút Start/Stop/Reset. Dùng `Timer.periodic` + `dispose`.

---

> **Bài tiếp theo**: [09 - Material Design Widgets](./09_flutter_material_widgets.md)
