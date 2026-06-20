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
  String get commonRefresh => 'Refresh';

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
  String get settingsUsernameStudentId => 'Username / student ID';

  @override
  String get settingsContactEmail => 'Contact email';

  @override
  String get settingsChangeEmail => 'Change email';

  @override
  String get settingsAddEmail => 'Add email';

  @override
  String get settingsContactEmailRemoved => 'Contact email removed';

  @override
  String get settingsContactEmailUpdated => 'Contact email updated';

  @override
  String get settingsContactEmailUpdateFailed => 'Could not update email';

  @override
  String get settingsContactEmailDialogIntro =>
      'Used for notifications and sign-in. Your student ID remains your username for school accounts.';

  @override
  String get settingsEmailOptional => 'Email (optional)';

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
  String get settingsAboutOrganizationIdLabel => 'Organization ID';

  @override
  String get settingsAboutOrganizationIdCopied => 'Organization ID copied';

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
  String get helpMemberTutorialTitle => 'Member Tutorial';

  @override
  String get helpMemberTutorialSubtitle =>
      'Step-by-step onboarding for first-time members';

  @override
  String get helpAdminTutorialTitle => 'Administrator Tutorial';

  @override
  String get helpAdminTutorialSubtitle =>
      'Step-by-step onboarding for first-time administrators';

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
  String get reminderComposeTitle => 'Compose Reminder';

  @override
  String get reminderComposeSendGroupAlertTitle => 'Send Group Alert';

  @override
  String reminderComposeSendFailed(String error) {
    return 'Failed to send: $error';
  }

  @override
  String get reminderComposeSubmittedForApproval =>
      'Reminder submitted for approval.';

  @override
  String get reminderComposeScheduled => 'Reminder scheduled.';

  @override
  String get reminderComposePublished => 'Reminder published.';

  @override
  String get reminderComposeSubmitForApproval => 'Submit for Approval';

  @override
  String get reminderComposeSendReminder => 'Send Reminder';

  @override
  String get reminderComposeGroupOnlyHint =>
      'This alert will be sent only to members of the group you select.';

  @override
  String get reminderComposeTitleLabel => 'Title';

  @override
  String get reminderComposeTitleHint => 'e.g. Early dismissal Friday';

  @override
  String get reminderComposeMessageLabel => 'Message';

  @override
  String get reminderComposeMessageHint => 'Write the reminder details…';

  @override
  String get reminderComposeAudienceLabel => 'Audience';

  @override
  String get reminderComposeAudienceEveryone => 'Everyone';

  @override
  String get reminderComposeAudienceGroup => 'Group';

  @override
  String get reminderComposeAudienceRole => 'Role';

  @override
  String reminderComposeLoadGroupsFailed(String error) {
    return 'Could not load groups: $error';
  }

  @override
  String get reminderComposeNoGroupsYet =>
      'No groups exist yet. Create a group first.';

  @override
  String get reminderComposeSelectGroup => 'Select group';

  @override
  String reminderComposeLoadRolesFailed(String error) {
    return 'Could not load roles: $error';
  }

  @override
  String get reminderComposeNoRolesYet => 'No roles defined yet.';

  @override
  String get reminderComposeSelectRole => 'Select role';

  @override
  String get reminderComposeNoPermission =>
      'You don\'t have permission to broadcast reminders.';

  @override
  String get reminderComposeApprovalBanner =>
      'Your organization requires reminders to be approved. This will be submitted for review before it is published.';

  @override
  String get reminderComposeValidationTitleMin =>
      'Title must be at least 3 characters.';

  @override
  String get reminderComposeValidationMessageMin =>
      'Message must be at least 5 characters.';

  @override
  String get reminderComposeValidationSelectGroup =>
      'Select a group for this alert.';

  @override
  String get reminderComposeValidationSelectAudience =>
      'Select an audience for this reminder.';

  @override
  String get reminderComposeValidationExpiration =>
      'Set a valid expiration date and time.';

  @override
  String get reminderComposeValidationCheckboxOptions =>
      'Add at least one checkbox option with a label.';

  @override
  String get reminderComposeValidationChoiceOptions =>
      'Add at least 2 answer choices with labels.';

  @override
  String get reminderComposeValidationCharLimit =>
      'Set a valid character limit for responses.';

  @override
  String get reminderComposeScheduleForLater => 'Schedule for later';

  @override
  String get reminderComposeScheduleOff => 'Off — send immediately';

  @override
  String get reminderComposeChangeTime => 'Change time';

  @override
  String get reminderComposeSetExpiration => 'Set expiration';

  @override
  String get reminderComposeExpirationOff =>
      'Off — stays until manually deleted';

  @override
  String get reminderComposeSetExpirationBelow => 'Set expiration below';

  @override
  String get reminderComposeExpirationDateTime => 'Date & time';

  @override
  String get reminderComposeExpirationDuration => 'Duration';

  @override
  String get reminderComposePickDateTime => 'Pick date & time';

  @override
  String get reminderComposeExpirationAfterSend =>
      'Expiration must be after the send time.';

  @override
  String get reminderComposeExpireAfter => 'Expire after';

  @override
  String get reminderComposeHours => 'Hours';

  @override
  String get reminderComposeMinutes => 'Minutes';

  @override
  String reminderComposeExpirationDurationSummary(
      String duration, String base, String dateTime) {
    return '$duration after $base ($dateTime)';
  }

  @override
  String reminderComposeExpirationAt(String dateTime) {
    return 'Expires $dateTime';
  }

  @override
  String get reminderComposeExpirationBaseScheduled => 'scheduled send';

  @override
  String get reminderComposeExpirationBaseSend => 'send';

  @override
  String reminderComposeDurationHours(int count) {
    return '$count hr';
  }

  @override
  String reminderComposeDurationMinutes(int count) {
    return '$count min';
  }

  @override
  String get reminderComposeDurationZeroMin => '0 min';

  @override
  String get reminderComposeRequestResponse => 'Request a response';

  @override
  String reminderComposeResponseRecipientsCan(String type) {
    return 'Recipients can respond via $type';
  }

  @override
  String get reminderComposeResponseOff => 'Off — no response requested';

  @override
  String get reminderComposeResponseRequired => 'Response required';

  @override
  String get reminderComposeResponseRequiredHint =>
      'Recipients must respond before they can dismiss the alert';

  @override
  String get reminderComposeAllowChangingResponses =>
      'Allow changing responses';

  @override
  String get reminderComposeAllowChangingResponsesOn =>
      'Recipients can update their answer after submitting';

  @override
  String get reminderComposeAllowChangingResponsesOff =>
      'Locked after submit — use for votes and one-time polls';

  @override
  String get reminderComposeResponseFreeText => 'Free text';

  @override
  String get reminderComposeResponseCheckboxes => 'Checkboxes';

  @override
  String get reminderComposeResponseChoices => 'Choices';

  @override
  String get reminderComposeCharacterLimit => 'Character limit';

  @override
  String reminderComposeCharactersCount(int count) {
    return '$count characters';
  }

  @override
  String get reminderComposeAllowExplanationText => 'Allow explanation text';

  @override
  String get reminderComposeAllowExplanationHint =>
      'Optional text box for comments (e.g. why they cannot attend)';

  @override
  String reminderComposeValidationCharLimitRange(int min, int max) {
    return 'Set a character limit between $min and $max.';
  }

  @override
  String get reminderComposeCheckboxOptions => 'Checkbox options';

  @override
  String get reminderComposeAnswerChoices => 'Answer choices';

  @override
  String reminderComposeOptionNumber(int number) {
    return 'Option $number';
  }

  @override
  String get reminderComposeRemoveOption => 'Remove option';

  @override
  String get reminderComposeAddOption => 'Add option';

  @override
  String get reminderComposeResponseTypeExplanationSuffix => '+ explanation';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonPublish => 'Publish';

  @override
  String get commonDone => 'Done';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonMessage => 'Message';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String commonActionFailed(String error) {
    return 'Action failed: $error';
  }

  @override
  String commonUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String commonDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String commonFailedToLoad(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get commonGrade => 'Grade';

  @override
  String get commonAllGrades => 'All grades';

  @override
  String get commonNoGradeAssigned => 'No grade assigned';

  @override
  String get commonGradeLevel => 'Grade level';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonReasonOptional => 'Reason (optional)';

  @override
  String get commonNoteOptional => 'Note (optional)';

  @override
  String commonByAuthor(String name) {
    return 'By $name';
  }

  @override
  String commonFromGroup(String groupName) {
    return 'From $groupName';
  }

  @override
  String get commonScheduled => 'scheduled';

  @override
  String get commonNoReasonProvided => 'No reason provided';

  @override
  String get commonSchoolWide => 'School-wide';

  @override
  String get commonRegistered => 'Registered';

  @override
  String get commonNotRegistered => 'Not registered';

  @override
  String get commonActive => 'Active';

  @override
  String get commonBlocked => 'Blocked';

  @override
  String get commonUnenrolled => 'Unenrolled';

  @override
  String get commonAll => 'All';

  @override
  String get commonSignedIn => 'Signed In';

  @override
  String get commonSaving => 'Saving…';

  @override
  String commonSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get commonSection => 'Section';

  @override
  String get commonIdLabel => 'ID';

  @override
  String get commonContinueButton => 'Continue';

  @override
  String get commonChooseFromGallery => 'Choose from gallery';

  @override
  String get commonTakePhoto => 'Take a photo';

  @override
  String get commonRemovePhoto => 'Remove photo';

  @override
  String get commonAddProfilePhoto => 'Add profile photo';

  @override
  String get commonChangeProfilePhoto => 'Change profile photo';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get commonNone => '(none)';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get changePasswordIntro =>
      'Enter your current password, then choose a new password.';

  @override
  String get changePasswordCurrentLabel => 'Current password';

  @override
  String get changePasswordCurrentHint => 'Your current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordNewHint => 'At least 8 characters';

  @override
  String get changePasswordConfirmLabel => 'Confirm new password';

  @override
  String get changePasswordConfirmHint => 'Re-enter your new password';

  @override
  String get changePasswordUpdateButton => 'Update Password';

  @override
  String get changePasswordMustDiffer =>
      'New password must be different from your current password.';

  @override
  String get changePasswordFailed =>
      'Could not change password. Please try again.';

  @override
  String get changePasswordSuccess => 'Password updated successfully.';

  @override
  String get pendingApprovalsAnnouncements => 'Announcements';

  @override
  String get pendingApprovalsGroupAlerts => 'Group alerts';

  @override
  String get pendingApprovalsSchoolWide => 'School-wide';

  @override
  String get pendingApprovalsEmpty => 'Nothing awaiting approval';

  @override
  String get pendingApprovalsNoPermission =>
      'You don\'t have permission to approve content.';

  @override
  String get pendingApprovalsRejectAnnouncement => 'Reject announcement';

  @override
  String get pendingApprovalsRejectReminder => 'Reject reminder';

  @override
  String get pendingApprovalsRejectReasonHint => 'Let the author know why…';

  @override
  String pendingApprovalsLoadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get composeAnnouncementTitle => 'Post Announcement';

  @override
  String get composeAnnouncementNoPermission =>
      'You do not have permission to post school-wide announcements.';

  @override
  String get composeAnnouncementIntro =>
      'School-wide announcements are visible to every member.';

  @override
  String get composeAnnouncementApprovalBanner =>
      'Your organization requires approval before announcements go live.';

  @override
  String get composeAnnouncementTitleHint => 'e.g. Join our club this semester';

  @override
  String get composeAnnouncementMessageHint =>
      'Share recruitment info, news, or updates…';

  @override
  String get composeAnnouncementPinTitle => 'Pin to top of announcements';

  @override
  String get composeAnnouncementPinSubtitle =>
      'Pinned posts appear first for all members';

  @override
  String get composeAnnouncementPublish => 'Publish';

  @override
  String get composeAnnouncementSubmitted =>
      'Announcement submitted for approval.';

  @override
  String get composeAnnouncementScheduled => 'Announcement scheduled.';

  @override
  String get composeAnnouncementPublished => 'Announcement published.';

  @override
  String composeAnnouncementSendFailed(String error) {
    return 'Failed to post: $error';
  }

  @override
  String get composeAnnouncementImageLoadFailed =>
      'Could not load that image. Try another photo.';

  @override
  String get composeAnnouncementGroupRequired =>
      'You must lead a group before posting announcements.';

  @override
  String get composeAnnouncementGroupOptional => 'Group (optional)';

  @override
  String get composeAnnouncementOnBehalfOf => 'On behalf of';

  @override
  String get composeAnnouncementMustLeadGroup =>
      'You can only post on behalf of groups you lead.';

  @override
  String get composeAnnouncementValidationTitleMin =>
      'Title must be at least 3 characters.';

  @override
  String get composeAnnouncementValidationMessageMin =>
      'Message must be at least 5 characters.';

  @override
  String get composeAnnouncementValidationExpiration =>
      'Set a valid expiration date and time.';

  @override
  String get composeAnnouncementValidationResponse =>
      'Complete the optional response settings or turn them off.';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get announcementsDetailTitle => 'Announcement';

  @override
  String get announcementsMyTitle => 'My Announcements';

  @override
  String get announcementsMyTooltip => 'My announcements';

  @override
  String get announcementsPost => 'Post';

  @override
  String get announcementsNotFound => 'Announcement not found.';

  @override
  String get announcementsNotFoundShort => 'Announcement not found';

  @override
  String announcementsFailedToLoadList(String error) {
    return 'Failed to load announcements: $error';
  }

  @override
  String announcementsFailedToLoadAnnouncement(String error) {
    return 'Failed to load announcement: $error';
  }

  @override
  String announcementsFailedToLoadResponses(String error) {
    return 'Failed to load responses: $error';
  }

  @override
  String announcementsFailedToLoadResponse(String error) {
    return 'Failed to load response: $error';
  }

  @override
  String get announcementsResponsesTitle => 'Responses';

  @override
  String get announcementsNoResponses => 'This announcement has no responses.';

  @override
  String get announcementsEmptyMine =>
      'You have not posted any announcements yet.';

  @override
  String get announcementsViewResponses => 'View responses';

  @override
  String get announcementsDeleteTitle => 'Delete announcement?';

  @override
  String get announcementsEditTitle => 'Edit announcement';

  @override
  String get announcementsAddImage => 'Add image';

  @override
  String get announcementsChooseFromGallery => 'Choose from gallery';

  @override
  String get announcementsTakePhoto => 'Take a photo';

  @override
  String get announcementsRemoveImage => 'Remove image';

  @override
  String get announcementsPreparingImage => 'Preparing image…';

  @override
  String get announcementsChangePhoto => 'Change photo';

  @override
  String get announcementsExpirationMustBeFuture =>
      'Expiration must be in the future';

  @override
  String get schoolGradesIntro => 'Define which grade levels your school uses.';

  @override
  String schoolGradesIntroWhereUsed(
      String studentRoster, String memberManagement) {
    return 'These appear in $studentRoster and $memberManagement filters.';
  }

  @override
  String get schoolGradesNonSchoolNote =>
      'Municipalities, barangays, and NGOs do not use grades.';

  @override
  String get schoolGradesCurrent => 'Current grades';

  @override
  String get schoolGradesEmpty => 'No grades configured yet.';

  @override
  String schoolGradesGradeChip(int level) {
    return 'Grade $level';
  }

  @override
  String get schoolGradesAddLabel => 'Add grade level';

  @override
  String get schoolGradesAddHint => 'e.g. 7';

  @override
  String get schoolGradesAddButton => 'Add grade';

  @override
  String get schoolGradesResetDefault => 'Reset to high school default (7–12)';

  @override
  String get schoolGradesSave => 'Save grades';

  @override
  String get schoolGradesSaving => 'Saving…';

  @override
  String schoolGradesSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get schoolGradesSaveSuccess => 'Grade levels updated';

  @override
  String get schoolGradesSaveVerifyFailed =>
      'Grade levels were not saved correctly. Try again.';

  @override
  String get schoolGradesAtLeastOneRequired =>
      'At least one grade level is required.';

  @override
  String get schoolGradesInvalidNumber => 'Enter a valid grade number';

  @override
  String get schoolGradesSaveDialogTitle => 'Save grade levels?';

  @override
  String get schoolGradesSaveDialogBody =>
      'Students will be filterable and assignable by:';

  @override
  String get schoolGradesNotSchool =>
      'Grade levels are only used by school-type organizations. This setting is not available for your organization type.';

  @override
  String get schoolGradesNoPermission =>
      'You do not have permission to manage organization settings.';

  @override
  String schoolGradesLoadFailed(String error) {
    return 'Failed to load settings: $error';
  }

  @override
  String get submitConcernTitle => 'Submit a Concern';

  @override
  String get submitConcernStepDetails => 'Details';

  @override
  String get submitConcernStepPhotos => 'Photos';

  @override
  String get submitConcernStepReview => 'Review';

  @override
  String get submitConcernCategoryPrompt => 'What type of concern is this?';

  @override
  String get submitConcernLoadCategoriesFailed => 'Failed to load categories';

  @override
  String get submitConcernTitleHint =>
      'Brief summary of your concern (min 5 characters)';

  @override
  String get submitConcernDescriptionLabel => 'Description';

  @override
  String get submitConcernDescriptionHint =>
      'Describe the concern in detail (min 10 characters)';

  @override
  String get submitConcernTitleMinLength =>
      'Title must be at least 5 characters';

  @override
  String get submitConcernDescriptionMinLength =>
      'Description must be at least 10 characters';

  @override
  String get submitConcernPhotosTitle => 'Attach Photos (optional)';

  @override
  String submitConcernPhotosLimit(int count) {
    return 'Up to $count photos';
  }

  @override
  String get submitConcernAnonymousTitle => 'Submit Anonymously';

  @override
  String get submitConcernAnonymousSubtitle =>
      'Your name and account will not be linked to this report.';

  @override
  String get submitConcernTakePhoto => 'Take a Photo';

  @override
  String get submitConcernChooseGallery => 'Choose from Gallery';

  @override
  String get submitConcernReviewTitle => 'Review Your Report';

  @override
  String get submitConcernReviewCategory => 'Category';

  @override
  String get submitConcernReviewPhotos => 'Photos';

  @override
  String get submitConcernReviewSubmittedAs => 'Submitted As';

  @override
  String get submitConcernReviewAnonymousWarning =>
      'Anonymous reports cannot be tracked. Save your reference number.';

  @override
  String get submitConcernSubmitButton => 'Submit Report';

  @override
  String get submitConcernStep1Incomplete =>
      'Please complete Step 1: select a category, title (min 5 chars), and description (min 10 chars).';

  @override
  String submitConcernSubmissionFailed(String error) {
    return 'Submission failed: $error';
  }

  @override
  String submitConcernPhotosAttached(int count) {
    return '$count attached';
  }

  @override
  String get adminDashboardJoinApplicationsTooltip => 'Join Applications';

  @override
  String get adminDashboardPendingApprovalsTooltip => 'Pending Approvals';

  @override
  String get adminDashboardMemberManagementTooltip => 'Member Management';

  @override
  String get adminDashboardStudentRosterTooltip => 'Student Roster';

  @override
  String get adminDashboardSchoolGradesTooltip => 'School Grades';

  @override
  String get adminDashboardRolesTooltip => 'Roles & Permissions';

  @override
  String get adminDashboardOrgSettingsTooltip => 'Organization Settings';

  @override
  String get adminDashboardTabAll => 'All';

  @override
  String get adminDashboardTabSubmitted => 'Submitted';

  @override
  String get adminDashboardTabUnderReview => 'Under Review';

  @override
  String get adminDashboardTabInProgress => 'In Progress';

  @override
  String get adminDashboardTabResolved => 'Resolved';

  @override
  String get adminDashboardTabClosed => 'Closed';

  @override
  String get adminDashboardStatTotal => 'Total';

  @override
  String get adminDashboardStatSubmitted => 'Submitted';

  @override
  String get adminDashboardStatUnderReview => 'Under Review';

  @override
  String get adminDashboardStatInProgress => 'In Progress';

  @override
  String get adminDashboardStatResolved => 'Resolved';

  @override
  String get adminDashboardStatClosed => 'Closed';

  @override
  String get adminDashboardSearchHint =>
      'Search by title or reference number...';

  @override
  String get adminDashboardLoadingReports => 'Loading reports...';

  @override
  String get adminDashboardLoadFailed => 'Failed to load reports';

  @override
  String get adminDashboardNoResults => 'No results';

  @override
  String get adminDashboardNoReports => 'No reports';

  @override
  String adminDashboardNoReportsMatch(String query) {
    return 'No reports match \"$query\".';
  }

  @override
  String get adminDashboardNoActiveReports =>
      'No active reports submitted yet.';

  @override
  String get adminDashboardNoClosedReports => 'No closed reports.';

  @override
  String adminDashboardNoTabReports(String tab) {
    return 'No \"$tab\" reports.';
  }

  @override
  String adminDashboardUpdateStatusFailed(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String adminDashboardReportsCount(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$label: $_temp0';
  }

  @override
  String get adminDashboardReportPriorityLow => 'Low';

  @override
  String get adminDashboardReportPriorityMedium => 'Medium';

  @override
  String get adminDashboardReportPriorityHigh => 'High';

  @override
  String get adminDashboardReportPriorityUrgent => 'Urgent';

  @override
  String get memberManagementSearchHint => 'Search by name or email…';

  @override
  String memberManagementUpdatedCount(int count) {
    return 'Updated $count member(s)';
  }

  @override
  String get memberManagementUpdated => 'Member updated';

  @override
  String get memberManagementBlocked => 'Member blocked';

  @override
  String get memberManagementUnblocked => 'Member unblocked';

  @override
  String memberManagementLoadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get memberManagementEmptyActive => 'No active members found.';

  @override
  String get memberManagementEmptyBlocked => 'No blocked members found.';

  @override
  String get memberManagementEmptyUnenrolled => 'No unenrolled members found.';

  @override
  String get memberManagementEmptyFiltered => 'No members match your filters.';

  @override
  String memberManagementSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get memberManagementBulkBlock => 'Block';

  @override
  String get memberManagementBulkUnenroll => 'Unenroll';

  @override
  String get memberManagementBulkReenroll => 'Re-enroll';

  @override
  String get memberManagementBulkAssignGrade => 'Assign grade';

  @override
  String get memberManagementReenroll => 'Re-enroll';

  @override
  String get memberManagementUnblock => 'Unblock';

  @override
  String get memberManagementUnenroll => 'Unenroll';

  @override
  String get memberManagementAssignGrade => 'Assign grade';

  @override
  String get memberManagementBlock => 'Block';

  @override
  String get memberManagementEditProfile => 'Edit profile…';

  @override
  String get memberManagementResetPassword => 'Reset password…';

  @override
  String memberManagementBlockDialogTitle(String name) {
    return 'Block $name?';
  }

  @override
  String memberManagementUnenrollDialogTitle(String name) {
    return 'Unenroll $name?';
  }

  @override
  String memberManagementReenrollDialogTitle(String name) {
    return 'Re-enroll $name?';
  }

  @override
  String memberManagementAssignGradeDialogTitle(String name) {
    return 'Assign grade to $name';
  }

  @override
  String get memberManagementGradeAssigned => 'Grade assigned';

  @override
  String get memberManagementNoAccess =>
      'You do not have permission to manage enrolled members.';

  @override
  String get memberManagementBlockReasonHint =>
      'Why is this account being blocked?';

  @override
  String get memberManagementConfirmBlockTitle => 'Confirm block';

  @override
  String memberManagementConfirmBlockMessage(String name) {
    return '$name will lose access immediately.';
  }

  @override
  String get memberManagementConfirmBlockAction => 'Confirm block';

  @override
  String get memberManagementUnblockMessage =>
      'This member will regain access to the organization.';

  @override
  String memberManagementUnenrollTitleOne(String name) {
    return 'Unenroll $name?';
  }

  @override
  String memberManagementUnenrollTitleMany(int count) {
    return 'Unenroll $count members?';
  }

  @override
  String get memberManagementUnenrollHint =>
      'e.g. Graduated, transferred, left the school';

  @override
  String get memberManagementConfirmUnenrollTitle => 'Confirm unenrollment';

  @override
  String get memberManagementConfirmUnenrollMessageOne =>
      'This member will lose access immediately.';

  @override
  String memberManagementConfirmUnenrollMessageMany(int count) {
    return '$count members will lose access immediately.';
  }

  @override
  String get memberManagementConfirmUnenrollAction => 'Confirm unenroll';

  @override
  String memberManagementBulkBlockTitle(int count) {
    return 'Block $count members?';
  }

  @override
  String get memberManagementBulkBlockHint =>
      'Why are these accounts being blocked?';

  @override
  String memberManagementBulkBlockConfirmMessage(int count) {
    return '$count member(s) will lose access immediately.';
  }

  @override
  String memberManagementBulkUnblockTitle(int count) {
    return 'Unblock $count members?';
  }

  @override
  String get memberManagementBulkUnblockMessage =>
      'These members will regain access to the organization.';

  @override
  String get memberManagementConfirmUnblockAction => 'Confirm unblock';

  @override
  String memberManagementReenrollTitleOne(String name) {
    return 'Re-enroll $name?';
  }

  @override
  String memberManagementReenrollTitleMany(int count) {
    return 'Re-enroll $count members?';
  }

  @override
  String get memberManagementReenrollMessageOne =>
      'This member will regain full access to the organization.';

  @override
  String memberManagementReenrollMessageMany(int count) {
    return '$count members will regain full access.';
  }

  @override
  String get memberManagementConfirmReenrollAction => 'Confirm re-enroll';

  @override
  String get memberManagementConfirmGradeTitle => 'Confirm grade assignment';

  @override
  String memberManagementConfirmGradeOne(String name, int grade) {
    return 'Set $name to Grade $grade?';
  }

  @override
  String memberManagementConfirmGradeMany(int count, int grade) {
    return 'Set $count members to Grade $grade?';
  }

  @override
  String memberManagementBlockReasonLabel(String reason) {
    return 'Block reason: $reason';
  }

  @override
  String memberManagementUnenrollReasonLabel(String reason) {
    return 'Unenrolled: $reason';
  }

  @override
  String memberManagementPreviewAndMore(int count) {
    return '…and $count more';
  }

  @override
  String get memberManagementEditMemberTitle => 'Edit Member';

  @override
  String get memberManagementEditMemberIntro =>
      'Update login username (student ID), contact email, grade, and display name. Changing a student ID also updates their sign-in username.';

  @override
  String memberManagementLoadMemberFailed(String error) {
    return 'Could not load member: $error';
  }

  @override
  String get memberManagementMemberNotFound => 'Member not found';

  @override
  String get memberManagementUpdateFailed => 'Could not update member';

  @override
  String get memberManagementStudentPersonalBadge => 'Student personal badge';

  @override
  String get memberManagementStudentPersonalBadgeHint =>
      'Optional photo the student chose in Settings. This does not replace the official school photo above.';

  @override
  String get memberManagementFullNameLabel => 'Full name';

  @override
  String get memberManagementFullNameHint => 'Legal / roster name';

  @override
  String get memberManagementFullNameExample => 'e.g. Juan Dela Cruz';

  @override
  String get memberManagementStudentIdUsernameLabel => 'Student ID (username)';

  @override
  String get memberManagementStudentIdLabel => 'Student ID';

  @override
  String get memberManagementStudentIdSignInHint =>
      'School-issued ID for sign-in';

  @override
  String get memberManagementStudentIdProvisionHint =>
      'School-issued ID (min. 6 characters)';

  @override
  String get memberManagementContactEmailOptionalLabel =>
      'Contact email (optional)';

  @override
  String get memberManagementContactEmailHint =>
      'For notifications; can also sign in if set';

  @override
  String get memberManagementContactEmailFutureHint =>
      'Contact email for future login';

  @override
  String get memberManagementNoGrade => 'No grade';

  @override
  String get memberManagementSaveChanges => 'Save changes';

  @override
  String get memberManagementPasswordSection => 'Password';

  @override
  String get memberManagementPasswordSectionHint =>
      'Set a new sign-in password for this member. Their current session stays active until they sign out.';

  @override
  String get memberManagementConfirmPasswordResetTitle =>
      'Confirm password reset';

  @override
  String memberManagementConfirmPasswordResetMessage(String name) {
    return 'Set a new sign-in password for $name? They will need it the next time they sign in.';
  }

  @override
  String get memberManagementResetPasswordAction => 'Reset password';

  @override
  String memberManagementPasswordResetSuccess(String name) {
    return 'Password reset for $name';
  }

  @override
  String get memberManagementPasswordResetFailed => 'Could not reset password';

  @override
  String memberManagementResetPasswordDialogTitle(String name) {
    return 'Reset password for $name';
  }

  @override
  String get memberManagementResetPasswordIntro =>
      'Choose a new sign-in password. Use the shortcuts below or enter one manually.';

  @override
  String get memberManagementUseUsernamePassword => 'Use username / student ID';

  @override
  String get memberManagementGenerate8DigitPassword =>
      'Generate 8-digit password';

  @override
  String get memberManagementPasswordMinHint => 'At least 6 characters';

  @override
  String get memberManagementConfirmPasswordLabel => 'Confirm password';

  @override
  String memberManagementAppliedAt(String date) {
    return 'Applied $date';
  }

  @override
  String memberManagementStudentIdWithValue(String id) {
    return 'Student ID: $id';
  }

  @override
  String get memberManagementViewOnlyNoPermission =>
      'View only — you do not have permission to approve applications.';

  @override
  String get memberManagementRejectApplication => 'Reject application';

  @override
  String get memberManagementRejectApplicationHint =>
      'Let the applicant know why…';

  @override
  String get memberManagementNoPendingApplications => 'No pending applications';

  @override
  String get memberManagementNoPendingApplicationsHint =>
      'When someone signs up and completes the Join form, their request will appear here.';

  @override
  String get studentRosterSearchHint => 'Search by name or student ID…';

  @override
  String get studentRosterAssignSelected => 'Assign grade to selected';

  @override
  String get studentRosterAddStudent => 'Add Student';

  @override
  String get studentRosterAddStudentIntro =>
      'Creates a pre-approved account. The student signs in using their school ID in both fields until email auth is enabled.';

  @override
  String get studentRosterSelectGrade => 'Select a grade';

  @override
  String get studentRosterAdding => 'Adding…';

  @override
  String studentRosterAddedSuccess(String name) {
    return 'Added $name. They can sign in with their student ID as the password.';
  }

  @override
  String get studentRosterAddFailed => 'Could not add student';

  @override
  String studentRosterGradeStatusLine(String grade, String status) {
    return '$grade · $status';
  }

  @override
  String get studentRosterOfficialPhotoUpdated => 'Official photo updated';

  @override
  String get studentRosterOfficialPhotoRemoved => 'Official photo removed';

  @override
  String get studentRosterOfficialPhotoSectionTitle => 'Official school photo';

  @override
  String get studentRosterOfficialPhotoSectionHint =>
      'Permanent school record for faculty and admins. Stored separately from any personal photo the student may add in Settings (when allowed). A student personal badge never replaces or deletes this official image.';

  @override
  String studentRosterPhotoUpdateFailed(String error) {
    return 'Photo update failed: $error';
  }

  @override
  String get studentRosterAssignGradeTitle => 'Assign grade';

  @override
  String studentRosterAllSelected(int count) {
    return 'All $count selected';
  }

  @override
  String studentRosterOfficialPhotoTitle(String name) {
    return 'Official photo — $name';
  }

  @override
  String studentRosterSectionLabel(String section) {
    return 'Section: $section';
  }

  @override
  String studentRosterAssignFailed(String error) {
    return 'Failed to assign grades: $error';
  }

  @override
  String studentRosterUpdatedCount(int count) {
    return 'Updated $count student(s)';
  }

  @override
  String studentRosterLoadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get studentRosterNoPermission =>
      'You do not have permission to manage the student roster.';

  @override
  String get studentRosterNotSchool =>
      'Student roster and grades are only available for school-type organizations.';

  @override
  String get studentRosterEmpty =>
      'No students yet. Tap Add Student to provision an account.';

  @override
  String get studentRosterNoMatch => 'No students match your filters.';

  @override
  String studentRosterAssignGradeWhichGroup(int count) {
    return '$count students are selected. Assign a grade to which group?';
  }

  @override
  String studentRosterOnlyNamed(String name) {
    return 'Only $name';
  }

  @override
  String get studentRosterOnlyThisStudent => 'Only this student';

  @override
  String studentRosterAssignGradeToOne(String name) {
    return 'Assign grade to $name';
  }

  @override
  String studentRosterAssignGradeToMany(int count) {
    return 'Assign grade to $count students';
  }

  @override
  String get studentRosterConfirmGradeTitle => 'Confirm grade assignment';

  @override
  String studentRosterConfirmGradeOne(String name, int grade) {
    return 'Set $name to Grade $grade?';
  }

  @override
  String studentRosterConfirmGradeMany(int count, int grade) {
    return 'Set $count students to Grade $grade?';
  }

  @override
  String studentRosterPreviewAndMore(int count) {
    return '…and $count more';
  }

  @override
  String get rolesManagementTitle => 'Roles & Permissions';

  @override
  String get rolesAssignments => 'Assignments';

  @override
  String get rolesCapabilities => 'Capabilities';

  @override
  String get rolesCreateRole => 'Create Role';

  @override
  String get rolesSystemRoles => 'System Roles';

  @override
  String get rolesCustomRoles => 'Custom Roles';

  @override
  String get rolesNoCapabilities => 'No capabilities assigned';

  @override
  String rolesMoreCapabilities(int count) {
    return '+$count more';
  }

  @override
  String get rolesAssignUsers => 'Assign Users';

  @override
  String rolesSeedFailed(String error) {
    return 'Seed failed: $error';
  }

  @override
  String get rolesSeedSuccess => 'Default roles added successfully';

  @override
  String get rolesCreateManually => 'Create Role Manually';

  @override
  String get rolesNoRolesEmpty => 'No roles defined yet';

  @override
  String get rolesSystemBadge => 'System';

  @override
  String get rolesSeedDefaultRoles => 'Seed Default Roles';

  @override
  String get rolesSeeding => 'Seeding…';

  @override
  String get rolesEmptyDescription =>
      'Create your first custom role to grant staff\nspecific capabilities within this organisation.';

  @override
  String rolesAllCapabilitiesTitle(String roleName) {
    return '$roleName — All Capabilities';
  }

  @override
  String get roleAssignmentsTitle => 'User Role Assignments';

  @override
  String get roleAssignmentsNoUsers => 'No approved users found.';

  @override
  String get roleAssignmentsNoRoles => 'No roles assigned';

  @override
  String assignRoleTitle(String roleName) {
    return 'Assign: $roleName';
  }

  @override
  String get assignRoleSuccess => 'Role assigned successfully';

  @override
  String assignRoleFailed(String error) {
    return 'Assignment failed: $error';
  }

  @override
  String get assignRoleScopeType => 'Scope Type';

  @override
  String get assignRoleRemoveTitle => 'Remove Assignment?';

  @override
  String assignRoleRemoveConfirm(Object scope) {
    return 'Remove this role assignment ($scope)? The user will immediately lose the permissions granted by this role.';
  }

  @override
  String get capabilitiesTitle => 'Capabilities';

  @override
  String get capabilitiesTabCustom => 'Custom';

  @override
  String get capabilitiesTabBuiltins => 'Built-ins';

  @override
  String get capabilitiesDeleteTitle => 'Delete Capability?';

  @override
  String capabilitiesDeleteBody(String name) {
    return '\"$name\" will be removed. Roles using it will lose this capability assignment.';
  }

  @override
  String get capabilitiesCreateLabel => 'Create Custom Capability';

  @override
  String get capabilitiesBackedByLabel => 'Backed by (built-in action)';

  @override
  String get capabilitiesBuiltinsIntro =>
      'These are the built-in capabilities available across all SpeakUp Connect organisations. They cannot be modified or removed — only custom capability aliases can be created on top of them.';

  @override
  String get roleEditorCreateTitle => 'Create Role';

  @override
  String get roleEditorEditTitle => 'Edit Role';

  @override
  String get roleEditorRoleDetails => 'Role Details';

  @override
  String get roleEditorRoleName => 'Role Name';

  @override
  String get roleEditorDescription => 'Description';

  @override
  String get roleEditorCapabilities => 'Capabilities';

  @override
  String get roleEditorManageCustom => 'Manage Custom';

  @override
  String get roleEditorCapabilitiesHint =>
      'Select the built-in capabilities this role grants.';

  @override
  String get roleEditorCustomCapabilities => 'Custom Capabilities';

  @override
  String get roleEditorCustomCapabilitiesHint =>
      'Org-defined capability aliases built on top of built-ins.';

  @override
  String get roleEditorNoCustomCaps => 'No custom capabilities yet.';

  @override
  String get roleEditorCreateCustomCap => 'Create a custom capability →';

  @override
  String get roleEditorSaveRole => 'Save Role';

  @override
  String get roleEditorSaving => 'Saving…';

  @override
  String get roleEditorSaved => 'Role saved';

  @override
  String roleEditorSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get roleEditorAssignUsers => 'Assign Users';

  @override
  String roleEditorBasedOn(String permission) {
    return 'Based on: $permission';
  }

  @override
  String get orgSettingsTitle => 'Organization Settings';

  @override
  String get orgSettingsDisplayName => 'Display Name';

  @override
  String get orgSettingsDisplayNameHint => 'e.g. Riverside High';

  @override
  String get orgSettingsBrandingUpdated => 'Branding updated successfully';

  @override
  String orgSettingsSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get orgSettingsContrastWarning => 'Contrast Warning';

  @override
  String get orgSettingsSaveAnyway => 'Save Anyway';

  @override
  String get orgSettingsAutoAdjustSave => 'Auto-adjust & Save';

  @override
  String orgSettingsSeedCategoriesFailed(String error) {
    return 'Seed failed: $error';
  }

  @override
  String get orgSettingsSeedCategoriesSuccess =>
      'Default categories added successfully';

  @override
  String get orgSettingsChangeOrgTypeTitle => 'Change organization type?';

  @override
  String orgSettingsChangeOrgTypeConfirm(
      String fromType, String toType, String description) {
    return 'Change from $fromType to $toType?\n\n$description\n\nThis affects which admin features are available (such as student grades and roster for schools).';
  }

  @override
  String orgSettingsOrgTypeSaved(String type) {
    return 'Organization type set to $type';
  }

  @override
  String orgSettingsOrgTypeFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get orgSettingsTypeLabel => 'Type';

  @override
  String get orgSettingsSaveType => 'Save type';

  @override
  String get orgSettingsAllowPersonalPhotos => 'Allow personal profile photos';

  @override
  String get orgSettingsRequireApproval => 'Require approval before publishing';

  @override
  String get orgSettingsOrgNameTitle => 'Organization Name';

  @override
  String get orgSettingsOrgNameSubtitle =>
      'Displayed on the splash screen as \"SpeakUp [Name]\".';

  @override
  String get orgSettingsOrganizationIdTitle => 'Organization ID';

  @override
  String get orgSettingsOrganizationIdSubtitle =>
      'Unique identifier used for this organization.';

  @override
  String get orgSettingsOrganizationIdLabel => 'Current organization ID';

  @override
  String get orgSettingsOrganizationIdCopied => 'Organization ID copied';

  @override
  String get orgSettingsBrandColorsTitle => 'Brand Colors';

  @override
  String get orgSettingsBrandColorsSubtitle =>
      'Enter 6-digit hex codes from the organization\'s brand guide (e.g. #1A73E8). Changes apply to all connected devices in real time and are cached locally for instant startup.';

  @override
  String get orgSettingsPrimaryColor => 'Primary Color';

  @override
  String get orgSettingsSecondaryColor => 'Secondary Color';

  @override
  String get orgSettingsColorHint => 'e.g. #1A73E8';

  @override
  String get orgSettingsSecondaryColorHint => 'e.g. #000000';

  @override
  String get orgSettingsSaveBranding => 'Save Branding';

  @override
  String get orgSettingsSaving => 'Saving…';

  @override
  String get orgSettingsBrandingInfo =>
      'After saving, the new colors will appear immediately on all connected devices. On this device the branding is also written to local storage, so it loads correctly on the next app launch before Firestore responds.';

  @override
  String get orgSettingsReportCategoriesTitle => 'Report Categories';

  @override
  String get orgSettingsReportCategoriesSubtitle =>
      'Categories are required for users to submit concerns. Tap the button below to populate the default set.';

  @override
  String orgSettingsCategoriesConfigured(int count) {
    return '$count categories configured';
  }

  @override
  String get orgSettingsAddDefaultCategories => 'Add Default Categories';

  @override
  String get orgSettingsAddingCategories => 'Adding…';

  @override
  String get orgSettingsOrgTypeTitle => 'Organization Type';

  @override
  String get orgSettingsOrgTypeSubtitle =>
      'Determines which features are available. Schools can use student grades and roster; municipalities and NGOs use member management without grades.';

  @override
  String get orgSettingsMemberPhotosTitle => 'Member Profile Photos';

  @override
  String get orgSettingsMemberPhotosSubtitle =>
      'When enabled, students may upload a personal badge in Settings. Official school photos uploaded by staff remain a separate permanent record and are never overwritten.';

  @override
  String get orgSettingsMemberPhotosOn =>
      'Currently ON — members can add a personal badge in Settings';

  @override
  String get orgSettingsMemberPhotosOff =>
      'Currently OFF — only official school photos are shown';

  @override
  String get orgSettingsMemberPhotosEnabled =>
      'Members can now upload personal profile photos';

  @override
  String get orgSettingsMemberPhotosDisabled =>
      'Personal profile photos are disabled for members';

  @override
  String get orgSettingsReminderApprovalTitle => 'Reminder Approval';

  @override
  String get orgSettingsReminderApprovalSubtitle =>
      'When enabled, members who can broadcast reminders but cannot approve them must submit reminders for review before they are published.';

  @override
  String get orgSettingsReminderApprovalOn =>
      'Currently ON — reminders from non-approvers are held for review';

  @override
  String get orgSettingsReminderApprovalOff =>
      'Currently OFF — reminders publish immediately';

  @override
  String get orgSettingsReminderApprovalEnabled =>
      'Reminders now require approval before publishing';

  @override
  String get orgSettingsReminderApprovalDisabled =>
      'Reminders now publish directly';

  @override
  String get orgSettingsPermissionDenied =>
      'You do not have permission to change this setting.';

  @override
  String get orgSettingsPrimarySwatch => 'Primary';

  @override
  String get orgSettingsSecondarySwatch => 'Secondary';

  @override
  String get orgSettingsRequired => 'Required';

  @override
  String get orgSettingsHexInvalid =>
      'Enter a valid 6-digit hex (e.g. #1A73E8)';

  @override
  String get orgSettingsPrimaryHexInvalid =>
      'Primary color must be a valid 6-digit hex (e.g. #1A73E8).';

  @override
  String get orgSettingsSecondaryHexInvalid =>
      'Secondary color must be a valid 6-digit hex (e.g. #000000).';

  @override
  String get orgSettingsContrastLightBackgrounds => 'light backgrounds';

  @override
  String get orgSettingsContrastDarkBackgrounds => 'dark backgrounds';

  @override
  String get orgSettingsContrastLightAndDarkBackgrounds =>
      'light and dark backgrounds';

  @override
  String orgSettingsContrastSecondaryFallback(
      String primary, String secondary, String surfaces) {
    return 'Your primary color ($primary) isn\'t visible enough on $surfaces — it will blend into the background.\n\nYour secondary color ($secondary) will be used as a fallback for buttons and icons, but you may want a more suitable primary.\n\nYou can save anyway or let the app shift the primary to the nearest contrast-safe shade.';
  }

  @override
  String orgSettingsContrastNeither(
      String primary, String secondary, String surfaces) {
    return 'Neither your primary ($primary) nor secondary ($secondary) color provides enough contrast against $surfaces. Buttons, links, and icons may be hard to see.\n\nYou can save anyway, or let the app shift the primary color to the nearest contrast-safe shade.';
  }

  @override
  String get orgSettingsProfilePhotoSaveFailed =>
      'Profile photo setting did not save.';

  @override
  String get orgSettingsReminderApprovalSaveFailed =>
      'Reminder approval setting did not save.';

  @override
  String get orgTypeAdminSchool => 'School';

  @override
  String get orgTypeAdminUniversity => 'University';

  @override
  String get orgTypeAdminLgu => 'Municipality / LGU';

  @override
  String get orgTypeAdminNgo => 'NGO';

  @override
  String get orgTypeAdminChurch => 'Church';

  @override
  String get orgTypeAdminCorporation => 'Corporation';

  @override
  String get orgTypeAdminOther => 'Other';

  @override
  String get orgTypeAdminSchoolDesc =>
      'Enables student grades, roster, and class-based features.';

  @override
  String get orgTypeAdminUniversityDesc =>
      'Enables student grades, roster, and class-based features.';

  @override
  String get orgTypeAdminLguDesc =>
      'For municipalities, barangays, and local government units.';

  @override
  String get orgTypeAdminNgoDesc =>
      'For non-profit and community organizations.';

  @override
  String get orgTypeAdminChurchDesc =>
      'For churches and faith-based communities.';

  @override
  String get orgTypeAdminCorporationDesc =>
      'For companies and workplace communities.';

  @override
  String get orgTypeAdminOtherDesc =>
      'Generic organization without type-specific features.';

  @override
  String get commonClose => 'Close';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRequired => 'Required';

  @override
  String commonErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get commonRole => 'Role';

  @override
  String get commonNameRequired => 'Name is required';

  @override
  String adminDashboardAnonymousDate(String date) {
    return 'Anonymous · $date';
  }

  @override
  String adminDashboardSubmitterDate(String name, String date) {
    return '$name · $date';
  }

  @override
  String get reportCategoryFacility => 'Facility & Infrastructure';

  @override
  String get reportCategorySafety => 'Safety & Security';

  @override
  String get reportCategoryAcademic => 'Academic Concern';

  @override
  String get reportCategoryBullying => 'Bullying & Harassment';

  @override
  String get reportCategorySanitation => 'Sanitation & Cleanliness';

  @override
  String get reportCategoryConduct => 'Staff / Teacher Conduct';

  @override
  String get reportCategoryAdministrative => 'Administrative';

  @override
  String get reportCategoryOther => 'Other';

  @override
  String get adminReportDetailTitle => 'Report Detail';

  @override
  String get adminReportDetailLoading => 'Loading report...';

  @override
  String get adminReportDetailLoadFailed => 'Failed to load report';

  @override
  String adminReportDetailSubmittedDate(String date) {
    return 'Submitted $date';
  }

  @override
  String get adminReportDetailAnonymousSubmission => 'Anonymous submission';

  @override
  String adminReportDetailBySubmitter(String name) {
    return 'By: $name';
  }

  @override
  String get adminReportDetailDescription => 'Description';

  @override
  String adminReportDetailPhotos(int count) {
    return 'Photos ($count)';
  }

  @override
  String get adminReportDetailAdminActions => 'Admin Actions';

  @override
  String get adminReportDetailUpdateStatus => 'Update Status';

  @override
  String get adminReportDetailAddNote => 'Add Note';

  @override
  String get adminReportDetailAssignToAdmin => 'Assign to Admin';

  @override
  String get adminReportDetailReassign => 'Reassign';

  @override
  String get adminReportDetailUnassigned => 'Unassigned';

  @override
  String adminReportDetailAssignedTo(String name) {
    return 'Assigned to: $name';
  }

  @override
  String adminReportDetailAdminNotes(int count) {
    return 'Admin Notes ($count)';
  }

  @override
  String get adminReportDetailStatusHistory => 'Status History';

  @override
  String get adminReportDetailAddAdminNote => 'Add Admin Note';

  @override
  String adminReportDetailCurrentStatus(String status) {
    return 'Current: $status';
  }

  @override
  String get adminReportDetailNewStatus => 'New Status';

  @override
  String get adminReportDetailStatusChangeNoteHint =>
      'Add a note about this status change…';

  @override
  String get adminReportDetailAssignTitle => 'Assign to Admin';

  @override
  String get adminReportDetailSearchAdmins => 'Search admins…';

  @override
  String get adminReportDetailNoAdmins => 'No admins found.';

  @override
  String adminReportDetailLoadAdminsFailed(String error) {
    return 'Failed to load admins: $error';
  }

  @override
  String adminReportDetailAssignFailed(String error) {
    return 'Failed to assign report: $error';
  }

  @override
  String adminReportDetailUpdateStatusFailed(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String adminReportDetailAddNoteFailed(String error) {
    return 'Failed to add note: $error';
  }

  @override
  String get adminReportDetailNoteLabel => 'Note';

  @override
  String get adminReportDetailEnterNote => 'Enter your note…';

  @override
  String get reportDetailsTitle => 'Report Details';

  @override
  String get reportDetailsLoading => 'Loading report...';

  @override
  String get reportDetailsLoadFailed => 'Failed to load report';

  @override
  String get myReportsTitle => 'My Reports';

  @override
  String get myReportsNoReportsYet => 'No reports yet';

  @override
  String get myReportsTabAll => 'All';

  @override
  String get myReportsTabInProgress => 'In Progress';

  @override
  String get myReportsTabResolved => 'Resolved';

  @override
  String get myReportsNewReport => 'New Report';

  @override
  String get myReportsEmptyAll => 'You haven\'t submitted any reports yet.';

  @override
  String myReportsEmptyFiltered(String status) {
    return 'No reports with status \"$status\".';
  }

  @override
  String get rolesEdit => 'Edit';

  @override
  String get roleEditorNameHint => 'e.g. Guidance Counselor';

  @override
  String get roleEditorDescriptionHint =>
      'Briefly describe who this role is for';

  @override
  String get assignRoleSelectUser => 'Select User';

  @override
  String get assignRoleSearchHint => 'Search by name or student ID';

  @override
  String get assignRoleConfirmAssignment => 'Confirm Assignment';

  @override
  String get assignRoleAssigning => 'Assigning…';

  @override
  String get assignRoleNoUsersFound => 'No users found.';

  @override
  String get assignRoleScopeTitle => 'Role Scope';

  @override
  String get assignRoleScopeSubtitle =>
      'Define how broadly this role applies for this user.';

  @override
  String get assignRoleScopeOptionOrg => 'Org-wide';

  @override
  String get assignRoleScopeOptionTag => 'Specific tag';

  @override
  String get assignRoleScopeOptionClass => 'Specific class / section';

  @override
  String get assignRoleScopeOptionGroup => 'Specific group / club';

  @override
  String get assignRoleScopeOptionDepartment => 'Specific department';

  @override
  String get assignRoleScopeOptionBarangay => 'Specific barangay';

  @override
  String get assignRoleScopeFieldTag => 'Tag';

  @override
  String get assignRoleScopeFieldClassId => 'Class ID';

  @override
  String get assignRoleScopeFieldGroupId => 'Group ID';

  @override
  String get assignRoleScopeFieldDepartmentId => 'Department ID';

  @override
  String get assignRoleScopeFieldBarangayId => 'Barangay ID';

  @override
  String get assignRoleScopeHintTag => 'e.g. guidance';

  @override
  String get assignRoleScopeHintClass => 'Firestore class document ID';

  @override
  String get assignRoleScopeHintGroup => 'Firestore group document ID';

  @override
  String get assignRoleScopeHintDepartment =>
      'Firestore department document ID';

  @override
  String get assignRoleScopeHintBarangay => 'Firestore barangay document ID';

  @override
  String get assignRoleScopeChipOrg => 'Org-wide';

  @override
  String get assignRoleScopeChipTag => 'Tag';

  @override
  String get assignRoleScopeChipClass => 'Class';

  @override
  String get assignRoleScopeChipGroup => 'Group';

  @override
  String get assignRoleScopeChipDepartment => 'Department';

  @override
  String get assignRoleScopeChipDept => 'Dept';

  @override
  String get assignRoleScopeChipBarangay => 'Barangay';

  @override
  String assignRoleScopeValueTag(String id) {
    return 'Tag: $id';
  }

  @override
  String assignRoleScopeValueClass(String id) {
    return 'Class: $id';
  }

  @override
  String assignRoleScopeValueGroup(String id) {
    return 'Group: $id';
  }

  @override
  String assignRoleScopeValueDepartment(String id) {
    return 'Department: $id';
  }

  @override
  String assignRoleScopeValueBarangay(String id) {
    return 'Barangay: $id';
  }

  @override
  String get assignRoleCurrentAssignments => 'Current Assignments';

  @override
  String assignRoleAssignedDate(String date) {
    return 'Assigned $date';
  }

  @override
  String get assignRoleRemoveTooltip => 'Remove assignment';

  @override
  String get assignRoleRevokeHint => 'Tap − to revoke an existing assignment.';

  @override
  String assignRoleRoleChip(String role, String scope) {
    return '$role · $scope';
  }

  @override
  String capabilitiesLoadFailed(String error) {
    return 'Could not load custom capabilities:\n$error';
  }

  @override
  String get capabilitiesDeleteTooltip => 'Delete';

  @override
  String get capabilitiesNewCustomTitle => 'New Custom Capability';

  @override
  String get capabilitiesNameLabel => 'Capability Name';

  @override
  String get capabilitiesNameHint => 'e.g. Review Guidance Referral';

  @override
  String get capabilitiesNameRequired => 'Name is required';

  @override
  String get capabilitiesDescriptionLabel => 'Description (optional)';

  @override
  String get capabilitiesSelectBacking => 'Select a backing action';

  @override
  String get capabilitiesRestrictTagLabel => 'Restrict to tag (optional)';

  @override
  String get capabilitiesRestrictTagHint => 'e.g. guidance';

  @override
  String get capabilitiesRestrictTagHelper =>
      'Leave empty to apply to all content with this action.';

  @override
  String get capabilitiesCreating => 'Creating…';

  @override
  String get capabilitiesNoCustomYet => 'No custom capabilities yet';

  @override
  String get capabilitiesNoCustomDescription =>
      'Create a capability alias to give school-specific names to built-in actions.';

  @override
  String get permissionViewAllReports => 'View all org reports';

  @override
  String get permissionViewGroupReports => 'View reports in assigned groups';

  @override
  String get permissionApproveReport => 'Approve / close reports';

  @override
  String get permissionManageReports => 'Update status, escalate & add notes';

  @override
  String get permissionPostBulletinOrgWide => 'Post bulletins org-wide';

  @override
  String get permissionPostBulletinToGroup => 'Post bulletins to own groups';

  @override
  String get permissionBroadcastReminders => 'Broadcast reminders';

  @override
  String get permissionApproveReminders => 'Approve / reject reminders';

  @override
  String get permissionManageGroupRoster => 'Manage own group roster';

  @override
  String get permissionManageClassRoster => 'Manage class roster (school only)';

  @override
  String get permissionApproveApplications => 'Approve join applications';

  @override
  String get permissionBlockUsers => 'Suspend or block users';

  @override
  String get permissionManageOrganizationSettings =>
      'Manage org settings & branding';

  @override
  String get permissionManageRoles => 'Manage roles & assign permissions';

  @override
  String get permissionManageTranslations =>
      'Translation moderator (edit UI strings)';

  @override
  String get permissionViewAuditLogs => 'View audit logs';

  @override
  String get permissionGroupReports => 'Reports';

  @override
  String get permissionGroupBulletins => 'Bulletins & News';

  @override
  String get permissionGroupReminders => 'Reminders';

  @override
  String get permissionGroupRosterUsers => 'Roster & Users';

  @override
  String get permissionGroupAdministration => 'Administration';

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

  @override
  String get translationScreenNamesTitle => 'Screen names';

  @override
  String get translationScreenNamesIntro =>
      'Create screen names, assign each to one app screen, and tag translation strings for filtering. Enable translation badges per app screen to control where in-context editing appears in translation mode.';

  @override
  String get translationScreenNamesNewLabel => 'New screen name';

  @override
  String get translationScreenNamesAdd => 'Add screen name';

  @override
  String get translationScreenNamesCatalog => 'Screen name catalog';

  @override
  String get translationScreenNamesEmpty => 'No screen names yet.';

  @override
  String get translationScreenNamesNameLabel => 'Screen name';

  @override
  String translationScreenNamesAssignedRoute(String route) {
    return 'Assigned to: $route';
  }

  @override
  String get translationScreenNamesUnassignRoute => 'Unassign route';

  @override
  String get translationScreenNamesRouteAssignment => 'Assign to app screen';

  @override
  String get translationScreenNamesRouteHint =>
      'Each app screen can have one screen name. Names already assigned elsewhere are hidden until unassigned. Turn on translation badges to show in-context edit badges on that screen during translation mode.';

  @override
  String get translationScreenNamesBadgesLabel => 'Translation badges';

  @override
  String get translationScreenNamesBadgesHint =>
      'Show edit badges in app translation mode';

  @override
  String get translationModeBadgesOffOnScreen =>
      'Edit badges are off for this screen. Enable them under Screen names.';

  @override
  String get translationScreenNamesRouteDropdown => 'Screen name';

  @override
  String get translationScreenNamesUnassigned => '(unassigned)';

  @override
  String get translationScreenNamesCreated => 'Screen name created.';

  @override
  String get translationScreenNamesSaved => 'Screen name saved.';

  @override
  String translationScreenNamesRenamedCount(int count) {
    return 'Saved. Updated $count string labels.';
  }

  @override
  String get translationScreenNamesDeleteTitle => 'Delete screen name?';

  @override
  String get translationScreenNamesDelete => 'Delete';

  @override
  String translationScreenNamesDeleteBody(String name) {
    return 'Delete \"$name\"? Unassign from any app screen first.';
  }

  @override
  String get translationScreenNamesManage => 'Manage screen names';

  @override
  String get translationScreensSummaryTitle => 'Screens summary';

  @override
  String get translationScreensSummaryTooltip => 'Screens summary';

  @override
  String get translationScreensSummaryBadgesOnlyLabel => 'Show badges ON only';

  @override
  String get translationScreensSummaryCountsHint =>
      'Counts reflect current locale and search filter.';

  @override
  String translationScreensSummaryTotalRoutes(int count) {
    return 'Routes: $count';
  }

  @override
  String translationScreensSummaryAssigned(int count) {
    return 'Assigned: $count';
  }

  @override
  String translationScreensSummaryBadgesOn(int count) {
    return 'Badges ON: $count';
  }

  @override
  String translationScreensSummaryUnknownRoutes(int count) {
    return 'Unknown: $count';
  }

  @override
  String get translationScreensSummaryUnknownSection => 'Unknown/custom routes';

  @override
  String translationScreensSummaryUnknownSectionSubtitle(int count) {
    return '$count route(s) found in entries';
  }

  @override
  String get translationScreensSummaryUnassigned => 'Unassigned';

  @override
  String get translationScreensSummaryBadgesOnChip => 'Badges ON';

  @override
  String get translationScreensSummaryBadgesOffChip => 'Badges OFF';

  @override
  String translationScreensSummaryCountChip(int count) {
    return '$count strings';
  }

  @override
  String get translationStringScreenLabel => 'Screen name';

  @override
  String get translationStringScreenNone => '(none)';

  @override
  String get translationModeStart => 'Browse app in translation mode';

  @override
  String get translationModeStartSubtitle =>
      'Tap badges on screen text to edit translations in context';

  @override
  String translationModeBanner(String locale) {
    return 'Translation mode — $locale';
  }

  @override
  String translationModeShowingPreview(String locale) {
    return 'Showing $locale';
  }

  @override
  String get translationModeLoadingEntries => 'Loading translation entries…';

  @override
  String translationModeSessionEdited(int count) {
    return '$count edits in this session';
  }

  @override
  String get translationModeReviewSession => 'Review';

  @override
  String get translationModeExit => 'Exit translation mode';

  @override
  String get translationModeExitConfirmTitle => 'Discard session edits?';

  @override
  String translationModeExitConfirmBody(int count) {
    return 'You have $count unsaved edits. Exit and discard them?';
  }

  @override
  String get translationModeExitDiscard => 'Discard and exit';

  @override
  String get translationModeEditTitle => 'Edit translation';

  @override
  String get translationModeSourceLabel => 'English (source)';

  @override
  String get translationModeReviewTitle => 'Review session';

  @override
  String get translationModeReviewInactive => 'Translation mode is not active.';

  @override
  String get translationModeReviewEmpty =>
      'No edits yet. Tap translation badges on screen text to add changes.';

  @override
  String translationModeReviewSaveAll(int count) {
    return 'Save $count edits to Firestore';
  }

  @override
  String translationModeReviewSaveAllSuccess(int count) {
    return 'Saved $count translations.';
  }

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsReminderApprovalsTooltip => 'Reminder approvals';

  @override
  String get alertsMoreTooltip => 'More';

  @override
  String get alertsMarkAllRead => 'Mark all read';

  @override
  String get alertsSelectAlerts => 'Select alerts';

  @override
  String get alertsClearSelected => 'Clear selected';

  @override
  String alertsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get alertsSwipeClear => 'Clear';

  @override
  String alertsClearedSelectedSnackbar(int cleared) {
    String _temp0 = intl.Intl.pluralLogic(
      cleared,
      locale: localeName,
      other: '$cleared alerts',
      one: '1 alert',
    );
    return 'Cleared $_temp0';
  }

  @override
  String alertsClearedSelectedSnackbarWithSkipped(int cleared, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      cleared,
      locale: localeName,
      other: '$cleared alerts',
      one: '1 alert',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped kept (response required)',
      one: '1 kept (response required)',
    );
    return 'Cleared $_temp0 · $_temp1';
  }

  @override
  String alertsFailedToLoad(String error) {
    return 'Failed to load alerts: $error';
  }

  @override
  String get alertsClearAllTitle => 'Clear all alerts?';

  @override
  String get alertsAlertDismissed => 'Alert dismissed';

  @override
  String get alertsSubmitBeforeDismiss =>
      'Submit your response before dismissing this alert.';

  @override
  String get alertsDeleteAlertTitle => 'Delete alert?';

  @override
  String get alertsDeleteBroadcastTitle => 'Delete broadcast?';

  @override
  String get alertsDeleteAnnouncementTitle => 'Delete announcement?';

  @override
  String get notificationHistoryTitle => 'Notification history';

  @override
  String notificationHistoryFailedToLoad(String error) {
    return 'Failed to load history: $error';
  }

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonSomethingWentWrong => 'Something went wrong';

  @override
  String get commonMoveUp => 'Move up';

  @override
  String get commonMoveDown => 'Move down';

  @override
  String get commonReason => 'Reason';

  @override
  String get authAccountRestrictedTitle => 'Account Restricted';

  @override
  String get authAccountRestrictedMessage =>
      'Your access to this organization has been suspended.';

  @override
  String get authAccountUnenrolledTitle => 'No Longer Enrolled';

  @override
  String get authAccountUnenrolledMessage =>
      'Your membership in this organization has ended.';

  @override
  String get authAccountReasonLabel => 'Reason';

  @override
  String get authAccountBlockedDefaultReason =>
      'Contact your administrator for help.';

  @override
  String get authAccountUnenrolledDefaultReason =>
      'Contact your administrator if you need access.';

  @override
  String get authApplyAcceptTermsSnackbar =>
      'Please accept the terms to continue.';

  @override
  String authJoinOrgTitle(String orgName) {
    return 'Join $orgName';
  }

  @override
  String authApplyReviewMessage(String orgName) {
    return 'Your details will be reviewed by an admin before you can access $orgName.';
  }

  @override
  String get authFullNameExampleHint => 'e.g. Juan Dela Cruz';

  @override
  String get authStudentMemberId => 'Student / Member ID';

  @override
  String get authStudentMemberIdHint => 'Your school-issued ID number';

  @override
  String get authApplyConfirmAccurate =>
      'I confirm that the information I provided is accurate.';

  @override
  String get authSubmitApplication => 'Submit Application';

  @override
  String get authPendingRejectedTitle => 'Application Rejected';

  @override
  String get authPendingSubmittedTitle => 'Application Submitted!';

  @override
  String get authPendingRejectedMessage =>
      'Your application was not approved. Please contact your administrator for more information.';

  @override
  String get authPendingReviewMessage =>
      'Your application is under review. You\'ll receive a notification once an admin approves your account.';

  @override
  String get authEditApplication => 'Edit Application';

  @override
  String get authSubmittedDetails => 'Submitted Details';

  @override
  String get authStudentId => 'Student ID';

  @override
  String get reminderDetailTitle => 'Reminder';

  @override
  String get reminderDetailNotFound => 'Reminder not found';

  @override
  String reminderDetailLoadFailed(String error) {
    return 'Failed to load reminder: $error';
  }

  @override
  String get reminderDetailScheduledLabel => 'Scheduled';

  @override
  String get reminderDetailExpiresLabel => 'Expires';

  @override
  String get reminderDetailDoesNotExpire => 'Does not expire';

  @override
  String get reminderDetailResponseRequiredBanner =>
      'Response required — submit your answer to dismiss this alert.';

  @override
  String get reminderDetailJustNow => 'Just now';

  @override
  String reminderDetailMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String reminderDetailHoursAgo(int count) {
    return '$count hr ago';
  }

  @override
  String reminderDetailDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String reminderMyBroadcastsUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String reminderMyBroadcastsUpdatedWithAlerts(int count) {
    return 'Broadcast updated — $count alert(s) refreshed.';
  }

  @override
  String get reminderMyBroadcastsUpdated => 'Broadcast updated.';

  @override
  String reminderMyBroadcastsRecallFailed(String error) {
    return 'Recall failed: $error';
  }

  @override
  String reminderMyBroadcastsRecalledWithAlerts(int count) {
    return 'Reminder recalled — $count delivered alert(s) removed.';
  }

  @override
  String get reminderMyBroadcastsDeleted => 'Reminder deleted.';

  @override
  String reminderMyBroadcastsExpiresAt(String dateTime) {
    return 'Expires $dateTime';
  }

  @override
  String get reminderMyBroadcastsRecallTitle => 'Recall this broadcast?';

  @override
  String get reminderMyBroadcastsDeleteTitle => 'Delete broadcast?';

  @override
  String get reminderMyBroadcastsRecallMessage =>
      'This deletes the reminder and removes it from every recipient\'s alerts feed. This cannot be undone.';

  @override
  String get reminderMyBroadcastsDeleteMessage =>
      'This permanently deletes the reminder. This cannot be undone.';

  @override
  String get reminderMyBroadcastsRecall => 'Recall';

  @override
  String get reminderMyBroadcastsEmptyLeader => 'No group alerts sent yet';

  @override
  String get reminderMyBroadcastsEmpty =>
      'You haven\'t sent any broadcasts yet';

  @override
  String get reminderMyBroadcastsEmptyLeaderHint =>
      'Send an alert from My Groups & Clubs, then return here to view member responses.';

  @override
  String get reminderEditBroadcastTitle => 'Edit broadcast';

  @override
  String get reminderEditEnterTitle => 'Enter a title';

  @override
  String get reminderEditEnterMessage => 'Enter a message';

  @override
  String get reminderResponsesNoResponses => 'This reminder has no responses.';

  @override
  String get reminderResponsesNoResponsesYet => 'No responses yet.';

  @override
  String get reminderResponseSubmitted => 'Response submitted';

  @override
  String get reminderResponseYourResponse => 'Your response';

  @override
  String get reminderResponseAlreadyResponded =>
      'You already responded. Update your answer below if needed.';

  @override
  String get reminderResponseTypeHint => 'Type your response…';

  @override
  String reminderResponseMaxCharacters(int count) {
    return 'Max $count characters';
  }

  @override
  String get reminderResponseAdditionalComments =>
      'Additional comments (optional)';

  @override
  String get reminderResponseAdditionalHint => 'Add an explanation if needed…';

  @override
  String get reminderResponseUpdate => 'Update response';

  @override
  String get reminderResponseSubmit => 'Submit response';

  @override
  String reminderResponseFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get reminderResponseSubmittedLabel => 'Submitted';

  @override
  String get reminderResponseLocked =>
      'Your answer is locked and cannot be changed.';

  @override
  String get reportConfirmationThankYou => 'Thank You!';

  @override
  String get reportConfirmationMessage =>
      'Your report has been submitted successfully. We\'ll look into it and keep you posted.';

  @override
  String get reportConfirmationReferenceLabel => 'Reference Number';

  @override
  String get reportConfirmationCopied => 'Reference number copied!';

  @override
  String get reportConfirmationGoToMyReports => 'Go to My Reports';

  @override
  String get reportConfirmationBackToHome => 'Back to Home';

  @override
  String get reportDetailsSubmittedAnonymously => 'Submitted anonymously';

  @override
  String get groupsDefaultPresident => 'President';

  @override
  String get groupsDefaultVicePresident => 'Vice President';

  @override
  String get groupsNoPositionsYet => 'No positions defined yet.';

  @override
  String groupsPositionNumber(int number) {
    return 'Position $number';
  }

  @override
  String get groupsPositionExampleHint => 'e.g. Vice President';
}
