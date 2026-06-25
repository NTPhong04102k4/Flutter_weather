# 📘 Bài Bổ Sung: Kiến Trúc Flutter & Cách Giao Tiếp Với Engine và OS

> **Mục tiêu**: Hiểu sâu kiến trúc 3 tầng của Flutter, cách Dart code chạy trên thiết bị, và cách Flutter giao tiếp với hệ điều hành mobile.

---

## 1. Kiến Trúc Tổng Quan — 3 Tầng (Layers)

```
┌─────────────────────────────────────────────────────────────┐
│                     YOUR DART CODE                          │
│                  (Widget, State, Logic)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              FRAMEWORK LAYER (Dart)                     │  │
│  │                                                        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │  │
│  │  │ Material │ │Cupertino │ │ Widgets  │ │ Painting │  │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │  │
│  │  │Rendering │ │Animation │ │Foundation│ │ Gestures │  │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
│                           │                                  │
│                    dart:ui (binding)                          │
│                           │                                  │
├───────────────────────────┼──────────────────────────────────┤
│  ┌────────────────────────┼───────────────────────────────┐  │
│  │              ENGINE LAYER (C/C++)                       │  │
│  │                        │                               │  │
│  │  ┌──────────┐  ┌──────┴─────┐  ┌──────────────────┐   │  │
│  │  │  Skia /  │  │ Dart       │  │ Platform         │   │  │
│  │  │ Impeller │  │ Runtime    │  │ Channels         │   │  │
│  │  │ (Render) │  │ (Dart VM)  │  │ (Native Bridge)  │   │  │
│  │  └──────────┘  └────────────┘  └──────────────────┘   │  │
│  │  ┌──────────┐  ┌────────────┐  ┌──────────────────┐   │  │
│  │  │  Text    │  │ Compositor │  │ I/O, Network,    │   │  │
│  │  │ Layout   │  │            │  │ File System      │   │  │
│  │  └──────────┘  └────────────┘  └──────────────────┘   │  │
│  └────────────────────────────────────────────────────────┘  │
│                           │                                  │
├───────────────────────────┼──────────────────────────────────┤
│  ┌────────────────────────┼───────────────────────────────┐  │
│  │            EMBEDDER / PLATFORM LAYER                    │  │
│  │                        │                               │  │
│  │  ┌─────────────────────┴──────────────────────────┐    │  │
│  │  │                                                │    │  │
│  │  │    Android (Java/Kotlin)  │  iOS (ObjC/Swift)  │    │  │
│  │  │    ──────────────────────   ─────────────────── │    │  │
│  │  │    • FlutterActivity       • FlutterViewController  │  │
│  │  │    • FlutterView           • FlutterView            │  │
│  │  │    • Surface/Texture       • Metal/OpenGL           │  │
│  │  │    • System Services       • System Services        │  │
│  │  │    • Plugins               • Plugins                │  │
│  │  │                                                │    │  │
│  │  └────────────────────────────────────────────────┘    │  │
│  └────────────────────────────────────────────────────────┘  │
│                           │                                  │
├───────────────────────────┼──────────────────────────────────┤
│  ┌────────────────────────┼───────────────────────────────┐  │
│  │         OPERATING SYSTEM (Android / iOS)                │  │
│  │                                                        │  │
│  │    Linux Kernel (Android)  │  Darwin/XNU (iOS)         │  │
│  │    Hardware Abstraction    │  Hardware Abstraction      │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Chi Tiết Từng Tầng

### 2.1. Framework Layer (Viết bằng Dart — bạn code ở đây)

Đây là tầng **bạn tương tác hàng ngày** khi viết Flutter app. Toàn bộ được viết bằng Dart.

```
Framework Layer (từ trên xuống dưới):
├── Material / Cupertino    ← Widget cấp cao (Button, AppBar, Dialog,...)
├── Widgets                 ← Widget cơ bản (Text, Row, Column, Stack,...)
├── Rendering               ← Layout, painting, hit testing
├── Animation               ← Tween, AnimationController, Curves
├── Painting                ← TextStyle, BoxDecoration, Canvas operations
├── Gestures                ← Tap, drag, scale gesture recognizers
├── Foundation              ← Utility classes, ChangeNotifier, Key,...
└── dart:ui                 ← Binding tới Engine (cầu nối Dart → C++)
```

```dart
// Bạn viết code ở tầng Material/Cupertino/Widgets:
MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: Text('Hello')),   // ← Material layer
    body: Column(                            // ← Widgets layer
      children: [
        Text('World'),                       // ← Widgets layer
        ElevatedButton(                      // ← Material layer
          onPressed: () {},
          child: Text('Click'),
        ),
      ],
    ),
  ),
)

