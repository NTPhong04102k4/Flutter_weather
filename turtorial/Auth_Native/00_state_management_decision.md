# 🔐 Quyết Định State Management Cho Flow Login/Logout Native

> **Bối cảnh**: Port flow **login/logout native** từ project `app-hrm` (ForgeRock/Ping Identity SDK bọc sau `MethodChannel`) sang project `weather`. Tài liệu này phân tích **Riverpod vs BLoC vs GetX** để chọn cách quản lý state cho phần Dart của flow auth.

---

## 1. Vì Sao Phải Chọn Lại State Management?

Hai project đang lệch nhau về stack:

| | `app-hrm` (nguồn) | `weather` (đích) |
|:--|:--|:--|
| State management | **GetX** (`get: ^4.6.6`) | **Riverpod** (`flutter_riverpod: ^2.6.1`) |
| DI / Navigation | GetX (`Get.put`, `Get.toNamed`) | `onGenerateRoute` thuần + Riverpod providers |
| Kiến trúc | GetX module (binding/controller/view) | Feature-based + core layer |
| Auth engine | ForgeRock SDK native (thật) | *(chưa có — sẽ port sang)* |

`weather` có khai báo `get: ^4.6.6` trong `pubspec.yaml` nhưng **không import ở đâu trong `lib/`** — tức là đã chuẩn hoá về Riverpod, `get` chỉ là dependency thừa.

> **Điểm mấu chốt**: Phần *engine auth thật* nằm ở **native (Java/Swift)** và giao tiếp qua `MethodChannel("...SampleBridge")`. State management ở Dart **chỉ điều phối journey** (gọi native → nhận node callbacks → render field → gửi `next`). Vì vậy việc chọn Riverpod/BLoC/GetX **không ảnh hưởng tới phần native**, chỉ ảnh hưởng tới cách tổ chức code Dart điều phối.

---

## 2. Flow Auth Cần Điều Phối (tóm tắt)

```
┌─────────────┐   MethodChannel    ┌──────────────────────┐
│  Dart layer │ ─────────────────► │  Native ForgeRock SDK │
│ (SM chọn ở  │  frAuthStart       │  (Android Java /      │
│  đây)       │  login / next      │   iOS Swift)          │
│             │  logout            │                       │
│             │ ◄───────────────── │  node JSON /          │
└─────────────┘  FRNode / Success  │  LoginSuccess+token   │
                                    └──────────────────────┘
```

State Dart cần giữ:
- `AuthStatus` (unknown → authenticating → authenticated / unauthenticated / error)
- `currentNode` (node hiện tại của journey) + danh sách field động render ra UI
- `user` (sau khi login thành công, lấy từ `getUserInfo`)
- Side-effects: điều hướng route, hiện dialog "session expired", xoá FCM token khi logout

Đây là **state bất đồng bộ, nhiều bước, event-driven** → là bài toán kinh điển để so 3 lựa chọn.

---

## 3. Phân Tích Từng Lựa Chọn

### 3.1. GetX — Trung Thành Với Nguồn 🟢

Copy gần như y hệt `AuthController` của `app-hrm`.

```dart
class AuthController extends GetxController {
  final _channel = AuthMethodChannel();
  final Rx<AuthStatus> status = AuthStatus.unknown.obs;
  FRNode? currentNode;

  @override
  void onInit() {
    super.onInit();
    _startSDK();
  }

  Future<void> login() async {
    final result = jsonDecode(await _channel.login());
    if (result['type'] == 'LoginSuccess') {
      status.value = AuthStatus.authenticated;
      Get.offAllNamed(Routes.root);
    } else {
      currentNode = FRNode.fromJson(result);
    }
  }

  Future<void> logout() async {
    await _channel.logout();
    Get.offAllNamed(Routes.login);
  }
}
```

| ✅ Ưu điểm | ❌ Nhược điểm |
|:--|:--|
| Copy nguyên si từ `app-hrm` → **nhanh nhất, ít lệch logic nhất** | Đi ngược chuẩn hiện tại của `weather` (Riverpod) → **2 pattern song song** trong 1 app |
| DI + navigation + state gộp một chỗ, ít boilerplate | `Get.toNamed`/`Get.offAllNamed` cần `GetMaterialApp`, trong khi `weather` dùng `MaterialApp` + `onGenerateRoute` → phải đổi root hoặc tách navigation |
| Đồng bộ về sau giữa 2 app dễ (cùng code) | Testability kém hơn, phụ thuộc service locator toàn cục (`Get.find`) |
| `.obs` reactive rất gọn | Cộng đồng đang dịch chuyển khỏi GetX; ít "Flutter-idiomatic" |

### 3.2. Riverpod — Đồng Bộ Với `weather` 🔵

Viết lại theo `Notifier`/`AsyncNotifier`, khớp `ProviderScope` sẵn có.

```dart
// State bất biến
sealed class AuthState {}
class AuthUnknown extends AuthState {}
class AuthAuthenticating extends AuthState {}
class AuthNeedsInput extends AuthState { final FRNode node; AuthNeedsInput(this.node); }
class AuthAuthenticated extends AuthState { final UserModel user; AuthAuthenticated(this.user); }
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { final String message; AuthError(this.message); }

class AuthNotifier extends Notifier<AuthState> {
  late final AuthMethodChannel _channel;

  @override
  AuthState build() {
    _channel = ref.read(authChannelProvider);
    _start();
    return AuthUnknown();
  }

  Future<void> login() async {
    state = AuthAuthenticating();
    final result = jsonDecode(await _channel.login());
    if (result['type'] == 'LoginSuccess') {
      state = AuthAuthenticated(await _getUserInfo());
    } else {
      state = AuthNeedsInput(FRNode.fromJson(result));
    }
  }

  Future<void> logout() async {
    await _channel.logout();
    state = AuthUnauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
```

