# 📘 Bài 19: Phân Chia Môi Trường Dev / Staging / Prod

> **Mục tiêu**: Cấu hình nhiều môi trường, Flavors, .env files, và CI/CD cơ bản.

---

## 1. Tại Sao Cần Phân Chia Môi Trường?

```
Dev (Development):
├── API: http://localhost:3000
├── Debug mode ON
├── Fake data / Mock API
└── Logs chi tiết

Staging (Pre-production):
├── API: https://staging-api.myapp.com
├── Debug mode ON
├── Data thật (test server)
└── Kiểm tra trước khi release

Production:
├── API: https://api.myapp.com
├── Debug mode OFF
├── Data thật (live server)
└── Logs tối thiểu
```

---

## 2. Cách 1: `--dart-define` (Đơn giản nhất)

```bash
# Truyền biến qua command line
flutter run --dart-define=ENV=dev --dart-define=API_URL=http://localhost:3000
flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging-api.myapp.com
flutter run --dart-define=ENV=prod --dart-define=API_URL=https://api.myapp.com
```

```dart
// Đọc trong code
class AppConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static bool get isDev => env == 'dev';
  static bool get isStaging => env == 'staging';
  static bool get isProd => env == 'prod';
}

void main() {
  print('Environment: ${AppConfig.env}');
  print('API URL: ${AppConfig.apiUrl}');

  if (AppConfig.isDev) {
    // Bật debug tools
  }

  runApp(const MyApp());
}
```

### `--dart-define-from-file` (Gọn hơn)

```json
// config/dev.json
{
  "ENV": "dev",
  "API_URL": "http://localhost:3000",
  "API_KEY": "dev_key_123",
  "ENABLE_LOGGING": true
}
```

```json
// config/prod.json
{
  "ENV": "prod",
  "API_URL": "https://api.myapp.com",
  "API_KEY": "prod_key_secret",
  "ENABLE_LOGGING": false
}
```

```bash
flutter run --dart-define-from-file=config/dev.json
flutter build apk --dart-define-from-file=config/prod.json
```

---

## 3. Cách 2: `.env` files với `flutter_dotenv`

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```bash
# .env.dev
API_URL=http://localhost:3000
API_KEY=dev_key_123
DEBUG=true

# .env.staging
API_URL=https://staging-api.myapp.com
API_KEY=staging_key_456
DEBUG=true

# .env.prod
API_URL=https://api.myapp.com
API_KEY=prod_key_secret
DEBUG=false
```

```yaml
# pubspec.yaml — khai báo assets
flutter:
  assets:
    - .env.dev
    - .env.staging
    - .env.prod
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Load file .env tương ứng
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$env');

  print('API URL: ${dotenv.env['API_URL']}');
  print('API Key: ${dotenv.env['API_KEY']}');

  runApp(const MyApp());
}

// Sử dụng
class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';
}
```

```bash
flutter run --dart-define=ENV=dev
flutter run --dart-define=ENV=staging
flutter build apk --dart-define=ENV=prod
```

> ⚠️ **Quan trọng**: KHÔNG bao giờ commit file `.env.prod` chứa secret keys! Thêm vào `.gitignore`.

---

## 4. Cách 3: Flavors (Android) + Schemes (iOS)

### Android Flavors

```groovy
// android/app/build.gradle
android {
    flavorDimensions "environment"

    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "MyApp Dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "MyApp Staging"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "MyApp"
        }
    }
}
```

### iOS Schemes

```
1. Xcode → Product → Scheme → Manage Schemes
2. Duplicate scheme cho mỗi environment
3. Tạo xcconfig files:
   - ios/Flutter/Dev.xcconfig
   - ios/Flutter/Staging.xcconfig
   - ios/Flutter/Prod.xcconfig
4. Set Bundle Identifier khác nhau cho mỗi scheme
```

### Chạy với Flavor

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart

flutter build apk --flavor prod -t lib/main_prod.dart
flutter build ipa --flavor prod -t lib/main_prod.dart
```

### Entry points cho mỗi môi trường

```dart
// lib/main_dev.dart
import 'package:weather/app.dart';
import 'package:weather/config/app_config.dart';

void main() {
  AppConfig.init(
    env: Environment.dev,
    apiUrl: 'http://localhost:3000',
  );
  runApp(const MyApp());
}

// lib/main_staging.dart
void main() {
  AppConfig.init(
    env: Environment.staging,
    apiUrl: 'https://staging-api.myapp.com',
  );
  runApp(const MyApp());
}

// lib/main_prod.dart
void main() {
  AppConfig.init(
    env: Environment.prod,
    apiUrl: 'https://api.myapp.com',
  );
  runApp(const MyApp());
}

// lib/config/app_config.dart
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment env;
  static late String apiUrl;
  static bool get isDev => env == Environment.dev;
  static bool get isProd => env == Environment.prod;

  static void init({required Environment env, required String apiUrl}) {
    AppConfig.env = env;
    AppConfig.apiUrl = apiUrl;
  }
}
```

---

## 5. Firebase Multi-Environment

```
Project Firebase:
├── myapp-dev      → google-services-dev.json (Android)
│                    GoogleService-Info-dev.plist (iOS)
├── myapp-staging  → google-services-staging.json
└── myapp-prod     → google-services-prod.json

Dùng Flavors/Schemes để chọn file config tương ứng.
```

---

## 6. CI/CD Cơ Bản — GitHub Actions

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - run: flutter pub get
      - run: flutter build apk --release --dart-define-from-file=config/prod.json

      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

---

## 7. Script Tự Động

```bash
# scripts/run_dev.sh
#!/bin/bash
flutter run --flavor dev --dart-define-from-file=config/dev.json -t lib/main_dev.dart

# scripts/build_prod.sh
#!/bin/bash
echo "🏗️ Building production..."
flutter clean
flutter pub get
flutter build apk --release --flavor prod --dart-define-from-file=config/prod.json -t lib/main_prod.dart
flutter build ipa --release --flavor prod --dart-define-from-file=config/prod.json -t lib/main_prod.dart
echo "✅ Build hoàn tất!"
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Multi-environment Config
Tạo 3 file config (dev/staging/prod) với `--dart-define-from-file`. Hiển thị banner "DEV" / "STAGING" trên app khi không phải production.

### Bài 2: Flavor Setup
Cấu hình Android Flavors cho app hiện tại. Mỗi flavor có app name và app icon khác nhau.

### Bài 3: GitHub Actions
Tạo workflow CI: chạy test tự động mỗi khi push code.

---

> **Bài tiếp theo**: [20 - Build & Triển khai sản phẩm](./20_flutter_build_and_deploy.md)
