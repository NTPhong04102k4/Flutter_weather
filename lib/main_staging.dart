import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/app.dart';
import 'package:weather/bootstrap.dart';
import 'package:weather/config/app_config.dart';

/// Entry point môi trường STAGING.
///
/// Chạy: `flutter run --flavor staging -t lib/main_staging.dart`
void main() {
  bootstrap(Environment.staging);
  runApp(const ProviderScope(child: App()));
}
