import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/app.dart';
import 'package:weather/bootstrap.dart';
import 'package:weather/config/app_config.dart';

/// Entry point môi trường DEV.
///
/// Chạy: `flutter run --flavor dev -t lib/main_dev.dart`
void main() {
  bootstrap(Environment.dev);
  runApp(const ProviderScope(child: App()));
}
