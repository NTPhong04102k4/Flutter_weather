# 🧰 Bộ Công Cụ Auth Trong `weather`: Lớp Xử Lí, `tenantId` & Header

> **Bối cảnh**: tiếp nối [00 — Quyết định state management](./00_state_management_decision.md) (đã chốt **Riverpod**). Tài liệu này mô tả **bộ công cụ auth đã gom vào project `weather`**, trả lời câu hỏi *"vì sao phải tự viết lớp xử lí thay vì dùng đồ có sẵn của Flutter hoặc một thư viện ngoài?"*, và mô tả đường đi của `tenantId` + các header qua lớp auth khi engine IAM là **ForgeRock (Ping Identity)** — một thư viện **native**, không phải package Dart.

---

## 1. Bộ Công Cụ Đã Gom Vào `weather`

```
lib/
├── config/
│   └── app_config.dart              ← + tenantId, + useFakeAuthBridge (theo môi trường)
├── core/
│   ├── auth/
│   │   ├── auth_channel.dart        ← HỢP ĐỒNG với native + bản MethodChannel + dịch lỗi
│   │   ├── fake_auth_channel.dart   ← bản giả lập: chạy/test KHÔNG cần SDK native
│   │   ├── auth_api_client.dart     ← gọi API nội bộ qua native, BƠM header tenant
│   │   ├── tenant_context.dart      ← tenantId + toàn bộ luật ghép header
│   │   ├── auth_exception.dart      ← AuthErrorKind: bảng phân loại lỗi duy nhất
│   │   ├── session_event_bus.dart   ← phát/nghe "phiên hết hạn" (cắt phụ thuộc vòng)
│   │   ├── auth_providers.dart      ← DI bằng Riverpod cho 4 lớp trên
│   │   └── models/
│   │       ├── fr_callback.dart     ← 1 ô nhập của journey (immutable)
│   │       ├── fr_node.dart         ← 1 bước của journey (immutable)
│   │       └── auth_journey.dart    ← sealed: LoginSuccess | NeedsInput | lỗi parse
│   ├── core.dart                    ← + export toàn bộ auth
│   └── router/app_router.dart       ← + route '/login'
├── features/auth/
│   ├── application/auth_state.dart      ← sealed AuthState (6 nhánh)
│   ├── application/auth_notifier.dart   ← orchestrator Riverpod (login/submit/logout)
│   ├── domain/auth_user.dart            ← model user từ claim OIDC
│   ├── presentation/login_page.dart     ← form render ĐỘNG theo node journey
│   └── auth_module.dart                 ← barrel + route name
└── test/core/auth/auth_toolkit_test.dart ← 10 test: header, 401, parse, immutability
```

Chia làm 3 tầng, phụ thuộc **một chiều**:

```
UI (login_page)  →  Orchestrator (auth_notifier)  →  Hạ tầng (auth_channel / auth_api_client)
     Widget              Riverpod Notifier                MethodChannel ↔ SDK native
```

> Tầng dưới **không biết** tầng trên. `auth_api_client` phát hiện 401 nhưng không tự hiện dialog — nó `emit(SessionEvent.expired)`, `auth_notifier` nghe và đổi state. Đây là lý do có `session_event_bus.dart`.

---

## 2. Câu Hỏi Chính: Vì Sao Cần "Lớp Xử Lí"?

Có 4 phương án cho tầng auth. Phải hiểu **mỗi thứ cho ta cái gì** trước khi so sánh.

### 2.1. Flutter có sẵn những gì?

| Thứ Flutter cho sẵn | Nó làm | Nó **không** làm |
|:--|:--|:--|
| `MethodChannel` (`dart:ui`/`flutter/services`) | Truyền được `String`/`Map`/`List` qua native, trả `Future` | Không biết `login` là gì; lỗi về dạng `PlatformException(code: String)` — **stringly-typed** |
| `package:http` / `HttpClient` | Gửi HTTP từ Dart | **Không có** access token (token nằm trong Keychain/Keystore của SDK native), không refresh token, không dùng chung cookie jar với SDK |
| `flutter_secure_storage` | Lưu chuỗi có mã hoá | Không tự refresh/rotate token, không biết vòng đời OAuth |

