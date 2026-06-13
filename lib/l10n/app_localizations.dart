import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en')
  ];

  /// Product name shown in splash title and about dialogs.
  ///
  /// In en, this message translates to:
  /// **'SpeakUp'**
  String get appName;

  /// No description provided for @splashDefaultTagline.
  ///
  /// In en, this message translates to:
  /// **'Your voice. Our action.'**
  String get splashDefaultTagline;

  /// No description provided for @splashGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get splashGetStarted;

  /// No description provided for @splashLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get splashLearnMore;

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get commonLogin;

  /// No description provided for @commonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get commonSignUp;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @authAcceptTermsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Privacy Policy'**
  String get authAcceptTermsSnackbar;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get authSignInFailed;

  /// No description provided for @authOrgFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get authOrgFallbackName;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authGoogleSignInSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in coming soon!'**
  String get authGoogleSignInSoon;

  /// No description provided for @authTermsFooter.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms and Privacy Policy.'**
  String get authTermsFooter;

  /// No description provided for @authEmailOrStudentId.
  ///
  /// In en, this message translates to:
  /// **'Email or student ID'**
  String get authEmailOrStudentId;

  /// No description provided for @authEmailOrStudentIdHint.
  ///
  /// In en, this message translates to:
  /// **'you@school.edu or student ID'**
  String get authEmailOrStudentIdHint;

  /// No description provided for @authPasswordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Your password or student ID'**
  String get authPasswordHintLogin;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@school.edu'**
  String get authEmailHint;

  /// No description provided for @authPasswordHintRegister.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHintRegister;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authAcceptTermsCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms & Privacy Policy'**
  String get authAcceptTermsCheckbox;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {firstName}!'**
  String homeWelcome(String firstName);

  /// No description provided for @homeDefaultWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'How can we help make things better?'**
  String get homeDefaultWelcomeMessage;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeSubmitConcern.
  ///
  /// In en, this message translates to:
  /// **'Submit\nConcern'**
  String get homeSubmitConcern;

  /// No description provided for @homeMyReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports\n(Track Status)'**
  String get homeMyReports;

  /// No description provided for @homeAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get homeAnnouncements;

  /// No description provided for @homeOrgInformation.
  ///
  /// In en, this message translates to:
  /// **'{orgName}\nInformation'**
  String homeOrgInformation(String orgName);

  /// No description provided for @homeOrgFallback.
  ///
  /// In en, this message translates to:
  /// **'Org'**
  String get homeOrgFallback;

  /// No description provided for @homeOrgInfoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Organization Info — Coming Soon'**
  String get homeOrgInfoComingSoon;

  /// No description provided for @homeNavMyReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get homeNavMyReports;

  /// No description provided for @homeNavAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get homeNavAlerts;

  /// No description provided for @homeNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeNavProfile;

  /// No description provided for @homeGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Groups & Clubs'**
  String get homeGroupsTitle;

  /// No description provided for @homeGroupsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeGroupsSeeAll;

  /// No description provided for @homeGroupsSeeAllCount.
  ///
  /// In en, this message translates to:
  /// **'See all ({count})'**
  String homeGroupsSeeAllCount(int count);

  /// No description provided for @homeGroupsView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get homeGroupsView;

  /// No description provided for @homeGroupsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your groups. Tap See all to retry.'**
  String get homeGroupsLoadError;

  /// No description provided for @homeGroupsNone.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get homeGroupsNone;

  /// No description provided for @homeGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String homeGroupsCount(int count);

  /// No description provided for @homeGroupsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not in any groups yet. Tap View for details.'**
  String get homeGroupsEmptyMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get settingsAnonymous;

  /// No description provided for @settingsOrgUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get settingsOrgUnavailable;

  /// No description provided for @settingsPhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update photo: {message}'**
  String settingsPhotoUpdateFailed(String message);

  /// No description provided for @settingsUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get settingsUnknownError;

  /// No description provided for @settingsPersonalPhotosDisabled.
  ///
  /// In en, this message translates to:
  /// **'Personal profile photos are not enabled. Ask an administrator to turn on \"Allow personal profile photos\" under Organization Settings.'**
  String get settingsPersonalPhotosDisabled;

  /// No description provided for @settingsPersonalPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Personal profile photo updated'**
  String get settingsPersonalPhotoUpdated;

  /// No description provided for @settingsPersonalPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Personal photo removed — showing school photo'**
  String get settingsPersonalPhotoRemoved;

  /// No description provided for @settingsSpeakUpOrg.
  ///
  /// In en, this message translates to:
  /// **'SpeakUp {orgName}'**
  String settingsSpeakUpOrg(String orgName);

  /// No description provided for @settingsTapPhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Tap your photo to change your personal badge'**
  String get settingsTapPhotoChange;

  /// No description provided for @settingsSchoolPhotoOnFile.
  ///
  /// In en, this message translates to:
  /// **'School photo on file — ask an admin to enable personal uploads'**
  String get settingsSchoolPhotoOnFile;

  /// No description provided for @settingsPersonalUploadsRequireApproval.
  ///
  /// In en, this message translates to:
  /// **'Tap your photo — personal uploads require admin approval'**
  String get settingsPersonalUploadsRequireApproval;

  /// No description provided for @settingsSectionGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups & Clubs'**
  String get settingsSectionGroups;

  /// No description provided for @settingsMyGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups & Clubs'**
  String get settingsMyGroups;

  /// No description provided for @settingsPendingMembershipRequests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pending membership request} other{{count} pending membership requests}}'**
  String settingsPendingMembershipRequests(int count);

  /// No description provided for @settingsGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clubs and organizations you belong to'**
  String get settingsGroupsSubtitle;

  /// No description provided for @settingsBrowseGroups.
  ///
  /// In en, this message translates to:
  /// **'Browse Groups & Clubs'**
  String get settingsBrowseGroups;

  /// No description provided for @settingsBrowseGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover clubs and request to join'**
  String get settingsBrowseGroupsSubtitle;

  /// No description provided for @settingsSentGroupAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sent Group Alerts'**
  String get settingsSentGroupAlerts;

  /// No description provided for @settingsMyBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'My Broadcasts'**
  String get settingsMyBroadcasts;

  /// No description provided for @settingsSentGroupAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View alerts you sent and member responses'**
  String get settingsSentGroupAlertsSubtitle;

  /// No description provided for @settingsMyBroadcastsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage sent reminders and view responses'**
  String get settingsMyBroadcastsSubtitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsMemberSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your student ID or contact email and your password.'**
  String get settingsMemberSignInHint;

  /// No description provided for @settingsNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get settingsNotificationPreferences;

  /// No description provided for @settingsNotificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications — coming soon'**
  String get settingsNotificationsComingSoon;

  /// No description provided for @settingsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsSectionHelp;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guides for members and administrators'**
  String get settingsHelpCenterSubtitle;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String settingsAboutApp(String appName);

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2026 SpeakUp Connect'**
  String get settingsAboutLegalese;

  /// No description provided for @settingsSectionAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get settingsSectionAdmin;

  /// No description provided for @settingsAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get settingsAdminDashboard;

  /// No description provided for @settingsAdminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and manage submitted reports'**
  String get settingsAdminDashboardSubtitle;

  /// No description provided for @settingsAdminGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups & Clubs'**
  String get settingsAdminGroups;

  /// No description provided for @settingsAdminGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create groups and manage member rosters'**
  String get settingsAdminGroupsSubtitle;

  /// No description provided for @settingsJoinApplications.
  ///
  /// In en, this message translates to:
  /// **'Join Applications'**
  String get settingsJoinApplications;

  /// No description provided for @settingsJoinApplicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve new member sign-ups'**
  String get settingsJoinApplicationsSubtitle;

  /// No description provided for @settingsPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get settingsPendingApprovals;

  /// No description provided for @settingsPendingApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review announcements and group alerts awaiting publish'**
  String get settingsPendingApprovalsSubtitle;

  /// No description provided for @settingsMemberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get settingsMemberManagement;

  /// No description provided for @settingsMemberManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View, block, unenroll, unblock, or re-enroll members'**
  String get settingsMemberManagementSubtitle;

  /// No description provided for @settingsStudentRoster.
  ///
  /// In en, this message translates to:
  /// **'Student Roster'**
  String get settingsStudentRoster;

  /// No description provided for @settingsStudentRosterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add students, assign grades individually or in bulk'**
  String get settingsStudentRosterSubtitle;

  /// No description provided for @settingsSchoolGrades.
  ///
  /// In en, this message translates to:
  /// **'School Grades'**
  String get settingsSchoolGrades;

  /// No description provided for @settingsSchoolGradesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define which grade levels your school uses'**
  String get settingsSchoolGradesSubtitle;

  /// No description provided for @settingsTranslations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get settingsTranslations;

  /// No description provided for @settingsTranslationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit UI strings for your organization\'s languages'**
  String get settingsTranslationsSubtitle;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageCebuano.
  ///
  /// In en, this message translates to:
  /// **'Bisaya / Cebuano'**
  String get settingsLanguageCebuano;

  /// No description provided for @settingsLanguageRevertToEnglish.
  ///
  /// In en, this message translates to:
  /// **'That language could not be applied. Reverted to English.'**
  String get settingsLanguageRevertToEnglish;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpHubHeadline.
  ///
  /// In en, this message translates to:
  /// **'Guides for using SpeakUp Connect'**
  String get helpHubHeadline;

  /// No description provided for @helpHubDescription.
  ///
  /// In en, this message translates to:
  /// **'Guides for {orgName}. {adminNote}Content is specific to how this organization is set up.'**
  String helpHubDescription(String orgName, String adminNote);

  /// No description provided for @helpHubAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Includes administration topics for your role. '**
  String get helpHubAdminNote;

  /// No description provided for @helpOrgFallback.
  ///
  /// In en, this message translates to:
  /// **'your organization'**
  String get helpOrgFallback;

  /// No description provided for @helpMemberGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Member Guide'**
  String get helpMemberGuideTitle;

  /// No description provided for @helpMemberGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in, submit reports, and use alerts'**
  String get helpMemberGuideSubtitle;

  /// No description provided for @helpAdminGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Administrator Guide'**
  String get helpAdminGuideTitle;

  /// No description provided for @helpAdminGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Roster, groups, reports, and reminders'**
  String get helpAdminGuideSubtitle;

  /// No description provided for @helpGuideNotFound.
  ///
  /// In en, this message translates to:
  /// **'This guide could not be found.'**
  String get helpGuideNotFound;

  /// No description provided for @helpAdminAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this administrator guide.'**
  String get helpAdminAccessDenied;

  /// No description provided for @helpLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load guide for your organization.'**
  String get helpLoadFailed;

  /// No description provided for @helpLoadFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not load guide for your organization.\n{error}'**
  String helpLoadFailedDetail(String error);

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validationFieldRequired(String fieldName);

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMin8;

  /// No description provided for @validationPasswordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordMin6;

  /// No description provided for @validationLoginIdentifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Email or student ID is required'**
  String get validationLoginIdentifierRequired;

  /// No description provided for @validationStudentIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Student ID is required'**
  String get validationStudentIdRequired;

  /// No description provided for @validationStudentIdMin6.
  ///
  /// In en, this message translates to:
  /// **'Student ID must be at least 6 characters'**
  String get validationStudentIdMin6;

  /// No description provided for @validationStudentIdInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers, and hyphens only'**
  String get validationStudentIdInvalidChars;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be {maxLength} characters or fewer'**
  String validationMaxLength(String fieldName, int maxLength);

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be at least {minLength} characters'**
  String validationMinLength(String fieldName, int minLength);

  /// No description provided for @validationReportTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get validationReportTitleField;

  /// No description provided for @validationReportDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get validationReportDescriptionField;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @translationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search keys or English text'**
  String get translationSearchHint;

  /// No description provided for @translationBatchAi.
  ///
  /// In en, this message translates to:
  /// **'Translate missing (AI)'**
  String get translationBatchAi;

  /// No description provided for @translationBatchAiNoneMissing.
  ///
  /// In en, this message translates to:
  /// **'No missing strings to translate.'**
  String get translationBatchAiNoneMissing;

  /// No description provided for @translationBatchAiResult.
  ///
  /// In en, this message translates to:
  /// **'AI draft: {succeeded} of {total} succeeded'**
  String translationBatchAiResult(int succeeded, int total);

  /// No description provided for @translationExportArb.
  ///
  /// In en, this message translates to:
  /// **'Export ARB (copy JSON)'**
  String get translationExportArb;

  /// No description provided for @translationExportCopied.
  ///
  /// In en, this message translates to:
  /// **'ARB JSON copied to clipboard'**
  String get translationExportCopied;

  /// No description provided for @translationEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} strings loaded'**
  String translationEntryCount(int count);

  /// No description provided for @translationNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No translation entries yet. Platform operators import app_en.arb first.'**
  String get translationNoEntries;

  /// No description provided for @translationTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationTargetLabel;

  /// No description provided for @translationAiDraft.
  ///
  /// In en, this message translates to:
  /// **'AI draft'**
  String get translationAiDraft;

  /// No description provided for @translationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get translationApprove;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
