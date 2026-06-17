/// Environment configuration selector.
///
/// The active environment is set at compile time via `--dart-define`:
///   flutter run --dart-define=ENVIRONMENT=development
///   flutter run --dart-define=ENVIRONMENT=staging
///   flutter run --dart-define=ENVIRONMENT=production
///
/// If no ENVIRONMENT is provided, defaults to 'development'.
abstract class EnvConfig {
  static const String _env = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => _env == 'development';
  static bool get isStaging => _env == 'staging';
  static bool get isProduction => _env == 'production';

  /// Whether to use Firebase Emulator Suite (dev only).
  static bool get useEmulators => isDevelopment;

  /// Firebase Emulator host (when [useEmulators] is true).
  static const String emulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  static const int authEmulatorPort = 9099;
  static const int storageEmulatorPort = 9199;

  /// Whether to show verbose logging.
  static bool get enableLogging => !isProduction;

  /// Whether to show the debug banner in the app.
  static bool get showDebugBanner => isDevelopment;

  static String get environmentLabel {
    if (isDevelopment) return 'DEV';
    if (isStaging) return 'STAGING';
    return '';
  }
}
