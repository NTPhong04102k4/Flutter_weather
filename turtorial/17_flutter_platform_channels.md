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

## 📝 Bài Tập Thực Hành

### Bài 1: Battery Info
Tạo MethodChannel lấy mức pin từ native (Android hoặc iOS). Hiển thị trong Flutter UI.

### Bài 2: Clipboard Manager
Tạo MethodChannel copy/paste text qua native clipboard API.

### Bài 3: Sensor Stream
Dùng EventChannel stream dữ liệu accelerometer từ native. Hiển thị real-time trong Flutter.

---

> **Bài tiếp theo**: [18 - Camera, Bluetooth, Animation,...](./18_flutter_device_features.md)