Điểm chết người: **`package:http` không thể tự gọi API nội bộ**, vì Dart không giữ token. Token do SDK ForgeRock ở native quản lý và tự refresh. Nếu muốn gọi từ Dart, phải kéo token sang Dart — tức là bê secret ra khỏi vùng bảo mật của SDK. Vì vậy request đi **qua native** (`callEndpoint`), và cần một lớp Dart mô tả request đó.

### 2.2. Thư viện ngoài có thay được không?

| Thư viện | Bản chất | Vì sao **không** thay được ForgeRock ở đây |
|:--|:--|:--|
| `flutter_appauth` | Bọc AppAuth-Android/iOS, chạy OAuth2/OIDC **Authorization Code + PKCE** qua browser | Chỉ làm được luồng "mở browser → đăng nhập → nhận code". **Không** chạy được *journey* của ForgeRock AM (node/callback, MFA, đổi mật khẩu lần đầu, device binding) và **không** cho UI native trong app |
| `openid_client` | OIDC thuần Dart | Cũng chỉ OIDC chuẩn; không có journey; token lại nằm ở Dart |
| `dio` + `Interceptor` | HTTP client Dart mạnh, có interceptor gắn header | Interceptor rất hợp để gắn `TenantId`, **nhưng** vẫn cần token — mà token ở native. Thêm `dio` chỉ để gắn header là thêm dependency mà vẫn thiếu mảnh quan trọng nhất |
| **ForgeRock SDK** (`forgerock-auth` Android / `FRAuth` iOS) | SDK **native**, quản lý journey + token + secure storage + cookie | ✅ Đúng thứ cần — **nhưng không có plugin Flutter chính thức**. Đó là lý do bắt buộc phải có `MethodChannel` và một lớp Dart bọc nó |

> **Điểm khác cốt lõi**: `flutter_appauth`/`openid_client` biết **OIDC**; ForgeRock SDK biết **journey của AM** (một tầng cao hơn OIDC, do quản trị viên cấu hình động trên server). Journey là thứ quyết định UI có 1 ô, 2 ô hay 3 ô nhập — không thư viện OIDC nào mô tả được.

### 2.3. Bảng so sánh 4 phương án

| | A. UI gọi `MethodChannel` trực tiếp | B. `flutter_appauth`/`openid_client` | C. `dio` + interceptor từ Dart | D. **Lớp xử lí mỏng + SDK native** *(đã chọn)* |
|:--|:--:|:--:|:--:|:--:|
| Chạy được journey ForgeRock (MFA, đổi MK) | ✅ | ❌ | ❌ | ✅ |
| Token nằm trong vùng bảo mật native | ✅ | ⚠️ (Dart giữ) | ❌ | ✅ |
| Gắn `TenantId` một chỗ duy nhất | ❌ mỗi call site tự gắn | — | ✅ | ✅ |
| Lỗi có kiểu (không so sánh chuỗi) | ❌ | ✅ | ✅ | ✅ |
| Test được không cần thiết bị/SDK | ❌ | ⚠️ | ✅ | ✅ (`FakeAuthChannel`) |
| Đổi engine IAM về sau | ❌ sửa khắp app | ⚠️ | ⚠️ | ✅ đổi 1 implementation |
| Thêm dependency | 0 | +1 | +1 | 0 (chỉ code) |
| Công viết ban đầu | Thấp | TB | TB | **Cao hơn (~700 dòng)** |

### 2.4. Cùng một việc, không lớp vs có lớp

**Không có lớp** — cách `app-hrm` đang làm, mỗi provider tự lo:

