#!/usr/bin/env bash
# Chạy app ở môi trường STAGING.
set -e
flutter run --flavor staging -t lib/main_staging.dart "$@"