// Bên dưới, Flutter tự xử lý:
// Widgets layer → tạo Element tree
// Rendering layer → tạo RenderObject tree → tính layout → vẽ lên canvas
// dart:ui → gửi frame xuống Engine
```

### 2.2. Engine Layer (Viết bằng C/C++ — Flutter tự quản lý)

Engine là **trái tim** của Flutter, xử lý tất cả công việc nặng:

```
Engine Layer:
├── Skia / Impeller        ← Thư viện đồ họa 2D (vẽ pixel lên màn hình)
│   ├── Skia: engine đồ họa cũ, dùng OpenGL/Vulkan
│   └── Impeller: engine mới (Flutter 3.16+), hiệu năng tốt hơn
│
├── Dart Runtime           ← Máy ảo Dart (Dart VM)
│   ├── JIT (Debug)        : compile + chạy ngay → Hot Reload
│   └── AOT (Release)      : compile trước → native code → nhanh hơn
│
├── Text Layout            ← Xử lý text: đo size, line break, bidi
│   └── Dùng libtext (HarfBuzz + ICU + Minikin)
│
├── Compositor             ← Ghép các layer lại thành frame cuối cùng
│   └── Tạo layer tree → rasterize → gửi tới GPU
│
└── Platform Channels      ← Cầu nối giữa Dart ↔ Native code
    └── Serialize/Deserialize messages qua binary codec
```

#### Skia vs Impeller

```
Skia (trước Flutter 3.16):
├── Thư viện đồ họa 2D của Google (cũng dùng trong Chrome, Android)
├── Dùng OpenGL ES (Android) / Metal (iOS)
├── Compile shader lúc runtime → có thể gây "jank" (giật frame đầu tiên)
└── Ổn định, đã dùng lâu

Impeller (mặc định từ Flutter 3.16+):
├── Engine đồ họa mới, thiết kế riêng cho Flutter
├── Dùng Metal (iOS) / Vulkan (Android) / OpenGL fallback
├── Pre-compile shader lúc build → KHÔNG jank
├── Hiệu suất ổn định hơn (predictable performance)
└── Đang dần thay thế Skia
```

#### JIT vs AOT Compilation

```
JIT (Just-In-Time) — Dùng khi DEBUG:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Dart Source │ →  │   Dart VM   │ →  │  Machine    │
│   (.dart)    │    │ (compile &  │    │   Code      │
│              │    │  run ngay)  │    │ (lúc chạy)  │
└─────────────┘    └─────────────┘    └─────────────┘
                   ↑ Hot Reload!
                   Thay đổi code → inject vào VM → rebuild widget

AOT (Ahead-Of-Time) — Dùng khi RELEASE:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Dart Source │ →  │  Compiler   │ →  │  Native     │
│   (.dart)    │    │ (compile    │    │  Binary     │
│              │    │  TRƯỚC)     │    │ (ARM/x86)   │
└─────────────┘    └─────────────┘    └─────────────┘
                   Không có VM → nhỏ hơn, nhanh hơn
                   Không có Hot Reload!
```

### 2.3. Embedder / Platform Layer (Viết bằng Java/Kotlin/Swift/ObjC)

Embedder là tầng **gắn Flutter vào hệ điều hành**. Mỗi OS có embedder riêng.

```
Android Embedder:
├── FlutterActivity / FlutterFragment  ← Activity/Fragment chứa Flutter
├── FlutterView                         ← SurfaceView để render
├── FlutterEngine                       ← Khởi tạo + quản lý engine
├── Plugins Registry                    ← Đăng ký native plugins
└── System Channels                     ← Kênh giao tiếp mặc định
    ├── navigation    → Back button, deep links
    ├── platform      → Clipboard, haptic feedback, system UI
    ├── textinput     → Keyboard input
    ├── keyevent      → Physical key events
    └── lifecycle     → App lifecycle (foreground/background)

