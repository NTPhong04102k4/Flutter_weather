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

## 6. GetX Navigation (Tham khảo)

GetX là lựa chọn thay thế: điều hướng **không cần `BuildContext`**, gộp luôn state management + DI.

```yaml
dependencies:
  get: ^4.6.0
```

```dart
// Cấu hình
GetMaterialApp(home: HomeScreen());   // thay MaterialApp

// Điều hướng — KHÔNG cần context
Get.to(() => DetailScreen());              // push
Get.off(() => HomeScreen());               // pushReplacement
Get.offAll(() => HomeScreen());            // xóa hết stack
Get.back();                                // pop

// ─── Truyền dữ liệu ĐI ───
Get.to(() => DetailScreen(), arguments: {'id': 42});   // qua arguments
final args = Get.arguments;                            // màn sau nhận
Get.to(() => DetailScreen(id: 42));                    // hoặc qua constructor (rõ hơn)

// ─── Đẩy dữ liệu NGƯỢC lại ───
final result = await Get.to(() => PickScreen());   // màn trước chờ
Get.back(result: selectedCity);                    // màn sau trả về

// ─── Hoặc shared controller (điểm mạnh riêng của GetX) ───
// Màn sau update controller → màn trước Obx() tự rebuild, không cần pop/callback.
```

| So với go_router | GetX | go_router |
|------------------|------|-----------|
| Cần context | ❌ Không | ✅ Có |
| Deep link / web URL | Yếu | ✅ Mạnh |
| Trách nhiệm | Routing + State + DI (gộp) | Chỉ routing (tách bạch) |
| App lớn | Dễ rối | ✅ Khuyên dùng |

> 💡 **Khuyến nghị**: App vừa/lớn dùng **go_router** + state manager riêng (Riverpod/Bloc). GetX hợp prototype nhanh.

---

## 7. Vòng đời (Lifecycle) của Navigation

Khác biệt cốt lõi cần nhớ:

> **push/pop** → widget bị **tạo mới / hủy** (initState/dispose).
> **chuyển tab** → tùy cách code, widget có thể **giữ nguyên** hoặc **bị hủy rebuild**.

### 7.1. Lifecycle khi push / pop

```
Màn A đang hiển thị
   │  context.push('/B')
   ▼
Màn B: initState() → didChangeDependencies() → build()
Màn A: VẪN SỐNG (nằm dưới stack, KHÔNG bị dispose)
   │  context.pop()  (B về A)
   ▼
Màn B: dispose()          ← B bị hủy hoàn toàn
Màn A: KHÔNG gọi lại initState, chỉ build() lại nếu setState
```

- `push` **không** dispose màn trước → timer/video/controller ở màn A **vẫn chạy ngầm**.
- `pop` **dispose** màn hiện tại → phải cleanup trong `dispose()`.
- `pushReplacement` → dispose màn cũ ngay.

```dart
class _DetailState extends State<DetailScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});  // chạy khi push lên
  }

  @override
  void dispose() {
    _timer.cancel();   // BẮT BUỘC — không cleanup sẽ leak khi pop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
```

### 7.2. RouteAware — biết khi màn bị che / hiện lại

Khi push B lên A, **A không nhận sự kiện gì** mặc định. Muốn biết "màn vừa bị che" / "vừa hiện lại" → dùng `RouteObserver` + `RouteAware`.

```dart
final routeObserver = RouteObserver<PageRoute>();          // 1. khai báo global
MaterialApp(navigatorObservers: [routeObserver]);          // 2. đăng ký

class _AScreenState extends State<AScreen> with RouteAware {   // 3. mixin
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {}   // màn khác push ĐÈ lên → tạm dừng video...
  @override
  void didPopNext() {}    // màn trên pop → màn này hiện lại → refresh data
}
```

> ✅ Dùng `didPopNext()` để **reload dữ liệu** khi user quay lại từ màn con (VD: quay lại list sau khi sửa item).

### 7.3. App lifecycle (nền/foreground) — khác route lifecycle

