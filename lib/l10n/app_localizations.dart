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
