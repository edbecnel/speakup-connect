// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appName => 'SpeakUp';

  @override
  String get splashDefaultTagline => 'Your voice. Our action.';

  @override
  String get splashGetStarted => 'Get Started';

  @override
  String get splashLearnMore => 'Learn More';

  @override
  String get commonLogin => 'Login';

  @override
  String get commonSignUp => 'Sign Up';

  @override
  String get commonOr => 'or';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonEmail => 'Email';

  @override
  String get authAcceptTermsSnackbar =>
      'Please accept the Terms & Privacy Policy';

  @override
  String get authSignInFailed => 'Sign in failed. Please try again.';

  @override
  String get authOrgFallbackName => 'Connect';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authGoogleSignInSoon => 'Google sign-in coming soon!';

  @override
  String get authTermsFooter =>
      'By continuing, you agree to our Terms and Privacy Policy.';

  @override
  String get authEmailOrStudentId => 'Email or student ID';

  @override
  String get authEmailOrStudentIdHint => 'you@school.edu or student ID';

  @override
  String get authPasswordHintLogin => 'Your password or student ID';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authEmailHint => 'you@school.edu';

  @override
  String get authPasswordHintRegister => 'At least 8 characters';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authAcceptTermsCheckbox => 'I accept the Terms & Privacy Policy';

  @override
  String get homeTitle => 'Home';

  @override
  String homeWelcome(String firstName) {
    return 'Welcome, $firstName!';
  }

  @override
  String get homeDefaultWelcomeMessage => 'How can we help make things better?';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeSubmitConcern => 'Submit\nConcern';

  @override
  String get homeMyReports => 'My Reports\n(Track Status)';

  @override
  String get homeAnnouncements => 'Announcements';

  @override
  String homeOrgInformation(String orgName) {
    return '$orgName\nInformation';
  }

  @override
  String get homeOrgFallback => 'Org';

  @override
  String get homeOrgInfoComingSoon => 'Organization Info — Coming Soon';

  @override
  String get homeNavMyReports => 'My Reports';

  @override
  String get homeNavAlerts => 'Alerts';

  @override
  String get homeNavProfile => 'Profile';

  @override
  String get homeGroupsTitle => 'My Groups & Clubs';

  @override
  String get homeGroupsSeeAll => 'See all';

  @override
  String homeGroupsSeeAllCount(int count) {
    return 'See all ($count)';
  }

  @override
  String get homeGroupsView => 'View';

  @override
  String get homeGroupsLoadError =>
      'Could not load your groups. Tap See all to retry.';

  @override
  String get homeGroupsNone => 'No groups yet';

  @override
  String homeGroupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get homeGroupsEmptyMessage =>
      'You are not in any groups yet. Tap View for details.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAnonymous => 'Anonymous';

  @override
  String get settingsOrgUnavailable => '—';

  @override
  String settingsPhotoUpdateFailed(String message) {
    return 'Could not update photo: $message';
  }

  @override
  String get settingsUnknownError => 'Unknown error';

  @override
  String get settingsPersonalPhotosDisabled =>
      'Personal profile photos are not enabled. Ask an administrator to turn on \"Allow personal profile photos\" under Organization Settings.';

  @override
  String get settingsPersonalPhotoUpdated => 'Personal profile photo updated';

  @override
  String get settingsPersonalPhotoRemoved =>
      'Personal photo removed — showing school photo';

  @override
  String settingsSpeakUpOrg(String orgName) {
    return 'SpeakUp $orgName';
  }

  @override
  String get settingsTapPhotoChange =>
      'Tap your photo to change your personal badge';

  @override
  String get settingsSchoolPhotoOnFile =>
      'School photo on file — ask an admin to enable personal uploads';

  @override
  String get settingsPersonalUploadsRequireApproval =>
      'Tap your photo — personal uploads require admin approval';

  @override
  String get settingsSectionGroups => 'Groups & Clubs';

  @override
  String get settingsMyGroups => 'My Groups & Clubs';

  @override
  String settingsPendingMembershipRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending membership requests',
      one: '1 pending membership request',
    );
    return '$_temp0';
  }

  @override
  String get settingsGroupsSubtitle => 'Clubs and organizations you belong to';

  @override
  String get settingsBrowseGroups => 'Browse Groups & Clubs';

  @override
  String get settingsBrowseGroupsSubtitle =>
      'Discover clubs and request to join';

  @override
  String get settingsSentGroupAlerts => 'Sent Group Alerts';

  @override
  String get settingsMyBroadcasts => 'My Broadcasts';

  @override
  String get settingsSentGroupAlertsSubtitle =>
      'View alerts you sent and member responses';

  @override
  String get settingsMyBroadcastsSubtitle =>
      'Manage sent reminders and view responses';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsNotificationPreferences => 'Notification Preferences';

  @override
  String get settingsNotificationsComingSoon => 'Notifications — coming soon';

  @override
  String get settingsSectionHelp => 'Help & Support';

  @override
  String get settingsHelpCenter => 'Help Center';

  @override
  String get settingsHelpCenterSubtitle =>
      'Guides for members and administrators';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String settingsAboutApp(String appName) {
    return 'About $appName';
  }

  @override
  String get settingsAboutLegalese => '© 2026 SpeakUp Connect';

  @override
  String get settingsSectionAdmin => 'Administration';

  @override
  String get settingsAdminDashboard => 'Admin Dashboard';

  @override
  String get settingsAdminDashboardSubtitle =>
      'Review and manage submitted reports';

  @override
  String get settingsAdminGroups => 'Groups & Clubs';

  @override
  String get settingsAdminGroupsSubtitle =>
      'Create groups and manage member rosters';

  @override
  String get settingsJoinApplications => 'Join Applications';

  @override
  String get settingsJoinApplicationsSubtitle => 'Approve new member sign-ups';

  @override
  String get settingsPendingApprovals => 'Pending Approvals';

  @override
  String get settingsPendingApprovalsSubtitle =>
      'Review announcements and group alerts awaiting publish';

  @override
  String get settingsMemberManagement => 'Member Management';

  @override
  String get settingsMemberManagementSubtitle =>
      'View, block, unenroll, unblock, or re-enroll members';

  @override
  String get settingsStudentRoster => 'Student Roster';

  @override
  String get settingsStudentRosterSubtitle =>
      'Add students, assign grades individually or in bulk';

  @override
  String get settingsSchoolGrades => 'School Grades';

  @override
  String get settingsSchoolGradesSubtitle =>
      'Define which grade levels your school uses';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageCebuano => 'Bisaya / Cebuano';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpHubHeadline => 'Guides for using SpeakUp Connect';

  @override
  String helpHubDescription(String orgName, String adminNote) {
    return 'Guides for $orgName. ${adminNote}Content is specific to how this organization is set up.';
  }

  @override
  String get helpHubAdminNote =>
      'Includes administration topics for your role. ';

  @override
  String get helpOrgFallback => 'your organization';

  @override
  String get helpMemberGuideTitle => 'Member Guide';

  @override
  String get helpMemberGuideSubtitle =>
      'Sign in, submit reports, and use alerts';

  @override
  String get helpAdminGuideTitle => 'Administrator Guide';

  @override
  String get helpAdminGuideSubtitle => 'Roster, groups, reports, and reminders';

  @override
  String get helpGuideNotFound => 'This guide could not be found.';

  @override
  String get helpAdminAccessDenied =>
      'You do not have access to this administrator guide.';

  @override
  String get helpLoadFailed => 'Could not load guide for your organization.';

  @override
  String helpLoadFailedDetail(String error) {
    return 'Could not load guide for your organization.\n$error';
  }
}