```dart
// Mỗi provider tự lặp lại: hợp đồng vị trí, jsonDecode, dò lỗi bằng chuỗi
final response = await AuthMethodChannel().makeRequest(['$apiUrl/Users/profile', 'GET', '']);
final user = UserModel.fromJson(jsonDecode(response));          // ném FormatException nếu 502 trả HTML

// ...và ở method_channel.dart phải dò lỗi kiểu này:
final iosError = GetPlatform.isIOS &&
    (e.code == 'Token Error' || e.details.contains('Unauthorized'));
final androidError = GetPlatform.isAndroid && e.details?.contains('Unauthorized') == true;
if (iosError || androidError) { /* tự hiện dialog ngay trong tầng network */ }
```

Vấn đề: (1) `TenantId` bị **hardcode trong native**, Dart không kiểm soát; (2) lỗi nhận diện bằng `contains('Unauthorized')` — đổi thông điệp phía server là hỏng; (3) tầng network tự hiện dialog → không test được; (4) `['url', 'GET', '']` là hợp đồng vị trí, gõ sai thứ tự chỉ biết lúc chạy.

**Có lớp** — trong `weather`:

```dart
// features/.../user_repository.dart
class UserRepository {
  UserRepository(this._client);
  final AuthApiClient _client;

  Future<AuthUser> profile() async {
    final json = await _client.get('${AppConfig.current.apiBaseUrl}/Users/profile');
    return AuthUser.fromJson(json! as Map<String, dynamic>);
  }
}
```

Header tenant, `Accept`, `Content-Type`, correlation id: **tự có**. Lỗi 401: `AuthApiClient` phát `SessionEvent.expired`, `AuthNotifier` đổi state → UI điều hướng. Repository không biết gì về `MethodChannel`.

> **Kết luận**: lớp xử lí không thay thế thư viện — nó **là chỗ duy nhất biết về thư viện**. Cái ta mua bằng ~700 dòng code là: header nhất quán, lỗi có kiểu, test không cần thiết bị, và khả năng đổi engine IAM.

---

## 3. `tenantId` Là Gì?

Backend là hệ **multi-tenant**: một cụm máy chủ + một database phục vụ nhiều công ty. Cùng endpoint `GET /Users/profile`, dữ liệu trả về phải khác nhau tuỳ công ty đang gọi. Máy chủ phân biệt bằng header `TenantId` — một GUID định danh công ty.

```http
GET /Users/profile HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...   ← AI đang gọi        (native gắn)
TenantId: 11111111-1111-1111-1111-111111111111  ← DỮ LIỆU CỦA AI     (Dart gắn)
Accept-Language: vi-VN                           ← muốn nhận thế nào  (Dart gắn)
```

Ba câu hỏi khác nhau, và **quan trọng nhất là ai gắn**:

| Header | Trả lời | Nguồn | Vì sao ở đó |
|:--|:--|:--|:--|
| `Authorization` | *Ai* đang gọi | **Native** (`AccessTokenInterceptor` / `user.buildAuthHeader()`) | Token là secret, nằm trong Keystore/Keychain, cần refresh — Dart không được giữ |
| `TenantId` | Dữ liệu *của ai* | **Dart** (`TenantContext`) | Là **cấu hình**, không phải secret; đổi theo môi trường |
| `Accept-Language`, `X-App-Version`, `X-Device-Id`, `X-Correlation-Id` | Ngữ cảnh client | **Dart** | Chỉ Dart biết (locale người dùng, version app, id request) |

⚠️ `tenantId` **không cấp quyền** — nó chỉ định danh. Gửi `TenantId` của công ty khác mà token không thuộc công ty đó thì server phải trả 403. Nếu server *không* kiểm tra, đó là lỗ hổng phía server, không phải chỗ client bù đắp.

### Vì sao không hardcode như `app-hrm`?

Trong `app-hrm`, GUID tenant bị viết cứng ở **3 chỗ trong Java** (`callEndpoint`, `uploadFiles`, `callChangePassword`) và **2 chỗ trong Swift**. Hậu quả: đổi tenant ⇒ sửa native ⇒ build lại cả 2 nền tảng; dev/staging/prod dùng chung một tenant.

Trong `weather`, tenant là **dữ liệu theo môi trường**:

