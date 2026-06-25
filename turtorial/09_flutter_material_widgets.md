# 📘 Bài 09: Material Design Widgets Trong Flutter

> **Mục tiêu**: Thành thạo Material Design widgets, tạo giao diện Android-style chuyên nghiệp.

---

## 1. MaterialApp — Gốc Của App Material

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,   // Ẩn banner "Debug"

      // Theme — định nghĩa style toàn app
      theme: ThemeData(
        useMaterial3: true,   // Dùng Material 3 (mới nhất)
        colorSchemeSeed: Colors.blue,   // Tạo palette từ seed color
        brightness: Brightness.light,
      ),

      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,   // Theo system setting

      home: const HomePage(),
    );
  }
}
```

---

## 2. Scaffold — Bộ Khung Trang

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        elevation: 2,
      ),

      // --- Body ---
      body: const Center(child: Text('Nội dung')),

      // --- FloatingActionButton ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- BottomNavigationBar ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),

      // --- Drawer (menu bên trái) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(radius: 30, child: Text('P')),
                  SizedBox(height: 8),
                  Text('Phong', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('phong@email.com', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Giới thiệu'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. Buttons (Nút bấm)

```dart
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- ElevatedButton (nút nổi) ---
        ElevatedButton(
          onPressed: () => print('Pressed!'),
          child: const Text('Elevated Button'),
        ),

        // Styled ElevatedButton
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: const Text('Custom Style'),
        ),

        // --- TextButton (nút text) ---
        TextButton(
          onPressed: () {},
          child: const Text('Text Button'),
        ),

        // --- OutlinedButton (nút viền) ---
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined Button'),
        ),

        // --- IconButton ---
        IconButton(
          icon: const Icon(Icons.favorite),
          color: Colors.red,
          iconSize: 32,
          onPressed: () {},
        ),

        // --- Button với icon ---
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Tải xuống'),
        ),

        // --- FilledButton (Material 3) ---
        FilledButton(
          onPressed: () {},
          child: const Text('Filled Button'),
        ),

        FilledButton.tonal(
          onPressed: () {},
          child: const Text('Filled Tonal'),
        ),

        // --- Disabled button ---
        ElevatedButton(
          onPressed: null,   // null = disabled
          child: const Text('Disabled'),
        ),

        // --- Loading button ---
        ElevatedButton(
          onPressed: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Đang xử lý...'),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## 4. TextField & Form Validation

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Form hợp lệ
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Email ---
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;   // null = hợp lệ
              },
            ),

            const SizedBox(height: 16),

            // --- Password ---
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mật khẩu phải >= 6 ký tự';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 24),

            // --- Submit ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Card & ListTile

```dart
class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh
          Image.network(
            'https://picsum.photos/400/200',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Nội dung
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sản phẩm A',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Mô tả ngắn về sản phẩm...',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('199.000₫',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Mua ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Dialog, SnackBar, BottomSheet

```dart
class DialogsDemo extends StatelessWidget {
  const DialogsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- AlertDialog ---
        ElevatedButton(
          onPressed: () => _showAlertDialog(context),
          child: const Text('Show Dialog'),
        ),

        // --- SnackBar ---
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đã lưu thành công!'),
                action: SnackBarAction(
                  label: 'Hoàn tác',
                  onPressed: () => print('Undo'),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: const Text('Show SnackBar'),
        ),

        // --- BottomSheet ---
        ElevatedButton(
          onPressed: () => _showBottomSheet(context),
          child: const Text('Show Bottom Sheet'),
        ),
      ],
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,   // Không đóng khi tap ngoài
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Xóa...
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,   // Cho phép full height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const ListTile(title: Text('Option 1'), leading: Icon(Icons.share)),
            const ListTile(title: Text('Option 2'), leading: Icon(Icons.copy)),
            const ListTile(title: Text('Option 3'), leading: Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. TabBar & TabBarView

```dart
class TabDemo extends StatelessWidget {
  const TabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabs Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Trang chủ'),
              Tab(icon: Icon(Icons.search), text: 'Tìm kiếm'),
              Tab(icon: Icon(Icons.person), text: 'Cá nhân'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Tab 1: Trang chủ')),
            Center(child: Text('Tab 2: Tìm kiếm')),
            Center(child: Text('Tab 3: Cá nhân')),
          ],
        ),
      ),
    );
  }
}
```

---

## 8. Theme & Material 3

```dart
// Tùy chỉnh Theme toàn diện
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,

    // Color scheme từ seed color
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),

    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// Sử dụng Theme trong widget
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Text(
    'Hello',
    style: theme.textTheme.headlineLarge?.copyWith(
      color: colorScheme.primary,
    ),
  );
}
```

---

## 9. ListView & GridView

```dart
// ListView.builder — tạo item khi scroll tới (hiệu quả với list lớn)
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text('Item $index'),
      subtitle: Text('Mô tả item $index'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  },
)

// ListView.separated — có divider giữa các items
ListView.separated(
  itemCount: 50,
  separatorBuilder: (context, index) => const Divider(),
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// GridView.builder
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: 20,
  itemBuilder: (context, index) {
    return Card(child: Center(child: Text('Grid $index')));
  },
)
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Login Screen
Tạo trang đăng nhập hoàn chỉnh với: logo, email/password fields, validation, nút đăng nhập, link "Quên mật khẩu?".

### Bài 2: Product List
Tạo trang danh sách sản phẩm với: GridView.builder, ProductCard, và nút thêm vào giỏ hàng.

### Bài 3: Settings Page
Tạo trang cài đặt với: ListTile, Switch, Dropdown, và Dialog xác nhận đăng xuất.

### Bài 4: Custom Theme
Tạo app có 2 theme (light/dark) với custom color scheme. User có thể chuyển đổi qua Switch.

---

> **Bài tiếp theo**: [10 - Cupertino Widgets (iOS-style)](./10_flutter_cupertino_widgets.md)
