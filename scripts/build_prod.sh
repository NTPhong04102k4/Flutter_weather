#!/usr/bin/env bash
# Build bản release PROD (Android APK + iOS, bỏ --no-codesign nếu đã ký).
set -e

echo "🧹 Dọn build cũ..."
flutter clean
flutter pub get

echo "🤖 Build Android APK (prod)..."
flutter build apk --release --flavor prod -t lib/main_prod.dart

# Bỏ comment nếu build trên macOS có Xcode:
# echo "🍎 Build iOS (prod)..."
# flutter build ipa --release --flavor prod -t lib/main_prod.dart

echo "✅ Build prod hoàn tất!"
