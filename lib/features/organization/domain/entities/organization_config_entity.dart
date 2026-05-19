import 'package:speakup_connect/core/theme/app_colors.dart';

/// Domain entity representing an organization's configuration.
///
/// This is the runtime representation of what's stored in:
/// `organizations/{organizationId}` in Firestore.
///
/// All user-facing display is driven from this config — the app
/// has no hard-coded organization names, colors, or branding.
class OrganizationConfigEntity {
  const OrganizationConfigEntity({
    required this.organizationId,
    required this.displayName,
    required this.type,
    required this.themeColors,
    required this.allowAnonymousReports,
    required this.reportCodePrefix,
    this.logoUrl,
    this.tagline,
    this.welcomeMessage,
    this.country = 'PH',
    this.isActive = true,
  });

  /// Unique identifier for this organization (e.g., 'monhs-ph-001').
  final String organizationId;

  /// Human-readable display name (e.g., 'Misamis Oriental National High School').
  final String displayName;

  /// Short display name used in the app header (e.g., 'MONHS').
  /// The full splash screen title is rendered as "SpeakUp {displayName}".

  /// Organization type.
  final OrganizationType type;

  /// Theme colors loaded from Firestore and applied to the MaterialApp.
  final OrgThemeColors themeColors;

  /// Whether this organization allows anonymous report submissions.
  final bool allowAnonymousReports;

  /// Short code used in report reference numbers (e.g., 'MONHS').
  final String reportCodePrefix;

  /// URL to the organization's logo image (Firebase Storage URL).
  final String? logoUrl;

  /// Custom tagline displayed on the splash screen.
  /// Defaults to 'Your voice. Our action.' if null.
  final String? tagline;

  /// Welcome message shown on the home dashboard.
  final String? welcomeMessage;

  /// ISO country code.
  final String country;

  /// Whether the organization's account is active.
  final bool isActive;

  /// The effective tagline, with a sensible default.
  String get effectiveTagline =>
      tagline ?? 'Your voice. Our action. A better community for all.';

  /// The effective welcome message with a sensible default.
  String get effectiveWelcomeMessage =>
      welcomeMessage ?? 'How can we help make our ${type.label} better?';

  /// The full app title as shown on splash screen (e.g., "SpeakUp MONHS").
  String get appTitle => 'SpeakUp $displayName';
}

/// Represents the type of organization using the platform.
enum OrganizationType {
  school('school', 'school'),
  university('university', 'university'),
  lgu('lgu', 'community'),
  ngo('ngo', 'organization'),
  church('church', 'church'),
  corporation('corporation', 'workplace'),
  other('other', 'organization');

  const OrganizationType(this.value, this.label);

  final String value;
  final String label;

  static OrganizationType fromValue(String value) {
    return OrganizationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrganizationType.other,
    );
  }
}
