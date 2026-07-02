#!/usr/bin/env bash
# Chạy app ở môi trường DEV.
set -e
flutter run --flavor dev -t lib/main_dev.dart "$@"