iOS Embedder:
├── FlutterViewController              ← UIViewController chứa Flutter
├── FlutterView                        ← Metal-backed UIView
├── FlutterEngine                      ← Khởi tạo + quản lý engine
├── Plugins Registry                   ← Đăng ký native plugins
└── System Channels                    ← Tương tự Android
```

---

## 3. Cách Flutter Render Lên Màn Hình — Pipeline

```
Bạn viết:  Widget build() → return Column(children: [Text('Hi'), ...])

Flutter xử lý (mỗi frame ~16ms cho 60fps):

┌──────────────────────────────────────────────────────────┐
│ 1. BUILD PHASE                                           │
│    Widget Tree → Element Tree                            │
│    (Tạo/cập nhật blueprint)                              │
│                                                          │
│    MyApp → MaterialApp → Scaffold → Column → Text        │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ 2. LAYOUT PHASE                                          │
│    Element Tree → RenderObject Tree                      │
│    (Tính toán size & position)                           │
│                                                          │
│    Parent truyền constraints xuống → Child trả size lên  │
│    "Con ơi, con có TỐI ĐA 400px rộng"                   │
│    "Dạ con chỉ cần 200px thôi ạ"                        │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ 3. PAINT PHASE                                           │
│    RenderObject → Layer Tree                             │
│    (Vẽ lên canvas)                                       │
│                                                          │
│    Mỗi RenderObject.paint() vẽ lên Canvas                │
│    canvas.drawRect(), canvas.drawText(),...               │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ 4. COMPOSITE PHASE                                       │
│    Layer Tree → Frame                                    │
│    (Ghép layers + gửi tới GPU)                           │
│                                                          │
│    Engine (Skia/Impeller) rasterize → GPU render          │
│    GPU vẽ pixel lên Surface/Metal Texture                │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ 5. DISPLAY                                               │
│    GPU → Screen                                          │
│    Frame buffer → Hiển thị lên màn hình vật lý           │
└──────────────────────────────────────────────────────────┘
```

### 3 Trees chi tiết

```dart
// Code bạn viết:
Text('Hello', style: TextStyle(fontSize: 20))

// Flutter tạo 3 trees:

// 1️⃣ WIDGET TREE (Immutable blueprint)
// Text widget (cấu hình: text='Hello', fontSize=20)
//   → Mô tả UI muốn hiển thị gì
//   → Được tạo mới mỗi lần build()
//   → Rẻ để tạo (const constructor)

// 2️⃣ ELEMENT TREE (Mutable instance, quản lý lifecycle)
// TextElement
//   → Cầu nối giữa Widget và RenderObject
//   → Giữ reference tới Widget hiện tại
//   → So sánh Widget cũ vs mới để quyết định: update hay recreate
//   → Tồn tại lâu dài (không tạo lại mỗi frame)

// 3️⃣ RENDEROBJECT TREE (Tính layout + vẽ)
// RenderParagraph
//   → Tính toán kích thước text (width, height)
//   → Vẽ text lên canvas
//   → Xử lý hit testing (tap gesture)
//   → Tồn tại lâu dài, chỉ update khi data thay đổi
```

```
Tại sao 3 trees? Tối ưu hiệu suất!

setState() → Widget tree rebuild (RẺ - chỉ tạo object Dart)
           → Element tree so sánh: "Widget mới có khác Widget cũ không?"
              ├── Giống → KHÔNG update RenderObject → tiết kiệm!
              └── Khác → Update RenderObject → re-layout → re-paint
```

---

## 4. Cách Flutter Giao Tiếp Với OS 🔥

### 4.1. Flutter KHÔNG dùng Native UI Widgets!

```
React Native:                    Flutter:
┌──────────────┐                ┌──────────────┐
│  JS Code     │                │  Dart Code   │
│  <Button>    │                │  ElevatedButton│
│       │      │                │       │      │
│       ▼      │                │       ▼      │
│  Bridge (JS→ │                │  Skia/Impeller│
│  Native)     │                │  (vẽ TRỰC TIẾP│
│       │      │                │   lên canvas) │
│       ▼      │                │       │      │
│  UIButton    │                │       ▼      │
│  (Native iOS)│                │  Pixel trên  │
│              │                │  Surface/    │
│              │                │  Metal       │
└──────────────┘                └──────────────┘