Navigation tách riêng qua listener ở widget (`ref.listen(authProvider, ...)`) → giữ đúng `onGenerateRoute` sẵn có.

| ✅ Ưu điểm | ❌ Nhược điểm |
|:--|:--|
| **Đồng bộ 100% với `weather`** (ProviderScope, core_providers đã có) | Phải **viết lại** logic từ GetX → tốn công hơn, rủi ro lệch logic |
| Không cần global service locator; DI qua `ref` → dễ mock, **test tốt** | Learning curve cao hơn GetX một chút |
| Navigation/side-effect tách khỏi state (`ref.listen`) → sạch, đúng chuẩn Flutter | Cần cẩn thận vòng đời `Notifier` khi chạy init trong `build()` |
| Không cần đổi `MaterialApp` → `GetMaterialApp` | |
| Tương lai project chỉ còn **1 pattern** duy nhất | |

### 3.3. BLoC / Cubit — Chuẩn Enterprise 🟣

Event-driven, rõ ràng nhất cho flow nhiều bước.

```dart
sealed class AuthEvent {}
class AuthStarted extends AuthEvent {}
class LoginRequested extends AuthEvent {}
class NodeSubmitted extends AuthEvent { final Map<String,String> inputs; NodeSubmitted(this.inputs); }
class LogoutRequested extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthMethodChannel _channel;
  AuthBloc(this._channel) : super(AuthUnknown()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    // ...
  }
}
```

| ✅ Ưu điểm | ❌ Nhược điểm |
|:--|:--|
| Model event/state tường minh nhất cho journey nhiều bước | **Boilerplate nhiều nhất** (event + state + bloc cho mỗi flow) |
| Testability & traceability cao nhất (BlocObserver) | Đưa **pattern thứ 3** vào — `weather` chưa dùng BLoC ở đâu |
| Rất hợp khi team lớn, flow phức tạp | Overkill cho 1 feature auth; tốn công nhất trong 3 lựa chọn |

---

## 4. Bảng So Sánh Nhanh

| Tiêu chí | GetX | Riverpod | BLoC |
|:--|:--:|:--:|:--:|
| Công sức port | ⭐ Thấp (copy) | ⭐⭐ TB (viết lại) | ⭐⭐⭐ Cao |
| Khớp `weather` hiện tại | ❌ Không | ✅ **Có** | ❌ Không |
| Boilerplate | Ít | TB | Nhiều |
| Testability | TB | Cao | Rất cao |
| Ảnh hưởng phần native | Không | Không | Không |
| Cần đổi root App | Có (`GetMaterialApp`) | Không | Không |
| Số pattern trong app sau cùng | 2 | **1** | 2 |
| Đồng bộ code với `app-hrm` | ✅ Dễ | Trung bình | Khó |

---

## 5. ✅ Khuyến Nghị

> **Chọn Riverpod** cho phần Dart của flow auth.

**Lý do:**
1. `weather` đã chuẩn hoá về Riverpod (`ProviderScope`, `core_providers`) — thêm GetX/BLoC sẽ tạo **2–3 pattern song song**, khó bảo trì.
2. Phần **native (ForgeRock) được copy nguyên si** dù chọn SM nào → rủi ro lớn nhất (native) không đổi; chỉ phần điều phối Dart cần viết lại, và Riverpod diễn đạt state bất đồng bộ nhiều bước rất tốt.
3. Navigation của `weather` (`onGenerateRoute`) giữ nguyên — không cần đổi sang `GetMaterialApp`.
4. `AuthMethodChannel` + models `FRNode`/`FRCallback` **giữ gần như y hệt** `app-hrm` (chúng độc lập với SM); chỉ `AuthController` (GetX) → `AuthNotifier` (Riverpod) là phải chuyển.

**Khi nào cân nhắc khác:**
- Nếu cần **ship cực nhanh** và chấp nhận nợ kỹ thuật (2 pattern) → GetX (copy nguyên).
- Nếu auth sắp phình rất phức tạp và có team lớn quen BLoC → BLoC.

---

## 6. Ranh Giới Port (giữ nguyên vs viết lại)

| Thành phần | Nguồn (`app-hrm`) | Ở `weather` |
|:--|:--|:--|
| Native bridge Android | `FRAuthSampleBridge.java` + `MainActivity` | **Copy nguyên** (đổi package) |
| Native bridge iOS | `FRAuthSampleBridge.swift` + structs/helpers | **Copy nguyên** (chỉnh wiring cho SceneDelegate) |
| `AuthMethodChannel` | `lib/core/auth/method_channel.dart` | **Copy gần nguyên** |
| Models `FRNode`/`FRCallback` | `lib/app/data/model/*` | **Copy nguyên** |
| Orchestrator | `AuthController` (GetX) | **Viết lại** → `AuthNotifier` (Riverpod) |
| Login UI | `login/page.dart` (GetView) | **Viết lại** → `ConsumerWidget` |
| Config ForgeRock | hardcoded `id.ttmedic.vn`... | **Placeholder** (điền sau) |

---

## 7. Liên Quan

- [Bài 14 — Quản lý State](../14_flutter_state_management.md) (Provider/Riverpod/BLoC)
- [Bài 17 — Platform Channels](../17_flutter_platform_channels.md) (MethodChannel)
- [Bài 21 — Kiến trúc Flutter](../21_flutter_architecture.md)

---

> **Tiếp theo**: sau khi chốt SM (khuyến nghị **Riverpod**) → tiến hành port native bridge + Dart auth. Xem `01_native_login_logout_implementation.md` (sẽ tạo khi implement).
