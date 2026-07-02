/// Barrel export của tầng core.
///
/// Feature chỉ cần `import 'package:weather/core/core.dart';` là có đủ
/// constants, theme, error handling, network và shared widgets.
library;

export 'constants/app_constants.dart';
export 'error/failure.dart';
export 'error/result.dart';
export 'network/api_client.dart';
export 'network/api_exception.dart';
export 'providers/core_providers.dart';
export 'router/app_router.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';
export 'utils/logger.dart';
export 'widgets/app_error_view.dart';
export 'widgets/app_loading.dart';
export 'widgets/env_banner.dart';