React Native: JS → Bridge → Native Widget → OS render
Flutter:      Dart → Skia/Impeller → trực tiếp vẽ pixel → GPU

→ Flutter KHÔNG dùng UIButton, UITextField,... của iOS
→ Flutter TỰ VẼ mọi pixel lên canvas (giống game engine!)
→ Vì vậy Flutter render GIỐNG NHAU trên mọi OS
→ Và vì vậy Flutter CẦN Cupertino widgets để "giả" iOS look
```

### 4.2. Flutter cần OS cho gì?

Dù Flutter tự vẽ UI, nó VẪN CẦN OS cho:

```
Flutter cần OS cung cấp:
├── 1. Surface/Canvas         ← Vùng nhớ để vẽ pixel
│      Android: SurfaceView
│      iOS: CAMetalLayer (Metal) hoặc CAEAGLLayer (OpenGL)
│
├── 2. Input Events           ← Touch, keyboard, mouse
│      OS gửi raw touch events → Flutter gesture system xử lý
│      OS gửi keyboard input → Flutter text input system
│
├── 3. Lifecycle Events       ← App foreground/background/terminate
│      OS thông báo → Flutter AppLifecycleState
│
├── 4. Accessibility          ← Screen reader, font size, contrast
│      Flutter tạo SemanticsTree → gửi cho OS accessibility service
│
├── 5. System Services        ← Camera, GPS, Bluetooth, File system,...
│      Truy cập qua Platform Channels (bài 17)
│
└── 6. Thread/Process         ← Main thread (UI), raster thread, I/O thread
       OS cung cấp thread → Flutter engine quản lý
```

### 4.3. Luồng Giao Tiếp Khi User Tap Nút

```
User chạm ngón tay lên màn hình:

1. HARDWARE: Digitizer cảm ứng phát hiện touch
       │
2. OS KERNEL: Driver cảm ứng tạo touch event
       │
3. OS FRAMEWORK:
   ├── Android: MotionEvent → Activity.dispatchTouchEvent()
   └── iOS: UITouch → UIView.touchesBegan()
       │
4. EMBEDDER: FlutterView nhận event
   ├── Android: FlutterView.onTouchEvent(MotionEvent)
   └── iOS: FlutterView.touchesBegan(_:with:)
       │
5. ENGINE: Chuyển thành FlutterPointerEvent
   └── Gửi qua dart:ui → Window.onPointerDataPacket
       │
6. FRAMEWORK (Dart):
   ├── GestureBinding nhận PointerEvent
   ├── HitTest: tìm widget nào ở vị trí tap
   │   └── RenderObject tree duyệt top-down
   │       → "Ah, user tap vào RenderBox của ElevatedButton"
   ├── GestureArena: quyết định gesture type (tap? drag? long press?)
   │   └── TapGestureRecognizer wins → "Đây là tap!"
   └── Callback: onPressed() được gọi
       │
7. YOUR CODE:
   onPressed: () {
     setState(() {
       _count++;    // ← Code bạn viết chạy ở đây
     });
   }
       │
8. REBUILD: setState → build() → new Widget tree
       → Element tree diff → RenderObject update
       → Paint → Composite → GPU → Pixel trên màn hình
       │
9. DISPLAY: Màn hình hiển thị frame mới (trong ~16ms cho 60fps)
```

---

## 5. Threading Model — Các Luồng Trong Flutter

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Engine Threads                     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Platform     │  │ UI Thread    │  │ Raster Thread    │  │
│  │ Thread       │  │ (Dart)       │  │ (GPU)            │  │
│  │              │  │              │  │                  │  │
│  │ • Main thread│  │ • Dart code  │  │ • Rasterize      │  │
│  │   của OS     │  │ • build()    │  │   layer tree     │  │
│  │ • Plugin     │  │ • layout()   │  │ • Gửi frame      │  │
│  │   calls      │  │ • paint()    │  │   tới GPU        │  │
│  │ • Native     │  │ • Event loop │  │ • Skia/Impeller  │  │
│  │   UI events  │  │ • Gesture    │  │   rendering      │  │
│  │              │  │ • Animation  │  │                  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                              │
│  ┌──────────────┐  ┌──────────────────────────────────────┐  │
│  │ I/O Thread   │  │ Dart Isolate Threads                 │  │
│  │              │  │                                      │  │
│  │ • File I/O   │  │ • compute() chạy trên isolate riêng │  │
│  │ • Network    │  │ • Tính toán nặng không block UI      │  │
│  │ • Database   │  │ • Mỗi isolate có memory riêng       │  │
│  │              │  │                                      │  │
│  └──────────────┘  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

```dart
// UI Thread bận → app giật (jank)!
// Ví dụ:

