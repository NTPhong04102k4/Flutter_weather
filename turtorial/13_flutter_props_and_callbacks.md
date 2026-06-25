# 📘 Bài 13: Truyền Dữ Liệu Giữa Widgets Trong Flutter

> **Mục tiêu**: Nắm vững các cách truyền dữ liệu: Props, Callbacks, InheritedWidget, ValueNotifier.

---

## 1. Tổng Quan Các Cách Truyền Dữ Liệu

```
Parent → Child:         Constructor (Props)
Child → Parent:         Callback Functions
Sibling ↔ Sibling:      Lifting State Up
Ancestor → Descendants: InheritedWidget / Provider
Any → Any:              State Management (bài 14)
```

---

## 2. Props (Constructor Parameters) — Parent → Child

```dart
// Parent truyền dữ liệu xuống Child qua constructor

class UserCard extends StatelessWidget {
  // Props
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null ? Text(name[0]) : null,
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: Icon(
          Icons.circle,
          color: isOnline ? Colors.green : Colors.grey,
          size: 12,
        ),
      ),
    );
  }
}

// Parent sử dụng
class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserCard(name: 'Phong', email: 'phong@email.com', isOnline: true),
        UserCard(name: 'Minh', email: 'minh@email.com'),
      ],
    );
  }
}
```

---

## 3. Callback Functions — Child → Parent

```dart
// Child thông báo sự kiện lên Parent qua callback

class TodoItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;      // Callback: (bool) → void
  final VoidCallback onDelete;            // Callback: () → void
  final Function(String) onRename;        // Callback: (String) → void

  const TodoItem({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: (value) => onToggle(value ?? false),
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,   // Gọi callback lên parent
      ),
      onLongPress: () {
        onRename('New Title');   // Gọi callback với data
      },
    );
  }
}

// Parent nhận callback
class TodoListScreen extends StatefulWidget {
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _todos = [
    {'title': 'Học Flutter', 'done': false},
    {'title': 'Làm bài tập', 'done': true},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return TodoItem(
          title: todo['title'],
          isCompleted: todo['done'],
          onToggle: (value) {
            setState(() => _todos[index]['done'] = value);
          },
          onDelete: () {
            setState(() => _todos.removeAt(index));
          },
          onRename: (newTitle) {
            setState(() => _todos[index]['title'] = newTitle);
          },
        );
      },
    );
  }
}
```

---

## 4. Lifting State Up — Sibling Communication

```dart
// Khi 2 widget cùng cấp cần chia sẻ state
// → Đẩy state lên widget CHA chung

class TemperatureConverter extends StatefulWidget {
  @override
  State<TemperatureConverter> createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter> {
  // State được "lift up" lên parent
  double _celsius = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sibling 1: Nhập Celsius
        CelsiusInput(
          value: _celsius,
          onChanged: (value) {
            setState(() => _celsius = value);
          },
        ),
        const SizedBox(height: 16),
        // Sibling 2: Hiển thị Fahrenheit
        FahrenheitDisplay(celsius: _celsius),
      ],
    );
  }
}

class CelsiusInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const CelsiusInput({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Celsius'),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

class FahrenheitDisplay extends StatelessWidget {
  final double celsius;
  const FahrenheitDisplay({super.key, required this.celsius});

  @override
  Widget build(BuildContext context) {
    final fahrenheit = celsius * 9 / 5 + 32;
    return Text('${fahrenheit.toStringAsFixed(1)} °F',
        style: const TextStyle(fontSize: 32));
  }
}
```

---

## 5. InheritedWidget — Chia Sẻ Data Xuống Widget Tree

