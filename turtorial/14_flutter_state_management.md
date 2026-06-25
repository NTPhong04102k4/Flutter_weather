# 📘 Bài 14: Quản Lý State Toàn Cục Trong Flutter

> **Mục tiêu**: So sánh và sử dụng Provider, Riverpod, Bloc/Cubit cho state management.

---

## 1. Tại Sao Cần Global State?

```
Vấn đề: "Prop Drilling" — truyền data qua 5-10 cấp widget
Widget A (có data)
└── Widget B (chỉ truyền tiếp)
    └── Widget C (chỉ truyền tiếp)
        └── Widget D (chỉ truyền tiếp)
            └── Widget E (cần data)  ← Quá nhiều cấp trung gian!

Giải pháp: Global State — Widget E truy cập trực tiếp
```

---

## 2. Provider — Cách Đơn Giản Nhất 🔥

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.0
```

### 2.1. ChangeNotifier — State class

```dart
import 'package:flutter/foundation.dart';

class CartModel extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);

  void addItem(Product product) {
    _items.add(product);
    notifyListeners();   // 🔔 Thông báo UI rebuild
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  const Product({required this.id, required this.name, required this.price});
}
```

### 2.2. Provide — Cung cấp state

```dart
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Provide state ở gốc app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => AuthModel()),
        Provider(create: (_) => ApiService()),   // Không cần notify
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2.3. Consume — Sử dụng state

```dart
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          // Cách 1: Consumer — rebuild chỉ phần bên trong
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Badge(
                label: Text('${cart.itemCount}'),
                child: child!,
              );
            },
            child: const Icon(Icons.shopping_cart),   // Không rebuild
          ),
        ],
      ),

      body: Consumer<CartModel>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }
          return ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.price}₫'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => cart.removeItem(index),
                ),
              );
            },
          );
        },
      ),

      // Cách 2: context.read — không listen (dùng trong callback)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CartModel>().addItem(
            Product(id: '1', name: 'Flutter Book', price: 299000),
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomBar: Builder(
        builder: (context) {
          // Cách 3: context.watch — listen và rebuild
          final totalPrice = context.watch<CartModel>().totalPrice;
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text('Tổng: ${totalPrice.toStringAsFixed(0)}₫'),
          );
        },
      ),
    );
  }
}
```

### 2.4. Selector — Tối ưu rebuild

```dart
// Chỉ rebuild khi GIÁC TRỊ CỤ THỂ thay đổi
Selector<CartModel, int>(
  selector: (_, cart) => cart.itemCount,   // Chỉ chọn itemCount
  builder: (context, count, child) {
    // Chỉ rebuild khi itemCount thay đổi
    // Không rebuild khi totalPrice thay đổi mà itemCount giữ nguyên
    return Text('$count items');
  },
)
```

---

## 3. Riverpod — Provider Thế Hệ Mới 🔥

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
```

### 3.1. Các loại Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider — giá trị bất biến
final apiUrlProvider = Provider<String>((ref) {
  return 'https://api.example.com';
});

// 2. StateProvider — state đơn giản
final counterProvider = StateProvider<int>((ref) => 0);

// 3. FutureProvider — async data
final userProvider = FutureProvider<User>((ref) async {
  final apiUrl = ref.watch(apiUrlProvider);
  final response = await http.get(Uri.parse('$apiUrl/user'));
  return User.fromJson(jsonDecode(response.body));
});

// 4. StreamProvider — stream data
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Message.fromJson(d.data())).toList());
});

// 5. StateNotifierProvider — state phức tạp
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(Todo todo) {
    state = [...state, todo];   // Immutable update
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});
```

### 3.2. Sử dụng Riverpod

```dart
// Wrap app với ProviderScope
void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// ConsumerWidget thay cho StatelessWidget
class TodoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch — listen và rebuild
    final todos = ref.watch(todoProvider);
    final counter = ref.watch(counterProvider);

    // Async data với FutureProvider
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      body: Column(
        children: [
          // Handle async states
          userAsync.when(
            data: (user) => Text('Xin chào, ${user.name}'),
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Lỗi: $err'),
          ),

          // Todo list
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      // read — không listen (dùng trong callback)
                      ref.read(todoProvider.notifier).toggleTodo(todo.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ConsumerStatefulWidget thay cho StatefulWidget
class EditPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    return Scaffold(body: Text('${todos.length} todos'));
  }
}
```

---

## 4. Bloc / Cubit — Pattern Doanh Nghiệp 🔥

```yaml
dependencies:
  flutter_bloc: ^8.1.0
```

### 4.1. Cubit — Đơn giản hơn Bloc

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class CounterState {
  final int count;
  final bool isLoading;

  const CounterState({this.count = 0, this.isLoading = false});

  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cubit — emit state trực tiếp
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState());

  void increment() => emit(state.copyWith(count: state.count + 1));
  void decrement() => emit(state.copyWith(count: state.count - 1));
  void reset() => emit(const CounterState());

  Future<void> loadFromApi() async {
    emit(state.copyWith(isLoading: true));
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(count: 42, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
```

### 4.2. Bloc — Event-driven (Scale lớn)

```dart
// Events
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}
class CheckAuthStatus extends AuthEvent {}

// States
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = await _authRepo.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
```

### 4.3. Sử dụng Bloc trong UI

```dart
// Provide
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit()),
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
      ],
      child: const MyApp(),
    ),
  );
}

// Consume
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        // listener — side effects (snackbar, navigation)
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        // builder — UI
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  LoginRequested('email@test.com', 'password123'),
                );
              },
              child: const Text('Đăng nhập'),
            ),
          );
        },
      ),
    );
  }
}

// BlocBuilder — chỉ rebuild UI
BlocBuilder<CounterCubit, CounterState>(
  buildWhen: (prev, curr) => prev.count != curr.count,   // Tối ưu
  builder: (context, state) {
    return Text('Count: ${state.count}');
  },
)

// BlocListener — chỉ side effects
BlocListener<AuthBloc, AuthState>(
  listenWhen: (prev, curr) => curr is AuthError,
  listener: (context, state) {
    if (state is AuthError) {
      showDialog(...);
    }
  },
  child: const SomeWidget(),
)
```

---

## 5. So Sánh

| | Provider | Riverpod | Bloc |
|:--|:--------|:---------|:-----|
| Độ phức tạp | ⭐ Thấp | ⭐⭐ TB | ⭐⭐⭐ Cao |
| Learning curve | Dễ | Trung bình | Khó |
| Boilerplate | Ít | Ít | Nhiều |
| Testability | Trung bình | Cao | Rất cao |
| Scalability | TB | Cao | Rất cao |
| Debug tools | DevTools | DevTools | Bloc Observer |
| Dùng khi | App nhỏ-vừa | App vừa-lớn | App lớn, team |

### Quy tắc chọn

```
App cá nhân, prototype → Provider
App trung bình, cần test → Riverpod
App enterprise, team lớn → Bloc
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Todo App với Provider
Tạo Todo app hoàn chỉnh: thêm/xóa/toggle todo, filter (All/Active/Completed), count.

### Bài 2: Shopping Cart với Riverpod
Implement giỏ hàng: products list, add/remove, total price, checkout.

### Bài 3: Auth Flow với Bloc
Implement: Login → Loading → Home/Error. Dùng BlocListener cho navigation.

---

> **Bài tiếp theo**: [15 - Gọi API & Xử lý dữ liệu](./15_flutter_call_api.md)
