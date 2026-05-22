import 'package:speakup_connect/core/theme/app_colors.dart';

/// Compile-time application configuration.
///
/// Values here are environment-independent. Environment-specific
/// values (Firebase project IDs, API keys) live in [EnvConfig].
abstract class AppConfig {
  static const String appName = 'SpeakUp Connect';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// The organization ID to load when no deep-link org is specified.
  /// Set this to the client's Firestore document ID before building
  /// for a specific deployment.
  ///
  /// In a full multi-tenant deployment, this is determined by:
  /// 1. A deep link / dynamic link containing the org ID
  /// 2. A stored preference from last session
  /// 3. An organization selection screen
  static const String defaultOrganizationId = 'monhs-ph-001';

  /// Short human-readable name for the client organisation.
  /// Shown on the splash screen and used as the offline display-name
  /// fallback before Firestore config loads.
  /// Change this for each client deployment.
  static const String clientDisplayName = 'MONHS';

  /// Default fallback theme colors used before org config loads.
  static const OrgThemeColors defaultThemeColors = OrgThemeColors(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  );
}