```dart
// lib/config/app_config.dart
Environment.dev:     tenantId: '11111111-1111-...',  useFakeAuthBridge: true,
Environment.staging: tenantId: '22222222-2222-...',  useFakeAuthBridge: false,
Environment.prod:    tenantId: '',                   useFakeAuthBridge: false,
//                              ↑ cố tình rỗng: prod BẮT BUỘC --dart-define=TENANT_ID=<guid>
//                                quên ⇒ ném StateError ngay request đầu, thay vì âm thầm gửi sai tenant
```

```bash
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define=TENANT_ID=<guid-thật>
```

---

## 4. Header Đi Qua Lớp Auth Như Thế Nào

```
┌───────────────────────────────────────────────────────────────────────────┐
│ DART                                                                      │
│                                                                           │
│  Repository                                                               │
│    └─ AuthApiClient.get('/Users/profile', query: {...})                   │
│         │                                                                 │
│         ├─ 1. ghép query vào URL                                          │
│         ├─ 2. TenantContext.headersFor()                                  │
│         │      → { TenantId, Accept, Accept-Language,                     │
│         │          X-App-Version, X-Correlation-Id, Content-Type }         │
│         │      (KHÔNG có Authorization — cố ý)                             │
│         └─ 3. AuthChannel.callEndpoint(url, method, body, headers)         │
│                 └─ jsonEncode(headers) → ['url','GET','', '{"TenantId":…}']│
└──────────────────────────────────┬────────────────────────────────────────┘
                                   │ MethodChannel('forgerock.com/SampleBridge')
┌──────────────────────────────────▼────────────────────────────────────────┐
│ NATIVE (Android Java / iOS Swift)                                         │
│                                                                           │
│  4. đọc headersJson → gắn từng header vào Request                          │
│  5. AccessTokenInterceptor / buildAuthHeader() → THÊM Authorization        │
│     (tự refresh token nếu hết hạn — Dart không cần biết)                  │
│  6. SecureCookieJar → thêm cookie SSO                                     │
│  7. gửi request thật (OkHttp / URLSession)                                │
└──────────────────────────────────┬────────────────────────────────────────┘
                                   ▼
                         Backend nội bộ / ForgeRock AM
```

Đường về của lỗi:

```
401 ─→ native promise.error("Unauthorized") ─→ MethodChannelAuthChannel._translate()
    ─→ AuthException(kind: sessionExpired) ─→ AuthApiClient bắt được, emit(SessionEvent.expired)
    ─→ AuthNotifier._onSessionEvent() ─→ state = AuthUnauthenticated(reason: '...hết hạn')
    ─→ UI (ref.listen) điều hướng về /login
```

Cả app có **đúng một** chỗ dịch lỗi native (`_translate`) và **đúng một** chỗ phản ứng với hết phiên (`_onSessionEvent`).

### Code: nơi header được sinh ra

```dart
// lib/core/auth/tenant_context.dart
Map<String, String> baseHeaders() {
  if (!isConfigured) {
    throw StateError('tenantId đang rỗng. Cấu hình AppConfig hoặc --dart-define=TENANT_ID=<guid>.');
  }
  return {
    headerName: tenantId,              // 'TenantId'
    'Accept': 'application/json',
    'Accept-Language': locale,
    'X-App-Version': ?appVersion,      // null-aware element: null thì bỏ hẳn entry
    'X-Device-Id': ?deviceId,
  };
}

Map<String, String> headersFor({Map<String, String>? extra, String? correlationId}) => {
  ...baseHeaders(),
  'X-Correlation-Id': ?correlationId,
  ...?extra,                            // request-specific, áp sau nên ghi đè được
};
```

```dart
// lib/core/auth/auth_api_client.dart — điểm vào duy nhất của mọi request có xác thực
Future<Object?> send({
  required String method,
  required String url,
  Object? body,
  Map<String, dynamic>? query,
  Map<String, String>? headers,
  String? correlationId,
}) async {
  final finalUrl = _withQuery(url, query);
  final encodedBody = body == null ? '' : jsonEncode(body);
  final finalHeaders = _tenant.headersFor(
    extra: {
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
      ...?headers,
    },
    correlationId: correlationId,
  );

  try {
    final raw = await _channel.callEndpoint(
      url: finalUrl, method: method, body: encodedBody, headers: finalHeaders,
    );
    return _decode(raw, method: method, url: finalUrl);
  } on AuthException catch (e) {
    if (e.requiresReLogin) {
      _sessionEvents?.emit(SessionEvent.expired);   // 1 chỗ duy nhất trong app
    }
    rethrow;
  }
}
```

