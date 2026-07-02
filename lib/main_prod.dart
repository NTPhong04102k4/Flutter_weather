import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'config/app_config.dart';

/// Entry point môi trường PROD.
///
/// Chạy: `flutter run --flavor prod -t lib/main_prod.dart`
void main() {
  bootstrap(Environment.prod);
  runApp(const ProviderScope(child: App()));
}