```dart
// InheritedWidget cho phép widget con truy cập data
// mà KHÔNG cần truyền qua từng constructor

class AppConfig extends InheritedWidget {
  final String apiBaseUrl;
  final String appVersion;
  final bool isDarkMode;

  const AppConfig({
    super.key,
    required this.apiBaseUrl,
    required this.appVersion,
    required this.isDarkMode,
    required super.child,
  });

  // Static method để truy cập dễ dàng
  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  // maybeOf — trả null nếu không tìm thấy (an toàn hơn)
  static AppConfig? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(AppConfig oldWidget) {
    // Trả true nếu data thay đổi → notify widget con rebuild
    return apiBaseUrl != oldWidget.apiBaseUrl ||
        appVersion != oldWidget.appVersion ||
        isDarkMode != oldWidget.isDarkMode;
  }
}

// Sử dụng — Wrap ở trên cùng
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppConfig(
      apiBaseUrl: 'https://api.example.com',
      appVersion: '1.0.0',
      isDarkMode: false,
      child: MaterialApp(home: HomeScreen()),
    );
  }
}

// Widget con — truy cập bất kỳ đâu trong tree
class SomeDeepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Truy cập data từ InheritedWidget
    final config = AppConfig.of(context);
    return Text('API: ${config.apiBaseUrl}, v${config.appVersion}');
  }
}
```

> 💡 `Theme.of(context)` và `MediaQuery.of(context)` đều hoạt động nhờ InheritedWidget!

---

## 6. ValueNotifier & ValueListenableBuilder

```dart
// ValueNotifier = cách đơn giản để reactive update
// Không cần setState, không cần State management library

class CounterPage extends StatefulWidget {
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // ValueNotifier thay cho biến thường
  final ValueNotifier<int> _counter = ValueNotifier(0);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _counter.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ValueListenableBuilder — chỉ rebuild PHẦN NÀY khi giá trị thay đổi
        ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, count, child) {
            return Text('Count: $count', style: TextStyle(fontSize: 32));
          },
        ),

        // child parameter — widget KHÔNG rebuild
        ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            return isLoading
                ? const CircularProgressIndicator()
                : child!;   // child không rebuild
          },
          child: const Text('Content loaded'),   // Widget cố định
        ),

        ElevatedButton(
          onPressed: () {
            // Thay đổi giá trị → tự động rebuild ValueListenableBuilder
            _counter.value++;   // Không cần setState!
          },
          child: const Text('+1'),
        ),
      ],
    );
  }
}
```

### Chia sẻ ValueNotifier giữa widgets

```dart
// Truyền ValueNotifier qua constructor
class ChildWidget extends StatelessWidget {
  final ValueNotifier<int> counter;
  const ChildWidget({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: counter,
      builder: (_, count, __) => Text('Child count: $count'),
    );
  }
}
```

---

## 7. Bảng So Sánh

| Cách | Hướng | Phức tạp | Dùng khi |
|:-----|:------|:---------|:---------|
| Props (constructor) | Parent → Child | Thấp | Truyền data xuống 1-2 cấp |
| Callbacks | Child → Parent | Thấp | Thông báo sự kiện lên parent |
| Lifting State Up | Sibling ↔ Sibling | Trung bình | 2 widget cùng cấp chia sẻ state |
| InheritedWidget | Ancestor → Descendants | Trung bình | Data cần chia sẻ sâu (config, theme) |
| ValueNotifier | Any | Thấp | State đơn giản, reactive |
| Provider/Riverpod/Bloc | Any → Any | Cao | State phức tạp (bài 14) |

---

## 📝 Bài Tập Thực Hành

### Bài 1: Shopping Cart
- `ProductCard` → callback `onAddToCart(product)` lên parent
- Parent quản lý `List<Product>` cart
- Hiển thị badge số lượng trên icon giỏ hàng

### Bài 2: Theme Switcher
Dùng `InheritedWidget` tạo `ThemeProvider` cho phép bất kỳ widget con nào toggle dark/light mode.

### Bài 3: Form với ValueNotifier
Tạo form đăng ký với `ValueNotifier<bool>` cho `isFormValid`. Nút submit chỉ bật khi form hợp lệ.

---

> **Bài tiếp theo**: [14 - Quản lý State](./14_flutter_state_management.md)
