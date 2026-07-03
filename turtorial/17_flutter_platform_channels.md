# 📘 Bài 17: Giao Tiếp Với Tầng Native (Platform Channels)

> **Mục tiêu**: Hiểu cách Flutter giao tiếp với iOS (Swift) và Android (Kotlin) qua Platform Channels.

---

## 1. Tổng Quan

```
┌──────────────────────────────────────────┐
│              Flutter (Dart)              │
│                                          │
│   MethodChannel    EventChannel          │
│       │ ▲              │ ▲               │
│       ▼ │              ▼ │               │
├──────────────────────────────────────────┤
│           Platform Channel               │
│        (Binary Message Passing)          │
├──────────────────────────────────────────┤
│  ┌────────────┐    ┌────────────┐        │
│  │  Android   │    │    iOS     │        │
│  │  (Kotlin)  │    │  (Swift)   │        │
│  └────────────┘    └────────────┘        │
└──────────────────────────────────────────┘

3 loại Channel:
1. MethodChannel — gọi method (request/response)
2. EventChannel — stream events liên tục
3. BasicMessageChannel — raw messages
```

---

## 2. MethodChannel — Gọi Native Method

### 2.1. Flutter side (Dart)

```dart
import 'package:flutter/services.dart';

class BatteryService {
  // Channel name — phải trùng giữa Dart và Native
  static const _channel = MethodChannel('com.myapp.weather/battery');

  /// Lấy mức pin hiện tại
  Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Lỗi lấy pin: ${e.message}');
    }
  }

  /// Lấy thông tin thiết bị
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod<Map>('getDeviceInfo');
    return Map<String, dynamic>.from(result!);
  }

  /// Mở cài đặt hệ thống
  Future<bool> openSettings() async {
    return await _channel.invokeMethod<bool>('openSettings') ?? false;
  }

  /// Rung thiết bị
  Future<void> vibrate({int duration = 500}) async {
    await _channel.invokeMethod('vibrate', {'duration': duration});
  }
}

// Sử dụng
void main() async {
  final battery = BatteryService();
  final level = await battery.getBatteryLevel();
  print('Pin: $level%');
}
```

### 2.2. Android side (Kotlin)

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
package com.myapp.weather

import android.content.Intent
import android.os.BatteryManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.myapp.weather/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val level = getBatteryLevel()
                        if (level != -1) {
                            result.success(level)
                        } else {
                            result.error("UNAVAILABLE", "Pin không khả dụng", null)
                        }
                    }
                    "getDeviceInfo" -> {
                        result.success(mapOf(
                            "model" to Build.MODEL,
                            "manufacturer" to Build.MANUFACTURER,
                            "version" to Build.VERSION.RELEASE,
                            "sdk" to Build.VERSION.SDK_INT
                        ))
                    }
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                        result.success(true)
                    }
                    "vibrate" -> {
                        val duration = call.argument<Int>("duration") ?: 500
                        vibrate(duration.toLong())
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun vibrate(duration: Long) {
        val vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            vibrator.vibrate(duration)
        }
    }
}
```

### 2.3. iOS side (Swift)

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.myapp.weather/battery",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getBatteryLevel":
                UIDevice.current.isBatteryMonitoringEnabled = true
                let level = Int(UIDevice.current.batteryLevel * 100)
                if level >= 0 {
                    result(level)
                } else {
                    result(FlutterError(
                        code: "UNAVAILABLE",
                        message: "Pin không khả dụng",
                        details: nil
                    ))
                }

            case "getDeviceInfo":
                result([
                    "model": UIDevice.current.model,
                    "name": UIDevice.current.name,
                    "version": UIDevice.current.systemVersion,
                    "identifier": UIDevice.current.identifierForVendor?.uuidString ?? ""
                ])

            case "openSettings":
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                    result(true)
                } else {
                    result(false)
                }

            case "vibrate":
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

---

## 3. EventChannel — Stream Events Từ Native

### Dart side

```dart
class SensorService {
  static const _eventChannel = EventChannel('com.myapp.weather/sensors');

  /// Stream accelerometer data
  Stream<Map<String, double>> get accelerometerStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event);
      return {
        'x': (map['x'] as num).toDouble(),
        'y': (map['y'] as num).toDouble(),
        'z': (map['z'] as num).toDouble(),
      };
    });
  }
}

// Sử dụng
StreamBuilder<Map<String, double>>(
  stream: SensorService().accelerometerStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final data = snapshot.data!;
    return Text('X: ${data['x']}, Y: ${data['y']}, Z: ${data['z']}');
  },
)
```

### Android side (Kotlin)

```kotlin
// Trong MainActivity.kt
val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger,
    "com.myapp.weather/sensors")

eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
    private var sensorManager: SensorManager? = null
    private var listener: SensorEventListener? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.let {
                    events?.success(mapOf(
                        "x" to it.values[0],
                        "y" to it.values[1],
                        "z" to it.values[2]
                    ))
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(listener, accelerometer,
            SensorManager.SENSOR_DELAY_UI)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(listener)
    }
})
```

---

## 4. Native Gọi Flutter (Reverse Channel)

```dart
// Flutter side — lắng nghe method call từ native
class NativeCallHandler {
  static const _channel = MethodChannel('com.myapp.weather/native_to_flutter');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPushNotificationTapped':
          final data = Map<String, dynamic>.from(call.arguments);
          _handleNotification(data);
          return true;

        case 'onDeepLink':
          final url = call.arguments as String;
          _handleDeepLink(url);
          return true;

        default:
          throw PlatformException(code: 'NOT_IMPLEMENTED');
      }
    });
  }

  static void _handleNotification(Map<String, dynamic> data) {
    // Navigate to specific screen
  }

  static void _handleDeepLink(String url) {
    // Handle deep link
  }
}
```

---

## 5. Pigeon — Type-safe Code Generation 🔥

Pigeon sinh code tự động cho cả Dart, Kotlin, Swift — không cần viết thủ công.

```yaml
# pubspec.yaml
dev_dependencies:
  pigeon: ^17.0.0
```

```dart
// pigeons/messages.dart
import 'package:pigeon/pigeon.dart';

class DeviceInfo {
  String? model;
  String? osVersion;
  int? batteryLevel;
}

@HostApi()   // Native → Dart (Flutter gọi native)
abstract class DeviceApi {
  DeviceInfo getDeviceInfo();
  int getBatteryLevel();
  void openSettings();
}

@FlutterApi()   // Dart → Native (Native gọi Flutter)
abstract class FlutterNotificationApi {
  void onNotificationReceived(String title, String body);
}

// Chạy: dart run pigeon --input pigeons/messages.dart
// Sẽ sinh ra code cho Dart, Kotlin, Swift tự động!
```

---

## 6. Tạo Flutter Plugin

```bash
# Tạo plugin mới
flutter create --template=plugin --platforms=android,ios my_plugin

# Cấu trúc plugin
my_plugin/
├── lib/
│   └── my_plugin.dart           # Dart API
├── android/
│   └── src/main/kotlin/.../     # Android implementation
├── ios/
│   └── Classes/                 # iOS implementation
├── example/                     # Example app
└── pubspec.yaml
```

```dart
// lib/my_plugin.dart
class MyPlugin {
  static const _channel = MethodChannel('my_plugin');

  static Future<String?> getPlatformVersion() async {
    return await _channel.invokeMethod<String>('getPlatformVersion');
  }
}
```

---

## 7. Federated Plugin Architecture

```
my_plugin/                        # App-facing package (API chung)
├── my_plugin_platform_interface/ # Platform interface (abstract)
├── my_plugin_android/            # Android implementation
├── my_plugin_ios/                # iOS implementation
├── my_plugin_web/                # Web implementation
└── my_plugin_windows/            # Windows implementation
```

---

## 8. FFI — Gọi Trực Tiếp C/C++ (dart:ffi) 🔥

**FFI (Foreign Function Interface)** cho phép Dart gọi thẳng hàm C/C++ **trong cùng tiến trình**, không qua cầu bất đồng bộ như MethodChannel.

### 8.1. FFI khác Platform Channel thế nào?

| Tiêu chí | MethodChannel | FFI (`dart:ffi`) |
|----------|--------------|------------------|
| Gọi tới | Kotlin/Swift | Thư viện **C/C++** (`.so`, `.dylib`, `.dll`) |
| Cơ chế | Serialize + gửi message qua platform bridge | Gọi hàm trực tiếp (như gọi hàm Dart) |
| Đồng bộ? | **Bất đồng bộ** (`Future`) | **Đồng bộ** mặc định (nhanh, không await) |
| Tốc độ | Có overhead serialize | Gần như native, cực nhanh |
| Hợp cho | Gọi API hệ điều hành (pin, GPS, camera) | Thư viện tính toán C có sẵn (SQLite, mã hóa, xử lý ảnh) |

> 💡 Dùng FFI khi bạn có sẵn **thư viện C/C++** muốn tái sử dụng. Dùng MethodChannel khi cần API cấp OS mà Android/iOS cung cấp qua Kotlin/Swift.

### 8.2. Gọi hàm C cơ bản

```c
// native/math.c  → biên dịch thành libmath.so / libmath.dylib
int32_t add(int32_t a, int32_t b) { return a + b; }
```

```dart
import 'dart:ffi';
import 'dart:io' show Platform;

