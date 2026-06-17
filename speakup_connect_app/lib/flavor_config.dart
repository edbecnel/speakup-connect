import 'package:speakup_connect/client_org_defaults.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Compile-time flavor identity set at app startup.
///
/// Each client entry point (`main.dart` for MONHS, `main_standard.dart` for the
/// generic app) configures [instance] before calling [mainCommon]. The rest of
/// the app reads the display name and default org from here.
///
/// Per-school store listings use a separate entry point + native app name
/// (Android `resValue` / iOS `CFBundleDisplayName`) — see `docs/CLIENT_BUILDS.md`.
enum AppFlavor { standard, monhs }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.appDisplayName,
    this.orgId,
    this.orgDefaults,
  });

  static FlavorConfig _instance = FlavorConfig.standard();

  static FlavorConfig get instance => _instance;
  static set instance(FlavorConfig config) => _instance = config;

  final AppFlavor flavor;

  /// Launcher / task-switcher name for this binary (e.g. "Speakup MONHS").
  final String appDisplayName;

  /// When set, skip org selection and pre-load this org on first launch.
  final String? orgId;

  /// Branding shown on first launch before Firestore loads (client builds only).
  final ClientOrgDefaults? orgDefaults;

  bool get isStandard => flavor == AppFlavor.standard;
  bool get isClientBuild => !isStandard;
  bool get hasBakedOrgDefaults => orgDefaults != null;

  static FlavorConfig standard() => FlavorConfig._(
        flavor: AppFlavor.standard,
        appDisplayName: 'Speakup Connect',
        orgId: null,
      );

  static FlavorConfig monhs() => FlavorConfig._(
        flavor: AppFlavor.monhs,
        appDisplayName: 'Speakup MONHS',
        orgId: 'monhs-ph-001',
        orgDefaults: const ClientOrgDefaults(
          displayName: 'MONHS',
          type: OrganizationType.school,
          primaryColorHex: '#CE1126',
          secondaryColorHex: '#111111',
          reportCodePrefix: 'MONHS',
        ),
      );
}