Test chứng minh (đã chạy pass):

```dart
test('mọi request đều có header tenant + query được ghép đúng', () async {
  await client.get('https://api.example.com/Users/profile', query: {'skip': 0, 'take': 20});

  expect(channel.lastUrl, contains('skip=0'));
  expect(channel.lastHeaders['TenantId'], 'tenant-abc');
  expect(channel.lastHeaders.containsKey('Authorization'), isFalse);  // native mới gắn
});
```

---

## 5. Phần Native Cần Sửa (bỏ hardcode, nhận header từ Dart)

Hợp đồng mới: `callEndpoint` nhận **4** phần tử `[url, method, body, headersJson]`. Bridge cũ nhận 3 vẫn chạy (chỉ là không nhận được header từ Dart) → nâng cấp được từng bước.

**Android** (`FRAuthSampleBridge.java`):

```java
public void callEndpoint(String endpoint, String method, String payload,
                         String headersJson, MethodChannel.Result promise) {
    Request.Builder builder = new Request.Builder().url(endpoint);
    builder.method(method, payload.isEmpty() ? null
            : RequestBody.create(payload, MediaType.parse("application/json; charset=utf-8")));

    // Header do Dart quyết định — KHÔNG còn .addHeader("TenantId", "dae13df6-...")
    if (headersJson != null && !headersJson.isEmpty()) {
        JSONObject headers = new JSONObject(headersJson);
        for (Iterator<String> it = headers.keys(); it.hasNext(); ) {
            String key = it.next();
            builder.addHeader(key, headers.getString(key));
        }
    }
    // Authorization vẫn do AccessTokenInterceptor gắn trong buildClient()
    buildClient().newCall(builder.build()).enqueue(/* ... */);
}
```

**iOS** (`FRAuthSampleBridge.swift`):

```swift
@objc func callEndpoint(_ endpoint: String, method: String, payload: String,
                        headersJson: String, completion: @escaping FlutterResult) {
    FRUser.currentUser?.getAccessToken { (user, error) in
        var headers: [String: String] = headersJson.toStringDictionary()   // từ Dart
        if error == nil, let user = user {
            headers["Authorization"] = user.buildAuthHeader()              // chỉ native gắn
        }
        // KHÔNG còn: headers["TenantId"] = "dae13df6-..."
        let request = Request(url: endpoint, method: .init(rawValue: method) ?? .GET,
                              headers: headers, bodyParams: payload.convertToDictionary() ?? [:],
                              urlParams: [:], requestType: .json, responseType: .json)
        self.session.dataTask(with: request.build()!) { /* ... */ }.resume()
    }
}
```

Áp dụng tương tự cho `uploadFiles` và `callChangePassword` (2 chỗ hardcode còn lại).

---

## 6. ForgeRock IAM — Thư Viện Ngoài Nằm Ở Đâu

| | Chi tiết |
|:--|:--|
| Tên | ForgeRock / Ping Identity — **AM** (Access Management) phía server |
| SDK client | `org.forgerock:forgerock-auth` (Android, Java/Kotlin) · `FRAuth` (iOS, Swift, qua CocoaPods) |
| Plugin Flutter | **Không có bản chính thức** → bắt buộc `MethodChannel` |
| Khái niệm chính | **Journey**: chuỗi *node*, mỗi node chứa *callback* (ô nhập). Do quản trị viên cấu hình trên AM |
| SDK lo giúp | Journey state (`authId`), token + refresh, secure storage, cookie SSO, sinh trắc học |
| Dart phải lo | Điều phối journey, render callback thành UI, header nghiệp vụ (`TenantId`), dịch lỗi, quản lý state |

