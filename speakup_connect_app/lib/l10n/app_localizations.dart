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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get commonBrowse;

  /// No description provided for @commonLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get commonLeave;

  /// No description provided for @commonApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get commonApprove;

  /// No description provided for @commonDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get commonDecline;

  /// No description provided for @commonDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get commonDeny;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get commonSelectAll;

  /// No description provided for @commonClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

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

  /// No description provided for @homeWelcomeMessageWithOrgType.
  ///
  /// In en, this message translates to:
  /// **'How can we help make our {orgType} better?'**
  String homeWelcomeMessageWithOrgType(String orgType);

  /// No description provided for @orgTypeWordSchool.
  ///
  /// In en, this message translates to:
  /// **'school'**
  String get orgTypeWordSchool;

  /// No description provided for @orgTypeWordUniversity.
  ///
  /// In en, this message translates to:
  /// **'university'**
  String get orgTypeWordUniversity;

  /// No description provided for @orgTypeWordLgu.
  ///
  /// In en, this message translates to:
  /// **'community'**
  String get orgTypeWordLgu;

  /// No description provided for @orgTypeWordNgo.
  ///
  /// In en, this message translates to:
  /// **'organization'**
  String get orgTypeWordNgo;

  /// No description provided for @orgTypeWordChurch.
  ///
  /// In en, this message translates to:
  /// **'church'**
  String get orgTypeWordChurch;

  /// No description provided for @orgTypeWordCorporation.
  ///
  /// In en, this message translates to:
  /// **'workplace'**
  String get orgTypeWordCorporation;

  /// No description provided for @orgTypeWordOther.
  ///
  /// In en, this message translates to:
  /// **'organization'**
  String get orgTypeWordOther;

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

  /// No description provided for @groupsManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get groupsManageMembers;

  /// No description provided for @groupsViewMembers.
  ///
  /// In en, this message translates to:
  /// **'View Members'**
  String get groupsViewMembers;

  /// No description provided for @groupsAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get groupsAddMembers;

  /// No description provided for @groupsRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get groupsRequests;

  /// No description provided for @groupsRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Requests ({count})'**
  String groupsRequestsCount(int count);

  /// No description provided for @groupsSendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get groupsSendAlert;

  /// No description provided for @groupsEditGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get groupsEditGroup;

  /// No description provided for @groupsEditGroupMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Change name, description, policies, and club positions'**
  String get groupsEditGroupMembersHint;

  /// No description provided for @groupsPostAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get groupsPostAnnouncement;

  /// No description provided for @groupsCancelLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel leave request'**
  String get groupsCancelLeaveRequest;

  /// No description provided for @groupsLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get groupsLeaveGroup;

  /// No description provided for @groupsRequestToLeave.
  ///
  /// In en, this message translates to:
  /// **'Request to leave'**
  String get groupsRequestToLeave;

  /// No description provided for @groupsLeavePending.
  ///
  /// In en, this message translates to:
  /// **'Leave pending'**
  String get groupsLeavePending;

  /// No description provided for @groupsMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String groupsMemberCount(int count);

  /// No description provided for @groupsMyGroupsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When an administrator adds you to a club, it will appear here. You can also browse open groups and request to join.'**
  String get groupsMyGroupsEmptyMessage;

  /// No description provided for @groupsLeaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get groupsLeaveGroupTitle;

  /// No description provided for @groupsLeaveGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving alerts for this group.'**
  String get groupsLeaveGroupMessage;

  /// No description provided for @groupsLeftGroup.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get groupsLeftGroup;

  /// No description provided for @groupsCouldNotLeave.
  ///
  /// In en, this message translates to:
  /// **'Could not leave'**
  String get groupsCouldNotLeave;

  /// No description provided for @groupsLeaveRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Leave request cancelled'**
  String get groupsLeaveRequestCancelled;

  /// No description provided for @groupsCouldNotCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel request'**
  String get groupsCouldNotCancelRequest;

  /// No description provided for @groupsLeaveReasonMinLength.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 20 characters'**
  String get groupsLeaveReasonMinLength;

  /// No description provided for @groupsLeaveRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted'**
  String get groupsLeaveRequestSubmitted;

  /// No description provided for @groupsCouldNotSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not submit request'**
  String get groupsCouldNotSubmitRequest;

  /// No description provided for @groupsLeaveRequestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Request to leave'**
  String get groupsLeaveRequestDialogTitle;

  /// No description provided for @groupsLeaveReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to leave?'**
  String get groupsLeaveReasonLabel;

  /// No description provided for @groupsLeaveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'At least 20 characters'**
  String get groupsLeaveReasonHint;

  /// No description provided for @groupsGenericName.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupsGenericName;

  /// No description provided for @groupsGroupMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get groupsGroupMembersTitle;

  /// No description provided for @groupsMembershipRequests.
  ///
  /// In en, this message translates to:
  /// **'Membership requests'**
  String get groupsMembershipRequests;

  /// No description provided for @groupsMembershipSettings.
  ///
  /// In en, this message translates to:
  /// **'Membership settings'**
  String get groupsMembershipSettings;

  /// No description provided for @groupsMembershipRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Membership requests ({count})'**
  String groupsMembershipRequestsCount(int count);

  /// No description provided for @groupsEditGroupSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit group settings'**
  String get groupsEditGroupSettingsTooltip;

  /// No description provided for @groupsNoMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get groupsNoMembersYet;

  /// No description provided for @groupsNoMembersManageHint.
  ///
  /// In en, this message translates to:
  /// **'Add students or staff to this group.'**
  String get groupsNoMembersManageHint;

  /// No description provided for @groupsNoMembersViewHint.
  ///
  /// In en, this message translates to:
  /// **'Members will appear here once added.'**
  String get groupsNoMembersViewHint;

  /// No description provided for @groupsRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get groupsRemoveMemberTitle;

  /// No description provided for @groupsRemoveMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this group?'**
  String groupsRemoveMemberMessage(String name);

  /// No description provided for @groupsCouldNotRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Could not remove member'**
  String get groupsCouldNotRemoveMember;

  /// No description provided for @groupsCouldNotUpdatePosition.
  ///
  /// In en, this message translates to:
  /// **'Could not update position'**
  String get groupsCouldNotUpdatePosition;

  /// No description provided for @groupsAssignPosition.
  ///
  /// In en, this message translates to:
  /// **'Assign position'**
  String get groupsAssignPosition;

  /// No description provided for @groupsNoPosition.
  ///
  /// In en, this message translates to:
  /// **'No position'**
  String get groupsNoPosition;

  /// No description provided for @groupsNoPositionSelected.
  ///
  /// In en, this message translates to:
  /// **'No position ✓'**
  String get groupsNoPositionSelected;

  /// No description provided for @groupsMakeLeader.
  ///
  /// In en, this message translates to:
  /// **'Make leader'**
  String get groupsMakeLeader;

  /// No description provided for @groupsMakeMember.
  ///
  /// In en, this message translates to:
  /// **'Make member'**
  String get groupsMakeMember;

  /// No description provided for @groupsRemoveFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get groupsRemoveFromGroup;

  /// No description provided for @groupsRoleLeader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get groupsRoleLeader;

  /// No description provided for @groupsRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupsRoleMember;

  /// No description provided for @groupsSearchClubHint.
  ///
  /// In en, this message translates to:
  /// **'Club or program name'**
  String get groupsSearchClubHint;

  /// No description provided for @groupsNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No groups match your search.'**
  String get groupsNoSearchResults;

  /// No description provided for @groupsStatusMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupsStatusMember;

  /// No description provided for @groupsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get groupsStatusPending;

  /// No description provided for @groupsStatusOpenToRequests.
  ///
  /// In en, this message translates to:
  /// **'Open to requests'**
  String get groupsStatusOpenToRequests;

  /// No description provided for @groupsStatusInvitationOnly.
  ///
  /// In en, this message translates to:
  /// **'Invitation only'**
  String get groupsStatusInvitationOnly;

  /// No description provided for @groupsRequestToJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to Join'**
  String get groupsRequestToJoin;

  /// No description provided for @groupsCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get groupsCancelRequest;

  /// No description provided for @groupsInvitationOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Membership by invitation only. Contact your adviser.'**
  String get groupsInvitationOnlyMessage;

  /// No description provided for @groupsJoinRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request to join {groupName}'**
  String groupsJoinRequestTitle(String groupName);

  /// No description provided for @groupsJoinMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get groupsJoinMessageLabel;

  /// No description provided for @groupsJoinMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the leader why you want to join'**
  String get groupsJoinMessageHint;

  /// No description provided for @groupsJoinRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Join request submitted'**
  String get groupsJoinRequestSubmitted;

  /// No description provided for @groupsCouldNotSubmitJoin.
  ///
  /// In en, this message translates to:
  /// **'Could not submit: {error}'**
  String groupsCouldNotSubmitJoin(String error);

  /// No description provided for @groupsRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get groupsRequestCancelled;

  /// No description provided for @groupsOpenToJoin.
  ///
  /// In en, this message translates to:
  /// **'open to join'**
  String get groupsOpenToJoin;

  /// No description provided for @groupsPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get groupsPending;

  /// No description provided for @groupsNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get groupsNewGroup;

  /// No description provided for @groupsCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get groupsCreateGroup;

  /// No description provided for @groupsSearchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups…'**
  String get groupsSearchGroupsHint;

  /// No description provided for @groupsNoSearchMatch.
  ///
  /// In en, this message translates to:
  /// **'No groups match your search'**
  String get groupsNoSearchMatch;

  /// No description provided for @groupsEmptySeedHint.
  ///
  /// In en, this message translates to:
  /// **'Seed the MONHS demo groups or create your own.'**
  String get groupsEmptySeedHint;

  /// No description provided for @groupsTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get groupsTryDifferentSearch;

  /// No description provided for @groupsSeedDemoGroups.
  ///
  /// In en, this message translates to:
  /// **'Seed Demo Groups'**
  String get groupsSeedDemoGroups;

  /// No description provided for @groupsSeeding.
  ///
  /// In en, this message translates to:
  /// **'Seeding…'**
  String get groupsSeeding;

  /// No description provided for @groupsSeedFailed.
  ///
  /// In en, this message translates to:
  /// **'Seed failed: {error}'**
  String groupsSeedFailed(String error);

  /// No description provided for @groupsSeedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Demo groups added successfully'**
  String get groupsSeedSuccess;

  /// No description provided for @groupsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String groupsSyncFailed(String error);

  /// No description provided for @groupsSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Synced 1 membership for My Groups} other{Synced {count} memberships for My Groups}}'**
  String groupsSyncSuccess(int count);

  /// No description provided for @groupsMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get groupsMoreActions;

  /// No description provided for @groupsSeedDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SPJ, Drum & Lyre, SSLG'**
  String get groupsSeedDemoSubtitle;

  /// No description provided for @groupsSyncIndexes.
  ///
  /// In en, this message translates to:
  /// **'Sync My Groups Indexes'**
  String get groupsSyncIndexes;

  /// No description provided for @groupsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get groupsSyncing;

  /// No description provided for @groupsSyncIndexesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Repair member visibility after roster changes'**
  String get groupsSyncIndexesSubtitle;

  /// No description provided for @groupsEditGroupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get groupsEditGroupTooltip;

  /// No description provided for @groupsCreateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get groupsCreateGroupTitle;

  /// No description provided for @groupsGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupsGroupNameLabel;

  /// No description provided for @groupsGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Journalism Club'**
  String get groupsGroupNameHint;

  /// No description provided for @groupsGroupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get groupsGroupNameRequired;

  /// No description provided for @groupsDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get groupsDescriptionLabel;

  /// No description provided for @groupsDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is this group about?'**
  String get groupsDescriptionHint;

  /// No description provided for @groupsDefineClubPositions.
  ///
  /// In en, this message translates to:
  /// **'Define club positions'**
  String get groupsDefineClubPositions;

  /// No description provided for @groupsDefineClubPositionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional offices like President or Treasurer'**
  String get groupsDefineClubPositionsSubtitle;

  /// No description provided for @groupsAllowJoinRequests.
  ///
  /// In en, this message translates to:
  /// **'Allow join requests'**
  String get groupsAllowJoinRequests;

  /// No description provided for @groupsAllowJoinRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let students request to join (off for elected groups like SSLG)'**
  String get groupsAllowJoinRequestsSubtitle;

  /// No description provided for @groupsMemberLeavePolicy.
  ///
  /// In en, this message translates to:
  /// **'Member leave policy'**
  String get groupsMemberLeavePolicy;

  /// No description provided for @groupsLeaveAnytime.
  ///
  /// In en, this message translates to:
  /// **'Leave anytime'**
  String get groupsLeaveAnytime;

  /// No description provided for @groupsMustRequestToLeave.
  ///
  /// In en, this message translates to:
  /// **'Must request to leave'**
  String get groupsMustRequestToLeave;

  /// No description provided for @groupsLeaveAnytimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members can leave without approval'**
  String get groupsLeaveAnytimeSubtitle;

  /// No description provided for @groupsMustRequestToLeaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requires a reason and leader approval'**
  String get groupsMustRequestToLeaveSubtitle;

  /// No description provided for @groupsJoinHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Join hint (optional)'**
  String get groupsJoinHintLabel;

  /// No description provided for @groupsJoinHintHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Auditions in August'**
  String get groupsJoinHintHint;

  /// No description provided for @groupsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {name}'**
  String groupsCreated(String name);

  /// No description provided for @groupsCouldNotCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create group'**
  String get groupsCouldNotCreate;

  /// No description provided for @groupsEditGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get groupsEditGroupTitle;

  /// No description provided for @groupsGroupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupsGroupNotFound;

  /// No description provided for @groupsGroupSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Group settings saved'**
  String get groupsGroupSettingsSaved;

  /// No description provided for @groupsCouldNotSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not save group settings'**
  String get groupsCouldNotSaveSettings;

  /// No description provided for @groupsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get groupsSaveChanges;

  /// No description provided for @groupsGroupIsActive.
  ///
  /// In en, this message translates to:
  /// **'Group is active'**
  String get groupsGroupIsActive;

  /// No description provided for @groupsGroupIsActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inactive groups are hidden from browse and lists'**
  String get groupsGroupIsActiveSubtitle;

  /// No description provided for @groupsAddPosition.
  ///
  /// In en, this message translates to:
  /// **'Add position'**
  String get groupsAddPosition;

  /// No description provided for @groupsSavePositions.
  ///
  /// In en, this message translates to:
  /// **'Save Positions'**
  String get groupsSavePositions;

  /// No description provided for @groupsClubPositionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Club positions saved'**
  String get groupsClubPositionsSaved;

  /// No description provided for @groupsCouldNotSavePositions.
  ///
  /// In en, this message translates to:
  /// **'Could not save positions'**
  String get groupsCouldNotSavePositions;

  /// No description provided for @groupsClubPositionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Club Positions'**
  String get groupsClubPositionsTitle;

  /// No description provided for @groupsClubPositionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Club positions'**
  String get groupsClubPositionsSectionTitle;

  /// No description provided for @groupsClubPositionsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional offices members can hold (e.g. President, Treasurer). You can assign these when adding or managing members.'**
  String get groupsClubPositionsSectionSubtitle;

  /// No description provided for @groupsMembershipRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'{groupName} — Requests'**
  String groupsMembershipRequestsTitle(String groupName);

  /// No description provided for @groupsTabJoinCount.
  ///
  /// In en, this message translates to:
  /// **'Join ({count})'**
  String groupsTabJoinCount(int count);

  /// No description provided for @groupsTabLeaveCount.
  ///
  /// In en, this message translates to:
  /// **'Leave ({count})'**
  String groupsTabLeaveCount(int count);

  /// No description provided for @groupsNoPendingJoinRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending join requests'**
  String get groupsNoPendingJoinRequests;

  /// No description provided for @groupsNoPendingLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending leave requests'**
  String get groupsNoPendingLeaveRequests;

  /// No description provided for @groupsStudentIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String groupsStudentIdPrefix(String id);

  /// No description provided for @groupsApproveLeave.
  ///
  /// In en, this message translates to:
  /// **'Approve leave'**
  String get groupsApproveLeave;

  /// No description provided for @groupsDeclineJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline join request?'**
  String get groupsDeclineJoinTitle;

  /// No description provided for @groupsDeclineJoinReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get groupsDeclineJoinReasonLabel;

  /// No description provided for @groupsDenyLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Deny leave request'**
  String get groupsDenyLeaveTitle;

  /// No description provided for @groupsDenyLeaveReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get groupsDenyLeaveReasonLabel;

  /// No description provided for @groupsReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required'**
  String get groupsReasonRequired;

  /// No description provided for @groupsJoinRequestUpdated.
  ///
  /// In en, this message translates to:
  /// **'Join request updated'**
  String get groupsJoinRequestUpdated;

  /// No description provided for @groupsLeaveRequestUpdated.
  ///
  /// In en, this message translates to:
  /// **'Leave request updated'**
  String get groupsLeaveRequestUpdated;

  /// No description provided for @groupsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get groupsActionFailed;

  /// No description provided for @groupsAddMembersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get groupsAddMembersSearchLabel;

  /// No description provided for @groupsAddMembersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, email, or school ID'**
  String get groupsAddMembersSearchHint;

  /// No description provided for @groupsCouldNotAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Could not add members: {error}'**
  String groupsCouldNotAddMembers(String error);

  /// No description provided for @groupsAllMembersAlreadyInGroup.
  ///
  /// In en, this message translates to:
  /// **'All approved members are already in this group.'**
  String get groupsAllMembersAlreadyInGroup;

  /// No description provided for @groupsNoUsersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No users match your search.'**
  String get groupsNoUsersMatchSearch;

  /// No description provided for @groupsAssignSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'{count} selected — choose role and assign'**
  String groupsAssignSelectedHint(int count);

  /// No description provided for @groupsAssignSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search and tap a member below'**
  String get groupsAssignSearchHint;

  /// No description provided for @groupsAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get groupsAssignButton;

  /// No description provided for @groupsGroupRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Group role'**
  String get groupsGroupRoleLabel;

  /// No description provided for @groupsClubPositionOptional.
  ///
  /// In en, this message translates to:
  /// **'Club position (optional)'**
  String get groupsClubPositionOptional;

  /// No description provided for @groupsAssignMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Assign 1 member} other{Assign {count} members}}'**
  String groupsAssignMembers(int count);

  /// No description provided for @groupsAssignMembersPartial.
  ///
  /// In en, this message translates to:
  /// **'Assigned {added, plural, =1{1 member} other{{added} members}}; {skipped} could not be added'**
  String groupsAssignMembersPartial(int added, int skipped);

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

  /// No description provided for @settingsUsernameStudentId.
  ///
  /// In en, this message translates to:
  /// **'Username / student ID'**
  String get settingsUsernameStudentId;

  /// No description provided for @settingsContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get settingsContactEmail;

  /// No description provided for @settingsChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmail;

  /// No description provided for @settingsAddEmail.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get settingsAddEmail;

  /// No description provided for @settingsContactEmailRemoved.
  ///
  /// In en, this message translates to:
  /// **'Contact email removed'**
  String get settingsContactEmailRemoved;

  /// No description provided for @settingsContactEmailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact email updated'**
  String get settingsContactEmailUpdated;

  /// No description provided for @settingsContactEmailUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update email'**
  String get settingsContactEmailUpdateFailed;

  /// No description provided for @settingsContactEmailDialogIntro.
  ///
  /// In en, this message translates to:
  /// **'Used for notifications and sign-in. Your student ID remains your username for school accounts.'**
  String get settingsContactEmailDialogIntro;

  /// No description provided for @settingsEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get settingsEmailOptional;

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

  /// No description provided for @reminderComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Compose Reminder'**
  String get reminderComposeTitle;

  /// No description provided for @reminderComposeSendGroupAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Group Alert'**
  String get reminderComposeSendGroupAlertTitle;

  /// No description provided for @reminderComposeSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String reminderComposeSendFailed(String error);

  /// No description provided for @reminderComposeSubmittedForApproval.
  ///
  /// In en, this message translates to:
  /// **'Reminder submitted for approval.'**
  String get reminderComposeSubmittedForApproval;

  /// No description provided for @reminderComposeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled.'**
  String get reminderComposeScheduled;

  /// No description provided for @reminderComposePublished.
  ///
  /// In en, this message translates to:
  /// **'Reminder published.'**
  String get reminderComposePublished;

  /// No description provided for @reminderComposeSubmitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for Approval'**
  String get reminderComposeSubmitForApproval;

  /// No description provided for @reminderComposeSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send Reminder'**
  String get reminderComposeSendReminder;

  /// No description provided for @reminderComposeGroupOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'This alert will be sent only to members of the group you select.'**
  String get reminderComposeGroupOnlyHint;

  /// No description provided for @reminderComposeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderComposeTitleLabel;

  /// No description provided for @reminderComposeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Early dismissal Friday'**
  String get reminderComposeTitleHint;

  /// No description provided for @reminderComposeMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get reminderComposeMessageLabel;

  /// No description provided for @reminderComposeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write the reminder details…'**
  String get reminderComposeMessageHint;

  /// No description provided for @reminderComposeAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get reminderComposeAudienceLabel;

  /// No description provided for @reminderComposeAudienceEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get reminderComposeAudienceEveryone;

  /// No description provided for @reminderComposeAudienceGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get reminderComposeAudienceGroup;

  /// No description provided for @reminderComposeAudienceRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get reminderComposeAudienceRole;

  /// No description provided for @reminderComposeLoadGroupsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups: {error}'**
  String reminderComposeLoadGroupsFailed(String error);

  /// No description provided for @reminderComposeNoGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups exist yet. Create a group first.'**
  String get reminderComposeNoGroupsYet;

  /// No description provided for @reminderComposeSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get reminderComposeSelectGroup;

  /// No description provided for @reminderComposeLoadRolesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load roles: {error}'**
  String reminderComposeLoadRolesFailed(String error);

  /// No description provided for @reminderComposeNoRolesYet.
  ///
  /// In en, this message translates to:
  /// **'No roles defined yet.'**
  String get reminderComposeNoRolesYet;

  /// No description provided for @reminderComposeSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get reminderComposeSelectRole;

  /// No description provided for @reminderComposeNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to broadcast reminders.'**
  String get reminderComposeNoPermission;

  /// No description provided for @reminderComposeApprovalBanner.
  ///
  /// In en, this message translates to:
  /// **'Your organization requires reminders to be approved. This will be submitted for review before it is published.'**
  String get reminderComposeApprovalBanner;

  /// No description provided for @reminderComposeValidationTitleMin.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters.'**
  String get reminderComposeValidationTitleMin;

  /// No description provided for @reminderComposeValidationMessageMin.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 5 characters.'**
  String get reminderComposeValidationMessageMin;

  /// No description provided for @reminderComposeValidationSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select a group for this alert.'**
  String get reminderComposeValidationSelectGroup;

  /// No description provided for @reminderComposeValidationSelectAudience.
  ///
  /// In en, this message translates to:
  /// **'Select an audience for this reminder.'**
  String get reminderComposeValidationSelectAudience;

  /// No description provided for @reminderComposeValidationExpiration.
  ///
  /// In en, this message translates to:
  /// **'Set a valid expiration date and time.'**
  String get reminderComposeValidationExpiration;

  /// No description provided for @reminderComposeValidationCheckboxOptions.
  ///
  /// In en, this message translates to:
  /// **'Add at least one checkbox option with a label.'**
  String get reminderComposeValidationCheckboxOptions;

  /// No description provided for @reminderComposeValidationChoiceOptions.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 answer choices with labels.'**
  String get reminderComposeValidationChoiceOptions;

  /// No description provided for @reminderComposeValidationCharLimit.
  ///
  /// In en, this message translates to:
  /// **'Set a valid character limit for responses.'**
  String get reminderComposeValidationCharLimit;

  /// No description provided for @reminderComposeScheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get reminderComposeScheduleForLater;

  /// No description provided for @reminderComposeScheduleOff.
  ///
  /// In en, this message translates to:
  /// **'Off — send immediately'**
  String get reminderComposeScheduleOff;

  /// No description provided for @reminderComposeChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get reminderComposeChangeTime;

  /// No description provided for @reminderComposeSetExpiration.
  ///
  /// In en, this message translates to:
  /// **'Set expiration'**
  String get reminderComposeSetExpiration;

  /// No description provided for @reminderComposeExpirationOff.
  ///
  /// In en, this message translates to:
  /// **'Off — stays until manually deleted'**
  String get reminderComposeExpirationOff;

  /// No description provided for @reminderComposeSetExpirationBelow.
  ///
  /// In en, this message translates to:
  /// **'Set expiration below'**
  String get reminderComposeSetExpirationBelow;

  /// No description provided for @reminderComposeExpirationDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get reminderComposeExpirationDateTime;

  /// No description provided for @reminderComposeExpirationDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get reminderComposeExpirationDuration;

  /// No description provided for @reminderComposePickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get reminderComposePickDateTime;

  /// No description provided for @reminderComposeExpirationAfterSend.
  ///
  /// In en, this message translates to:
  /// **'Expiration must be after the send time.'**
  String get reminderComposeExpirationAfterSend;

  /// No description provided for @reminderComposeExpireAfter.
  ///
  /// In en, this message translates to:
  /// **'Expire after'**
  String get reminderComposeExpireAfter;

  /// No description provided for @reminderComposeHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get reminderComposeHours;

  /// No description provided for @reminderComposeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get reminderComposeMinutes;

  /// No description provided for @reminderComposeExpirationDurationSummary.
  ///
  /// In en, this message translates to:
  /// **'{duration} after {base} ({dateTime})'**
  String reminderComposeExpirationDurationSummary(
      String duration, String base, String dateTime);

  /// No description provided for @reminderComposeExpirationAt.
  ///
  /// In en, this message translates to:
  /// **'Expires {dateTime}'**
  String reminderComposeExpirationAt(String dateTime);

  /// No description provided for @reminderComposeExpirationBaseScheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled send'**
  String get reminderComposeExpirationBaseScheduled;

  /// No description provided for @reminderComposeExpirationBaseSend.
  ///
  /// In en, this message translates to:
  /// **'send'**
  String get reminderComposeExpirationBaseSend;

  /// No description provided for @reminderComposeDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hr'**
  String reminderComposeDurationHours(int count);

  /// No description provided for @reminderComposeDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String reminderComposeDurationMinutes(int count);

  /// No description provided for @reminderComposeDurationZeroMin.
  ///
  /// In en, this message translates to:
  /// **'0 min'**
  String get reminderComposeDurationZeroMin;

  /// No description provided for @reminderComposeRequestResponse.
  ///
  /// In en, this message translates to:
  /// **'Request a response'**
  String get reminderComposeRequestResponse;

  /// No description provided for @reminderComposeResponseRecipientsCan.
  ///
  /// In en, this message translates to:
  /// **'Recipients can respond via {type}'**
  String reminderComposeResponseRecipientsCan(String type);

  /// No description provided for @reminderComposeResponseOff.
  ///
  /// In en, this message translates to:
  /// **'Off — no response requested'**
  String get reminderComposeResponseOff;

  /// No description provided for @reminderComposeResponseRequired.
  ///
  /// In en, this message translates to:
  /// **'Response required'**
  String get reminderComposeResponseRequired;

  /// No description provided for @reminderComposeResponseRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Recipients must respond before they can dismiss the alert'**
  String get reminderComposeResponseRequiredHint;

  /// No description provided for @reminderComposeAllowChangingResponses.
  ///
  /// In en, this message translates to:
  /// **'Allow changing responses'**
  String get reminderComposeAllowChangingResponses;

  /// No description provided for @reminderComposeAllowChangingResponsesOn.
  ///
  /// In en, this message translates to:
  /// **'Recipients can update their answer after submitting'**
  String get reminderComposeAllowChangingResponsesOn;

  /// No description provided for @reminderComposeAllowChangingResponsesOff.
  ///
  /// In en, this message translates to:
  /// **'Locked after submit — use for votes and one-time polls'**
  String get reminderComposeAllowChangingResponsesOff;

  /// No description provided for @reminderComposeResponseFreeText.
  ///
  /// In en, this message translates to:
  /// **'Free text'**
  String get reminderComposeResponseFreeText;

  /// No description provided for @reminderComposeResponseCheckboxes.
  ///
  /// In en, this message translates to:
  /// **'Checkboxes'**
  String get reminderComposeResponseCheckboxes;

  /// No description provided for @reminderComposeResponseChoices.
  ///
  /// In en, this message translates to:
  /// **'Choices'**
  String get reminderComposeResponseChoices;

  /// No description provided for @reminderComposeCharacterLimit.
  ///
  /// In en, this message translates to:
  /// **'Character limit'**
  String get reminderComposeCharacterLimit;

  /// No description provided for @reminderComposeCharactersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String reminderComposeCharactersCount(int count);

  /// No description provided for @reminderComposeAllowExplanationText.
  ///
  /// In en, this message translates to:
  /// **'Allow explanation text'**
  String get reminderComposeAllowExplanationText;

  /// No description provided for @reminderComposeAllowExplanationHint.
  ///
  /// In en, this message translates to:
  /// **'Optional text box for comments (e.g. why they cannot attend)'**
  String get reminderComposeAllowExplanationHint;

  /// No description provided for @reminderComposeValidationCharLimitRange.
  ///
  /// In en, this message translates to:
  /// **'Set a character limit between {min} and {max}.'**
  String reminderComposeValidationCharLimitRange(int min, int max);

  /// No description provided for @reminderComposeCheckboxOptions.
  ///
  /// In en, this message translates to:
  /// **'Checkbox options'**
  String get reminderComposeCheckboxOptions;

  /// No description provided for @reminderComposeAnswerChoices.
  ///
  /// In en, this message translates to:
  /// **'Answer choices'**
  String get reminderComposeAnswerChoices;

  /// No description provided for @reminderComposeOptionNumber.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String reminderComposeOptionNumber(int number);

  /// No description provided for @reminderComposeRemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get reminderComposeRemoveOption;

  /// No description provided for @reminderComposeAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get reminderComposeAddOption;

  /// No description provided for @reminderComposeResponseTypeExplanationSuffix.
  ///
  /// In en, this message translates to:
  /// **'+ explanation'**
  String get reminderComposeResponseTypeExplanationSuffix;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @commonPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get commonPublish;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get commonMessage;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @commonActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String commonActionFailed(String error);

  /// No description provided for @commonUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String commonUpdateFailed(String error);

  /// No description provided for @commonDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String commonDeleteFailed(String error);

  /// No description provided for @commonFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String commonFailedToLoad(String error);

  /// No description provided for @commonGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get commonGrade;

  /// No description provided for @commonAllGrades.
  ///
  /// In en, this message translates to:
  /// **'All grades'**
  String get commonAllGrades;

  /// No description provided for @commonNoGradeAssigned.
  ///
  /// In en, this message translates to:
  /// **'No grade assigned'**
  String get commonNoGradeAssigned;

  /// No description provided for @commonGradeLevel.
  ///
  /// In en, this message translates to:
  /// **'Grade level'**
  String get commonGradeLevel;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get commonReasonOptional;

  /// No description provided for @commonNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get commonNoteOptional;

  /// No description provided for @commonByAuthor.
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String commonByAuthor(String name);

  /// No description provided for @commonFromGroup.
  ///
  /// In en, this message translates to:
  /// **'From {groupName}'**
  String commonFromGroup(String groupName);

  /// No description provided for @commonScheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled'**
  String get commonScheduled;

  /// No description provided for @commonNoReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get commonNoReasonProvided;

  /// No description provided for @commonSchoolWide.
  ///
  /// In en, this message translates to:
  /// **'School-wide'**
  String get commonSchoolWide;

  /// No description provided for @commonRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get commonRegistered;

  /// No description provided for @commonNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get commonNotRegistered;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get commonBlocked;

  /// No description provided for @commonUnenrolled.
  ///
  /// In en, this message translates to:
  /// **'Unenrolled'**
  String get commonUnenrolled;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get commonSignedIn;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String commonSaveFailed(String error);

  /// No description provided for @commonSection.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get commonSection;

  /// No description provided for @commonIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get commonIdLabel;

  /// No description provided for @commonContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinueButton;

  /// No description provided for @commonChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get commonChooseFromGallery;

  /// No description provided for @commonTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get commonTakePhoto;

  /// No description provided for @commonRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get commonRemovePhoto;

  /// No description provided for @commonAddProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get commonAddProfilePhoto;

  /// No description provided for @commonChangeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get commonChangeProfilePhoto;

  /// No description provided for @commonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'(none)'**
  String get commonNone;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @changePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password, then choose a new password.'**
  String get changePasswordIntro;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'Your current password'**
  String get changePasswordCurrentHint;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordUpdateButton;

  /// No description provided for @changePasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from your current password.'**
  String get changePasswordMustDiffer;

  /// No description provided for @changePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change password. Please try again.'**
  String get changePasswordFailed;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get changePasswordSuccess;

  /// No description provided for @pendingApprovalsAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get pendingApprovalsAnnouncements;

  /// No description provided for @pendingApprovalsGroupAlerts.
  ///
  /// In en, this message translates to:
  /// **'Group alerts'**
  String get pendingApprovalsGroupAlerts;

  /// No description provided for @pendingApprovalsSchoolWide.
  ///
  /// In en, this message translates to:
  /// **'School-wide'**
  String get pendingApprovalsSchoolWide;

  /// No description provided for @pendingApprovalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing awaiting approval'**
  String get pendingApprovalsEmpty;

  /// No description provided for @pendingApprovalsNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to approve content.'**
  String get pendingApprovalsNoPermission;

  /// No description provided for @pendingApprovalsRejectAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Reject announcement'**
  String get pendingApprovalsRejectAnnouncement;

  /// No description provided for @pendingApprovalsRejectReminder.
  ///
  /// In en, this message translates to:
  /// **'Reject reminder'**
  String get pendingApprovalsRejectReminder;

  /// No description provided for @pendingApprovalsRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Let the author know why…'**
  String get pendingApprovalsRejectReasonHint;

  /// No description provided for @pendingApprovalsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String pendingApprovalsLoadFailed(String error);

  /// No description provided for @composeAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get composeAnnouncementTitle;

  /// No description provided for @composeAnnouncementNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to post school-wide announcements.'**
  String get composeAnnouncementNoPermission;

  /// No description provided for @composeAnnouncementIntro.
  ///
  /// In en, this message translates to:
  /// **'School-wide announcements are visible to every member.'**
  String get composeAnnouncementIntro;

  /// No description provided for @composeAnnouncementApprovalBanner.
  ///
  /// In en, this message translates to:
  /// **'Your organization requires approval before announcements go live.'**
  String get composeAnnouncementApprovalBanner;

  /// No description provided for @composeAnnouncementTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Join our club this semester'**
  String get composeAnnouncementTitleHint;

  /// No description provided for @composeAnnouncementMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Share recruitment info, news, or updates…'**
  String get composeAnnouncementMessageHint;

  /// No description provided for @composeAnnouncementPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Pin to top of announcements'**
  String get composeAnnouncementPinTitle;

  /// No description provided for @composeAnnouncementPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pinned posts appear first for all members'**
  String get composeAnnouncementPinSubtitle;

  /// No description provided for @composeAnnouncementPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get composeAnnouncementPublish;

  /// No description provided for @composeAnnouncementSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Announcement submitted for approval.'**
  String get composeAnnouncementSubmitted;

  /// No description provided for @composeAnnouncementScheduled.
  ///
  /// In en, this message translates to:
  /// **'Announcement scheduled.'**
  String get composeAnnouncementScheduled;

  /// No description provided for @composeAnnouncementPublished.
  ///
  /// In en, this message translates to:
  /// **'Announcement published.'**
  String get composeAnnouncementPublished;

  /// No description provided for @composeAnnouncementSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to post: {error}'**
  String composeAnnouncementSendFailed(String error);

  /// No description provided for @composeAnnouncementImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load that image. Try another photo.'**
  String get composeAnnouncementImageLoadFailed;

  /// No description provided for @composeAnnouncementGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'You must lead a group before posting announcements.'**
  String get composeAnnouncementGroupRequired;

  /// No description provided for @composeAnnouncementGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Group (optional)'**
  String get composeAnnouncementGroupOptional;

  /// No description provided for @composeAnnouncementOnBehalfOf.
  ///
  /// In en, this message translates to:
  /// **'On behalf of'**
  String get composeAnnouncementOnBehalfOf;

  /// No description provided for @composeAnnouncementMustLeadGroup.
  ///
  /// In en, this message translates to:
  /// **'You can only post on behalf of groups you lead.'**
  String get composeAnnouncementMustLeadGroup;

  /// No description provided for @composeAnnouncementValidationTitleMin.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters.'**
  String get composeAnnouncementValidationTitleMin;

  /// No description provided for @composeAnnouncementValidationMessageMin.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 5 characters.'**
  String get composeAnnouncementValidationMessageMin;

  /// No description provided for @composeAnnouncementValidationExpiration.
  ///
  /// In en, this message translates to:
  /// **'Set a valid expiration date and time.'**
  String get composeAnnouncementValidationExpiration;

  /// No description provided for @composeAnnouncementValidationResponse.
  ///
  /// In en, this message translates to:
  /// **'Complete the optional response settings or turn them off.'**
  String get composeAnnouncementValidationResponse;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @announcementsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcementsDetailTitle;

  /// No description provided for @announcementsMyTitle.
  ///
  /// In en, this message translates to:
  /// **'My Announcements'**
  String get announcementsMyTitle;

  /// No description provided for @announcementsMyTooltip.
  ///
  /// In en, this message translates to:
  /// **'My announcements'**
  String get announcementsMyTooltip;

  /// No description provided for @announcementsPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get announcementsPost;

  /// No description provided for @announcementsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Announcement not found.'**
  String get announcementsNotFound;

  /// No description provided for @announcementsNotFoundShort.
  ///
  /// In en, this message translates to:
  /// **'Announcement not found'**
  String get announcementsNotFoundShort;

  /// No description provided for @announcementsFailedToLoadList.
  ///
  /// In en, this message translates to:
  /// **'Failed to load announcements: {error}'**
  String announcementsFailedToLoadList(String error);

  /// No description provided for @announcementsFailedToLoadAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Failed to load announcement: {error}'**
  String announcementsFailedToLoadAnnouncement(String error);

  /// No description provided for @announcementsFailedToLoadResponses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load responses: {error}'**
  String announcementsFailedToLoadResponses(String error);

  /// No description provided for @announcementsFailedToLoadResponse.
  ///
  /// In en, this message translates to:
  /// **'Failed to load response: {error}'**
  String announcementsFailedToLoadResponse(String error);

  /// No description provided for @announcementsResponsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get announcementsResponsesTitle;

  /// No description provided for @announcementsNoResponses.
  ///
  /// In en, this message translates to:
  /// **'This announcement has no responses.'**
  String get announcementsNoResponses;

  /// No description provided for @announcementsEmptyMine.
  ///
  /// In en, this message translates to:
  /// **'You have not posted any announcements yet.'**
  String get announcementsEmptyMine;

  /// No description provided for @announcementsViewResponses.
  ///
  /// In en, this message translates to:
  /// **'View responses'**
  String get announcementsViewResponses;

  /// No description provided for @announcementsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete announcement?'**
  String get announcementsDeleteTitle;

  /// No description provided for @announcementsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit announcement'**
  String get announcementsEditTitle;

  /// No description provided for @announcementsAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get announcementsAddImage;

  /// No description provided for @announcementsChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get announcementsChooseFromGallery;

  /// No description provided for @announcementsTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get announcementsTakePhoto;

  /// No description provided for @announcementsRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get announcementsRemoveImage;

  /// No description provided for @announcementsPreparingImage.
  ///
  /// In en, this message translates to:
  /// **'Preparing image…'**
  String get announcementsPreparingImage;

  /// No description provided for @announcementsChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get announcementsChangePhoto;

  /// No description provided for @announcementsExpirationMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Expiration must be in the future'**
  String get announcementsExpirationMustBeFuture;

  /// No description provided for @schoolGradesIntro.
  ///
  /// In en, this message translates to:
  /// **'Define which grade levels your school uses.'**
  String get schoolGradesIntro;

  /// No description provided for @schoolGradesIntroWhereUsed.
  ///
  /// In en, this message translates to:
  /// **'These appear in {studentRoster} and {memberManagement} filters.'**
  String schoolGradesIntroWhereUsed(
      String studentRoster, String memberManagement);

  /// No description provided for @schoolGradesNonSchoolNote.
  ///
  /// In en, this message translates to:
  /// **'Municipalities, barangays, and NGOs do not use grades.'**
  String get schoolGradesNonSchoolNote;

  /// No description provided for @schoolGradesCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current grades'**
  String get schoolGradesCurrent;

  /// No description provided for @schoolGradesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No grades configured yet.'**
  String get schoolGradesEmpty;

  /// No description provided for @schoolGradesGradeChip.
  ///
  /// In en, this message translates to:
  /// **'Grade {level}'**
  String schoolGradesGradeChip(int level);

  /// No description provided for @schoolGradesAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add grade level'**
  String get schoolGradesAddLabel;

  /// No description provided for @schoolGradesAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7'**
  String get schoolGradesAddHint;

  /// No description provided for @schoolGradesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add grade'**
  String get schoolGradesAddButton;

  /// No description provided for @schoolGradesResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to high school default (7–12)'**
  String get schoolGradesResetDefault;

  /// No description provided for @schoolGradesSave.
  ///
  /// In en, this message translates to:
  /// **'Save grades'**
  String get schoolGradesSave;

  /// No description provided for @schoolGradesSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get schoolGradesSaving;

  /// No description provided for @schoolGradesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String schoolGradesSaveFailed(String error);

  /// No description provided for @schoolGradesSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Grade levels updated'**
  String get schoolGradesSaveSuccess;

  /// No description provided for @schoolGradesSaveVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Grade levels were not saved correctly. Try again.'**
  String get schoolGradesSaveVerifyFailed;

  /// No description provided for @schoolGradesAtLeastOneRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one grade level is required.'**
  String get schoolGradesAtLeastOneRequired;

  /// No description provided for @schoolGradesInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid grade number'**
  String get schoolGradesInvalidNumber;

  /// No description provided for @schoolGradesSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save grade levels?'**
  String get schoolGradesSaveDialogTitle;

  /// No description provided for @schoolGradesSaveDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Students will be filterable and assignable by:'**
  String get schoolGradesSaveDialogBody;

  /// No description provided for @schoolGradesNotSchool.
  ///
  /// In en, this message translates to:
  /// **'Grade levels are only used by school-type organizations. This setting is not available for your organization type.'**
  String get schoolGradesNotSchool;

  /// No description provided for @schoolGradesNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage organization settings.'**
  String get schoolGradesNoPermission;

  /// No description provided for @schoolGradesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings: {error}'**
  String schoolGradesLoadFailed(String error);

  /// No description provided for @submitConcernTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a Concern'**
  String get submitConcernTitle;

  /// No description provided for @submitConcernStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get submitConcernStepDetails;

  /// No description provided for @submitConcernStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get submitConcernStepPhotos;

  /// No description provided for @submitConcernStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get submitConcernStepReview;

  /// No description provided for @submitConcernCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'What type of concern is this?'**
  String get submitConcernCategoryPrompt;

  /// No description provided for @submitConcernLoadCategoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get submitConcernLoadCategoriesFailed;

  /// No description provided for @submitConcernTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Brief summary of your concern (min 5 characters)'**
  String get submitConcernTitleHint;

  /// No description provided for @submitConcernDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get submitConcernDescriptionLabel;

  /// No description provided for @submitConcernDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the concern in detail (min 10 characters)'**
  String get submitConcernDescriptionHint;

  /// No description provided for @submitConcernTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters'**
  String get submitConcernTitleMinLength;

  /// No description provided for @submitConcernDescriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters'**
  String get submitConcernDescriptionMinLength;

  /// No description provided for @submitConcernPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Attach Photos (optional)'**
  String get submitConcernPhotosTitle;

  /// No description provided for @submitConcernPhotosLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} photos'**
  String submitConcernPhotosLimit(int count);

  /// No description provided for @submitConcernAnonymousTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Anonymously'**
  String get submitConcernAnonymousTitle;

  /// No description provided for @submitConcernAnonymousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name and account will not be linked to this report.'**
  String get submitConcernAnonymousSubtitle;

  /// No description provided for @submitConcernTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get submitConcernTakePhoto;

  /// No description provided for @submitConcernChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get submitConcernChooseGallery;

  /// No description provided for @submitConcernReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Your Report'**
  String get submitConcernReviewTitle;

  /// No description provided for @submitConcernReviewCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get submitConcernReviewCategory;

  /// No description provided for @submitConcernReviewPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get submitConcernReviewPhotos;

  /// No description provided for @submitConcernReviewSubmittedAs.
  ///
  /// In en, this message translates to:
  /// **'Submitted As'**
  String get submitConcernReviewSubmittedAs;

  /// No description provided for @submitConcernReviewAnonymousWarning.
  ///
  /// In en, this message translates to:
  /// **'Anonymous reports cannot be tracked. Save your reference number.'**
  String get submitConcernReviewAnonymousWarning;

  /// No description provided for @submitConcernSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitConcernSubmitButton;

  /// No description provided for @submitConcernStep1Incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please complete Step 1: select a category, title (min 5 chars), and description (min 10 chars).'**
  String get submitConcernStep1Incomplete;

  /// No description provided for @submitConcernSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed: {error}'**
  String submitConcernSubmissionFailed(String error);

  /// No description provided for @submitConcernPhotosAttached.
  ///
  /// In en, this message translates to:
  /// **'{count} attached'**
  String submitConcernPhotosAttached(int count);

  /// No description provided for @adminDashboardJoinApplicationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Join Applications'**
  String get adminDashboardJoinApplicationsTooltip;

  /// No description provided for @adminDashboardPendingApprovalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get adminDashboardPendingApprovalsTooltip;

  /// No description provided for @adminDashboardMemberManagementTooltip.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get adminDashboardMemberManagementTooltip;

  /// No description provided for @adminDashboardStudentRosterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Student Roster'**
  String get adminDashboardStudentRosterTooltip;

  /// No description provided for @adminDashboardSchoolGradesTooltip.
  ///
  /// In en, this message translates to:
  /// **'School Grades'**
  String get adminDashboardSchoolGradesTooltip;

  /// No description provided for @adminDashboardRolesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Roles & Permissions'**
  String get adminDashboardRolesTooltip;

  /// No description provided for @adminDashboardOrgSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Organization Settings'**
  String get adminDashboardOrgSettingsTooltip;

  /// No description provided for @adminDashboardTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminDashboardTabAll;

  /// No description provided for @adminDashboardTabSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get adminDashboardTabSubmitted;

  /// No description provided for @adminDashboardTabUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get adminDashboardTabUnderReview;

  /// No description provided for @adminDashboardTabInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get adminDashboardTabInProgress;

  /// No description provided for @adminDashboardTabResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminDashboardTabResolved;

  /// No description provided for @adminDashboardTabClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminDashboardTabClosed;

  /// No description provided for @adminDashboardStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminDashboardStatTotal;

  /// No description provided for @adminDashboardStatSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get adminDashboardStatSubmitted;

  /// No description provided for @adminDashboardStatUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get adminDashboardStatUnderReview;

  /// No description provided for @adminDashboardStatInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get adminDashboardStatInProgress;

  /// No description provided for @adminDashboardStatResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminDashboardStatResolved;

  /// No description provided for @adminDashboardStatClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminDashboardStatClosed;

  /// No description provided for @adminDashboardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or reference number...'**
  String get adminDashboardSearchHint;

  /// No description provided for @adminDashboardLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Loading reports...'**
  String get adminDashboardLoadingReports;

  /// No description provided for @adminDashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports'**
  String get adminDashboardLoadFailed;

  /// No description provided for @adminDashboardNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get adminDashboardNoResults;

  /// No description provided for @adminDashboardNoReports.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get adminDashboardNoReports;

  /// No description provided for @adminDashboardNoReportsMatch.
  ///
  /// In en, this message translates to:
  /// **'No reports match \"{query}\".'**
  String adminDashboardNoReportsMatch(String query);

  /// No description provided for @adminDashboardNoActiveReports.
  ///
  /// In en, this message translates to:
  /// **'No active reports submitted yet.'**
  String get adminDashboardNoActiveReports;

  /// No description provided for @adminDashboardNoClosedReports.
  ///
  /// In en, this message translates to:
  /// **'No closed reports.'**
  String get adminDashboardNoClosedReports;

  /// No description provided for @adminDashboardNoTabReports.
  ///
  /// In en, this message translates to:
  /// **'No \"{tab}\" reports.'**
  String adminDashboardNoTabReports(String tab);

  /// No description provided for @adminDashboardUpdateStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String adminDashboardUpdateStatusFailed(String error);

  /// No description provided for @adminDashboardReportsCount.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count, plural, =1{1 report} other{{count} reports}}'**
  String adminDashboardReportsCount(String label, int count);

  /// No description provided for @adminDashboardReportPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get adminDashboardReportPriorityLow;

  /// No description provided for @adminDashboardReportPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get adminDashboardReportPriorityMedium;

  /// No description provided for @adminDashboardReportPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get adminDashboardReportPriorityHigh;

  /// No description provided for @adminDashboardReportPriorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get adminDashboardReportPriorityUrgent;

  /// No description provided for @memberManagementSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email…'**
  String get memberManagementSearchHint;

  /// No description provided for @memberManagementUpdatedCount.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} member(s)'**
  String memberManagementUpdatedCount(int count);

  /// No description provided for @memberManagementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member updated'**
  String get memberManagementUpdated;

  /// No description provided for @memberManagementBlocked.
  ///
  /// In en, this message translates to:
  /// **'Member blocked'**
  String get memberManagementBlocked;

  /// No description provided for @memberManagementUnblocked.
  ///
  /// In en, this message translates to:
  /// **'Member unblocked'**
  String get memberManagementUnblocked;

  /// No description provided for @memberManagementLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String memberManagementLoadFailed(String error);

  /// No description provided for @memberManagementEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active members found.'**
  String get memberManagementEmptyActive;

  /// No description provided for @memberManagementEmptyBlocked.
  ///
  /// In en, this message translates to:
  /// **'No blocked members found.'**
  String get memberManagementEmptyBlocked;

  /// No description provided for @memberManagementEmptyUnenrolled.
  ///
  /// In en, this message translates to:
  /// **'No unenrolled members found.'**
  String get memberManagementEmptyUnenrolled;

  /// No description provided for @memberManagementEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No members match your filters.'**
  String get memberManagementEmptyFiltered;

  /// No description provided for @memberManagementSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String memberManagementSelectedCount(int count);

  /// No description provided for @memberManagementBulkBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get memberManagementBulkBlock;

  /// No description provided for @memberManagementBulkUnenroll.
  ///
  /// In en, this message translates to:
  /// **'Unenroll'**
  String get memberManagementBulkUnenroll;

  /// No description provided for @memberManagementBulkReenroll.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll'**
  String get memberManagementBulkReenroll;

  /// No description provided for @memberManagementBulkAssignGrade.
  ///
  /// In en, this message translates to:
  /// **'Assign grade'**
  String get memberManagementBulkAssignGrade;

  /// No description provided for @memberManagementReenroll.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll'**
  String get memberManagementReenroll;

  /// No description provided for @memberManagementUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get memberManagementUnblock;

  /// No description provided for @memberManagementUnenroll.
  ///
  /// In en, this message translates to:
  /// **'Unenroll'**
  String get memberManagementUnenroll;

  /// No description provided for @memberManagementAssignGrade.
  ///
  /// In en, this message translates to:
  /// **'Assign grade'**
  String get memberManagementAssignGrade;

  /// No description provided for @memberManagementBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get memberManagementBlock;

  /// No description provided for @memberManagementEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile…'**
  String get memberManagementEditProfile;

  /// No description provided for @memberManagementResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password…'**
  String get memberManagementResetPassword;

  /// No description provided for @memberManagementBlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String memberManagementBlockDialogTitle(String name);

  /// No description provided for @memberManagementUnenrollDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unenroll {name}?'**
  String memberManagementUnenrollDialogTitle(String name);

  /// No description provided for @memberManagementReenrollDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll {name}?'**
  String memberManagementReenrollDialogTitle(String name);

  /// No description provided for @memberManagementAssignGradeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign grade to {name}'**
  String memberManagementAssignGradeDialogTitle(String name);

  /// No description provided for @memberManagementGradeAssigned.
  ///
  /// In en, this message translates to:
  /// **'Grade assigned'**
  String get memberManagementGradeAssigned;

  /// No description provided for @memberManagementNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage enrolled members.'**
  String get memberManagementNoAccess;

  /// No description provided for @memberManagementBlockReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this account being blocked?'**
  String get memberManagementBlockReasonHint;

  /// No description provided for @memberManagementConfirmBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm block'**
  String get memberManagementConfirmBlockTitle;

  /// No description provided for @memberManagementConfirmBlockMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will lose access immediately.'**
  String memberManagementConfirmBlockMessage(String name);

  /// No description provided for @memberManagementConfirmBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm block'**
  String get memberManagementConfirmBlockAction;

  /// No description provided for @memberManagementUnblockMessage.
  ///
  /// In en, this message translates to:
  /// **'This member will regain access to the organization.'**
  String get memberManagementUnblockMessage;

  /// No description provided for @memberManagementUnenrollTitleOne.
  ///
  /// In en, this message translates to:
  /// **'Unenroll {name}?'**
  String memberManagementUnenrollTitleOne(String name);

  /// No description provided for @memberManagementUnenrollTitleMany.
  ///
  /// In en, this message translates to:
  /// **'Unenroll {count} members?'**
  String memberManagementUnenrollTitleMany(int count);

  /// No description provided for @memberManagementUnenrollHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Graduated, transferred, left the school'**
  String get memberManagementUnenrollHint;

  /// No description provided for @memberManagementConfirmUnenrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm unenrollment'**
  String get memberManagementConfirmUnenrollTitle;

  /// No description provided for @memberManagementConfirmUnenrollMessageOne.
  ///
  /// In en, this message translates to:
  /// **'This member will lose access immediately.'**
  String get memberManagementConfirmUnenrollMessageOne;

  /// No description provided for @memberManagementConfirmUnenrollMessageMany.
  ///
  /// In en, this message translates to:
  /// **'{count} members will lose access immediately.'**
  String memberManagementConfirmUnenrollMessageMany(int count);

  /// No description provided for @memberManagementConfirmUnenrollAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm unenroll'**
  String get memberManagementConfirmUnenrollAction;

  /// No description provided for @memberManagementBulkBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {count} members?'**
  String memberManagementBulkBlockTitle(int count);

  /// No description provided for @memberManagementBulkBlockHint.
  ///
  /// In en, this message translates to:
  /// **'Why are these accounts being blocked?'**
  String get memberManagementBulkBlockHint;

  /// No description provided for @memberManagementBulkBlockConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} member(s) will lose access immediately.'**
  String memberManagementBulkBlockConfirmMessage(int count);

  /// No description provided for @memberManagementBulkUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock {count} members?'**
  String memberManagementBulkUnblockTitle(int count);

  /// No description provided for @memberManagementBulkUnblockMessage.
  ///
  /// In en, this message translates to:
  /// **'These members will regain access to the organization.'**
  String get memberManagementBulkUnblockMessage;

  /// No description provided for @memberManagementConfirmUnblockAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm unblock'**
  String get memberManagementConfirmUnblockAction;

  /// No description provided for @memberManagementReenrollTitleOne.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll {name}?'**
  String memberManagementReenrollTitleOne(String name);

  /// No description provided for @memberManagementReenrollTitleMany.
  ///
  /// In en, this message translates to:
  /// **'Re-enroll {count} members?'**
  String memberManagementReenrollTitleMany(int count);

  /// No description provided for @memberManagementReenrollMessageOne.
  ///
  /// In en, this message translates to:
  /// **'This member will regain full access to the organization.'**
  String get memberManagementReenrollMessageOne;

  /// No description provided for @memberManagementReenrollMessageMany.
  ///
  /// In en, this message translates to:
  /// **'{count} members will regain full access.'**
  String memberManagementReenrollMessageMany(int count);

  /// No description provided for @memberManagementConfirmReenrollAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm re-enroll'**
  String get memberManagementConfirmReenrollAction;

  /// No description provided for @memberManagementConfirmGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm grade assignment'**
  String get memberManagementConfirmGradeTitle;

  /// No description provided for @memberManagementConfirmGradeOne.
  ///
  /// In en, this message translates to:
  /// **'Set {name} to Grade {grade}?'**
  String memberManagementConfirmGradeOne(String name, int grade);

  /// No description provided for @memberManagementConfirmGradeMany.
  ///
  /// In en, this message translates to:
  /// **'Set {count} members to Grade {grade}?'**
  String memberManagementConfirmGradeMany(int count, int grade);

  /// No description provided for @memberManagementBlockReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Block reason: {reason}'**
  String memberManagementBlockReasonLabel(String reason);

  /// No description provided for @memberManagementUnenrollReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Unenrolled: {reason}'**
  String memberManagementUnenrollReasonLabel(String reason);

  /// No description provided for @memberManagementPreviewAndMore.
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String memberManagementPreviewAndMore(int count);

  /// No description provided for @memberManagementEditMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get memberManagementEditMemberTitle;

  /// No description provided for @memberManagementEditMemberIntro.
  ///
  /// In en, this message translates to:
  /// **'Update login username (student ID), contact email, grade, and display name. Changing a student ID also updates their sign-in username.'**
  String get memberManagementEditMemberIntro;

  /// No description provided for @memberManagementLoadMemberFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load member: {error}'**
  String memberManagementLoadMemberFailed(String error);

  /// No description provided for @memberManagementMemberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Member not found'**
  String get memberManagementMemberNotFound;

  /// No description provided for @memberManagementUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update member'**
  String get memberManagementUpdateFailed;

  /// No description provided for @memberManagementStudentPersonalBadge.
  ///
  /// In en, this message translates to:
  /// **'Student personal badge'**
  String get memberManagementStudentPersonalBadge;

  /// No description provided for @memberManagementStudentPersonalBadgeHint.
  ///
  /// In en, this message translates to:
  /// **'Optional photo the student chose in Settings. This does not replace the official school photo above.'**
  String get memberManagementStudentPersonalBadgeHint;

  /// No description provided for @memberManagementFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get memberManagementFullNameLabel;

  /// No description provided for @memberManagementFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Legal / roster name'**
  String get memberManagementFullNameHint;

  /// No description provided for @memberManagementFullNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Juan Dela Cruz'**
  String get memberManagementFullNameExample;

  /// No description provided for @memberManagementStudentIdUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID (username)'**
  String get memberManagementStudentIdUsernameLabel;

  /// No description provided for @memberManagementStudentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get memberManagementStudentIdLabel;

  /// No description provided for @memberManagementStudentIdSignInHint.
  ///
  /// In en, this message translates to:
  /// **'School-issued ID for sign-in'**
  String get memberManagementStudentIdSignInHint;

  /// No description provided for @memberManagementStudentIdProvisionHint.
  ///
  /// In en, this message translates to:
  /// **'School-issued ID (min. 6 characters)'**
  String get memberManagementStudentIdProvisionHint;

  /// No description provided for @memberManagementContactEmailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact email (optional)'**
  String get memberManagementContactEmailOptionalLabel;

  /// No description provided for @memberManagementContactEmailHint.
  ///
  /// In en, this message translates to:
  /// **'For notifications; can also sign in if set'**
  String get memberManagementContactEmailHint;

  /// No description provided for @memberManagementContactEmailFutureHint.
  ///
  /// In en, this message translates to:
  /// **'Contact email for future login'**
  String get memberManagementContactEmailFutureHint;

  /// No description provided for @memberManagementNoGrade.
  ///
  /// In en, this message translates to:
  /// **'No grade'**
  String get memberManagementNoGrade;

  /// No description provided for @memberManagementSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get memberManagementSaveChanges;

  /// No description provided for @memberManagementPasswordSection.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get memberManagementPasswordSection;

  /// No description provided for @memberManagementPasswordSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Set a new sign-in password for this member. Their current session stays active until they sign out.'**
  String get memberManagementPasswordSectionHint;

  /// No description provided for @memberManagementConfirmPasswordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm password reset'**
  String get memberManagementConfirmPasswordResetTitle;

  /// No description provided for @memberManagementConfirmPasswordResetMessage.
  ///
  /// In en, this message translates to:
  /// **'Set a new sign-in password for {name}? They will need it the next time they sign in.'**
  String memberManagementConfirmPasswordResetMessage(String name);

  /// No description provided for @memberManagementResetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get memberManagementResetPasswordAction;

  /// No description provided for @memberManagementPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset for {name}'**
  String memberManagementPasswordResetSuccess(String name);

  /// No description provided for @memberManagementPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset password'**
  String get memberManagementPasswordResetFailed;

  /// No description provided for @memberManagementResetPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password for {name}'**
  String memberManagementResetPasswordDialogTitle(String name);

  /// No description provided for @memberManagementResetPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a new sign-in password. Use the shortcuts below or enter one manually.'**
  String get memberManagementResetPasswordIntro;

  /// No description provided for @memberManagementUseUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Use username / student ID'**
  String get memberManagementUseUsernamePassword;

  /// No description provided for @memberManagementGenerate8DigitPassword.
  ///
  /// In en, this message translates to:
  /// **'Generate 8-digit password'**
  String get memberManagementGenerate8DigitPassword;

  /// No description provided for @memberManagementPasswordMinHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get memberManagementPasswordMinHint;

  /// No description provided for @memberManagementConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get memberManagementConfirmPasswordLabel;

  /// No description provided for @memberManagementAppliedAt.
  ///
  /// In en, this message translates to:
  /// **'Applied {date}'**
  String memberManagementAppliedAt(String date);

  /// No description provided for @memberManagementStudentIdWithValue.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {id}'**
  String memberManagementStudentIdWithValue(String id);

  /// No description provided for @memberManagementViewOnlyNoPermission.
  ///
  /// In en, this message translates to:
  /// **'View only — you do not have permission to approve applications.'**
  String get memberManagementViewOnlyNoPermission;

  /// No description provided for @memberManagementRejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Reject application'**
  String get memberManagementRejectApplication;

  /// No description provided for @memberManagementRejectApplicationHint.
  ///
  /// In en, this message translates to:
  /// **'Let the applicant know why…'**
  String get memberManagementRejectApplicationHint;

  /// No description provided for @memberManagementNoPendingApplications.
  ///
  /// In en, this message translates to:
  /// **'No pending applications'**
  String get memberManagementNoPendingApplications;

  /// No description provided for @memberManagementNoPendingApplicationsHint.
  ///
  /// In en, this message translates to:
  /// **'When someone signs up and completes the Join form, their request will appear here.'**
  String get memberManagementNoPendingApplicationsHint;

  /// No description provided for @studentRosterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or student ID…'**
  String get studentRosterSearchHint;

  /// No description provided for @studentRosterAssignSelected.
  ///
  /// In en, this message translates to:
  /// **'Assign grade to selected'**
  String get studentRosterAssignSelected;

  /// No description provided for @studentRosterAddStudent.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get studentRosterAddStudent;

  /// No description provided for @studentRosterAddStudentIntro.
  ///
  /// In en, this message translates to:
  /// **'Creates a pre-approved account. The student signs in using their school ID in both fields until email auth is enabled.'**
  String get studentRosterAddStudentIntro;

  /// No description provided for @studentRosterSelectGrade.
  ///
  /// In en, this message translates to:
  /// **'Select a grade'**
  String get studentRosterSelectGrade;

  /// No description provided for @studentRosterAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get studentRosterAdding;

  /// No description provided for @studentRosterAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added {name}. They can sign in with their student ID as the password.'**
  String studentRosterAddedSuccess(String name);

  /// No description provided for @studentRosterAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add student'**
  String get studentRosterAddFailed;

  /// No description provided for @studentRosterGradeStatusLine.
  ///
  /// In en, this message translates to:
  /// **'{grade} · {status}'**
  String studentRosterGradeStatusLine(String grade, String status);

  /// No description provided for @studentRosterOfficialPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Official photo updated'**
  String get studentRosterOfficialPhotoUpdated;

  /// No description provided for @studentRosterOfficialPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Official photo removed'**
  String get studentRosterOfficialPhotoRemoved;

  /// No description provided for @studentRosterOfficialPhotoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Official school photo'**
  String get studentRosterOfficialPhotoSectionTitle;

  /// No description provided for @studentRosterOfficialPhotoSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Permanent school record for faculty and admins. Stored separately from any personal photo the student may add in Settings (when allowed). A student personal badge never replaces or deletes this official image.'**
  String get studentRosterOfficialPhotoSectionHint;

  /// No description provided for @studentRosterPhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo update failed: {error}'**
  String studentRosterPhotoUpdateFailed(String error);

  /// No description provided for @studentRosterAssignGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign grade'**
  String get studentRosterAssignGradeTitle;

  /// No description provided for @studentRosterAllSelected.
  ///
  /// In en, this message translates to:
  /// **'All {count} selected'**
  String studentRosterAllSelected(int count);

  /// No description provided for @studentRosterOfficialPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Official photo — {name}'**
  String studentRosterOfficialPhotoTitle(String name);

  /// No description provided for @studentRosterSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Section: {section}'**
  String studentRosterSectionLabel(String section);

  /// No description provided for @studentRosterAssignFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign grades: {error}'**
  String studentRosterAssignFailed(String error);

  /// No description provided for @studentRosterUpdatedCount.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} student(s)'**
  String studentRosterUpdatedCount(int count);

  /// No description provided for @studentRosterLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String studentRosterLoadFailed(String error);

  /// No description provided for @studentRosterNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage the student roster.'**
  String get studentRosterNoPermission;

  /// No description provided for @studentRosterNotSchool.
  ///
  /// In en, this message translates to:
  /// **'Student roster and grades are only available for school-type organizations.'**
  String get studentRosterNotSchool;

  /// No description provided for @studentRosterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No students yet. Tap Add Student to provision an account.'**
  String get studentRosterEmpty;

  /// No description provided for @studentRosterNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No students match your filters.'**
  String get studentRosterNoMatch;

  /// No description provided for @studentRosterAssignGradeWhichGroup.
  ///
  /// In en, this message translates to:
  /// **'{count} students are selected. Assign a grade to which group?'**
  String studentRosterAssignGradeWhichGroup(int count);

  /// No description provided for @studentRosterOnlyNamed.
  ///
  /// In en, this message translates to:
  /// **'Only {name}'**
  String studentRosterOnlyNamed(String name);

  /// No description provided for @studentRosterOnlyThisStudent.
  ///
  /// In en, this message translates to:
  /// **'Only this student'**
  String get studentRosterOnlyThisStudent;

  /// No description provided for @studentRosterAssignGradeToOne.
  ///
  /// In en, this message translates to:
  /// **'Assign grade to {name}'**
  String studentRosterAssignGradeToOne(String name);

  /// No description provided for @studentRosterAssignGradeToMany.
  ///
  /// In en, this message translates to:
  /// **'Assign grade to {count} students'**
  String studentRosterAssignGradeToMany(int count);

  /// No description provided for @studentRosterConfirmGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm grade assignment'**
  String get studentRosterConfirmGradeTitle;

  /// No description provided for @studentRosterConfirmGradeOne.
  ///
  /// In en, this message translates to:
  /// **'Set {name} to Grade {grade}?'**
  String studentRosterConfirmGradeOne(String name, int grade);

  /// No description provided for @studentRosterConfirmGradeMany.
  ///
  /// In en, this message translates to:
  /// **'Set {count} students to Grade {grade}?'**
  String studentRosterConfirmGradeMany(int count, int grade);

  /// No description provided for @studentRosterPreviewAndMore.
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String studentRosterPreviewAndMore(int count);

  /// No description provided for @rolesManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles & Permissions'**
  String get rolesManagementTitle;

  /// No description provided for @rolesAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get rolesAssignments;

  /// No description provided for @rolesCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get rolesCapabilities;

  /// No description provided for @rolesCreateRole.
  ///
  /// In en, this message translates to:
  /// **'Create Role'**
  String get rolesCreateRole;

  /// No description provided for @rolesSystemRoles.
  ///
  /// In en, this message translates to:
  /// **'System Roles'**
  String get rolesSystemRoles;

  /// No description provided for @rolesCustomRoles.
  ///
  /// In en, this message translates to:
  /// **'Custom Roles'**
  String get rolesCustomRoles;

  /// No description provided for @rolesNoCapabilities.
  ///
  /// In en, this message translates to:
  /// **'No capabilities assigned'**
  String get rolesNoCapabilities;

  /// No description provided for @rolesMoreCapabilities.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String rolesMoreCapabilities(int count);

  /// No description provided for @rolesAssignUsers.
  ///
  /// In en, this message translates to:
  /// **'Assign Users'**
  String get rolesAssignUsers;

  /// No description provided for @rolesSeedFailed.
  ///
  /// In en, this message translates to:
  /// **'Seed failed: {error}'**
  String rolesSeedFailed(String error);

  /// No description provided for @rolesSeedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Default roles added successfully'**
  String get rolesSeedSuccess;

  /// No description provided for @rolesCreateManually.
  ///
  /// In en, this message translates to:
  /// **'Create Role Manually'**
  String get rolesCreateManually;

  /// No description provided for @rolesNoRolesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No roles defined yet'**
  String get rolesNoRolesEmpty;

  /// No description provided for @rolesSystemBadge.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get rolesSystemBadge;

  /// No description provided for @rolesSeedDefaultRoles.
  ///
  /// In en, this message translates to:
  /// **'Seed Default Roles'**
  String get rolesSeedDefaultRoles;

  /// No description provided for @rolesSeeding.
  ///
  /// In en, this message translates to:
  /// **'Seeding…'**
  String get rolesSeeding;

  /// No description provided for @rolesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first custom role to grant staff\nspecific capabilities within this organisation.'**
  String get rolesEmptyDescription;

  /// No description provided for @rolesAllCapabilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'{roleName} — All Capabilities'**
  String rolesAllCapabilitiesTitle(String roleName);

  /// No description provided for @roleAssignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'User Role Assignments'**
  String get roleAssignmentsTitle;

  /// No description provided for @roleAssignmentsNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No approved users found.'**
  String get roleAssignmentsNoUsers;

  /// No description provided for @roleAssignmentsNoRoles.
  ///
  /// In en, this message translates to:
  /// **'No roles assigned'**
  String get roleAssignmentsNoRoles;

  /// No description provided for @assignRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign: {roleName}'**
  String assignRoleTitle(String roleName);

  /// No description provided for @assignRoleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Role assigned successfully'**
  String get assignRoleSuccess;

  /// No description provided for @assignRoleFailed.
  ///
  /// In en, this message translates to:
  /// **'Assignment failed: {error}'**
  String assignRoleFailed(String error);

  /// No description provided for @assignRoleScopeType.
  ///
  /// In en, this message translates to:
  /// **'Scope Type'**
  String get assignRoleScopeType;

  /// No description provided for @assignRoleRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment?'**
  String get assignRoleRemoveTitle;

  /// No description provided for @assignRoleRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this role assignment ({scope})? The user will immediately lose the permissions granted by this role.'**
  String assignRoleRemoveConfirm(Object scope);

  /// No description provided for @capabilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get capabilitiesTitle;

  /// No description provided for @capabilitiesTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get capabilitiesTabCustom;

  /// No description provided for @capabilitiesTabBuiltins.
  ///
  /// In en, this message translates to:
  /// **'Built-ins'**
  String get capabilitiesTabBuiltins;

  /// No description provided for @capabilitiesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Capability?'**
  String get capabilitiesDeleteTitle;

  /// No description provided for @capabilitiesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed. Roles using it will lose this capability assignment.'**
  String capabilitiesDeleteBody(String name);

  /// No description provided for @capabilitiesCreateLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Capability'**
  String get capabilitiesCreateLabel;

  /// No description provided for @capabilitiesBackedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Backed by (built-in action)'**
  String get capabilitiesBackedByLabel;

  /// No description provided for @capabilitiesBuiltinsIntro.
  ///
  /// In en, this message translates to:
  /// **'These are the built-in capabilities available across all SpeakUp Connect organisations. They cannot be modified or removed — only custom capability aliases can be created on top of them.'**
  String get capabilitiesBuiltinsIntro;

  /// No description provided for @roleEditorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Role'**
  String get roleEditorCreateTitle;

  /// No description provided for @roleEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get roleEditorEditTitle;

  /// No description provided for @roleEditorRoleDetails.
  ///
  /// In en, this message translates to:
  /// **'Role Details'**
  String get roleEditorRoleDetails;

  /// No description provided for @roleEditorRoleName.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get roleEditorRoleName;

  /// No description provided for @roleEditorDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get roleEditorDescription;

  /// No description provided for @roleEditorCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get roleEditorCapabilities;

  /// No description provided for @roleEditorManageCustom.
  ///
  /// In en, this message translates to:
  /// **'Manage Custom'**
  String get roleEditorManageCustom;

  /// No description provided for @roleEditorCapabilitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Select the built-in capabilities this role grants.'**
  String get roleEditorCapabilitiesHint;

  /// No description provided for @roleEditorCustomCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Custom Capabilities'**
  String get roleEditorCustomCapabilities;

  /// No description provided for @roleEditorCustomCapabilitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Org-defined capability aliases built on top of built-ins.'**
  String get roleEditorCustomCapabilitiesHint;

  /// No description provided for @roleEditorNoCustomCaps.
  ///
  /// In en, this message translates to:
  /// **'No custom capabilities yet.'**
  String get roleEditorNoCustomCaps;

  /// No description provided for @roleEditorCreateCustomCap.
  ///
  /// In en, this message translates to:
  /// **'Create a custom capability →'**
  String get roleEditorCreateCustomCap;

  /// No description provided for @roleEditorSaveRole.
  ///
  /// In en, this message translates to:
  /// **'Save Role'**
  String get roleEditorSaveRole;

  /// No description provided for @roleEditorSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get roleEditorSaving;

  /// No description provided for @roleEditorSaved.
  ///
  /// In en, this message translates to:
  /// **'Role saved'**
  String get roleEditorSaved;

  /// No description provided for @roleEditorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String roleEditorSaveFailed(String error);

  /// No description provided for @roleEditorAssignUsers.
  ///
  /// In en, this message translates to:
  /// **'Assign Users'**
  String get roleEditorAssignUsers;

  /// No description provided for @roleEditorBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on: {permission}'**
  String roleEditorBasedOn(String permission);

  /// No description provided for @orgSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization Settings'**
  String get orgSettingsTitle;

  /// No description provided for @orgSettingsDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get orgSettingsDisplayName;

  /// No description provided for @orgSettingsDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Riverside High'**
  String get orgSettingsDisplayNameHint;

  /// No description provided for @orgSettingsBrandingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Branding updated successfully'**
  String get orgSettingsBrandingUpdated;

  /// No description provided for @orgSettingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String orgSettingsSaveFailed(String error);

  /// No description provided for @orgSettingsContrastWarning.
  ///
  /// In en, this message translates to:
  /// **'Contrast Warning'**
  String get orgSettingsContrastWarning;

  /// No description provided for @orgSettingsSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get orgSettingsSaveAnyway;

  /// No description provided for @orgSettingsAutoAdjustSave.
  ///
  /// In en, this message translates to:
  /// **'Auto-adjust & Save'**
  String get orgSettingsAutoAdjustSave;

  /// No description provided for @orgSettingsSeedCategoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Seed failed: {error}'**
  String orgSettingsSeedCategoriesFailed(String error);

  /// No description provided for @orgSettingsSeedCategoriesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Default categories added successfully'**
  String get orgSettingsSeedCategoriesSuccess;

  /// No description provided for @orgSettingsChangeOrgTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change organization type?'**
  String get orgSettingsChangeOrgTypeTitle;

  /// No description provided for @orgSettingsChangeOrgTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change from {fromType} to {toType}?\n\n{description}\n\nThis affects which admin features are available (such as student grades and roster for schools).'**
  String orgSettingsChangeOrgTypeConfirm(
      String fromType, String toType, String description);

  /// No description provided for @orgSettingsOrgTypeSaved.
  ///
  /// In en, this message translates to:
  /// **'Organization type set to {type}'**
  String orgSettingsOrgTypeSaved(String type);

  /// No description provided for @orgSettingsOrgTypeFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String orgSettingsOrgTypeFailed(String error);

  /// No description provided for @orgSettingsTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orgSettingsTypeLabel;

  /// No description provided for @orgSettingsSaveType.
  ///
  /// In en, this message translates to:
  /// **'Save type'**
  String get orgSettingsSaveType;

  /// No description provided for @orgSettingsAllowPersonalPhotos.
  ///
  /// In en, this message translates to:
  /// **'Allow personal profile photos'**
  String get orgSettingsAllowPersonalPhotos;

  /// No description provided for @orgSettingsRequireApproval.
  ///
  /// In en, this message translates to:
  /// **'Require approval before publishing'**
  String get orgSettingsRequireApproval;

  /// No description provided for @orgSettingsOrgNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get orgSettingsOrgNameTitle;

  /// No description provided for @orgSettingsOrgNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Displayed on the splash screen as \"SpeakUp [Name]\".'**
  String get orgSettingsOrgNameSubtitle;

  /// No description provided for @orgSettingsBrandColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Brand Colors'**
  String get orgSettingsBrandColorsTitle;

  /// No description provided for @orgSettingsBrandColorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit hex codes from the organization\'s brand guide (e.g. #1A73E8). Changes apply to all connected devices in real time and are cached locally for instant startup.'**
  String get orgSettingsBrandColorsSubtitle;

  /// No description provided for @orgSettingsPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get orgSettingsPrimaryColor;

  /// No description provided for @orgSettingsSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get orgSettingsSecondaryColor;

  /// No description provided for @orgSettingsColorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. #1A73E8'**
  String get orgSettingsColorHint;

  /// No description provided for @orgSettingsSecondaryColorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. #000000'**
  String get orgSettingsSecondaryColorHint;

  /// No description provided for @orgSettingsSaveBranding.
  ///
  /// In en, this message translates to:
  /// **'Save Branding'**
  String get orgSettingsSaveBranding;

  /// No description provided for @orgSettingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get orgSettingsSaving;

  /// No description provided for @orgSettingsBrandingInfo.
  ///
  /// In en, this message translates to:
  /// **'After saving, the new colors will appear immediately on all connected devices. On this device the branding is also written to local storage, so it loads correctly on the next app launch before Firestore responds.'**
  String get orgSettingsBrandingInfo;

  /// No description provided for @orgSettingsReportCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Categories'**
  String get orgSettingsReportCategoriesTitle;

  /// No description provided for @orgSettingsReportCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories are required for users to submit concerns. Tap the button below to populate the default set.'**
  String get orgSettingsReportCategoriesSubtitle;

  /// No description provided for @orgSettingsCategoriesConfigured.
  ///
  /// In en, this message translates to:
  /// **'{count} categories configured'**
  String orgSettingsCategoriesConfigured(int count);

  /// No description provided for @orgSettingsAddDefaultCategories.
  ///
  /// In en, this message translates to:
  /// **'Add Default Categories'**
  String get orgSettingsAddDefaultCategories;

  /// No description provided for @orgSettingsAddingCategories.
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get orgSettingsAddingCategories;

  /// No description provided for @orgSettingsOrgTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization Type'**
  String get orgSettingsOrgTypeTitle;

  /// No description provided for @orgSettingsOrgTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Determines which features are available. Schools can use student grades and roster; municipalities and NGOs use member management without grades.'**
  String get orgSettingsOrgTypeSubtitle;

  /// No description provided for @orgSettingsMemberPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Member Profile Photos'**
  String get orgSettingsMemberPhotosTitle;

  /// No description provided for @orgSettingsMemberPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, students may upload a personal badge in Settings. Official school photos uploaded by staff remain a separate permanent record and are never overwritten.'**
  String get orgSettingsMemberPhotosSubtitle;

  /// No description provided for @orgSettingsMemberPhotosOn.
  ///
  /// In en, this message translates to:
  /// **'Currently ON — members can add a personal badge in Settings'**
  String get orgSettingsMemberPhotosOn;

  /// No description provided for @orgSettingsMemberPhotosOff.
  ///
  /// In en, this message translates to:
  /// **'Currently OFF — only official school photos are shown'**
  String get orgSettingsMemberPhotosOff;

  /// No description provided for @orgSettingsMemberPhotosEnabled.
  ///
  /// In en, this message translates to:
  /// **'Members can now upload personal profile photos'**
  String get orgSettingsMemberPhotosEnabled;

  /// No description provided for @orgSettingsMemberPhotosDisabled.
  ///
  /// In en, this message translates to:
  /// **'Personal profile photos are disabled for members'**
  String get orgSettingsMemberPhotosDisabled;

  /// No description provided for @orgSettingsReminderApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Approval'**
  String get orgSettingsReminderApprovalTitle;

  /// No description provided for @orgSettingsReminderApprovalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, members who can broadcast reminders but cannot approve them must submit reminders for review before they are published.'**
  String get orgSettingsReminderApprovalSubtitle;

  /// No description provided for @orgSettingsReminderApprovalOn.
  ///
  /// In en, this message translates to:
  /// **'Currently ON — reminders from non-approvers are held for review'**
  String get orgSettingsReminderApprovalOn;

  /// No description provided for @orgSettingsReminderApprovalOff.
  ///
  /// In en, this message translates to:
  /// **'Currently OFF — reminders publish immediately'**
  String get orgSettingsReminderApprovalOff;

  /// No description provided for @orgSettingsReminderApprovalEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders now require approval before publishing'**
  String get orgSettingsReminderApprovalEnabled;

  /// No description provided for @orgSettingsReminderApprovalDisabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders now publish directly'**
  String get orgSettingsReminderApprovalDisabled;

  /// No description provided for @orgSettingsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change this setting.'**
  String get orgSettingsPermissionDenied;

  /// No description provided for @orgSettingsPrimarySwatch.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get orgSettingsPrimarySwatch;

  /// No description provided for @orgSettingsSecondarySwatch.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get orgSettingsSecondarySwatch;

  /// No description provided for @orgSettingsRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get orgSettingsRequired;

  /// No description provided for @orgSettingsHexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit hex (e.g. #1A73E8)'**
  String get orgSettingsHexInvalid;

  /// No description provided for @orgSettingsPrimaryHexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Primary color must be a valid 6-digit hex (e.g. #1A73E8).'**
  String get orgSettingsPrimaryHexInvalid;

  /// No description provided for @orgSettingsSecondaryHexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Secondary color must be a valid 6-digit hex (e.g. #000000).'**
  String get orgSettingsSecondaryHexInvalid;

  /// No description provided for @orgSettingsContrastLightBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'light backgrounds'**
  String get orgSettingsContrastLightBackgrounds;

  /// No description provided for @orgSettingsContrastDarkBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'dark backgrounds'**
  String get orgSettingsContrastDarkBackgrounds;

  /// No description provided for @orgSettingsContrastLightAndDarkBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'light and dark backgrounds'**
  String get orgSettingsContrastLightAndDarkBackgrounds;

  /// No description provided for @orgSettingsContrastSecondaryFallback.
  ///
  /// In en, this message translates to:
  /// **'Your primary color ({primary}) isn\'t visible enough on {surfaces} — it will blend into the background.\n\nYour secondary color ({secondary}) will be used as a fallback for buttons and icons, but you may want a more suitable primary.\n\nYou can save anyway or let the app shift the primary to the nearest contrast-safe shade.'**
  String orgSettingsContrastSecondaryFallback(
      String primary, String secondary, String surfaces);

  /// No description provided for @orgSettingsContrastNeither.
  ///
  /// In en, this message translates to:
  /// **'Neither your primary ({primary}) nor secondary ({secondary}) color provides enough contrast against {surfaces}. Buttons, links, and icons may be hard to see.\n\nYou can save anyway, or let the app shift the primary color to the nearest contrast-safe shade.'**
  String orgSettingsContrastNeither(
      String primary, String secondary, String surfaces);

  /// No description provided for @orgSettingsProfilePhotoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile photo setting did not save.'**
  String get orgSettingsProfilePhotoSaveFailed;

  /// No description provided for @orgSettingsReminderApprovalSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Reminder approval setting did not save.'**
  String get orgSettingsReminderApprovalSaveFailed;

  /// No description provided for @orgTypeAdminSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get orgTypeAdminSchool;

  /// No description provided for @orgTypeAdminUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get orgTypeAdminUniversity;

  /// No description provided for @orgTypeAdminLgu.
  ///
  /// In en, this message translates to:
  /// **'Municipality / LGU'**
  String get orgTypeAdminLgu;

  /// No description provided for @orgTypeAdminNgo.
  ///
  /// In en, this message translates to:
  /// **'NGO'**
  String get orgTypeAdminNgo;

  /// No description provided for @orgTypeAdminChurch.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get orgTypeAdminChurch;

  /// No description provided for @orgTypeAdminCorporation.
  ///
  /// In en, this message translates to:
  /// **'Corporation'**
  String get orgTypeAdminCorporation;

  /// No description provided for @orgTypeAdminOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get orgTypeAdminOther;

  /// No description provided for @orgTypeAdminSchoolDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables student grades, roster, and class-based features.'**
  String get orgTypeAdminSchoolDesc;

  /// No description provided for @orgTypeAdminUniversityDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables student grades, roster, and class-based features.'**
  String get orgTypeAdminUniversityDesc;

  /// No description provided for @orgTypeAdminLguDesc.
  ///
  /// In en, this message translates to:
  /// **'For municipalities, barangays, and local government units.'**
  String get orgTypeAdminLguDesc;

  /// No description provided for @orgTypeAdminNgoDesc.
  ///
  /// In en, this message translates to:
  /// **'For non-profit and community organizations.'**
  String get orgTypeAdminNgoDesc;

  /// No description provided for @orgTypeAdminChurchDesc.
  ///
  /// In en, this message translates to:
  /// **'For churches and faith-based communities.'**
  String get orgTypeAdminChurchDesc;

  /// No description provided for @orgTypeAdminCorporationDesc.
  ///
  /// In en, this message translates to:
  /// **'For companies and workplace communities.'**
  String get orgTypeAdminCorporationDesc;

  /// No description provided for @orgTypeAdminOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Generic organization without type-specific features.'**
  String get orgTypeAdminOtherDesc;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorPrefix(String error);

  /// No description provided for @commonRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get commonRole;

  /// No description provided for @commonNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get commonNameRequired;

  /// No description provided for @adminDashboardAnonymousDate.
  ///
  /// In en, this message translates to:
  /// **'Anonymous · {date}'**
  String adminDashboardAnonymousDate(String date);

  /// No description provided for @adminDashboardSubmitterDate.
  ///
  /// In en, this message translates to:
  /// **'{name} · {date}'**
  String adminDashboardSubmitterDate(String name, String date);

  /// No description provided for @reportCategoryFacility.
  ///
  /// In en, this message translates to:
  /// **'Facility & Infrastructure'**
  String get reportCategoryFacility;

  /// No description provided for @reportCategorySafety.
  ///
  /// In en, this message translates to:
  /// **'Safety & Security'**
  String get reportCategorySafety;

  /// No description provided for @reportCategoryAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic Concern'**
  String get reportCategoryAcademic;

  /// No description provided for @reportCategoryBullying.
  ///
  /// In en, this message translates to:
  /// **'Bullying & Harassment'**
  String get reportCategoryBullying;

  /// No description provided for @reportCategorySanitation.
  ///
  /// In en, this message translates to:
  /// **'Sanitation & Cleanliness'**
  String get reportCategorySanitation;

  /// No description provided for @reportCategoryConduct.
  ///
  /// In en, this message translates to:
  /// **'Staff / Teacher Conduct'**
  String get reportCategoryConduct;

  /// No description provided for @reportCategoryAdministrative.
  ///
  /// In en, this message translates to:
  /// **'Administrative'**
  String get reportCategoryAdministrative;

  /// No description provided for @reportCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportCategoryOther;

  /// No description provided for @adminReportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Detail'**
  String get adminReportDetailTitle;

  /// No description provided for @adminReportDetailLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading report...'**
  String get adminReportDetailLoading;

  /// No description provided for @adminReportDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report'**
  String get adminReportDetailLoadFailed;

  /// No description provided for @adminReportDetailSubmittedDate.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String adminReportDetailSubmittedDate(String date);

  /// No description provided for @adminReportDetailAnonymousSubmission.
  ///
  /// In en, this message translates to:
  /// **'Anonymous submission'**
  String get adminReportDetailAnonymousSubmission;

  /// No description provided for @adminReportDetailBySubmitter.
  ///
  /// In en, this message translates to:
  /// **'By: {name}'**
  String adminReportDetailBySubmitter(String name);

  /// No description provided for @adminReportDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminReportDetailDescription;

  /// No description provided for @adminReportDetailPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos ({count})'**
  String adminReportDetailPhotos(int count);

  /// No description provided for @adminReportDetailAdminActions.
  ///
  /// In en, this message translates to:
  /// **'Admin Actions'**
  String get adminReportDetailAdminActions;

  /// No description provided for @adminReportDetailUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get adminReportDetailUpdateStatus;

  /// No description provided for @adminReportDetailAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get adminReportDetailAddNote;

  /// No description provided for @adminReportDetailAssignToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Assign to Admin'**
  String get adminReportDetailAssignToAdmin;

  /// No description provided for @adminReportDetailReassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get adminReportDetailReassign;

  /// No description provided for @adminReportDetailUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get adminReportDetailUnassigned;

  /// No description provided for @adminReportDetailAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to: {name}'**
  String adminReportDetailAssignedTo(String name);

  /// No description provided for @adminReportDetailAdminNotes.
  ///
  /// In en, this message translates to:
  /// **'Admin Notes ({count})'**
  String adminReportDetailAdminNotes(int count);

  /// No description provided for @adminReportDetailStatusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status History'**
  String get adminReportDetailStatusHistory;

  /// No description provided for @adminReportDetailAddAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Add Admin Note'**
  String get adminReportDetailAddAdminNote;

  /// No description provided for @adminReportDetailCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current: {status}'**
  String adminReportDetailCurrentStatus(String status);

  /// No description provided for @adminReportDetailNewStatus.
  ///
  /// In en, this message translates to:
  /// **'New Status'**
  String get adminReportDetailNewStatus;

  /// No description provided for @adminReportDetailStatusChangeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about this status change…'**
  String get adminReportDetailStatusChangeNoteHint;

  /// No description provided for @adminReportDetailAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign to Admin'**
  String get adminReportDetailAssignTitle;

  /// No description provided for @adminReportDetailSearchAdmins.
  ///
  /// In en, this message translates to:
  /// **'Search admins…'**
  String get adminReportDetailSearchAdmins;

  /// No description provided for @adminReportDetailNoAdmins.
  ///
  /// In en, this message translates to:
  /// **'No admins found.'**
  String get adminReportDetailNoAdmins;

  /// No description provided for @adminReportDetailLoadAdminsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load admins: {error}'**
  String adminReportDetailLoadAdminsFailed(String error);

  /// No description provided for @adminReportDetailAssignFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign report: {error}'**
  String adminReportDetailAssignFailed(String error);

  /// No description provided for @adminReportDetailUpdateStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String adminReportDetailUpdateStatusFailed(String error);

  /// No description provided for @adminReportDetailAddNoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add note: {error}'**
  String adminReportDetailAddNoteFailed(String error);

  /// No description provided for @adminReportDetailNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get adminReportDetailNoteLabel;

  /// No description provided for @adminReportDetailEnterNote.
  ///
  /// In en, this message translates to:
  /// **'Enter your note…'**
  String get adminReportDetailEnterNote;

  /// No description provided for @reportDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetailsTitle;

  /// No description provided for @reportDetailsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading report...'**
  String get reportDetailsLoading;

  /// No description provided for @reportDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report'**
  String get reportDetailsLoadFailed;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReportsTitle;

  /// No description provided for @myReportsNoReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get myReportsNoReportsYet;

  /// No description provided for @myReportsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get myReportsTabAll;

  /// No description provided for @myReportsTabInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get myReportsTabInProgress;

  /// No description provided for @myReportsTabResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get myReportsTabResolved;

  /// No description provided for @myReportsNewReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get myReportsNewReport;

  /// No description provided for @myReportsEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any reports yet.'**
  String get myReportsEmptyAll;

  /// No description provided for @myReportsEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No reports with status \"{status}\".'**
  String myReportsEmptyFiltered(String status);

  /// No description provided for @rolesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get rolesEdit;

  /// No description provided for @roleEditorNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Guidance Counselor'**
  String get roleEditorNameHint;

  /// No description provided for @roleEditorDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe who this role is for'**
  String get roleEditorDescriptionHint;

  /// No description provided for @assignRoleSelectUser.
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get assignRoleSelectUser;

  /// No description provided for @assignRoleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or student ID'**
  String get assignRoleSearchHint;

  /// No description provided for @assignRoleConfirmAssignment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Assignment'**
  String get assignRoleConfirmAssignment;

  /// No description provided for @assignRoleAssigning.
  ///
  /// In en, this message translates to:
  /// **'Assigning…'**
  String get assignRoleAssigning;

  /// No description provided for @assignRoleNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get assignRoleNoUsersFound;

  /// No description provided for @assignRoleScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Scope'**
  String get assignRoleScopeTitle;

  /// No description provided for @assignRoleScopeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define how broadly this role applies for this user.'**
  String get assignRoleScopeSubtitle;

  /// No description provided for @assignRoleScopeOptionOrg.
  ///
  /// In en, this message translates to:
  /// **'Org-wide'**
  String get assignRoleScopeOptionOrg;

  /// No description provided for @assignRoleScopeOptionTag.
  ///
  /// In en, this message translates to:
  /// **'Specific tag'**
  String get assignRoleScopeOptionTag;

  /// No description provided for @assignRoleScopeOptionClass.
  ///
  /// In en, this message translates to:
  /// **'Specific class / section'**
  String get assignRoleScopeOptionClass;

  /// No description provided for @assignRoleScopeOptionGroup.
  ///
  /// In en, this message translates to:
  /// **'Specific group / club'**
  String get assignRoleScopeOptionGroup;

  /// No description provided for @assignRoleScopeOptionDepartment.
  ///
  /// In en, this message translates to:
  /// **'Specific department'**
  String get assignRoleScopeOptionDepartment;

  /// No description provided for @assignRoleScopeOptionBarangay.
  ///
  /// In en, this message translates to:
  /// **'Specific barangay'**
  String get assignRoleScopeOptionBarangay;

  /// No description provided for @assignRoleScopeFieldTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get assignRoleScopeFieldTag;

  /// No description provided for @assignRoleScopeFieldClassId.
  ///
  /// In en, this message translates to:
  /// **'Class ID'**
  String get assignRoleScopeFieldClassId;

  /// No description provided for @assignRoleScopeFieldGroupId.
  ///
  /// In en, this message translates to:
  /// **'Group ID'**
  String get assignRoleScopeFieldGroupId;

  /// No description provided for @assignRoleScopeFieldDepartmentId.
  ///
  /// In en, this message translates to:
  /// **'Department ID'**
  String get assignRoleScopeFieldDepartmentId;

  /// No description provided for @assignRoleScopeFieldBarangayId.
  ///
  /// In en, this message translates to:
  /// **'Barangay ID'**
  String get assignRoleScopeFieldBarangayId;

  /// No description provided for @assignRoleScopeHintTag.
  ///
  /// In en, this message translates to:
  /// **'e.g. guidance'**
  String get assignRoleScopeHintTag;

  /// No description provided for @assignRoleScopeHintClass.
  ///
  /// In en, this message translates to:
  /// **'Firestore class document ID'**
  String get assignRoleScopeHintClass;

  /// No description provided for @assignRoleScopeHintGroup.
  ///
  /// In en, this message translates to:
  /// **'Firestore group document ID'**
  String get assignRoleScopeHintGroup;

  /// No description provided for @assignRoleScopeHintDepartment.
  ///
  /// In en, this message translates to:
  /// **'Firestore department document ID'**
  String get assignRoleScopeHintDepartment;

  /// No description provided for @assignRoleScopeHintBarangay.
  ///
  /// In en, this message translates to:
  /// **'Firestore barangay document ID'**
  String get assignRoleScopeHintBarangay;

  /// No description provided for @assignRoleScopeChipOrg.
  ///
  /// In en, this message translates to:
  /// **'Org-wide'**
  String get assignRoleScopeChipOrg;

  /// No description provided for @assignRoleScopeChipTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get assignRoleScopeChipTag;

  /// No description provided for @assignRoleScopeChipClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get assignRoleScopeChipClass;

  /// No description provided for @assignRoleScopeChipGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get assignRoleScopeChipGroup;

  /// No description provided for @assignRoleScopeChipDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get assignRoleScopeChipDepartment;

  /// No description provided for @assignRoleScopeChipDept.
  ///
  /// In en, this message translates to:
  /// **'Dept'**
  String get assignRoleScopeChipDept;

  /// No description provided for @assignRoleScopeChipBarangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay'**
  String get assignRoleScopeChipBarangay;

  /// No description provided for @assignRoleScopeValueTag.
  ///
  /// In en, this message translates to:
  /// **'Tag: {id}'**
  String assignRoleScopeValueTag(String id);

  /// No description provided for @assignRoleScopeValueClass.
  ///
  /// In en, this message translates to:
  /// **'Class: {id}'**
  String assignRoleScopeValueClass(String id);

  /// No description provided for @assignRoleScopeValueGroup.
  ///
  /// In en, this message translates to:
  /// **'Group: {id}'**
  String assignRoleScopeValueGroup(String id);

  /// No description provided for @assignRoleScopeValueDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department: {id}'**
  String assignRoleScopeValueDepartment(String id);

  /// No description provided for @assignRoleScopeValueBarangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay: {id}'**
  String assignRoleScopeValueBarangay(String id);

  /// No description provided for @assignRoleCurrentAssignments.
  ///
  /// In en, this message translates to:
  /// **'Current Assignments'**
  String get assignRoleCurrentAssignments;

  /// No description provided for @assignRoleAssignedDate.
  ///
  /// In en, this message translates to:
  /// **'Assigned {date}'**
  String assignRoleAssignedDate(String date);

  /// No description provided for @assignRoleRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove assignment'**
  String get assignRoleRemoveTooltip;

  /// No description provided for @assignRoleRevokeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap − to revoke an existing assignment.'**
  String get assignRoleRevokeHint;

  /// No description provided for @assignRoleRoleChip.
  ///
  /// In en, this message translates to:
  /// **'{role} · {scope}'**
  String assignRoleRoleChip(String role, String scope);

  /// No description provided for @capabilitiesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load custom capabilities:\n{error}'**
  String capabilitiesLoadFailed(String error);

  /// No description provided for @capabilitiesDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get capabilitiesDeleteTooltip;

  /// No description provided for @capabilitiesNewCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'New Custom Capability'**
  String get capabilitiesNewCustomTitle;

  /// No description provided for @capabilitiesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Capability Name'**
  String get capabilitiesNameLabel;

  /// No description provided for @capabilitiesNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Review Guidance Referral'**
  String get capabilitiesNameHint;

  /// No description provided for @capabilitiesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get capabilitiesNameRequired;

  /// No description provided for @capabilitiesDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get capabilitiesDescriptionLabel;

  /// No description provided for @capabilitiesSelectBacking.
  ///
  /// In en, this message translates to:
  /// **'Select a backing action'**
  String get capabilitiesSelectBacking;

  /// No description provided for @capabilitiesRestrictTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Restrict to tag (optional)'**
  String get capabilitiesRestrictTagLabel;

  /// No description provided for @capabilitiesRestrictTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. guidance'**
  String get capabilitiesRestrictTagHint;

  /// No description provided for @capabilitiesRestrictTagHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to apply to all content with this action.'**
  String get capabilitiesRestrictTagHelper;

  /// No description provided for @capabilitiesCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get capabilitiesCreating;

  /// No description provided for @capabilitiesNoCustomYet.
  ///
  /// In en, this message translates to:
  /// **'No custom capabilities yet'**
  String get capabilitiesNoCustomYet;

  /// No description provided for @capabilitiesNoCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a capability alias to give school-specific names to built-in actions.'**
  String get capabilitiesNoCustomDescription;

  /// No description provided for @permissionViewAllReports.
  ///
  /// In en, this message translates to:
  /// **'View all org reports'**
  String get permissionViewAllReports;

  /// No description provided for @permissionViewGroupReports.
  ///
  /// In en, this message translates to:
  /// **'View reports in assigned groups'**
  String get permissionViewGroupReports;

  /// No description provided for @permissionApproveReport.
  ///
  /// In en, this message translates to:
  /// **'Approve / close reports'**
  String get permissionApproveReport;

  /// No description provided for @permissionManageReports.
  ///
  /// In en, this message translates to:
  /// **'Update status, escalate & add notes'**
  String get permissionManageReports;

  /// No description provided for @permissionPostBulletinOrgWide.
  ///
  /// In en, this message translates to:
  /// **'Post bulletins org-wide'**
  String get permissionPostBulletinOrgWide;

  /// No description provided for @permissionPostBulletinToGroup.
  ///
  /// In en, this message translates to:
  /// **'Post bulletins to own groups'**
  String get permissionPostBulletinToGroup;

  /// No description provided for @permissionBroadcastReminders.
  ///
  /// In en, this message translates to:
  /// **'Broadcast reminders'**
  String get permissionBroadcastReminders;

  /// No description provided for @permissionApproveReminders.
  ///
  /// In en, this message translates to:
  /// **'Approve / reject reminders'**
  String get permissionApproveReminders;

  /// No description provided for @permissionManageGroupRoster.
  ///
  /// In en, this message translates to:
  /// **'Manage own group roster'**
  String get permissionManageGroupRoster;

  /// No description provided for @permissionManageClassRoster.
  ///
  /// In en, this message translates to:
  /// **'Manage class roster (school only)'**
  String get permissionManageClassRoster;

  /// No description provided for @permissionApproveApplications.
  ///
  /// In en, this message translates to:
  /// **'Approve join applications'**
  String get permissionApproveApplications;

  /// No description provided for @permissionBlockUsers.
  ///
  /// In en, this message translates to:
  /// **'Suspend or block users'**
  String get permissionBlockUsers;

  /// No description provided for @permissionManageOrganizationSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage org settings & branding'**
  String get permissionManageOrganizationSettings;

  /// No description provided for @permissionManageRoles.
  ///
  /// In en, this message translates to:
  /// **'Manage roles & assign permissions'**
  String get permissionManageRoles;

  /// No description provided for @permissionManageTranslations.
  ///
  /// In en, this message translates to:
  /// **'Translation moderator (edit UI strings)'**
  String get permissionManageTranslations;

  /// No description provided for @permissionViewAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'View audit logs'**
  String get permissionViewAuditLogs;

  /// No description provided for @permissionGroupReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get permissionGroupReports;

  /// No description provided for @permissionGroupBulletins.
  ///
  /// In en, this message translates to:
  /// **'Bulletins & News'**
  String get permissionGroupBulletins;

  /// No description provided for @permissionGroupReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get permissionGroupReminders;

  /// No description provided for @permissionGroupRosterUsers.
  ///
  /// In en, this message translates to:
  /// **'Roster & Users'**
  String get permissionGroupRosterUsers;

  /// No description provided for @permissionGroupAdministration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get permissionGroupAdministration;

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

  /// No description provided for @translationScreenNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen names'**
  String get translationScreenNamesTitle;

  /// No description provided for @translationScreenNamesIntro.
  ///
  /// In en, this message translates to:
  /// **'Create screen names, assign each to one app screen, and tag translation strings for filtering. Enable translation badges per app screen to control where in-context editing appears in translation mode.'**
  String get translationScreenNamesIntro;

  /// No description provided for @translationScreenNamesNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New screen name'**
  String get translationScreenNamesNewLabel;

  /// No description provided for @translationScreenNamesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add screen name'**
  String get translationScreenNamesAdd;

  /// No description provided for @translationScreenNamesCatalog.
  ///
  /// In en, this message translates to:
  /// **'Screen name catalog'**
  String get translationScreenNamesCatalog;

  /// No description provided for @translationScreenNamesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No screen names yet.'**
  String get translationScreenNamesEmpty;

  /// No description provided for @translationScreenNamesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen name'**
  String get translationScreenNamesNameLabel;

  /// No description provided for @translationScreenNamesAssignedRoute.
  ///
  /// In en, this message translates to:
  /// **'Assigned to: {route}'**
  String translationScreenNamesAssignedRoute(String route);

  /// No description provided for @translationScreenNamesUnassignRoute.
  ///
  /// In en, this message translates to:
  /// **'Unassign route'**
  String get translationScreenNamesUnassignRoute;

  /// No description provided for @translationScreenNamesRouteAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assign to app screen'**
  String get translationScreenNamesRouteAssignment;

  /// No description provided for @translationScreenNamesRouteHint.
  ///
  /// In en, this message translates to:
  /// **'Each app screen can have one screen name. Names already assigned elsewhere are hidden until unassigned. Turn on translation badges to show in-context edit badges on that screen during translation mode.'**
  String get translationScreenNamesRouteHint;

  /// No description provided for @translationScreenNamesBadgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation badges'**
  String get translationScreenNamesBadgesLabel;

  /// No description provided for @translationScreenNamesBadgesHint.
  ///
  /// In en, this message translates to:
  /// **'Show edit badges in app translation mode'**
  String get translationScreenNamesBadgesHint;

  /// No description provided for @translationModeBadgesOffOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Edit badges are off for this screen. Enable them under Screen names.'**
  String get translationModeBadgesOffOnScreen;

  /// No description provided for @translationScreenNamesRouteDropdown.
  ///
  /// In en, this message translates to:
  /// **'Screen name'**
  String get translationScreenNamesRouteDropdown;

  /// No description provided for @translationScreenNamesUnassigned.
  ///
  /// In en, this message translates to:
  /// **'(unassigned)'**
  String get translationScreenNamesUnassigned;

  /// No description provided for @translationScreenNamesCreated.
  ///
  /// In en, this message translates to:
  /// **'Screen name created.'**
  String get translationScreenNamesCreated;

  /// No description provided for @translationScreenNamesSaved.
  ///
  /// In en, this message translates to:
  /// **'Screen name saved.'**
  String get translationScreenNamesSaved;

  /// No description provided for @translationScreenNamesRenamedCount.
  ///
  /// In en, this message translates to:
  /// **'Saved. Updated {count} string labels.'**
  String translationScreenNamesRenamedCount(int count);

  /// No description provided for @translationScreenNamesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete screen name?'**
  String get translationScreenNamesDeleteTitle;

  /// No description provided for @translationScreenNamesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get translationScreenNamesDelete;

  /// No description provided for @translationScreenNamesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Unassign from any app screen first.'**
  String translationScreenNamesDeleteBody(String name);

  /// No description provided for @translationScreenNamesManage.
  ///
  /// In en, this message translates to:
  /// **'Manage screen names'**
  String get translationScreenNamesManage;

  /// No description provided for @translationScreensSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Screens summary'**
  String get translationScreensSummaryTitle;

  /// No description provided for @translationScreensSummaryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Screens summary'**
  String get translationScreensSummaryTooltip;

  /// No description provided for @translationScreensSummaryBadgesOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Show badges ON only'**
  String get translationScreensSummaryBadgesOnlyLabel;

  /// No description provided for @translationScreensSummaryCountsHint.
  ///
  /// In en, this message translates to:
  /// **'Counts reflect current locale and search filter.'**
  String get translationScreensSummaryCountsHint;

  /// No description provided for @translationScreensSummaryTotalRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes: {count}'**
  String translationScreensSummaryTotalRoutes(int count);

  /// No description provided for @translationScreensSummaryAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned: {count}'**
  String translationScreensSummaryAssigned(int count);

  /// No description provided for @translationScreensSummaryBadgesOn.
  ///
  /// In en, this message translates to:
  /// **'Badges ON: {count}'**
  String translationScreensSummaryBadgesOn(int count);

  /// No description provided for @translationScreensSummaryUnknownRoutes.
  ///
  /// In en, this message translates to:
  /// **'Unknown: {count}'**
  String translationScreensSummaryUnknownRoutes(int count);

  /// No description provided for @translationScreensSummaryUnknownSection.
  ///
  /// In en, this message translates to:
  /// **'Unknown/custom routes'**
  String get translationScreensSummaryUnknownSection;

  /// No description provided for @translationScreensSummaryUnknownSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} route(s) found in entries'**
  String translationScreensSummaryUnknownSectionSubtitle(int count);

  /// No description provided for @translationScreensSummaryUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get translationScreensSummaryUnassigned;

  /// No description provided for @translationScreensSummaryBadgesOnChip.
  ///
  /// In en, this message translates to:
  /// **'Badges ON'**
  String get translationScreensSummaryBadgesOnChip;

  /// No description provided for @translationScreensSummaryBadgesOffChip.
  ///
  /// In en, this message translates to:
  /// **'Badges OFF'**
  String get translationScreensSummaryBadgesOffChip;

  /// No description provided for @translationScreensSummaryCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count} strings'**
  String translationScreensSummaryCountChip(int count);

  /// No description provided for @translationStringScreenLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen name'**
  String get translationStringScreenLabel;

  /// No description provided for @translationStringScreenNone.
  ///
  /// In en, this message translates to:
  /// **'(none)'**
  String get translationStringScreenNone;

  /// No description provided for @translationModeStart.
  ///
  /// In en, this message translates to:
  /// **'Browse app in translation mode'**
  String get translationModeStart;

  /// No description provided for @translationModeStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap badges on screen text to edit translations in context'**
  String get translationModeStartSubtitle;

  /// No description provided for @translationModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Translation mode — {locale}'**
  String translationModeBanner(String locale);

  /// No description provided for @translationModeShowingPreview.
  ///
  /// In en, this message translates to:
  /// **'Showing {locale}'**
  String translationModeShowingPreview(String locale);

  /// No description provided for @translationModeLoadingEntries.
  ///
  /// In en, this message translates to:
  /// **'Loading translation entries…'**
  String get translationModeLoadingEntries;

  /// No description provided for @translationModeSessionEdited.
  ///
  /// In en, this message translates to:
  /// **'{count} edits in this session'**
  String translationModeSessionEdited(int count);

  /// No description provided for @translationModeReviewSession.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get translationModeReviewSession;

  /// No description provided for @translationModeExit.
  ///
  /// In en, this message translates to:
  /// **'Exit translation mode'**
  String get translationModeExit;

  /// No description provided for @translationModeExitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard session edits?'**
  String get translationModeExitConfirmTitle;

  /// No description provided for @translationModeExitConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unsaved edits. Exit and discard them?'**
  String translationModeExitConfirmBody(int count);

  /// No description provided for @translationModeExitDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard and exit'**
  String get translationModeExitDiscard;

  /// No description provided for @translationModeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit translation'**
  String get translationModeEditTitle;

  /// No description provided for @translationModeSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'English (source)'**
  String get translationModeSourceLabel;

  /// No description provided for @translationModeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review session'**
  String get translationModeReviewTitle;

  /// No description provided for @translationModeReviewInactive.
  ///
  /// In en, this message translates to:
  /// **'Translation mode is not active.'**
  String get translationModeReviewInactive;

  /// No description provided for @translationModeReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No edits yet. Tap translation badges on screen text to add changes.'**
  String get translationModeReviewEmpty;

  /// No description provided for @translationModeReviewSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save {count} edits to Firestore'**
  String translationModeReviewSaveAll(int count);

  /// No description provided for @translationModeReviewSaveAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} translations.'**
  String translationModeReviewSaveAllSuccess(int count);

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsReminderApprovalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reminder approvals'**
  String get alertsReminderApprovalsTooltip;

  /// No description provided for @alertsMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get alertsMoreTooltip;

  /// No description provided for @alertsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get alertsMarkAllRead;

  /// No description provided for @alertsSelectAlerts.
  ///
  /// In en, this message translates to:
  /// **'Select alerts'**
  String get alertsSelectAlerts;

  /// No description provided for @alertsClearSelected.
  ///
  /// In en, this message translates to:
  /// **'Clear selected'**
  String get alertsClearSelected;

  /// No description provided for @alertsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String alertsSelectedCount(int count);

  /// No description provided for @alertsSwipeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get alertsSwipeClear;

  /// No description provided for @alertsClearedSelectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Cleared {cleared, plural, =1{1 alert} other{{cleared} alerts}}'**
  String alertsClearedSelectedSnackbar(int cleared);

  /// No description provided for @alertsClearedSelectedSnackbarWithSkipped.
  ///
  /// In en, this message translates to:
  /// **'Cleared {cleared, plural, =1{1 alert} other{{cleared} alerts}} · {skipped, plural, =1{1 kept (response required)} other{{skipped} kept (response required)}}'**
  String alertsClearedSelectedSnackbarWithSkipped(int cleared, int skipped);

  /// No description provided for @alertsFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts: {error}'**
  String alertsFailedToLoad(String error);

  /// No description provided for @alertsClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all alerts?'**
  String get alertsClearAllTitle;

  /// No description provided for @alertsAlertDismissed.
  ///
  /// In en, this message translates to:
  /// **'Alert dismissed'**
  String get alertsAlertDismissed;

  /// No description provided for @alertsSubmitBeforeDismiss.
  ///
  /// In en, this message translates to:
  /// **'Submit your response before dismissing this alert.'**
  String get alertsSubmitBeforeDismiss;

  /// No description provided for @alertsDeleteAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete alert?'**
  String get alertsDeleteAlertTitle;

  /// No description provided for @alertsDeleteBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete broadcast?'**
  String get alertsDeleteBroadcastTitle;

  /// No description provided for @alertsDeleteAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete announcement?'**
  String get alertsDeleteAnnouncementTitle;

  /// No description provided for @notificationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification history'**
  String get notificationHistoryTitle;

  /// No description provided for @notificationHistoryFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String notificationHistoryFailedToLoad(String error);

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get commonMoveUp;

  /// No description provided for @commonMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get commonMoveDown;

  /// No description provided for @commonReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get commonReason;

  /// No description provided for @authAccountRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Restricted'**
  String get authAccountRestrictedTitle;

  /// No description provided for @authAccountRestrictedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your access to this organization has been suspended.'**
  String get authAccountRestrictedMessage;

  /// No description provided for @authAccountUnenrolledTitle.
  ///
  /// In en, this message translates to:
  /// **'No Longer Enrolled'**
  String get authAccountUnenrolledTitle;

  /// No description provided for @authAccountUnenrolledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your membership in this organization has ended.'**
  String get authAccountUnenrolledMessage;

  /// No description provided for @authAccountReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get authAccountReasonLabel;

  /// No description provided for @authAccountBlockedDefaultReason.
  ///
  /// In en, this message translates to:
  /// **'Contact your administrator for help.'**
  String get authAccountBlockedDefaultReason;

  /// No description provided for @authAccountUnenrolledDefaultReason.
  ///
  /// In en, this message translates to:
  /// **'Contact your administrator if you need access.'**
  String get authAccountUnenrolledDefaultReason;

  /// No description provided for @authApplyAcceptTermsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue.'**
  String get authApplyAcceptTermsSnackbar;

  /// No description provided for @authJoinOrgTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {orgName}'**
  String authJoinOrgTitle(String orgName);

  /// No description provided for @authApplyReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your details will be reviewed by an admin before you can access {orgName}.'**
  String authApplyReviewMessage(String orgName);

  /// No description provided for @authFullNameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Juan Dela Cruz'**
  String get authFullNameExampleHint;

  /// No description provided for @authStudentMemberId.
  ///
  /// In en, this message translates to:
  /// **'Student / Member ID'**
  String get authStudentMemberId;

  /// No description provided for @authStudentMemberIdHint.
  ///
  /// In en, this message translates to:
  /// **'Your school-issued ID number'**
  String get authStudentMemberIdHint;

  /// No description provided for @authApplyConfirmAccurate.
  ///
  /// In en, this message translates to:
  /// **'I confirm that the information I provided is accurate.'**
  String get authApplyConfirmAccurate;

  /// No description provided for @authSubmitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get authSubmitApplication;

  /// No description provided for @authPendingRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Rejected'**
  String get authPendingRejectedTitle;

  /// No description provided for @authPendingSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get authPendingSubmittedTitle;

  /// No description provided for @authPendingRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your application was not approved. Please contact your administrator for more information.'**
  String get authPendingRejectedMessage;

  /// No description provided for @authPendingReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review. You\'ll receive a notification once an admin approves your account.'**
  String get authPendingReviewMessage;

  /// No description provided for @authEditApplication.
  ///
  /// In en, this message translates to:
  /// **'Edit Application'**
  String get authEditApplication;

  /// No description provided for @authSubmittedDetails.
  ///
  /// In en, this message translates to:
  /// **'Submitted Details'**
  String get authSubmittedDetails;

  /// No description provided for @authStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get authStudentId;

  /// No description provided for @reminderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderDetailTitle;

  /// No description provided for @reminderDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reminder not found'**
  String get reminderDetailNotFound;

  /// No description provided for @reminderDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reminder: {error}'**
  String reminderDetailLoadFailed(String error);

  /// No description provided for @reminderDetailScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get reminderDetailScheduledLabel;

  /// No description provided for @reminderDetailExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get reminderDetailExpiresLabel;

  /// No description provided for @reminderDetailDoesNotExpire.
  ///
  /// In en, this message translates to:
  /// **'Does not expire'**
  String get reminderDetailDoesNotExpire;

  /// No description provided for @reminderDetailResponseRequiredBanner.
  ///
  /// In en, this message translates to:
  /// **'Response required — submit your answer to dismiss this alert.'**
  String get reminderDetailResponseRequiredBanner;

  /// No description provided for @reminderDetailJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get reminderDetailJustNow;

  /// No description provided for @reminderDetailMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String reminderDetailMinutesAgo(int count);

  /// No description provided for @reminderDetailHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String reminderDetailHoursAgo(int count);

  /// No description provided for @reminderDetailDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String reminderDetailDaysAgo(int count);

  /// No description provided for @reminderMyBroadcastsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String reminderMyBroadcastsUpdateFailed(String error);

  /// No description provided for @reminderMyBroadcastsUpdatedWithAlerts.
  ///
  /// In en, this message translates to:
  /// **'Broadcast updated — {count} alert(s) refreshed.'**
  String reminderMyBroadcastsUpdatedWithAlerts(int count);

  /// No description provided for @reminderMyBroadcastsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Broadcast updated.'**
  String get reminderMyBroadcastsUpdated;

  /// No description provided for @reminderMyBroadcastsRecallFailed.
  ///
  /// In en, this message translates to:
  /// **'Recall failed: {error}'**
  String reminderMyBroadcastsRecallFailed(String error);

  /// No description provided for @reminderMyBroadcastsRecalledWithAlerts.
  ///
  /// In en, this message translates to:
  /// **'Reminder recalled — {count} delivered alert(s) removed.'**
  String reminderMyBroadcastsRecalledWithAlerts(int count);

  /// No description provided for @reminderMyBroadcastsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted.'**
  String get reminderMyBroadcastsDeleted;

  /// No description provided for @reminderMyBroadcastsExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires {dateTime}'**
  String reminderMyBroadcastsExpiresAt(String dateTime);

  /// No description provided for @reminderMyBroadcastsRecallTitle.
  ///
  /// In en, this message translates to:
  /// **'Recall this broadcast?'**
  String get reminderMyBroadcastsRecallTitle;

  /// No description provided for @reminderMyBroadcastsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete broadcast?'**
  String get reminderMyBroadcastsDeleteTitle;

  /// No description provided for @reminderMyBroadcastsRecallMessage.
  ///
  /// In en, this message translates to:
  /// **'This deletes the reminder and removes it from every recipient\'s alerts feed. This cannot be undone.'**
  String get reminderMyBroadcastsRecallMessage;

  /// No description provided for @reminderMyBroadcastsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the reminder. This cannot be undone.'**
  String get reminderMyBroadcastsDeleteMessage;

  /// No description provided for @reminderMyBroadcastsRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get reminderMyBroadcastsRecall;

  /// No description provided for @reminderMyBroadcastsEmptyLeader.
  ///
  /// In en, this message translates to:
  /// **'No group alerts sent yet'**
  String get reminderMyBroadcastsEmptyLeader;

  /// No description provided for @reminderMyBroadcastsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any broadcasts yet'**
  String get reminderMyBroadcastsEmpty;

  /// No description provided for @reminderMyBroadcastsEmptyLeaderHint.
  ///
  /// In en, this message translates to:
  /// **'Send an alert from My Groups & Clubs, then return here to view member responses.'**
  String get reminderMyBroadcastsEmptyLeaderHint;

  /// No description provided for @reminderEditBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit broadcast'**
  String get reminderEditBroadcastTitle;

  /// No description provided for @reminderEditEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get reminderEditEnterTitle;

  /// No description provided for @reminderEditEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get reminderEditEnterMessage;

  /// No description provided for @reminderResponsesNoResponses.
  ///
  /// In en, this message translates to:
  /// **'This reminder has no responses.'**
  String get reminderResponsesNoResponses;

  /// No description provided for @reminderResponsesNoResponsesYet.
  ///
  /// In en, this message translates to:
  /// **'No responses yet.'**
  String get reminderResponsesNoResponsesYet;

  /// No description provided for @reminderResponseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Response submitted'**
  String get reminderResponseSubmitted;

  /// No description provided for @reminderResponseYourResponse.
  ///
  /// In en, this message translates to:
  /// **'Your response'**
  String get reminderResponseYourResponse;

  /// No description provided for @reminderResponseAlreadyResponded.
  ///
  /// In en, this message translates to:
  /// **'You already responded. Update your answer below if needed.'**
  String get reminderResponseAlreadyResponded;

  /// No description provided for @reminderResponseTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type your response…'**
  String get reminderResponseTypeHint;

  /// No description provided for @reminderResponseMaxCharacters.
  ///
  /// In en, this message translates to:
  /// **'Max {count} characters'**
  String reminderResponseMaxCharacters(int count);

  /// No description provided for @reminderResponseAdditionalComments.
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get reminderResponseAdditionalComments;

  /// No description provided for @reminderResponseAdditionalHint.
  ///
  /// In en, this message translates to:
  /// **'Add an explanation if needed…'**
  String get reminderResponseAdditionalHint;

  /// No description provided for @reminderResponseUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update response'**
  String get reminderResponseUpdate;

  /// No description provided for @reminderResponseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit response'**
  String get reminderResponseSubmit;

  /// No description provided for @reminderResponseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String reminderResponseFailed(String error);

  /// No description provided for @reminderResponseSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get reminderResponseSubmittedLabel;

  /// No description provided for @reminderResponseLocked.
  ///
  /// In en, this message translates to:
  /// **'Your answer is locked and cannot be changed.'**
  String get reminderResponseLocked;

  /// No description provided for @reportConfirmationThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get reportConfirmationThankYou;

  /// No description provided for @reportConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted successfully. We\'ll look into it and keep you posted.'**
  String get reportConfirmationMessage;

  /// No description provided for @reportConfirmationReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get reportConfirmationReferenceLabel;

  /// No description provided for @reportConfirmationCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference number copied!'**
  String get reportConfirmationCopied;

  /// No description provided for @reportConfirmationGoToMyReports.
  ///
  /// In en, this message translates to:
  /// **'Go to My Reports'**
  String get reportConfirmationGoToMyReports;

  /// No description provided for @reportConfirmationBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get reportConfirmationBackToHome;

  /// No description provided for @reportDetailsSubmittedAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Submitted anonymously'**
  String get reportDetailsSubmittedAnonymously;

  /// No description provided for @groupsDefaultPresident.
  ///
  /// In en, this message translates to:
  /// **'President'**
  String get groupsDefaultPresident;

  /// No description provided for @groupsDefaultVicePresident.
  ///
  /// In en, this message translates to:
  /// **'Vice President'**
  String get groupsDefaultVicePresident;

  /// No description provided for @groupsNoPositionsYet.
  ///
  /// In en, this message translates to:
  /// **'No positions defined yet.'**
  String get groupsNoPositionsYet;

  /// No description provided for @groupsPositionNumber.
  ///
  /// In en, this message translates to:
  /// **'Position {number}'**
  String groupsPositionNumber(int number);

  /// No description provided for @groupsPositionExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vice President'**
  String get groupsPositionExampleHint;
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