```dart
class _MyState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:  break;  // quay lại foreground
      case AppLifecycleState.paused:   break;  // chạy nền → lưu state, dừng timer
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:   break;
    }
  }
}
```

---

## 8. Giữ state khi chuyển tab

Với tab/drawer, câu hỏi lớn nhất: **chuyển qua lại có mất state / scroll / dữ liệu đã load không?**

| Chiến lược | State khi rời tab | Bộ nhớ | Dùng cho |
|-----------|-------------------|--------|----------|
| **Rebuild** (switch-case trả widget mới) | ❌ Mất, load lại | Nhẹ nhất | Tab tĩnh, không cần scroll |
| **IndexedStack** | ✅ Giữ toàn bộ | Nặng (mọi tab sống cùng lúc) | 2-5 tab cần giữ scroll |
| **StatefulShellRoute** (go_router) | ✅ Giữ + mỗi tab có **stack riêng** | Vừa | Bottom tab app lớn |

```dart
// ❌ Rebuild — mất state mỗi lần đổi tab
Widget _current() {
  switch (_index) {
    case 0: return const HomeTab();   // widget MỚI → mất scroll
    default: return const SearchTab();
  }
}

// ✅ IndexedStack — giữ state, chỉ ẩn/hiện
IndexedStack(
  index: _index,
  children: const [HomeTab(), SearchTab(), ProfileTab()],  // cả 3 luôn sống
)
```

> ⚠️ `IndexedStack` build **tất cả** tab ngay lần đầu → nếu tab nào gọi API trong `initState`, **cả 3 API bắn cùng lúc** khi mở app. Cân nhắc lazy-load nếu tab nặng.

---

## 9. Pattern 1 — Bottom Tab Navigation

**Layout**: thanh tab dưới đáy, 3-5 mục cấp cao nhất.
**Nên dùng**: `StatefulShellRoute.indexedStack` → mỗi tab **giữ state** + có **stack push/pop riêng**.

```dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [   // Tab Home = 1 Navigator độc lập
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeTab(),
            routes: [
              // Push detail trong tab Home — bottom bar VẪN hiển thị
              GoRoute(path: 'detail/:id',
                builder: (_, s) => DetailScreen(id: s.pathParameters['id']!)),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/search', builder: (_, __) => const SearchTab()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileTab()),
        ]),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Nhấn lại tab đang chọn → về gốc tab đó (giống Instagram)
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

**Vòng đời**: đổi tab → tab cũ **không dispose** (giữ scroll/state); `goBranch(..., initialLocation: true)` → reset stack tab đó; push detail chỉ ảnh hưởng Navigator của tab đó.

> 📌 App đơn giản không cần stack riêng mỗi tab → chỉ cần `IndexedStack` thủ công như mục 8.

---

## 10. Pattern 2 — Drawer (Menu bên hông)

**Layout**: menu trượt từ cạnh, cho mục ít dùng (Settings, About, Logout) hoặc app nhiều section.
**Nên dùng**: Drawer thường **thay toàn bộ màn** → dùng `context.go()` (replace), không push.

```dart
Scaffold(
  appBar: AppBar(title: const Text('Dashboard')),
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);    // ĐÓNG drawer TRƯỚC
            context.go('/settings');   // rồi mới điều hướng (replace)
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () {
            Navigator.pop(context);
            // logout → redirect tự đẩy về /login
          },
        ),
      ],
    ),
  ),
  body: const DashboardBody(),
);
```

**Lưu ý vòng đời**:
- **Luôn `Navigator.pop(context)` đóng drawer TRƯỚC** khi `context.go`, nếu không drawer treo lại trên màn mới.
- `context.go()` → màn cũ **dispose**, không tích lũy stack (đúng ý cho menu chính).
- Muốn drawer + giữ state các section → bọc route trong `ShellRoute` (drawer ở shell, `child` đổi theo route).

> 💡 Drawer + Bottom tab **kết hợp được**: bottom tab cho 3-5 mục hằng ngày, drawer cho mục phụ. Đừng nhét quá nhiều vào bottom bar.

---

## 11. Pattern 3 — Header Tab Bar (TabBar trong AppBar)

**Layout**: tab dưới AppBar, vuốt ngang đổi (VD tab "Bài viết / Ảnh / Video" trong 1 trang profile).
**Điểm khác biệt quan trọng**: đây **KHÔNG phải navigation giữa route** — mà là chuyển view **trong cùng một màn**. Không dùng go_router; dùng `TabController` + `TabBarView`.

```dart
class _ProfileState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {   // cung cấp vsync cho animation
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();   // BẮT BUỘC
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Bài viết'),
            Tab(icon: Icon(Icons.photo), text: 'Ảnh'),
            Tab(icon: Icon(Icons.video_library), text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [PostsTab(), PhotosTab(), VideosTab()],
      ),
    );
  }
}
```

**Rút gọn** — không cần custom controller thì dùng `DefaultTabController`:

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: const TabBar(tabs: [Tab(text: 'A'), Tab(text: 'B'), Tab(text: 'C')]),
    ),
    body: const TabBarView(children: [TabA(), TabB(), TabC()]),
  ),
)
```

