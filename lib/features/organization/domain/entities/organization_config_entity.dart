import 'package:speakup_connect/core/theme/app_colors.dart';

/// Default grade levels for Philippine high schools when none are configured.
const kDefaultSchoolGradeLevels = [7, 8, 9, 10, 11, 12];

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
    this.requireReminderApproval = false,
    this.allowMemberProfilePhotos = false,
    this.gradeLevels,
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

  /// When true, members with `broadcastReminders` (but not `approveReminders`)
  /// must submit reminders for review — they are saved as `pending` instead of
  /// being published directly. Approvers act on them in the Approval Queue.
  final bool requireReminderApproval;

  /// When true, members may upload a personal profile badge in Settings.
  ///
  /// Does not affect [officialPhotoUrl] on their profile — the school photo
  /// remains an admin-only permanent record. Personal [avatarUrl] is stored
  /// separately and only affects what the member sees in the app UI.
  final bool allowMemberProfilePhotos;

  /// Grade levels offered by this school (e.g. [7, 8, 9, 10, 11, 12]).
  ///
  /// Only meaningful for [supportsStudentGrades] org types. Municipalities,
  /// NGOs, and other non-school clients do not use this field.
  final List<int>? gradeLevels;

  /// Whether this org uses student grade levels (schools and universities).
  bool get supportsStudentGrades =>
      type == OrganizationType.school || type == OrganizationType.university;

  /// Configured grade levels for school orgs, or an empty list otherwise.
  List<int> get effectiveGradeLevels {
    if (!supportsStudentGrades) return const [];
    final configured = gradeLevels;
    if (configured == null || configured.isEmpty) {
      return List<int>.from(kDefaultSchoolGradeLevels);
    }
    return List<int>.from(configured)..sort();
  }

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

  /// Admin-facing label for organization settings UI.
  String get adminDisplayName => switch (this) {
        OrganizationType.school => 'School',
        OrganizationType.university => 'University',
        OrganizationType.lgu => 'Municipality / LGU',
        OrganizationType.ngo => 'NGO',
        OrganizationType.church => 'Church',
        OrganizationType.corporation => 'Corporation',
        OrganizationType.other => 'Other',
      };

  /// Short note shown when selecting this type in admin settings.
  String get adminDescription => switch (this) {
        OrganizationType.school ||
        OrganizationType.university =>
          'Enables student grades, roster, and class-based features.',
        OrganizationType.lgu =>
          'For municipalities, barangays, and local government units.',
        OrganizationType.ngo => 'For non-profit and community organizations.',
        OrganizationType.church => 'For churches and faith-based communities.',
        OrganizationType.corporation =>
          'For companies and workplace communities.',
        OrganizationType.other => 'Generic organization without type-specific features.',
      };

  static OrganizationType fromValue(String value) {
    return OrganizationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrganizationType.other,
    );
  }
}
