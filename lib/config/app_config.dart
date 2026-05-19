import 'package:speakup_connect/core/theme/app_colors.dart';

/// Compile-time application configuration.
///
/// Values here are environment-independent. Environment-specific
/// values (Firebase project IDs, API keys) live in [EnvConfig].
abstract class AppConfig {
  static const String appName = 'SpeakUp Connect';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// The default organization ID loaded when no deep-link org is specified.
  /// This is the MONHS pilot organization. Change this before deploying
  /// for other organizations.
  ///
  /// In a full multi-tenant deployment, this is determined by:
  /// 1. A deep link / dynamic link containing the org ID
  /// 2. A stored preference from last session
  /// 3. An organization selection screen
  static const String defaultOrganizationId = 'monhs-ph-001';

  /// Default fallback theme colors used before org config loads.
  static const OrgThemeColors defaultThemeColors = OrgThemeColors(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  );
}