// ❌ SAI — tính toán nặng trên UI thread
void build(BuildContext context) {
  // Fibonacci(45) mất ~5 giây → block UI → app đơ!
  final result = fibonacci(45);
  return Text('$result');
}

// ✅ ĐÚNG — chuyển sang Isolate
void _calculate() async {
  // compute() chạy trên thread riêng → UI mượt mà
  final result = await compute(fibonacci, 45);
  setState(() => _result = result);
}
```

---

## 6. Platform Channels — Cầu Nối Dart ↔ Native

```
Dart Code                            Native Code
(Framework)                          (Android/iOS)
                 Platform Channel
    ┌─────┐      ┌──────────┐       ┌─────────┐
    │ Dart │ ──── │ Message  │ ────→ │ Kotlin/ │
    │ code │ ←─── │ Codec    │ ←──── │ Swift   │
    └─────┘      └──────────┘       └─────────┘

Message flow:
1. Dart gọi: channel.invokeMethod('getBattery')
2. Engine serialize → binary message
3. Platform thread nhận → gọi native code
4. Native code trả kết quả
5. Engine deserialize → Dart nhận Future<result>

Message Codecs:
├── StandardMessageCodec  ← Mặc định (hỗ trợ: null, bool, int, double, String, List, Map)
├── JSONMessageCodec      ← JSON format
├── BinaryCodec           ← Raw bytes
└── StringCodec           ← Plain string
```

### System Channels (Flutter tự dùng nội bộ)

```dart
// Flutter dùng Platform Channels nội bộ cho:

// 1. Text Input — Keyboard
// Channel: "flutter/textinput"
// OS keyboard → raw text → Flutter TextField

// 2. Navigation — Back button, Deep links
// Channel: "flutter/navigation"
// Android Back button → Navigator.pop()
// URL scheme → route matching

// 3. Platform — System UI
// Channel: "flutter/platform"
// Status bar style, orientation lock, haptic feedback

// 4. Lifecycle — App state
// Channel: "flutter/lifecycle"
// AppLifecycleState: resumed, inactive, paused, detached

// 5. Accessibility — Screen reader
// Channel: "flutter/accessibility"
// Flutter SemanticsTree → OS accessibility service (TalkBack/VoiceOver)

// Bạn CŨNG tạo channel riêng cho feature của mình (bài 17)
```

---

## 7. So Sánh Kiến Trúc Với Các Framework Khác

```
┌──────────────┬──────────────────┬────────────────────┬─────────────────┐
│              │ Flutter          │ React Native       │ Native (Swift/  │
│              │                  │                    │ Kotlin)         │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ UI Rendering │ Tự vẽ pixel     │ Bridge → Native    │ OS render       │
│              │ (Skia/Impeller) │ UIKit/Android View │ trực tiếp       │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ Language     │ Dart (AOT)      │ JavaScript (JIT)   │ Swift/Kotlin    │
│              │                  │ + Bridge overhead  │ (native)        │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ Performance  │ ≈ Native        │ Bridge bottleneck  │ Tốt nhất        │
│              │ (gần native)    │ (JS ↔ Native)      │                 │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ UI           │ Pixel-perfect   │ Native look mặc    │ Native look     │
│ Consistency  │ giống nhau trên │ định, có thể khác  │ 100%            │
│              │ mọi OS          │ giữa iOS/Android   │                 │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ Hot Reload   │ ✅ (Sub-second) │ ✅ (Fast Refresh)  │ ❌ (Xcode       │
│              │                  │                    │ Preview)        │
├──────────────┼──────────────────┼────────────────────┼─────────────────┤
│ Code Share   │ ~95% Dart       │ ~90% JS            │ 0% (viết riêng  │
│              │ iOS + Android   │ iOS + Android      │ cho mỗi OS)     │
└──────────────┴──────────────────┴────────────────────┴─────────────────┘
```

---

## 8. Tại Sao Flutter Nhanh?

```
5 lý do Flutter nhanh gần bằng native:

1️⃣ AOT Compilation
   Dart compile thành native ARM code (không qua interpreter/VM)
   → Chạy nhanh như C/C++

2️⃣ Không có Bridge
   React Native: JS → Bridge → Native → Bridge → JS (overhead mỗi frame)
   Flutter: Dart → Engine → GPU (trực tiếp, không bridge)

3️⃣ Skia/Impeller render trực tiếp
   Không phụ thuộc native widget → không phải chờ OS render
   Flutter kiểm soát toàn bộ pixel trên màn hình

4️⃣ Widget rebuild rẻ
   Widget là immutable, nhẹ (chỉ là config object)
   Element tree diff hiệu quả (giống React Virtual DOM)
   RenderObject chỉ update khi data thực sự thay đổi

5️⃣ Dart single-threaded + Event Loop
   Không cần lock/mutex → không deadlock
   UI thread chuyên render → consistent 60/120fps
   Heavy work → Isolate (true parallel, không block UI)
```

---

## 9. App Lifecycle — Vòng Đời Ứng Dụng

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App ở foreground, user đang dùng
        print('▶️ Resumed — App visible & active');
        // → Resume music, reconnect WebSocket, refresh data
        break;

      case AppLifecycleState.inactive:
        // App bị che một phần (incoming call, notification panel)
        print('⏸️ Inactive — App partially visible');
        // → Pause game, stop camera preview
        break;

      case AppLifecycleState.paused:
        // App ở background (user chuyển app khác)
        print('⏹️ Paused — App NOT visible');
        // → Save state, stop location tracking, pause timers
        break;

      case AppLifecycleState.detached:
        // App sắp bị hủy
        print('💀 Detached — App will be destroyed');
        // → Final cleanup
        break;

      case AppLifecycleState.hidden:
        // App bị ẩn hoàn toàn (Flutter 3.13+)
        print('👻 Hidden');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const MyHomePage();
}
```

```
App Lifecycle trên mỗi OS:

Android:
  onCreate → onStart → onResume    ═══► resumed
  onPause                          ═══► inactive → paused
  onStop                           ═══► hidden
  onDestroy                        ═══► detached

iOS:
  applicationDidBecomeActive       ═══► resumed
  applicationWillResignActive      ═══► inactive
  applicationDidEnterBackground    ═══► hidden → paused
  applicationWillTerminate         ═══► detached
```

---

## 10. Tóm Tắt — Bức Tranh Toàn Cảnh

```
Bạn viết Dart code (Widget, State, Logic)
        │
        ▼
Framework Layer (Dart):
  Widget Tree → Element Tree → RenderObject Tree
  Layout → Paint → Layer Tree
        │
        ▼ (qua dart:ui)
Engine Layer (C++):
  Dart VM (JIT/AOT) + Skia/Impeller (GPU rendering)
  + Platform Channels (giao tiếp native)
        │
        ▼
Embedder Layer (Kotlin/Swift):
  FlutterActivity/FlutterViewController
  Cung cấp Surface, Input, Lifecycle, System Services
        │
        ▼
OS (Android/iOS):
  Linux Kernel / Darwin + Hardware
  → Pixel hiển thị trên màn hình 📱
```

> 💡 **Key insight**: Flutter là **game engine cho app**. Giống Unity vẽ game, Flutter tự vẽ toàn bộ UI lên canvas mà không dùng native widget. Đó là lý do nó nhanh, đồng nhất, nhưng cũng là lý do bạn cần Platform Channels để truy cập tính năng OS.

---

## 📝 Câu Hỏi Ôn Tập

1. Tại sao Flutter không dùng native widgets (UIButton, TextView,...)?
2. Sự khác biệt giữa Widget Tree, Element Tree, RenderObject Tree?
3. JIT và AOT khác nhau thế nào? Khi nào dùng cái nào?
4. Skia và Impeller khác nhau ở điểm gì?
5. Khi user tap nút, luồng xử lý đi qua những tầng nào?
6. Platform Channel hoạt động như thế nào?
7. Tại sao Flutter nhanh gần bằng native?

---

> **Quay lại mục lục**: [00 - Index](./00_index.md)