**Giữ state chắc chắn** khi tab bị hủy khỏi view → thêm `AutomaticKeepAliveClientMixin`:

```dart
class _PostsTabState extends State<PostsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;   // giữ state khi vuốt xa

  @override
  Widget build(BuildContext context) {
    super.build(context);   // BẮT BUỘC gọi khi dùng mixin này
    return ListView(/* ... */);
  }
}
```

---

## 12. Bảng chọn nhanh — dùng cách nào?

| Layout | Widget chính | Cơ chế | Giữ state | Deep link? |
|--------|-------------|--------|-----------|------------|
| **Bottom Tab** | `NavigationBar` + `StatefulShellRoute.indexedStack` | go_router branch (mỗi tab 1 stack) | ✅ | ✅ |
| **Drawer** | `Drawer` + `context.go()` | go_router replace (+ `ShellRoute` nếu cần giữ state) | Tùy | ✅ |
| **Header Tab Bar** | `TabBar` + `TabBarView` + `TabController` | **Không phải route** — view nội bộ | ✅ (+ KeepAlive) | ❌ |

### Quy tắc ngón tay cái

1. **Điều hướng cấp cao giữa các "khu vực"** → Bottom Tab (≤5 mục) hoặc Drawer (>5 / mục phụ).
2. **Chuyển view trong CÙNG một trang** → Header TabBar, **không** đụng router.
3. **Đi vào chi tiết / flow tuyến tính** (list → detail → edit) → `push`/`context.push`, đặt trong branch của tab.
4. **Cần giữ scroll & state khi rời đi** → IndexedStack / StatefulShellRoute / AutomaticKeepAlive; **không** switch-case rebuild.
5. **Cleanup**: mọi `Timer`, `TabController`, `AnimationController`, `StreamSubscription` phải hủy trong `dispose()`.

---

## 📝 Bài Tập Thực Hành

### Bài 1: Multi-screen App
Tạo app 3 trang: Home → List → Detail. Truyền data giữa các trang.

### Bài 2: GoRouter Tab Navigation
Implement bottom tab navigation với GoRouter `StatefulShellRoute.indexedStack`. Mỗi tab có navigation stack riêng — kiểm chứng: scroll ở Home → push Detail → pop → scroll **không** bị reset.

### Bài 3: Auth Flow
Implement authentication flow: Splash → Login/Signup → Home. Dùng `redirect` để bảo vệ routes.

### Bài 4: RouteAware Reload
List → push Edit → pop về. Dùng `RouteAware.didPopNext()` để tự refresh list sau khi edit.

### Bài 5: Kết hợp 3 pattern
1 app có: Drawer (Settings, Logout) + Bottom Tab (Home, Search, Profile) + trong Profile có Header TabBar (Bài viết/Ảnh/Video). Xác định đúng cơ chế cho từng lớp.

---

> **Bài tiếp theo**: [13 - Truyền dữ liệu giữa Widgets](./13_flutter_props_and_callbacks.md)
