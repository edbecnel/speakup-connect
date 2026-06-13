// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get commonCancel => 'Cancel';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonBrowse => 'Browse';

  @override
  String get commonLeave => 'Leave';

  @override
  String get commonApprove => 'Approve';

  @override
  String get commonDecline => 'Decline';

  @override
  String get commonDeny => 'Deny';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get commonClearAll => 'Clear all';

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
  String homeWelcomeMessageWithOrgType(String orgType) {
    return 'How can we help make our $orgType better?';
  }

  @override
  String get orgTypeWordSchool => 'school';

  @override
  String get orgTypeWordUniversity => 'university';

  @override
  String get orgTypeWordLgu => 'community';

  @override
  String get orgTypeWordNgo => 'organization';

  @override
  String get orgTypeWordChurch => 'church';

  @override
  String get orgTypeWordCorporation => 'workplace';

  @override
  String get orgTypeWordOther => 'organization';

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
  String get groupsManageMembers => 'Manage Members';

  @override
  String get groupsViewMembers => 'View Members';

  @override
  String get groupsAddMembers => 'Add Members';

  @override
  String get groupsRequests => 'Requests';

  @override
  String groupsRequestsCount(int count) {
    return 'Requests ($count)';
  }

  @override
  String get groupsSendAlert => 'Send Alert';

  @override
  String get groupsEditGroup => 'Edit Group';

  @override
  String get groupsEditGroupMembersHint =>
      'Change name, description, policies, and club positions';

  @override
  String get groupsPostAnnouncement => 'Post Announcement';

  @override
  String get groupsCancelLeaveRequest => 'Cancel leave request';

  @override
  String get groupsLeaveGroup => 'Leave group';

  @override
  String get groupsRequestToLeave => 'Request to leave';

  @override
  String get groupsLeavePending => 'Leave pending';

  @override
  String groupsMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get groupsMyGroupsEmptyMessage =>
      'When an administrator adds you to a club, it will appear here. You can also browse open groups and request to join.';

  @override
  String get groupsLeaveGroupTitle => 'Leave group?';

  @override
  String get groupsLeaveGroupMessage =>
      'You will stop receiving alerts for this group.';

  @override
  String get groupsLeftGroup => 'You left the group';

  @override
  String get groupsCouldNotLeave => 'Could not leave';

  @override
  String get groupsLeaveRequestCancelled => 'Leave request cancelled';

  @override
  String get groupsCouldNotCancelRequest => 'Could not cancel request';

  @override
  String get groupsLeaveReasonMinLength =>
      'Please enter at least 20 characters';

  @override
  String get groupsLeaveRequestSubmitted => 'Leave request submitted';

  @override
  String get groupsCouldNotSubmitRequest => 'Could not submit request';

  @override
  String get groupsLeaveRequestDialogTitle => 'Request to leave';

  @override
  String get groupsLeaveReasonLabel => 'Why do you want to leave?';

  @override
  String get groupsLeaveReasonHint => 'At least 20 characters';

  @override
  String get groupsGenericName => 'Group';

  @override
  String get groupsGroupMembersTitle => 'Group Members';

  @override
  String get groupsMembershipRequests => 'Membership requests';

  @override
  String get groupsMembershipSettings => 'Membership settings';

  @override
  String groupsMembershipRequestsCount(int count) {
    return 'Membership requests ($count)';
  }

  @override
  String get groupsEditGroupSettingsTooltip => 'Edit group settings';

  @override
  String get groupsNoMembersYet => 'No members yet';

  @override
  String get groupsNoMembersManageHint =>
      'Add students or staff to this group.';

  @override
  String get groupsNoMembersViewHint => 'Members will appear here once added.';

  @override
  String get groupsRemoveMemberTitle => 'Remove member?';

  @override
  String groupsRemoveMemberMessage(String name) {
    return 'Remove $name from this group?';
  }

  @override
  String get groupsCouldNotRemoveMember => 'Could not remove member';

  @override
  String get groupsCouldNotUpdatePosition => 'Could not update position';

  @override
  String get groupsAssignPosition => 'Assign position';

  @override
  String get groupsNoPosition => 'No position';

  @override
  String get groupsNoPositionSelected => 'No position ✓';

  @override
  String get groupsMakeLeader => 'Make leader';

  @override
  String get groupsMakeMember => 'Make member';

  @override
  String get groupsRemoveFromGroup => 'Remove from group';

  @override
  String get groupsRoleLeader => 'Leader';

  @override
  String get groupsRoleMember => 'Member';

  @override
  String get groupsSearchClubHint => 'Club or program name';

  @override
  String get groupsNoSearchResults => 'No groups match your search.';

  @override
  String get groupsStatusMember => 'Member';

  @override
  String get groupsStatusPending => 'Pending';

  @override
  String get groupsStatusOpenToRequests => 'Open to requests';

  @override
  String get groupsStatusInvitationOnly => 'Invitation only';

  @override
  String get groupsRequestToJoin => 'Request to Join';

  @override
  String get groupsCancelRequest => 'Cancel Request';

  @override
  String get groupsInvitationOnlyMessage =>
      'Membership by invitation only. Contact your adviser.';

  @override
  String groupsJoinRequestTitle(String groupName) {
    return 'Request to join $groupName';
  }

  @override
  String get groupsJoinMessageLabel => 'Message (optional)';

  @override
  String get groupsJoinMessageHint => 'Tell the leader why you want to join';

  @override
  String get groupsJoinRequestSubmitted => 'Join request submitted';

  @override
  String groupsCouldNotSubmitJoin(String error) {
    return 'Could not submit: $error';
  }

  @override
  String get groupsRequestCancelled => 'Request cancelled';

  @override
  String get groupsOpenToJoin => 'open to join';

  @override
  String get groupsPending => 'pending';

  @override
  String get groupsNewGroup => 'New Group';

  @override
  String get groupsCreateGroup => 'Create Group';

  @override
  String get groupsSearchGroupsHint => 'Search groups…';

  @override
  String get groupsNoSearchMatch => 'No groups match your search';

  @override
  String get groupsEmptySeedHint =>
      'Seed the MONHS demo groups or create your own.';

  @override
  String get groupsTryDifferentSearch => 'Try a different search term.';

  @override
  String get groupsSeedDemoGroups => 'Seed Demo Groups';

  @override
  String get groupsSeeding => 'Seeding…';

  @override
  String groupsSeedFailed(String error) {
    return 'Seed failed: $error';
  }

  @override
  String get groupsSeedSuccess => 'Demo groups added successfully';

  @override
  String groupsSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String groupsSyncSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced $count memberships for My Groups',
      one: 'Synced 1 membership for My Groups',
    );
    return '$_temp0';
  }

  @override
  String get groupsMoreActions => 'More actions';

  @override
  String get groupsSeedDemoSubtitle => 'SPJ, Drum & Lyre, SSLG';

  @override
  String get groupsSyncIndexes => 'Sync My Groups Indexes';

  @override
  String get groupsSyncing => 'Syncing…';

  @override
  String get groupsSyncIndexesSubtitle =>
      'Repair member visibility after roster changes';

  @override
  String get groupsEditGroupTooltip => 'Edit group';

  @override
  String get groupsCreateGroupTitle => 'Create Group';

  @override
  String get groupsGroupNameLabel => 'Group name';

  @override
  String get groupsGroupNameHint => 'e.g. Journalism Club';

  @override
  String get groupsGroupNameRequired => 'Enter a group name';

  @override
  String get groupsDescriptionLabel => 'Description (optional)';

  @override
  String get groupsDescriptionHint => 'What is this group about?';

  @override
  String get groupsDefineClubPositions => 'Define club positions';

  @override
  String get groupsDefineClubPositionsSubtitle =>
      'Optional offices like President or Treasurer';

  @override
  String get groupsAllowJoinRequests => 'Allow join requests';

  @override
  String get groupsAllowJoinRequestsSubtitle =>
      'Let students request to join (off for elected groups like SSLG)';

  @override
  String get groupsMemberLeavePolicy => 'Member leave policy';

  @override
  String get groupsLeaveAnytime => 'Leave anytime';

  @override
  String get groupsMustRequestToLeave => 'Must request to leave';

  @override
  String get groupsLeaveAnytimeSubtitle => 'Members can leave without approval';

  @override
  String get groupsMustRequestToLeaveSubtitle =>
      'Requires a reason and leader approval';

  @override
  String get groupsJoinHintLabel => 'Join hint (optional)';

  @override
  String get groupsJoinHintHint => 'e.g. Auditions in August';

  @override
  String groupsCreated(String name) {
    return 'Created $name';
  }

  @override
  String get groupsCouldNotCreate => 'Could not create group';

  @override
  String get groupsEditGroupTitle => 'Edit Group';

  @override
  String get groupsGroupNotFound => 'Group not found';

  @override
  String get groupsGroupSettingsSaved => 'Group settings saved';

  @override
  String get groupsCouldNotSaveSettings => 'Could not save group settings';

  @override
  String get groupsSaveChanges => 'Save Changes';

  @override
  String get groupsGroupIsActive => 'Group is active';

  @override
  String get groupsGroupIsActiveSubtitle =>
      'Inactive groups are hidden from browse and lists';

  @override
  String get groupsAddPosition => 'Add position';

  @override
  String get groupsSavePositions => 'Save Positions';

  @override
  String get groupsClubPositionsSaved => 'Club positions saved';

  @override
  String get groupsCouldNotSavePositions => 'Could not save positions';

  @override
  String get groupsClubPositionsTitle => 'Club Positions';

  @override
  String get groupsClubPositionsSectionTitle => 'Club positions';

  @override
  String get groupsClubPositionsSectionSubtitle =>
      'Optional offices members can hold (e.g. President, Treasurer). You can assign these when adding or managing members.';

  @override
  String groupsMembershipRequestsTitle(String groupName) {
    return '$groupName — Requests';
  }

  @override
  String groupsTabJoinCount(int count) {
    return 'Join ($count)';
  }

  @override
  String groupsTabLeaveCount(int count) {
    return 'Leave ($count)';
  }

  @override
  String get groupsNoPendingJoinRequests => 'No pending join requests';

  @override
  String get groupsNoPendingLeaveRequests => 'No pending leave requests';

  @override
  String groupsStudentIdPrefix(String id) {
    return 'ID: $id';
  }

  @override
  String get groupsApproveLeave => 'Approve leave';

  @override
  String get groupsDeclineJoinTitle => 'Decline join request?';

  @override
  String get groupsDeclineJoinReasonLabel => 'Reason (optional)';

  @override
  String get groupsDenyLeaveTitle => 'Deny leave request';

  @override
  String get groupsDenyLeaveReasonLabel => 'Reason (required)';

  @override
  String get groupsReasonRequired => 'A reason is required';

  @override
  String get groupsJoinRequestUpdated => 'Join request updated';

  @override
  String get groupsLeaveRequestUpdated => 'Leave request updated';

  @override
  String get groupsActionFailed => 'Action failed';

  @override
  String get groupsAddMembersSearchLabel => 'Search members';

  @override
  String get groupsAddMembersSearchHint => 'Name, email, or school ID';

  @override
  String groupsCouldNotAddMembers(String error) {
    return 'Could not add members: $error';
  }

  @override
  String get groupsAllMembersAlreadyInGroup =>
      'All approved members are already in this group.';

  @override
  String get groupsNoUsersMatchSearch => 'No users match your search.';

  @override
  String groupsAssignSelectedHint(int count) {
    return '$count selected — choose role and assign';
  }

  @override
  String get groupsAssignSearchHint => 'Search and tap a member below';

  @override
  String get groupsAssignButton => 'Assign';

  @override
  String get groupsGroupRoleLabel => 'Group role';

  @override
  String get groupsClubPositionOptional => 'Club position (optional)';

  @override
  String groupsAssignMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assign $count members',
      one: 'Assign 1 member',
    );
    return '$_temp0';
  }

  @override
  String groupsAssignMembersPartial(int added, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added members',
      one: '1 member',
    );
    return 'Assigned $_temp0; $skipped could not be added';
  }

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
  String get settingsMemberSignInHint =>
      'Sign in with your student ID or contact email and your password.';

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
  String get settingsTranslations => 'Translations';

  @override
  String get settingsTranslationsSubtitle =>
      'Edit UI strings for your organization\'s languages';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageCebuano => 'Bisaya / Cebuano';

  @override
  String get settingsLanguageRevertToEnglish =>
      'That language could not be applied. Reverted to English.';

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

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordMin8 => 'Password must be at least 8 characters';

  @override
  String get validationPasswordMin6 => 'Password must be at least 6 characters';

  @override
  String get validationLoginIdentifierRequired =>
      'Email or student ID is required';

  @override
  String get validationStudentIdRequired => 'Student ID is required';

  @override
  String get validationStudentIdMin6 =>
      'Student ID must be at least 6 characters';

  @override
  String get validationStudentIdInvalidChars =>
      'Use letters, numbers, and hyphens only';

  @override
  String get validationConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String validationMaxLength(String fieldName, int maxLength) {
    return '$fieldName must be $maxLength characters or fewer';
  }

  @override
  String validationMinLength(String fieldName, int minLength) {
    return '$fieldName must be at least $minLength characters';
  }

  @override
  String get validationReportTitleField => 'Title';

  @override
  String get validationReportDescriptionField => 'Description';

  @override
  String get commonSave => 'Save';

  @override
  String get translationSearchHint => 'Search keys or English text';

  @override
  String get translationBatchAi => 'Translate missing (AI)';

  @override
  String get translationBatchAiNoneMissing =>
      'No missing strings to translate.';

  @override
  String translationBatchAiResult(int succeeded, int total) {
    return 'AI draft: $succeeded of $total succeeded';
  }

  @override
  String get translationExportArb => 'Export ARB (copy JSON)';

  @override
  String get translationExportCopied => 'ARB JSON copied to clipboard';

  @override
  String translationEntryCount(int count) {
    return '$count strings loaded';
  }

  @override
  String get translationNoEntries =>
      'No translation entries yet. Platform operators import app_en.arb first.';

  @override
  String get translationTargetLabel => 'Translation';

  @override
  String get translationAiDraft => 'AI draft';

  @override
  String get translationApprove => 'Approve';
}
