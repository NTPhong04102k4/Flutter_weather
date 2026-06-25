# 📘 Bài 20: Build & Triển Khai Sản Phẩm

> **Mục tiêu**: Build APK/AAB/IPA, signing, tối ưu, submit lên App Store & Google Play.

---

## 1. Chuẩn Bị Trước Khi Build

### Checklist

```
□ Đổi app name & bundle ID
□ Cập nhật version & build number
□ Thay app icon
□ Thay splash screen
□ Kiểm tra permissions
□ Remove debug logs
□ Test trên device thật
□ Kiểm tra dark mode
□ Kiểm tra responsive (nhiều kích thước)
□ Kiểm tra performance (release mode)
```

### Đổi App Name & Bundle ID

```yaml
# pubspec.yaml
name: weather
description: Weather forecast app
version: 1.0.0+1   # version+buildNumber
```

```xml
<!-- Android: android/app/src/main/AndroidManifest.xml -->
<application android:label="Weather App" ...>
```

```
<!-- Android: android/app/build.gradle -->
defaultConfig {
    applicationId "com.mycompany.weather"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

```
<!-- iOS: ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>Weather App</string>
<key>CFBundleName</key>
<string>Weather</string>
```

### App Icon

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

```bash
dart run flutter_launcher_icons
```

### Splash Screen

```yaml
# pubspec.yaml
dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#1976D2"
  image: assets/splash/splash_logo.png
  android: true
  ios: true
  android_12:
    color: "#1976D2"
    icon_background_color: "#FFFFFF"
    image: assets/splash/splash_logo.png
```

```bash
dart run flutter_native_splash:create
```

---

## 2. Build Android

### 2.1. Signing — Ký ứng dụng

```bash
# Tạo keystore (chỉ làm 1 lần — GIỮ FILE NÀY CẨN THẬN!)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

```properties
# android/key.properties (KHÔNG commit lên git!)
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/Users/phong/upload-keystore.jks
```

```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2.2. Build APK vs AAB

```bash
# APK — cài trực tiếp (testing, sideload)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Split APK — nhỏ hơn, tách theo architecture
flutter build apk --split-per-abi --release
# Output:
#   app-armeabi-v7a-release.apk  (~15MB)
#   app-arm64-v8a-release.apk   (~16MB)
#   app-x86_64-release.apk      (~17MB)

# AAB — Google Play yêu cầu (Google tối ưu cho từng device)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 2.3. ProGuard Rules

```
# android/app/proguard-rules.pro
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Giữ lại model classes (nếu dùng reflection/serialization)
-keep class com.myapp.weather.models.** { *; }
```

---

## 3. Build iOS

### 3.1. Yêu cầu

```
□ macOS với Xcode (latest)
□ Apple Developer Account ($99/năm)
□ Provisioning Profile
□ Distribution Certificate
□ Đã test trên device thật
```

### 3.2. Xcode Configuration

```
1. Mở ios/Runner.xcworkspace trong Xcode
2. Runner → General:
   - Display Name: Weather App
   - Bundle Identifier: com.mycompany.weather
   - Version: 1.0.0
   - Build: 1
3. Signing & Capabilities:
   - Team: Chọn Apple Developer account
   - Signing Certificate: Distribution
   - Provisioning Profile: App Store
4. Deployment Info:
   - iOS 14.0+ (hoặc cao hơn)
   - Devices: iPhone, iPad
```

### 3.3. Build IPA

```bash
# Build iOS (không ký — cho CI/CD)
flutter build ios --release --no-codesign

# Build IPA (có ký — cho App Store)
flutter build ipa --release

# Output: build/ios/ipa/weather.ipa
```

### 3.4. Archive & Upload (qua Xcode)

```
1. Xcode → Product → Archive
2. Window → Organizer → chọn archive
3. Distribute App → App Store Connect
4. Upload
```

---

## 4. Tối Ưu Kích Thước App

### 4.1. Tree Shaking

```dart
// Flutter tự động tree-shake code không dùng
// Nhưng cần cẩn thận với:

// ❌ import tất cả
import 'package:flutter/material.dart';

// ✅ import cụ thể (giúp tree-shake tốt hơn)
import 'package:flutter/material.dart' show MaterialApp, Scaffold;
```

### 4.2. Deferred Loading (Lazy Load)

```dart
// Import với deferred — chỉ load khi cần
import 'package:heavy_package/heavy_package.dart' deferred as heavy;

Future<void> loadHeavyFeature() async {
  await heavy.loadLibrary();   // Load khi cần
  heavy.doSomething();
}
```

