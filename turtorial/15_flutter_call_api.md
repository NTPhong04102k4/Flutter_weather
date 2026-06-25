# 📘 Bài 15: Gọi API & Xử Lý Dữ Liệu Trong Flutter

> **Mục tiêu**: Gọi REST API, parse JSON, xử lý lỗi, interceptors, và pagination.

---

## 1. Package `http` — Cơ Bản

```yaml
# pubspec.yaml
dependencies:
  http: ^1.2.0
```

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BasicApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET request
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  // POST request
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  // PUT request
  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }

  // DELETE request
  Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }
}
```

---

## 2. JSON ↔ Model Class

### 2.1. Thủ công: fromJson / toJson

```dart
class User {
  final int id;
  final String name;
  final String email;
  final Address? address;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.address,
  });

  // Factory constructor từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }

  // Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (address != null) 'address': address!.toJson(),
    };
  }

  // copyWith — tạo bản sao với thay đổi
  User copyWith({String? name, String? email}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address,
    );
  }
}

class Address {
  final String street;
  final String city;

  const Address({required this.street, required this.city});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'street': street, 'city': city};
}

// Sử dụng
void main() {
  // JSON → Model
  var json = {'id': 1, 'name': 'Phong', 'email': 'phong@test.com'};
  var user = User.fromJson(json);
  print(user.name);   // Phong

  // Model → JSON
  var backToJson = user.toJson();
  print(jsonEncode(backToJson));

  // Parse List<User> từ JSON Array
  var jsonList = [json, json];
  var users = jsonList.map((j) => User.fromJson(j)).toList();
}
```

### 2.2. Code Generation: json_serializable

```yaml
# pubspec.yaml
dependencies:
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
```

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';   // File generated

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;

  @JsonKey(name: 'created_at')   // Map tên khác
  final DateTime? createdAt;

  @JsonKey(defaultValue: 'user')
  final String role;

  @JsonKey(includeToJson: false)   // Không include khi toJson
  final String? password;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.role = 'user',
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

// Chạy: dart run build_runner build
// Hoặc: dart run build_runner watch (tự generate khi file thay đổi)
```

---

## 3. Package Dio — HTTP Client Nâng Cao 🔥

```yaml
dependencies:
  dio: ^5.4.0
```

### 3.1. Cấu hình cơ bản

```dart
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }

  // POST
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // PUT
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  // DELETE
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  // Upload file
  Future<Response> uploadFile(String path, String filePath) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath),
    });
    return _dio.post(path, data: formData);
  }
}
```

### 3.2. Interceptors

```dart
// Auth Interceptor — tự thêm token vào mỗi request
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token hết hạn → refresh
      try {
        final newToken = await AuthStorage.refreshToken();
        // Retry request với token mới
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(options);
        handler.resolve(response);
        return;
      } catch (e) {
        // Refresh thất bại → logout
        AuthStorage.logout();
      }
    }
    handler.next(err);
  }
}

// Logging Interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('✗ ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

// Error Interceptor — chuyển DioException → AppException
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          message: 'Kết nối quá thời gian',
        ));
        break;
      case DioExceptionType.connectionError:
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          message: 'Không có kết nối mạng',
        ));
        break;
      default:
        handler.next(err);
    }
  }
}
```

---

## 4. Repository Pattern

```dart
// Tách logic API ra khỏi UI

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  Future<List<User>> getUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get(
        '/users',
        queryParams: {'page': page, 'limit': limit},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Lỗi không xác định',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<User> getUserById(int id) async {
    final response = await _api.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> createUser(User user) async {
    final response = await _api.post('/users', data: user.toJson());
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    await _api.delete('/users/$id');
  }
}

// Sử dụng trong UI
class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _repo = UserRepository(ApiClient());
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _users = await _repo.getUsers();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lỗi: $_error'),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (_, i) => ListTile(title: Text(_users[i].name)),
      ),
    );
  }
}
```

---

## 5. Pagination — Phân Trang

```dart
class PaginatedUsersPage extends StatefulWidget {
  @override
  State<PaginatedUsersPage> createState() => _PaginatedUsersPageState();
}

class _PaginatedUsersPageState extends State<PaginatedUsersPage> {
  final _repo = UserRepository(ApiClient());
  final _scrollController = ScrollController();
  final List<User> _users = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more khi scroll gần cuối
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final newUsers = await _repo.getUsers(page: _currentPage);
      setState(() {
        _users.addAll(newUsers);
        _currentPage++;
        _hasMore = newUsers.length >= 20;   // Hết data nếu < 20 items
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _users.length + (_hasMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == _users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(title: Text(_users[index].name));
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 6. FutureBuilder & Error Handling UI

```dart
class UserDetailPage extends StatelessWidget {
  final int userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết')),
      body: FutureBuilder<User>(
        future: UserRepository(ApiClient()).getUserById(userId),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            );
          }

          // Success
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
                Text(user.email),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Fetch & Display
Gọi `https://jsonplaceholder.typicode.com/users` và hiển thị danh sách users.

### Bài 2: CRUD App
Tạo app quản lý posts: hiển thị list, tạo mới, sửa, xóa (dùng jsonplaceholder API).

### Bài 3: Infinite Scroll
Implement infinite scroll pagination cho danh sách posts.

---

> **Bài tiếp theo**: [16 - Tích hợp WebView](./16_flutter_webview.md)
