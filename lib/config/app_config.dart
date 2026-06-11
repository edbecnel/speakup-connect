import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/flavor_config.dart';

/// Compile-time application configuration.
///
/// Values here are environment-independent. Environment-specific
/// values (Firebase project IDs, API keys) live in [EnvConfig].
///
/// Client-specific display name and default org come from [FlavorConfig],
/// set in each entry point (`main.dart`, `main_standard.dart`, etc.).
abstract class AppConfig {
  /// Launcher / window title for this binary (e.g. "Speakup MONHS").
  static String get appName => FlavorConfig.instance.appDisplayName;

  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// The organization ID to load when no deep-link org is specified.
  /// Client builds set this via [FlavorConfig]; the standard app leaves it
  /// null until the user picks or joins an org.
  static String get defaultOrganizationId =>
      FlavorConfig.instance.orgId ?? '';

  /// Short human-readable name for the client organisation.
  /// Shown on the splash screen and used as the offline display-name
  /// fallback before Firestore config loads.
  static String get clientDisplayName {
    final baked = FlavorConfig.instance.orgDefaults?.displayName;
    if (baked != null) return baked;

    final name = FlavorConfig.instance.appDisplayName;
    if (name.startsWith('Speakup ')) {
      return name.substring('Speakup '.length);
    }
    return 'Connect';
  }

  /// Default fallback theme colors used before org config loads.
  static OrgThemeColors get defaultThemeColors {
    final baked = FlavorConfig.instance.orgDefaults?.themeColors;
    if (baked != null) return baked;

    return const OrgThemeColors(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );
  }
}