Journey là dữ liệu động, nên form đăng nhập **không biết trước có mấy ô**:

```dart
// login_page.dart — số ô nhập do AM quyết định (username+password, +OTP, đổi MK lần đầu...)
for (final callback in node.textInputs)
  TextFormField(
    controller: _controllerFor(callback),
    obscureText: callback.isPassword,                       // PasswordCallback
    decoration: InputDecoration(labelText: callback.prompt), // nhãn do AM gửi xuống
  ),
```

Và kết quả một bước journey được gói thành `sealed class` để không phải `if (json['type'] == 'LoginSuccess')` ở mọi chỗ gọi:

```dart
// core/auth/models/auth_journey.dart
sealed class JourneyStep { factory JourneyStep.parse(String rawJson, {String? operation}) { ... } }
class JourneySuccess    extends JourneyStep { final String? sessionToken; }
class JourneyNeedsInput extends JourneyStep { final FRNode node; }

// auth_notifier.dart — compiler bắt buộc phủ hết nhánh
switch (JourneyStep.parse(raw, operation: operation)) {
  case JourneySuccess():                 await _loadUser();
  case JourneyNeedsInput(:final node):   state = AuthNeedsInput(node);
}
```

Node **bất biến**: trả lời tạo ra node mới (`node.withAnswers({0: 'phong'})`) thay vì sửa `callback.input[0].value` như code cũ — tránh bug khi form bị render lại giữa lúc gửi.

---

## 7. Dùng Trong Feature

```dart
// 1. Gọi API nội bộ (token + tenant tự có)
final client = ref.read(authApiClientProvider);
final json   = await client.get('${AppConfig.current.apiBaseUrl}/Users/profile');

// 2. Theo dõi trạng thái đăng nhập
final authState = ref.watch(authProvider);

// 3. Điều hướng theo side-effect, KHÔNG nhét vào notifier
ref.listen(authProvider, (previous, next) {
  if (next is AuthUnauthenticated) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }
});

// 4. Test / dev không cần SDK native: AppConfig dev có useFakeAuthBridge = true
//    → FakeAuthChannel, đăng nhập bằng demo / demo123
```

Chạy thử: `flutter run --flavor dev -t lib/main_dev.dart` rồi vào route `/login`.

---

## 8. Trạng Thái & Việc Còn Lại

| Đã xong | Còn lại |
|:--|:--|
| ✅ Toàn bộ tầng Dart (channel, tenant/header, client, models, notifier, UI, DI) | ⬜ Copy `FRAuthSampleBridge.java` + `MainActivity` sang Android (đổi package) |
| ✅ `FakeAuthChannel` + 10 unit test (pass) | ⬜ Copy `FRAuthSampleBridge.swift` + wiring `AppDelegate/SceneDelegate` sang iOS |
| ✅ `tenantId` theo môi trường + `--dart-define` | ⬜ Thêm dependency SDK: `forgerock-auth` (Gradle) / `FRAuth` (Podfile) |
| ✅ Analyze sạch trên code mới | ⬜ Sửa 3 chỗ hardcode `TenantId` ở Java + 2 ở Swift theo §5 |
| ✅ Route `/login` | ⬜ Cấu hình AM thật (`FRAuthConfig` / `.plist`): realm, cookie name, journey name |

> Phần native **chưa** được port trong lần này: nó cần thêm SDK ForgeRock vào Gradle/Podfile, đổi package name và có cấu hình AM thật — làm riêng để không trộn lẫn với việc dựng tầng Dart. Nhờ `FakeAuthChannel`, tầng Dart vẫn chạy và test được ngay.

---

## 9. Liên Quan

- [00 — Quyết định state management (Riverpod vs BLoC vs GetX)](./00_state_management_decision.md)
- [Bài 15 — Call API](../15_flutter_call_api.md) · [Bài 17 — Platform Channels](../17_flutter_platform_channels.md)
- [Bài 19 — Environments](../19_flutter_environments.md) (flavor + `--dart-define`)
- [Bài 21 — Kiến trúc Flutter](../21_flutter_architecture.md)
