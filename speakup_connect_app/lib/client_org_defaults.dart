import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Compile-time organization branding for a client store build.
///
/// Baked into the APK/IPA so splash, login, and offline startup show the
/// correct school identity before Firestore is reachable. Firestore remains
/// the runtime source of truth once the user is signed in.
class ClientOrgDefaults {
  const ClientOrgDefaults({
    required this.displayName,
    required this.type,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    this.reportCodePrefix,
  });

  final String displayName;
  final OrganizationType type;
  final String primaryColorHex;
  final String secondaryColorHex;

  /// Defaults to [displayName] when omitted.
  final String? reportCodePrefix;

  OrgThemeColors get themeColors => OrgThemeColors(
        primary: OrgThemeColors.fromHex(primaryColorHex),
        secondary: OrgThemeColors.fromHex(secondaryColorHex),
      );

  String get effectiveReportCodePrefix => reportCodePrefix ?? displayName;
}
