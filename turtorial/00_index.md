# 📚 Lộ Trình Tự Học Dart & Flutter (iOS + Android)

> **Mục tiêu**: Từ con số 0, nắm vững Dart và Flutter để xây dựng ứng dụng mobile hoàn chỉnh cho cả iOS và Android.

---

## 🗺️ Tổng Quan Lộ Trình

```
┌─────────────────────────────────────────────────────────────┐
│  PHẦN 1: DART CƠ BẢN (Bài 01 → 04)                        │
│  Kiểu dữ liệu → Toán tử → OOP → Collections               │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 2: DART NÂNG CAO (Bài 05 → 07)                       │
│  Async/Await → Error Handling → Race Condition              │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 3: FLUTTER CƠ BẢN (Bài 08 → 11)                     │
│  Widget → Material → Cupertino → Custom                     │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 4: NAVIGATION & STATE (Bài 12 → 14)                  │
│  Navigation → Props/Callbacks → State Management            │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 5: NETWORKING (Bài 15 → 16)                           │
│  Call API → WebView                                         │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 6: NATIVE & HARDWARE (Bài 17 → 18)                   │
│  Platform Channels → Camera/Bluetooth/Animation             │
├─────────────────────────────────────────────────────────────┤
│  PHẦN 7: BUILD & DEPLOY (Bài 19 → 20)                      │
│  Environments → Build & Triển khai                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📖 Danh Sách Bài Học

### 🟢 Phần 1: Dart Cơ Bản *(Tuần 1-2)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 01 | [Kiểu dữ liệu & Biến](./01_dart_data_types.md) | `int`, `double`, `String`, `bool`, `var`, `const`, `final`, Null Safety | ~2h |
| 02 | [Toán tử & Luồng điều khiển](./02_dart_operators_and_control_flow.md) | Toán tử, `if/else`, `switch`, vòng lặp | ~2h |
| 03 | [Hàm & OOP](./03_dart_functions_and_oop.md) | Function, Class, kế thừa, đa hình, abstract, mixin | ~3h |
| 04 | [Collections & Xử lý chuỗi/số](./04_dart_collections_and_string.md) | `List`, `Set`, `Map`, String methods, math | ~2h |

### 🟡 Phần 2: Dart Nâng Cao *(Tuần 2-3)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 05 | [Lập trình bất đồng bộ](./05_dart_async_programming.md) | `Future`, `async/await`, `Stream`, `Isolate`, Event Loop | ~3h |
| 06 | [Xử lý lỗi & Exception](./06_dart_error_handling.md) | `try/catch`, custom exceptions, best practices | ~1.5h |
| 07 | [Race Condition & Cache](./07_dart_race_condition_and_cache.md) | Debounce, throttle, search cache, CancelableOperation | ~2h |

### 🔵 Phần 3: Flutter Cơ Bản *(Tuần 3-5)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 08 | [Widget Cơ Bản](./08_flutter_widget_basics.md) | StatelessWidget, StatefulWidget, Lifecycle, Hot Reload | ~3h |
| 09 | [Material Design Widgets](./09_flutter_material_widgets.md) | MaterialApp, Scaffold, Button, TextField, Dialog, Theme | ~4h |
| 10 | [Cupertino Widgets (iOS)](./10_flutter_cupertino_widgets.md) | CupertinoApp, iOS-style widgets, so sánh Material vs Cupertino | ~3h |
| 11 | [Custom Widgets & Painting](./11_flutter_custom_widgets.md) | CustomPaint, Sliver, LayoutBuilder, responsive design | ~3h |

### 🟣 Phần 4: Navigation & State *(Tuần 5-6)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 12 | [Navigation & Routing](./12_flutter_navigation.md) | Navigator, GoRouter, deep linking, nested navigation | ~3h |
| 13 | [Truyền dữ liệu giữa Widgets](./13_flutter_props_and_callbacks.md) | Props, callbacks, InheritedWidget, ValueNotifier | ~2h |
| 14 | [Quản lý State](./14_flutter_state_management.md) | Provider, Riverpod, Bloc/Cubit, so sánh | ~4h |

### 🟠 Phần 5: Networking *(Tuần 6-7)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 15 | [Gọi API & Xử lý dữ liệu](./15_flutter_call_api.md) | http, Dio, JSON parsing, interceptors, pagination | ~4h |
| 16 | [Tích hợp WebView](./16_flutter_webview.md) | webview_flutter, JS ↔ Flutter, cookies, permissions | ~3h |

### 🔴 Phần 6: Native & Hardware *(Tuần 7-8)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 17 | [Giao tiếp Native (Platform Channels)](./17_flutter_platform_channels.md) | MethodChannel, EventChannel, Pigeon, Plugin development | ~4h |
| 18 | [Camera, Bluetooth, Animation,...](./18_flutter_device_features.md) | Camera, file upload, Bluetooth, gestures, animations | ~4h |

### ⚫ Phần 7: Build & Deploy *(Tuần 8-9)*

| # | Bài học | Mô tả | Thời gian |
|:--|:-------|:------|:---------:|
| 19 | [Phân chia môi trường](./19_flutter_environments.md) | Dev/Staging/Prod, Flavors, `.env`, CI/CD | ~3h |
| 20 | [Build & Triển khai](./20_flutter_build_and_deploy.md) | APK/AAB/IPA, signing, App Store, Google Play | ~3h |

---

### 🏛️ Tài Liệu Bổ Trợ: Kiến Trúc Hệ Thống *(nền tảng — nên đọc song song)*

| Chủ đề | Mô tả |
|:-------|:------|
| [System Architecture](./System_Architecture/00_index.md) | Phần cứng (CPU/GPU/RAM/ROM), Hệ điều hành, **phân biệt Process/Thread/Service**, Concurrency vs Parallelism, Isolate & mô hình luồng Flutter |
| [Auth Native (Login/Logout)](./Auth_Native/00_state_management_decision.md) | Port flow **login/logout native** (ForgeRock qua MethodChannel) từ `app-hrm` sang `weather`; **so sánh Riverpod vs BLoC vs GetX** & quyết định state management |
| [Auth Native — Bộ công cụ, `tenantId` & Header](./Auth_Native/01_auth_toolkit_and_tenant_header.md) | Bộ công cụ auth đã gom vào `weather`; **vì sao cần lớp xử lí** thay vì dùng `MethodChannel`/`http` sẵn có hay `flutter_appauth`/`dio`; đường đi của `tenantId` và header qua lớp auth tới SDK ForgeRock |

---

## ⏱️ Tổng thời gian ước tính: **~55 giờ** (~6-9 tuần nếu học 1-2h/ngày)

---

## 💡 Mẹo Học Hiệu Quả

1. **Đọc lý thuyết → Gõ code → Chạy thử → Sửa lỗi** — Đừng chỉ đọc, hãy gõ lại từng dòng code
2. **Làm bài tập cuối mỗi bài** — Mỗi bài đều có phần thực hành
3. **Không cần học hết rồi mới code** — Học đến bài 08-09 là đã có thể bắt đầu làm app đơn giản
4. **Quay lại ôn** — Kiến thức Dart (bài 01-07) sẽ cần dùng liên tục khi viết Flutter

---

> *Chúc bạn học tốt! 🚀 — Bộ tài liệu này được tạo để bạn có thể tự học từ cơ bản đến nâng cao.*
