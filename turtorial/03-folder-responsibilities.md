# Trach nhiem tung folder Flutter

## Thu muc goc

- `.dart_tool/`: file sinh tu dong.
- `.idea/`: cau hinh IDE.
- `build/`: artifact build.
- `.env`: bien moi truong (khong commit secret).
- `pubspec.yaml`: dependency, assets, environment.
- `pubspec.lock`: khoa version package.
- `analysis_options.yaml`: lint/analyzer rules.

## `lib/`

- `lib/main.dart`: entrypoint (`runApp`).
- `lib/app.dart`: app shell (`MaterialApp`, theme, router).
- `lib/core/`: thanh phan dung chung.
- `lib/features/`: chia theo nghiep vu (weather/auth/...).

## Nen tang native

- `android/`: Gradle, manifest, build Android.
- `ios/`: Xcode, plist, capability iOS.
- `web/`: ho tro Flutter Web.
- `windows/`, `macos/`, `linux/`: desktop support.