### 4.3. Giảm kích thước assets

```yaml
# Nén ảnh trước khi đặt vào assets/
# Dùng WebP thay PNG/JPEG
# Dùng vector (SVG) thay bitmap khi có thể

dependencies:
  flutter_svg: ^2.0.0   # Để render SVG
```

### 4.4. Kiểm tra kích thước

```bash
# Phân tích kích thước app
flutter build apk --analyze-size
flutter build ipa --analyze-size

# Output: Bảng chi tiết kích thước từng phần
```

---

## 5. Google Play Submission

### Checklist

```
1. Tạo Google Play Console account ($25 một lần)
2. Create App → nhập thông tin
3. Store listing:
   □ App icon (512x512 PNG)
   □ Feature graphic (1024x500)
   □ Screenshots (ít nhất 2, tối đa 8 cho mỗi loại device)
   □ Short description (80 ký tự)
   □ Full description (4000 ký tự)
   □ Danh mục
   □ Content rating
   □ Privacy policy URL
4. App content:
   □ Privacy policy
   □ Ads declaration
   □ Target audience
   □ Content rating questionnaire
5. Release:
   □ Upload AAB file
   □ Release notes
   □ Chọn countries
   □ Pricing (Free / Paid)
6. Review & Publish (2-7 ngày review)
```

---

## 6. App Store Submission (iOS)

### Checklist

```
1. Apple Developer account ($99/năm)
2. App Store Connect → New App
3. App Information:
   □ App name
   □ Bundle ID
   □ SKU
   □ Primary language
4. App Store listing:
   □ Screenshots:
     - iPhone 6.7" (1290x2796)
     - iPhone 6.5" (1284x2778)
     - iPad 12.9" (2048x2732, nếu hỗ trợ iPad)
   □ Description
   □ Keywords
   □ Support URL
   □ Marketing URL
   □ Privacy Policy URL
5. Build:
   □ Upload IPA qua Xcode / Transporter
   □ Chọn build
6. App Review Information:
   □ Contact info
   □ Demo account (nếu cần đăng nhập)
   □ Notes for reviewer
7. Submit for Review (1-3 ngày review)
```

### App Store Review Guidelines (Lưu ý)

```
Các lý do bị reject phổ biến:
❌ App crash hoặc bug nghiêm trọng
❌ Không giải thích tại sao cần permission
❌ UI không tương thích iPhone + iPad (nếu Universal)
❌ Thiếu Privacy Policy
❌ Giống web app quá nhiều (không có native feel)
❌ Placeholder content
❌ Không có tính năng hữu ích rõ ràng
```

---

## 7. Crashlytics & Analytics

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_crashlytics: ^4.0.0
  firebase_analytics: ^11.0.0
```

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Crashlytics — bắt crash tự động
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Bắt lỗi ngoài Flutter (async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Tắt Crashlytics trong debug mode
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  runApp(const MyApp());
}
```

---

## 8. Version Management

```yaml
# pubspec.yaml
# version: MAJOR.MINOR.PATCH+BUILD_NUMBER
# 1.0.0+1 → 1.0.1+2 → 1.1.0+3 → 2.0.0+4
version: 1.2.3+45
```

```bash
# Tự động tăng build number
# Thường làm trong CI/CD
flutter build apk --build-number=$GITHUB_RUN_NUMBER
```

---

## 9. OTA Update (Over-the-Air)

```yaml
# Shorebird — OTA update cho Flutter
# https://shorebird.dev
dependencies:
  shorebird_code_push: ^1.0.0
```

```bash
# Setup Shorebird
shorebird init

# Release
shorebird release android
shorebird release ios

# Push update (không cần qua Store review!)
shorebird patch android
shorebird patch ios
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Build APK
Build APK release cho app hiện tại. Cài trên device thật và kiểm tra.

### Bài 2: App Icon & Splash
Tạo app icon và splash screen custom cho app.

### Bài 3: Analyze Size
Chạy `--analyze-size` và tìm cách giảm kích thước app.

---

## 🎉 Chúc Mừng! Bạn Đã Hoàn Thành Lộ Trình!

```
Bạn đã học:
✅ Dart cơ bản → nâng cao
✅ Flutter widgets: Material + Cupertino + Custom
✅ Navigation & State Management
✅ API calls & WebView
✅ Platform Channels & Device Features
✅ Build & Deploy cho cả iOS & Android

Bước tiếp theo:
🚀 Xây dựng app thực tế!
🚀 Contribute open-source Flutter packages
🚀 Tham gia Flutter community
```

> **Quay lại mục lục**: [00 - Index](./00_index.md)
