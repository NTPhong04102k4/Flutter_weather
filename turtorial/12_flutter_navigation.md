# 📘 Bài 12: Navigation & Routing Trong Flutter

> **Mục tiêu**: Thành thạo điều hướng giữa các màn hình, deep linking, và nested navigation.

---

## 1. Navigator 1.0 — Imperative Navigation

### 1.1. push & pop cơ bản

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // push — đẩy trang mới lên stack
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DetailScreen(itemId: 42),
              ),
            );
          },
          child: const Text('Xem chi tiết'),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final int itemId;
  const DetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết #$itemId')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // pop — quay về trang trước
            Navigator.of(context).pop();
          },
          child: const Text('Quay lại'),
        ),
      ),
    );
  }
}
```

### 1.2. Trả dữ liệu khi pop

```dart
// Trang chọn màu
class ColorPickerScreen extends StatelessWidget {
  const ColorPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn màu')),
      body: Column(
        children: [
          for (var color in [Colors.red, Colors.blue, Colors.green])
            ListTile(
              leading: CircleAvatar(backgroundColor: color),
              title: Text(color.toString()),
              onTap: () {
                Navigator.pop(context, color);   // Trả kết quả về
              },
            ),
        ],
      ),
    );
  }
}

// Trang gọi
void _pickColor(BuildContext context) async {
  // push trả về Future — await để nhận kết quả
  final Color? selectedColor = await Navigator.push<Color>(
    context,
    MaterialPageRoute(builder: (_) => const ColorPickerScreen()),
  );

  if (selectedColor != null) {
    print('Màu đã chọn: $selectedColor');
  }
}
```

### 1.3. Các phương thức Navigator

```dart
// pushReplacement — thay thế trang hiện tại (không quay lại được)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
);

// pushAndRemoveUntil — push trang mới + xóa tất cả trang trước đó
// Dùng cho: Đăng nhập thành công → về Home (xóa Login khỏi stack)
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
  (route) => false,   // false = xóa tất cả
);

// pushAndRemoveUntil — giữ lại root
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const ProfileScreen()),
  ModalRoute.withName('/'),   // Giữ route '/'
);

// popUntil — pop về route cụ thể
Navigator.popUntil(context, ModalRoute.withName('/home'));

// canPop — kiểm tra có thể pop không
if (Navigator.canPop(context)) {
  Navigator.pop(context);
}

// maybePop — pop nếu có thể, không làm gì nếu đã ở root
Navigator.maybePop(context);
```

### 1.4. Page Transitions

```dart
// MaterialPageRoute — slide từ phải (Android) / từ dưới (iOS)
// CupertinoPageRoute — slide từ phải (iOS style)

// Custom transition
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const DetailScreen(itemId: 1);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade transition
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);

// Slide transition
PageRouteBuilder(
  pageBuilder: (_, __, ___) => const DetailScreen(itemId: 1),
  transitionsBuilder: (_, animation, __, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),   // Từ dưới lên
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  },
)
```

---

## 2. Named Routes (Cơ bản)

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(itemId: 0),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// Sử dụng
Navigator.pushNamed(context, '/detail');
Navigator.pushReplacementNamed(context, '/');
Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

// Truyền arguments
Navigator.pushNamed(
  context,
  '/detail',
  arguments: {'id': 42, 'title': 'Flutter'},
);

// Nhận arguments
class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
    final id = args['id'] as int;
    return Scaffold(
      appBar: AppBar(title: Text('Detail #$id')),
    );
  }
}
```

---

## 3. GoRouter — Modern Routing (Khuyên dùng!) 🔥

```yaml
# pubspec.yaml
dependencies:
  go_router: ^14.0.0
```

### 3.1. Cấu hình cơ bản