// 1. typedef chữ ký hàm ở phía C (Native) và phía Dart
typedef AddNative = Int32 Function(Int32 a, Int32 b);   // kiểu FFI
typedef AddDart   = int   Function(int a, int b);        // kiểu Dart

// 2. Mở thư viện động
final DynamicLibrary _lib = Platform.isAndroid
    ? DynamicLibrary.open('libmath.so')
    : DynamicLibrary.process();   // iOS: static link vào process

// 3. Tra cứu hàm và ép về hàm Dart gọi được
final AddDart add = _lib
    .lookup<NativeFunction<AddNative>>('add')
    .asFunction<AddDart>();

void main() {
  print(add(3, 4));   // 7 — gọi đồng bộ, không cần await
}
```

### 8.3. Con trỏ, chuỗi & bộ nhớ (package `ffi`)

C dùng con trỏ và cấp phát thủ công → phải tự `allocate` và `free`:

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';   // dependency: ffi

// C: char* greet(char* name);
typedef GreetNative = Pointer<Utf8> Function(Pointer<Utf8> name);
typedef GreetDart   = Pointer<Utf8> Function(Pointer<Utf8> name);

final greet = _lib.lookupFunction<GreetNative, GreetDart>('greet');

String callGreet(String name) {
  final namePtr = name.toNativeUtf8();          // Dart String → char* (malloc)
  try {
    final resultPtr = greet(namePtr);
    return resultPtr.toDartString();            // char* → Dart String
  } finally {
    malloc.free(namePtr);                       // BẮT BUỘC free → tránh leak
  }
}
```

### 8.4. Struct C

```dart
// C: struct Point { double x; double y; };
final class Point extends Struct {
  @Double()
  external double x;
  @Double()
  external double y;
}

// Cấp phát struct trên native heap
final p = malloc<Point>();
p.ref.x = 1.0;
p.ref.y = 2.0;
// ... truyền p vào hàm C ...
malloc.free(p);
```

### 8.5. Sinh binding tự động với `ffigen`

Viết typedef tay dễ sai. `ffigen` đọc header `.h` và **generate toàn bộ binding**:

```yaml
# pubspec.yaml
dev_dependencies:
  ffigen: ^11.0.0

# ffigen.yaml
name: NativeBindings
output: 'lib/native_bindings.dart'
headers:
  entry-points:
    - 'native/math.h'
```

```bash
dart run ffigen   # → sinh lib/native_bindings.dart
```

### 8.6. FFI nặng & Isolate — tránh block UI

FFI gọi **đồng bộ** → hàm C chạy lâu sẽ **đứng UI thread**. Việc nặng → đẩy sang Isolate:

```dart
// Chạy hàm C nặng trong isolate riêng để giữ UI mượt
final result = await Isolate.run(() => heavyNativeCompute(input));
```

> ⚠️ Không thể gửi thẳng `Pointer` qua port giữa isolate (địa chỉ bộ nhớ không hợp lệ ở isolate khác). Truyền **dữ liệu** (số, `Uint8List`) và mở/lookup thư viện lại bên trong isolate đó.

Chiều ngược lại — **C gọi lại Dart** (callback từ luồng native) dùng `NativeCallable.listener` (Dart 3.1+) để an toàn giữa các luồng.

---

## 📝 Bài Tập Thực Hành

### Bài 1: Battery Info
Tạo MethodChannel lấy mức pin từ native (Android hoặc iOS). Hiển thị trong Flutter UI.

### Bài 2: Clipboard Manager
Tạo MethodChannel copy/paste text qua native clipboard API.

### Bài 3: Sensor Stream
Dùng EventChannel stream dữ liệu accelerometer từ native. Hiển thị real-time trong Flutter.

### Bài 4: FFI Calculator
Viết hàm C `int add(int, int)` + `int fib(int)`, biên dịch thành thư viện động, gọi qua `dart:ffi`. So sánh thời gian gọi `fib(40)` trực tiếp (block UI) vs bọc trong `Isolate.run`.

---

> **Bài tiếp theo**: [18 - Camera, Bluetooth, Animation,...](./18_flutter_device_features.md)
