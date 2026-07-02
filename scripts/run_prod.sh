#!/usr/bin/env bash
# Chạy app ở môi trường PROD.
set -e
flutter run --flavor prod -t lib/main_prod.dart "$@"