```dart
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,   // Log navigation trong debug

  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail/:id',   // Path parameter
      name: 'detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final title = state.uri.queryParameters['title'];
        return DetailScreen(itemId: id, title: title);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],

  // Error page
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('404: ${state.uri}')),
  ),

  // Redirect (ví dụ: chưa đăng nhập → /login)
  redirect: (context, state) {
    final isLoggedIn = false;   // Kiểm tra auth
    final isLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/';
    return null;   // null = không redirect
  },
);

// Sử dụng trong MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
```

### 3.2. Navigation với GoRouter

```dart
// Chuyển trang
context.go('/detail/42');                    // Replace (không stack)
context.push('/detail/42');                  // Push (stack)
context.go('/detail/42?title=Flutter');      // Với query params

// Named route
context.goNamed('detail', pathParameters: {'id': '42'});
context.pushNamed('detail',
  pathParameters: {'id': '42'},
  queryParameters: {'title': 'Flutter'},
);

// Pop
context.pop();
context.pop(resultData);   // Pop với kết quả

// Replace
context.pushReplacement('/home');
```

### 3.3. Nested Routes (Sub-routes)

```dart
GoRoute(
  path: '/products',
  builder: (context, state) => const ProductListScreen(),
  routes: [
    GoRoute(
      path: ':id',   // /products/:id
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
      routes: [
        GoRoute(
          path: 'reviews',   // /products/:id/reviews
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductReviewsScreen(productId: id);
          },
        ),
      ],
    ),
  ],
)
```

### 3.4. ShellRoute — Bottom Navigation

```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeTab(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchTab(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileTab(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(GoRouterState.of(context).matchedLocation),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home');
            case 1: context.go('/search');
            case 2: context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }
}
```

---

## 4. Deep Linking

```dart
// GoRouter tự hỗ trợ deep linking!
// URL: myapp://detail/42 → GoRoute path: '/detail/:id'

// Android: android/app/src/main/AndroidManifest.xml
// <intent-filter>
//   <action android:name="android.intent.action.VIEW" />
//   <category android:name="android.intent.category.DEFAULT" />
//   <category android:name="android.intent.category.BROWSABLE" />
//   <data android:scheme="myapp" />
//   <data android:scheme="https" android:host="myapp.com" />
// </intent-filter>

// iOS: ios/Runner/Info.plist
// <key>CFBundleURLTypes</key>
// <array>
//   <dict>
//     <key>CFBundleURLSchemes</key>
//     <array>
//       <string>myapp</string>
//     </array>
//   </dict>
// </array>
```

---

## 5. Route Guards & Authentication Flow

```dart
final router = GoRouter(
  redirect: (context, state) {
    // Đọc auth state
    final authState = AuthService.instance;
    final isLoggedIn = authState.isAuthenticated;
    final isLoginPage = state.matchedLocation == '/login';
    final isSignupPage = state.matchedLocation == '/signup';

    // Chưa đăng nhập → redirect về login (trừ khi đang ở login/signup)
    if (!isLoggedIn && !isLoginPage && !isSignupPage) {
      return '/login?redirect=${state.matchedLocation}';
    }

    // Đã đăng nhập mà vào login → redirect về home
    if (isLoggedIn && (isLoginPage || isSignupPage)) {
      return '/';
    }

    return null;   // Không redirect
  },

  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminScreen(),
      redirect: (context, state) {
        // Route-level redirect
        if (!AuthService.instance.isAdmin) {
          return '/';   // Không phải admin → về home
        }
        return null;
      },
    ),
  ],
);
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Multi-screen App
Tạo app 3 trang: Home → List → Detail. Truyền data giữa các trang.

### Bài 2: GoRouter Tab Navigation
Implement bottom tab navigation với GoRouter `ShellRoute`. Mỗi tab có navigation stack riêng.

### Bài 3: Auth Flow
Implement authentication flow: Splash → Login/Signup → Home. Dùng `redirect` để bảo vệ routes.

---

> **Bài tiếp theo**: [13 - Truyền dữ liệu giữa Widgets](./13_flutter_props_and_callbacks.md)
