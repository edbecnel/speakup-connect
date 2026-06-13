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
  String get splashDefaultTagline => 'Imong tingog. Among aksyon.';

  @override
  String get splashGetStarted => 'Sugdi na';

  @override
  String get splashLearnMore => 'Pagkat-on Pa';

  @override
  String get commonLogin => 'Sulod';

  @override
  String get commonSignUp => 'Mag-sign Up';

  @override
  String get commonOr => 'o';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonSubmit => 'Ipadala';

  @override
  String get commonRemove => 'Kuhaa';

  @override
  String get commonBrowse => 'Susiha';

  @override
  String get commonLeave => 'Biyaan';

  @override
  String get commonApprove => 'Aprobahan';

  @override
  String get commonDecline => 'Dili mo-uyon';

  @override
  String get commonDeny => 'Dili';

  @override
  String get commonBack => 'Balik';

  @override
  String get commonSearch => 'Pangita';

  @override
  String get commonRefresh => 'I-refresh';

  @override
  String get commonSelectAll => 'Pilia tanan';

  @override
  String get commonClearAll => 'Ihawan tanan';

  @override
  String get authAcceptTermsSnackbar =>
      'Palihug dawata ang mga Termino ug Patakaran sa Privacy';

  @override
  String get authSignInFailed =>
      'Nakapakyas ang pag-sign in. Palihug sulayi pag-usab.';

  @override
  String get authOrgFallbackName => 'Sumpay';

  @override
  String get authContinueWithGoogle => 'Padayon gamit ang Google';

  @override
  String get authGoogleSignInSoon =>
      'Mag-antos sa pag-sign in sa Google sa dili madugay!';

  @override
  String get authTermsFooter =>
      'Sa pagpadayon, mouyon ka sa among mga Termino ug Privacy Policy.';

  @override
  String get authEmailOrStudentId => 'Email o student ID';

  @override
  String get authEmailOrStudentIdHint => 'you@school.edu o student ID';

  @override
  String get authPasswordHintLogin => 'Ang imong password o student ID';

  @override
  String get authForgotPassword => 'Nakalimot ka sa Password?';

  @override
  String get authFullName => 'Tibuok nga Ngalan';

  @override
  String get authFullNameHint => 'Ibutang ang imong tibuok ngalan';

  @override
  String get authEmailHint => 'ikaw@eskwelahan.edu';

  @override
  String get authPasswordHintRegister =>
      'Dapat adunay labing menos 8 ka karakter';

  @override
  String get authConfirmPassword => 'Kumpirmaha Password';

  @override
  String get authConfirmPasswordHint => 'Ibalik ang imong password';

  @override
  String get authAcceptTermsCheckbox =>
      'Akong gidawat ang mga Termino ug Patakaran sa Privacy';

  @override
  String get homeTitle => 'Balay';

  @override
  String homeWelcome(String firstName) {
    return 'Dayon, $firstName!';
  }

  @override
  String get homeDefaultWelcomeMessage =>
      'Unsaon namo pagtabang aron mapalambo ang mga butang?';

  @override
  String homeWelcomeMessageWithOrgType(String orgType) {
    return 'Unsaon namo pagtabang aron mapalambo ang among $orgType?';
  }

  @override
  String get orgTypeWordSchool => 'eskwelahan';

  @override
  String get orgTypeWordUniversity => 'unibersidad';

  @override
  String get orgTypeWordLgu => 'komunidad';

  @override
  String get orgTypeWordNgo => 'organisasyon';

  @override
  String get orgTypeWordChurch => 'simbahan';

  @override
  String get orgTypeWordCorporation => 'opisina';

  @override
  String get orgTypeWordOther => 'organisasyon';

  @override
  String get homeQuickActions => 'Mabilis nga mga Aksyon';

  @override
  String get homeSubmitConcern => 'Ipadala ang Kabalaoran';

  @override
  String get homeMyReports => 'Ang Akong mga Report (Sundan ang Kahimtang)';

  @override
  String get homeAnnouncements => 'Mga Anunsyo';

  @override
  String homeOrgInformation(String orgName) {
    return '$orgName  \nImpormasyon';
  }

  @override
  String get homeOrgFallback => 'Org';

  @override
  String get homeOrgInfoComingSoon =>
      'Impormasyon sa Organisasyon — Sa Umaabot';

  @override
  String get homeNavMyReports => 'Ang Akong mga Report';

  @override
  String get homeNavAlerts => 'Mga Abiso';

  @override
  String get homeNavProfile => 'Profile';

  @override
  String get homeGroupsTitle => 'Ang Akong mga Grupo ug Klab';

  @override
  String get homeGroupsSeeAll => 'Tan-awa tanan';

  @override
  String homeGroupsSeeAllCount(int count) {
    return 'Tan-awa tanan ($count)';
  }

  @override
  String get homeGroupsView => 'Tan-awa';

  @override
  String get homeGroupsLoadError =>
      'Dili ma-load ang imong mga grupo. I-tap ang Tan-awa ang tanan aron mosulay pag-usab.';

  @override
  String get homeGroupsNone => 'Walay mga grupo pa';

  @override
  String homeGroupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mga grupo',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String get homeGroupsEmptyMessage =>
      'Wala ka pa sa bisan unsang grupo. I-tap ang Tan-awa para sa mga detalye.';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get settingsAnonymous => 'Walay Ngalan';

  @override
  String get settingsOrgUnavailable => '—';

  @override
  String settingsPhotoUpdateFailed(String message) {
    return 'Dili ma-update ang litrato: $message';
  }

  @override
  String get settingsUnknownError => 'Dili mailhan nga sayop';

  @override
  String get settingsPersonalPhotosDisabled =>
      'Wala gi-enable ang mga personal nga profile photo. Pangutan-a ang usa ka administrador aron i-on ang \"Tugoti ang mga personal nga profile photo\" sa ilawom sa Mga Setting sa Organisasyon.';

  @override
  String get settingsPersonalPhotoUpdated =>
      'Na-update ang personal nga profile nga litrato';

  @override
  String get settingsPersonalPhotoRemoved =>
      'Nawala ang personal nga litrato — nagpakita sa litrato sa eskwelahan';

  @override
  String settingsSpeakUpOrg(String orgName) {
    return 'SpeakUp $orgName';
  }

  @override
  String get settingsTapPhotoChange =>
      'I-tap ang imong litrato aron usbon ang imong personal nga badge';

  @override
  String get settingsSchoolPhotoOnFile =>
      'Naa\'y litrato sa eskwelahan nga naka-file — pangutan-a ang admin aron ma-enable ang personal nga pag-upload';

  @override
  String get settingsPersonalUploadsRequireApproval =>
      'I-tap ang imong litrato — ang personal nga mga upload nagkinahanglan og pag-apruba sa admin';

  @override
  String get groupsManageMembers => 'Pagdumala sa mga Miyembro';

  @override
  String get groupsViewMembers => 'Tan-awa ang mga Miyembro';

  @override
  String get groupsAddMembers => 'Magdugang og mga Miyembro';

  @override
  String get groupsRequests => 'Mga Hangyo';

  @override
  String groupsRequestsCount(int count) {
    return 'Mga Hangyo ($count)';
  }

  @override
  String get groupsSendAlert => 'Magpadala og Alerto';

  @override
  String get groupsEditGroup => 'Usba ang Grupo';

  @override
  String get groupsEditGroupMembersHint =>
      'Usba ang ngalan, deskripsyon, mga palisiya, ug mga posisyon sa klub';

  @override
  String get groupsPostAnnouncement => 'I-post ang Anunsyo';

  @override
  String get groupsCancelLeaveRequest => 'I-cancel ang hangyo sa pagbiya';

  @override
  String get groupsLeaveGroup => 'Biyaan ang grupo';

  @override
  String get groupsRequestToLeave => 'Hangyo nga mabiyaan';

  @override
  String get groupsLeavePending => 'Biyaan nga naghulat';

  @override
  String groupsMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ka mga miyembro',
      one: '1 ka miyembro',
    );
    return '$_temp0';
  }

  @override
  String get groupsMyGroupsEmptyMessage =>
      'Kung ang usa ka administrador magdugang kanimo sa usa ka club, makita kini dinhi. Mahimo usab nimo tan-awon ang mga bukas nga grupo ug mangayo nga moapil.';

  @override
  String get groupsLeaveGroupTitle => 'Mobiya sa grupo?';

  @override
  String get groupsLeaveGroupMessage =>
      'Mawad-an ka na og mga pahibalo para niining grupoha.';

  @override
  String get groupsLeftGroup => 'Nibiya ka sa grupo';

  @override
  String get groupsCouldNotLeave => 'Dili makabiya';

  @override
  String get groupsLeaveRequestCancelled =>
      'Niwang hangyo sa pagbiya gikansela';

  @override
  String get groupsCouldNotCancelRequest => 'Dili ma-cancel ang hangyo';

  @override
  String get groupsLeaveReasonMinLength =>
      'Palihug isulod ang labing menos 20 ka mga karakter';

  @override
  String get groupsLeaveRequestSubmitted => 'Nagsumite og hangyo sa pagbiya';

  @override
  String get groupsCouldNotSubmitRequest => 'Dili makasumite og hangyo';

  @override
  String get groupsLeaveRequestDialogTitle => 'Hangyo sa Pagbiya';

  @override
  String get groupsLeaveReasonLabel => 'Ngano gusto nimo nga mabiyaan?';

  @override
  String get groupsLeaveReasonHint =>
      'Kinahanglan nga labing menos 20 ka karakter';

  @override
  String get groupsGenericName => 'Grupo';

  @override
  String get groupsGroupMembersTitle => 'Mga Miyembro sa Grupo';

  @override
  String get groupsMembershipRequests => 'Mga hangyo sa pagka-miyembro';

  @override
  String get groupsMembershipSettings => 'Mga setting sa pagiging miyembro';

  @override
  String groupsMembershipRequestsCount(int count) {
    return 'Mga hangyo sa pagka-miyembro ($count)';
  }

  @override
  String get groupsEditGroupSettingsTooltip => 'Usba ang mga setting sa grupo';

  @override
  String get groupsNoMembersYet => 'Wala pay mga miyembro';

  @override
  String get groupsNoMembersManageHint =>
      'Idugang ang mga estudyante o kawani sa kini nga grupo.';

  @override
  String get groupsNoMembersViewHint =>
      'Magpakita ang mga miyembro dinhi kung maidugang na.';

  @override
  String get groupsRemoveMemberTitle => 'Tangtangon ang miyembro?';

  @override
  String groupsRemoveMemberMessage(String name) {
    return 'Tangtangon si $name gikan sa kini nga grupo?';
  }

  @override
  String get groupsCouldNotRemoveMember => 'Dili maalis ang miyembro';

  @override
  String get groupsCouldNotUpdatePosition => 'Dili ma-update ang posisyon';

  @override
  String get groupsAssignPosition => 'Ihatag ang posisyon';

  @override
  String get groupsNoPosition => 'Walay posisyon';

  @override
  String get groupsNoPositionSelected => 'Walay posisyon ✓';

  @override
  String get groupsMakeLeader => 'Himoon nga lider';

  @override
  String get groupsMakeMember => 'Himuang miyembro';

  @override
  String get groupsRemoveFromGroup => 'Kuhaa gikan sa grupo';

  @override
  String get groupsRoleLeader => 'Pangulo';

  @override
  String get groupsRoleMember => 'Miyembro';

  @override
  String get groupsSearchClubHint => 'Ngalan sa club o programa';

  @override
  String get groupsNoSearchResults =>
      'Walay mga grupo nga nagtugma sa imong gipangita.';

  @override
  String get groupsStatusMember => 'Miyembro';

  @override
  String get groupsStatusPending => 'Naghulat';

  @override
  String get groupsStatusOpenToRequests => 'Bukas sa mga hangyo';

  @override
  String get groupsStatusInvitationOnly => 'Imbitasyon ra';

  @override
  String get groupsRequestToJoin => 'Hangyo sa Pag-apil';

  @override
  String get groupsCancelRequest => 'I-cancel ang Hangyo';

  @override
  String get groupsInvitationOnlyMessage =>
      'Membership pinaagi sa imbitasyon lamang. Kontaka ang imong magtutudlo.';

  @override
  String groupsJoinRequestTitle(String groupName) {
    return 'Hangyo sa pag-apil sa $groupName';
  }

  @override
  String get groupsJoinMessageLabel => 'Mensahe (opsyonal)';

  @override
  String get groupsJoinMessageHint =>
      'Sultihi ang lider kung nganong gusto ka moapil';

  @override
  String get groupsJoinRequestSubmitted => 'Nagsumite og hangyo sa pag-apil';

  @override
  String groupsCouldNotSubmitJoin(String error) {
    return 'Dili makasumite: $error';
  }

  @override
  String get groupsRequestCancelled => 'Nihunong ang hangyo';

  @override
  String get groupsOpenToJoin => 'abli sa pag-apil';

  @override
  String get groupsPending => 'naghulat';

  @override
  String get groupsNewGroup => 'Bag-ong Grupo';

  @override
  String get groupsCreateGroup => 'Maghimo og Grupo';

  @override
  String get groupsSearchGroupsHint => 'Pangitaa ang mga grupo…';

  @override
  String get groupsNoSearchMatch =>
      'Walay grupo nga nagtugma sa imong gipangita';

  @override
  String get groupsEmptySeedHint =>
      'Punoha ang mga demo group sa MONHS o maghimo sa imong kaugalingon.';

  @override
  String get groupsTryDifferentSearch =>
      'Sulayi ang lain nga termino sa pagpangita.';

  @override
  String get groupsSeedDemoGroups => 'Ibutang ang mga Demo nga Grupo';

  @override
  String get groupsSeeding => 'Nag-seed…';

  @override
  String groupsSeedFailed(String error) {
    return 'Nabigo ang seed: $error';
  }

  @override
  String get groupsSeedSuccess => 'Malampusong nadugang ang mga demo nga grupo';

  @override
  String groupsSyncFailed(String error) {
    return 'Nawala ang pag-synchronize: $error';
  }

  @override
  String groupsSyncSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Na-synced ang $count ka memberships para sa Akong mga Grupo',
      one: 'Na-synced ang 1 ka membership para sa Akong mga Grupo',
    );
    return '$_temp0';
  }

  @override
  String get groupsMoreActions => 'Dugang nga mga aksyon';

  @override
  String get groupsSeedDemoSubtitle => 'SPJ, Drum & Lyre, SSLG';

  @override
  String get groupsSyncIndexes =>
      'I-synchronize ang Akong Mga Grupo nga Indexes';

  @override
  String get groupsSyncing => 'Nag-synchronize…';

  @override
  String get groupsSyncIndexesSubtitle =>
      'Ayuhon ang pagtan-aw sa mga miyembro human sa mga kausaban sa roster';

  @override
  String get groupsEditGroupTooltip => 'Usba ang grupo';

  @override
  String get groupsCreateGroupTitle => 'Paghimo og Grupo';

  @override
  String get groupsGroupNameLabel => 'Ngalan sa grupo';

  @override
  String get groupsGroupNameHint => 'e.g. Klab sa Binalita';

  @override
  String get groupsGroupNameRequired => 'Isulod ang ngalan sa grupo';

  @override
  String get groupsDescriptionLabel => 'Paglaraw (opsyonal)';

  @override
  String get groupsDescriptionHint => 'Unsa man ang tumong sa kini nga grupo?';

  @override
  String get groupsDefineClubPositions => 'Ilaraw ang mga posisyon sa klub';

  @override
  String get groupsDefineClubPositionsSubtitle =>
      'Mga opsyonal nga katungdanan sama sa Presidente o Tesorero';

  @override
  String get groupsAllowJoinRequests => 'Tugoti ang mga hangyo sa pag-apil';

  @override
  String get groupsAllowJoinRequestsSubtitle =>
      'Pasagdi ang mga estudyante nga mangayo og pag-apil (nawala para sa mga napiling grupo sama sa SSLG)';

  @override
  String get groupsMemberLeavePolicy => 'Palisiya sa pagbiya sa mga miyembro';

  @override
  String get groupsLeaveAnytime => 'Biyahe bisan kanus-a';

  @override
  String get groupsMustRequestToLeave =>
      'Kinahanglan mag-request aron makabiya';

  @override
  String get groupsLeaveAnytimeSubtitle =>
      'Ang mga miyembro makabiya nga walay pag-apruba';

  @override
  String get groupsMustRequestToLeaveSubtitle =>
      'Kinahanglan og rason ug pag-apruba sa lider';

  @override
  String get groupsJoinHintLabel => 'Tip sa pag-apil (opsyonal)';

  @override
  String get groupsJoinHintHint => 'pananglitan, Auditions sa Agosto';

  @override
  String groupsCreated(String name) {
    return 'Gihimo ang $name';
  }

  @override
  String get groupsCouldNotCreate => 'Dili makabuhat og grupo';

  @override
  String get groupsEditGroupTitle => 'Usba ang Grupo';

  @override
  String get groupsGroupNotFound => 'Walay nakitang grupo';

  @override
  String get groupsGroupSettingsSaved => 'Na-save ang mga setting sa grupo';

  @override
  String get groupsCouldNotSaveSettings =>
      'Dili masave ang mga setting sa grupo';

  @override
  String get groupsSaveChanges => 'I-save ang mga Pagbag-o';

  @override
  String get groupsGroupIsActive => 'Aktibo ang grupo';

  @override
  String get groupsGroupIsActiveSubtitle =>
      'Ang mga inactive nga grupo kay gitago gikan sa pag-browse ug mga lista.';

  @override
  String get groupsAddPosition => 'Idugang ang posisyon';

  @override
  String get groupsSavePositions => 'I-save ang mga Posisyon';

  @override
  String get groupsClubPositionsSaved => 'Na-save ang mga posisyon sa club';

  @override
  String get groupsCouldNotSavePositions => 'Dili ma-save ang mga posisyon';

  @override
  String get groupsClubPositionsTitle => 'Mga Posisyon sa Klab';

  @override
  String get groupsClubPositionsSectionTitle => 'Mga Posisyon sa Klab';

  @override
  String get groupsClubPositionsSectionSubtitle =>
      'Mga opsyonal nga katungdanan nga mahimong hawiran sa mga miyembro (sama sa Presidente, Ingat-yaman). Mahimo nimo kini i-assign sa dihang nagdugang o nagdumala sa mga miyembro.';

  @override
  String groupsMembershipRequestsTitle(String groupName) {
    return '$groupName — Mga Hangyo';
  }

  @override
  String groupsTabJoinCount(int count) {
    return 'Apil ($count)';
  }

  @override
  String groupsTabLeaveCount(int count) {
    return 'Biyaan ($count)';
  }

  @override
  String get groupsNoPendingJoinRequests =>
      'Walay mga naghulat nga hangyo sa pag-apil';

  @override
  String get groupsNoPendingLeaveRequests =>
      'Walay mga pending nga hangyo sa pagbiya';

  @override
  String groupsStudentIdPrefix(String id) {
    return 'ID: $id';
  }

  @override
  String get groupsApproveLeave => 'Aprobahi ang pagbiya';

  @override
  String get groupsDeclineJoinTitle => 'Dili ba moapil sa hangyo?';

  @override
  String get groupsDeclineJoinReasonLabel => 'Rason (opsyonal)';

  @override
  String get groupsDenyLeaveTitle => 'Dili tugotan ang hangyo sa pagbiya';

  @override
  String get groupsDenyLeaveReasonLabel => 'Rason (kinahanglan)';

  @override
  String get groupsReasonRequired => 'Kinahanglan ug rason';

  @override
  String get groupsJoinRequestUpdated => 'Na-update ang hangyo sa pag-apil';

  @override
  String get groupsLeaveRequestUpdated => 'Na-update ang hangyo sa pagbiya';

  @override
  String get groupsActionFailed => 'Napalpak ang aksyon';

  @override
  String get groupsAddMembersSearchLabel => 'Pangitaa ang mga miyembro';

  @override
  String get groupsAddMembersSearchHint => 'Ngalan, email, o ID sa eskwelahan';

  @override
  String groupsCouldNotAddMembers(String error) {
    return 'Dili ma-add ang mga miyembro: $error';
  }

  @override
  String get groupsAllMembersAlreadyInGroup =>
      'Ang tanan nga gi-aprobahan nga mga miyembro anaa na sa kini nga grupo.';

  @override
  String get groupsNoUsersMatchSearch =>
      'Walay mga tiggamit nga nagtugma sa imong gipangita.';

  @override
  String groupsAssignSelectedHint(int count) {
    return '$count napili — pilii ang papel ug i-assign';
  }

  @override
  String get groupsAssignSearchHint =>
      'Pangitaa ug i-tap ang usa ka miyembro sa ubos';

  @override
  String get groupsAssignButton => 'I-assign';

  @override
  String get groupsGroupRoleLabel => 'Grupo nga papel';

  @override
  String get groupsClubPositionOptional => 'Posisyon sa klub (opsyonal)';

  @override
  String groupsAssignMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mag-assign og $count ka mga miyembro',
      one: 'Mag-assign og 1 ka miyembro',
    );
    return '$_temp0';
  }

  @override
  String groupsAssignMembersPartial(int added, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added nga mga miyembro',
      one: '1 ka miyembro',
    );
    return 'Ginatag ang $_temp0; $skipped dili maapil';
  }

  @override
  String get settingsSectionGroups => 'Mga Grupo ug Klab';

  @override
  String get settingsMyGroups => 'Ang Akong mga Grupo ug Klab';

  @override
  String settingsPendingMembershipRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count naghulat nga mga hangyo sa pagiging miyembro',
      one: '1 naghulat nga hangyo sa pagiging miyembro',
    );
    return '$_temp0';
  }

  @override
  String get settingsGroupsSubtitle =>
      'Mga klub ug organisasyon nga imong gikauban';

  @override
  String get settingsBrowseGroups => 'Tan-awa ang mga Grupo ug Klab';

  @override
  String get settingsBrowseGroupsSubtitle =>
      'Suhita ang mga grupo ug mag-request nga moapil';

  @override
  String get settingsSentGroupAlerts => 'Gipadala nga Grupo nga mga Alerto';

  @override
  String get settingsMyBroadcasts => 'Ang Akong mga Broadcast';

  @override
  String get settingsSentGroupAlertsSubtitle =>
      'Tan-awa ang mga alerto nga imong gipadala ug ang mga tubag sa mga miyembro';

  @override
  String get settingsMyBroadcastsSubtitle =>
      'Pagdumala sa gipadala nga mga pahimangno ug tan-awa ang mga tubag';

  @override
  String get settingsSectionAppearance => 'Hitsura';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Default sa Sistema';

  @override
  String get settingsThemeLight => 'Hayag';

  @override
  String get settingsThemeDark => 'Ngitngit';

  @override
  String get settingsSectionAccount => 'Akun';

  @override
  String get settingsChangePassword => 'Usba Password';

  @override
  String get settingsMemberSignInHint =>
      'Mag-sign in gamit ang imong student ID o contact email ug ang imong password.';

  @override
  String get settingsNotificationPreferences => 'Mga Paborito sa Notipikasyon';

  @override
  String get settingsNotificationsComingSoon => 'Mga pahibalo — umaabot na';

  @override
  String get settingsSectionHelp => 'Tabang & Suporta';

  @override
  String get settingsHelpCenter => 'Sentro sa Tabang';

  @override
  String get settingsHelpCenterSubtitle =>
      'Mga giya para sa mga miyembro ug mga administrador';

  @override
  String get settingsSectionAbout => 'Mahitungod';

  @override
  String settingsAboutApp(String appName) {
    return 'Mahitungod sa $appName';
  }

  @override
  String get settingsAboutLegalese => '© 2026 SpeakUp Connect';

  @override
  String get settingsSectionAdmin => 'Administrasyon';

  @override
  String get settingsAdminDashboard => 'Dashboard sa Admin';

  @override
  String get settingsAdminDashboardSubtitle =>
      'Susiha ug pagdumala ang mga gisumiter nga report';

  @override
  String get settingsAdminGroups => 'Mga Grupo ug Klab';

  @override
  String get settingsAdminGroupsSubtitle =>
      'Magtukod og mga grupo ug pagdumala sa mga listahan sa mga miyembro';

  @override
  String get settingsJoinApplications => 'Apil sa mga Aplikasyon';

  @override
  String get settingsJoinApplicationsSubtitle =>
      'Aprobahi ang mga bag-ong pag-sign up sa mga miyembro';

  @override
  String get settingsPendingApprovals => 'Naghulat nga Pag-apruba';

  @override
  String get settingsPendingApprovalsSubtitle =>
      'Susiha ang mga anunsyo ug mga alerto sa grupo nga naghulat sa pagmantala';

  @override
  String get settingsMemberManagement => 'Pagdumala sa mga Miyembro';

  @override
  String get settingsMemberManagementSubtitle =>
      'Tan-awa, i-block, i-unenroll, i-unblock, o i-re-enroll ang mga miyembro';

  @override
  String get settingsStudentRoster => 'Listahan sa mga Estudyante';

  @override
  String get settingsStudentRosterSubtitle =>
      'Idugang ang mga estudyante, itakda ang mga grado sa indibidwal o sa daghan.';

  @override
  String get settingsSchoolGrades => 'Mga Baitang sa Eskwela';

  @override
  String get settingsSchoolGradesSubtitle =>
      'I-define kung unsang mga lebel sa grado ang gigamit sa imong eskwelahan';

  @override
  String get settingsTranslations => 'Mga Hubad';

  @override
  String get settingsTranslationsSubtitle =>
      'I-edit ang mga UI string para sa mga sinultian sa inyong organisasyon';

  @override
  String get settingsSignOut => 'Mag-sign out';

  @override
  String get settingsLanguage => 'Wika';

  @override
  String get settingsLanguageEnglish => 'Ingles';

  @override
  String get settingsLanguageCebuano => 'Bisaya / Cebuano';

  @override
  String get settingsLanguageRevertToEnglish =>
      'Dili maaplikar ang maong sinultian. Gibalik sa Iningles.';

  @override
  String get helpTitle => 'Tabang';

  @override
  String get helpHubHeadline => 'Mga giya sa paggamit sa SpeakUp Connect';

  @override
  String helpHubDescription(String orgName, String adminNote) {
    return 'Mga giya para sa $orgName. ${adminNote}Ang sulod kay espesipiko sa kung giunsa pag-set up ang kini nga organisasyon.';
  }

  @override
  String get helpHubAdminNote =>
      'Naglakip sa mga topiko sa administrasyon alang sa imong papel.';

  @override
  String get helpOrgFallback => 'imong organisasyon';

  @override
  String get helpMemberGuideTitle => 'Giya sa Miyembro';

  @override
  String get helpMemberGuideSubtitle =>
      'Mag-sign in, mag-submit og mga report, ug gamita ang mga alerto';

  @override
  String get helpAdminGuideTitle => 'Giya sa Administrator';

  @override
  String get helpAdminGuideSubtitle =>
      'Lista, mga grupo, mga report, ug mga pahimangno';

  @override
  String get helpGuideNotFound => 'Wala makit-i ang giya nga kini.';

  @override
  String get helpAdminAccessDenied =>
      'Wala kay access sa kini nga giya sa administrador.';

  @override
  String get helpLoadFailed =>
      'Dili ma-load ang giya para sa imong organisasyon.';

  @override
  String helpLoadFailedDetail(String error) {
    return 'Dili ma-load ang giya para sa imong organisasyon. $error';
  }

  @override
  String get validationEmailRequired => 'Kinahanglan ang email';

  @override
  String get validationEmailInvalid =>
      'Palihug isulod ang usa ka balido nga email address';

  @override
  String validationFieldRequired(String fieldName) {
    return 'Kinahanglan ang $fieldName';
  }

  @override
  String get validationPasswordRequired => 'Kinahanglan ang password';

  @override
  String get validationPasswordMin8 =>
      'Kinahanglan nga ang password adunay labing menos 8 ka karakter.';

  @override
  String get validationPasswordMin6 =>
      'Kinahanglan ang password nga labing menos 6 ka karakter';

  @override
  String get validationLoginIdentifierRequired =>
      'Kinahanglan ang email o student ID';

  @override
  String get validationStudentIdRequired => 'Kinahanglan ang Student ID';

  @override
  String get validationStudentIdMin6 =>
      'Kinahanglan nga ang Student ID adunay labing menos 6 ka karakter';

  @override
  String get validationStudentIdInvalidChars =>
      'Gamiton lang ang mga letra, numero, ug mga hyphen.';

  @override
  String get validationConfirmPasswordRequired =>
      'Palihug kumpirmaha ang imong password';

  @override
  String get validationPasswordsDoNotMatch => 'Dili magtagbo ang mga password';

  @override
  String validationMaxLength(String fieldName, int maxLength) {
    return 'Ang $fieldName kinahanglan nga $maxLength ka karakter o mas gamay.';
  }

  @override
  String validationMinLength(String fieldName, int minLength) {
    return 'Ang $fieldName kinahanglan adunay labing menos $minLength ka mga karakter.';
  }

  @override
  String get validationReportTitleField => 'Titulo';

  @override
  String get validationReportDescriptionField => 'Deskripsyon';

  @override
  String get commonSave => 'I-save';

  @override
  String get reminderComposeTitle => 'Paghimo og Paalaala';

  @override
  String get reminderComposeSendGroupAlertTitle =>
      'Ipadala ang Grupo nga Alerto';

  @override
  String reminderComposeSendFailed(String error) {
    return 'Nakapakyas sa pagpadala: $error';
  }

  @override
  String get reminderComposeSubmittedForApproval =>
      'Gihangyo ang pahimangno alang sa pag-aprubar.';

  @override
  String get reminderComposeScheduled => 'Naka-iskedyul ang pahimangno.';

  @override
  String get reminderComposePublished => 'Nakapublish nga pahimangno.';

  @override
  String get reminderComposeSubmitForApproval => 'Ipadala para sa Pag-apruba';

  @override
  String get reminderComposeSendReminder => 'Magpadala og Paalaala';

  @override
  String get reminderComposeGroupOnlyHint =>
      'Ang alerto nga kini ipapadala lamang sa mga miyembro sa grupo nga imong gipili.';

  @override
  String get reminderComposeTitleLabel => 'Titulo';

  @override
  String get reminderComposeTitleHint =>
      'Pananglitan: Sayong pagbiya sa Biyernes';

  @override
  String get reminderComposeMessageLabel => 'Mensahe';

  @override
  String get reminderComposeMessageHint =>
      'Isulat ang mga detalye sa pahimangno…';

  @override
  String get reminderComposeAudienceLabel => 'Mga Taga-paminaw';

  @override
  String get reminderComposeAudienceEveryone => 'Tanan';

  @override
  String get reminderComposeAudienceGroup => 'Grupo';

  @override
  String get reminderComposeAudienceRole => 'Roly';

  @override
  String reminderComposeLoadGroupsFailed(String error) {
    return 'Dili ma-load ang mga grupo: $error';
  }

  @override
  String get reminderComposeNoGroupsYet =>
      'Wala pa\'y mga grupo. Maghimo usa og grupo.';

  @override
  String get reminderComposeSelectGroup => 'Pili-a ang grupo';

  @override
  String reminderComposeLoadRolesFailed(String error) {
    return 'Dili ma-load ang mga papel: $error';
  }

  @override
  String get reminderComposeNoRolesYet => 'Walay mga papel nga gihimo pa.';

  @override
  String get reminderComposeSelectRole => 'Pili-a ang papel';

  @override
  String get reminderComposeNoPermission =>
      'Wala kay permiso sa pag-broadcast sa mga pahimangno.';

  @override
  String get reminderComposeApprovalBanner =>
      'Gikinahanglan sa imong organisasyon nga maaprobahan ang mga pahimangno. Kini isumite alang sa pagrepaso sa dili pa kini ipagawas.';

  @override
  String get reminderComposeValidationTitleMin =>
      'Ang titulo kinahanglan nga labing menos 3 ka karakter.';

  @override
  String get reminderComposeValidationMessageMin =>
      'Ang mensahe kinahanglan nga labing menos 5 ka karakter.';

  @override
  String get reminderComposeValidationSelectGroup =>
      'Pili-a ang grupo para sa kini nga pahimangno.';

  @override
  String get reminderComposeValidationSelectAudience =>
      'Pili-a ang audience para sa kini nga pahimangno.';

  @override
  String get reminderComposeValidationExpiration =>
      'Mag-set ug balido nga petsa ug oras sa pag-expire.';

  @override
  String get reminderComposeValidationCheckboxOptions =>
      'Magdugang ug labing menos usa ka checkbox nga kapilian nga adunay label.';

  @override
  String get reminderComposeValidationChoiceOptions =>
      'Magdugang ug labing menos 2 ka mga kapilian sa tubag nga adunay mga label.';

  @override
  String get reminderComposeValidationCharLimit =>
      'Mag-set og balido nga limitasyon sa karakter para sa mga tubag.';

  @override
  String get reminderComposeScheduleForLater => 'I-iskedyul para sa ulahi';

  @override
  String get reminderComposeScheduleOff => 'Walay — ipadala dayon';

  @override
  String get reminderComposeChangeTime => 'Usba ang oras';

  @override
  String get reminderComposeSetExpiration => 'I-set ang pagkaputol';

  @override
  String get reminderComposeExpirationOff =>
      'Wala — magpabilin hangtod nga manu-manong tanggalon';

  @override
  String get reminderComposeSetExpirationBelow =>
      'I-set ang pag-expire sa ubos';

  @override
  String get reminderComposeExpirationDateTime => 'Petsa ug oras';

  @override
  String get reminderComposeExpirationDuration => 'Gidugayon';

  @override
  String get reminderComposePickDateTime => 'Pili-a ang petsa ug oras';

  @override
  String get reminderComposeExpirationAfterSend =>
      'Ang pag-expire kinahanglan nga human sa oras sa pagpadala.';

  @override
  String get reminderComposeExpireAfter => 'Mawagtang human sa';

  @override
  String get reminderComposeHours => 'Mga Oras';

  @override
  String get reminderComposeMinutes => 'Minuto';

  @override
  String reminderComposeExpirationDurationSummary(
      String duration, String base, String dateTime) {
    return '$duration human sa $base ($dateTime)';
  }

  @override
  String reminderComposeExpirationAt(String dateTime) {
    return 'Mawad-an og bisa $dateTime';
  }

  @override
  String get reminderComposeExpirationBaseScheduled =>
      'naka-iskedyul nga pagpadala';

  @override
  String get reminderComposeExpirationBaseSend => 'ipadala';

  @override
  String reminderComposeDurationHours(int count) {
    return '$count ka oras';
  }

  @override
  String reminderComposeDurationMinutes(int count) {
    return '$count min';
  }

  @override
  String get reminderComposeDurationZeroMin => '0 ka minuto';

  @override
  String get reminderComposeRequestResponse => 'Mangayo og tubag';

  @override
  String reminderComposeResponseRecipientsCan(String type) {
    return 'Maka-reply ang mga recipient pinaagi sa $type';
  }

  @override
  String get reminderComposeResponseOff =>
      'Walay tubag — wala’y gikinahanglan nga tubag';

  @override
  String get reminderComposeResponseRequired => 'Kinahanglan ang tubag';

  @override
  String get reminderComposeResponseRequiredHint =>
      'Kinahanglan nga motubag ang mga nakadawat sa wala pa nila ma-dismiss ang alerto.';

  @override
  String get reminderComposeAllowChangingResponses =>
      'Tugoti ang pag-usab sa mga tubag';

  @override
  String get reminderComposeAllowChangingResponsesOn =>
      'Makahimo ang mga nakadawat sa pag-update sa ilang tubag human sa pag-submit';

  @override
  String get reminderComposeAllowChangingResponsesOff =>
      'Nakasalalay pagkahuman sa pag-submit — gamita alang sa mga boto ug usa ka higayon nga mga poll';

  @override
  String get reminderComposeResponseFreeText => 'Libre nga teksto';

  @override
  String get reminderComposeResponseCheckboxes => 'Mga checkbox';

  @override
  String get reminderComposeResponseChoices => 'Mga Kapilian';

  @override
  String get reminderComposeCharacterLimit => 'Limit sa karakter';

  @override
  String reminderComposeCharactersCount(int count) {
    return '$count mga karakter';
  }

  @override
  String get reminderComposeAllowExplanationText =>
      'Tugoti ang teksto sa pasabot';

  @override
  String get reminderComposeAllowExplanationHint =>
      'Opsyonal nga kahon sa teksto para sa mga komento (pananglitan, nganong dili sila makaapil)';

  @override
  String reminderComposeValidationCharLimitRange(int min, int max) {
    return 'I-set ang limit sa karakter tali sa $min ug $max.';
  }

  @override
  String get reminderComposeCheckboxOptions => 'Mga opsyon sa checkbox';

  @override
  String get reminderComposeAnswerChoices => 'Mga kapilian sa tubag';

  @override
  String reminderComposeOptionNumber(int number) {
    return 'Opsyon $number';
  }

  @override
  String get reminderComposeRemoveOption => 'Kuhaa ang opsyon';

  @override
  String get reminderComposeAddOption => 'Magdugang og kapilian';

  @override
  String get reminderComposeResponseTypeExplanationSuffix => '+ pasabot';

  @override
  String get commonReject => 'Dili dawaton';

  @override
  String get commonPublish => 'I-publish';

  @override
  String get commonDone => 'Nahuman';

  @override
  String get commonConfirm => 'Kumpirmaha';

  @override
  String get commonContinue => 'Padayon';

  @override
  String get commonNext => 'Sunod';

  @override
  String get commonTitle => 'Ulohan';

  @override
  String get commonMessage => 'Mensahe';

  @override
  String get commonDescription => 'Paglarawan';

  @override
  String get commonUnknown => 'Wala mahibal-i';

  @override
  String commonActionFailed(String error) {
    return 'Nihitabo ang aksyon: $error';
  }

  @override
  String commonFailedToLoad(String error) {
    return 'Nakapakyas sa pag-load: $error';
  }

  @override
  String get commonGrade => 'Baitang';

  @override
  String get commonAllGrades => 'Tanang grado';

  @override
  String get commonNoGradeAssigned => 'Walay grado nga gihatag';

  @override
  String get commonGradeLevel => 'Antas sa grado';

  @override
  String get commonStatus => 'Kahimtang';

  @override
  String get commonReasonOptional => 'Rason (opsyonal)';

  @override
  String get commonNoteOptional => 'Nota (opsyonal)';

  @override
  String commonByAuthor(String name) {
    return 'Ni $name';
  }

  @override
  String commonFromGroup(String groupName) {
    return 'Gikan sa $groupName';
  }

  @override
  String get commonScheduled => 'naka-iskedyul';

  @override
  String get commonNoReasonProvided => 'Walay gihatag nga rason';

  @override
  String get commonSchoolWide => 'Tibuok eskwelahan';

  @override
  String get commonRegistered => 'Narehistro';

  @override
  String get commonNotRegistered => 'Wala magparehistro';

  @override
  String get commonActive => 'Aktibo';

  @override
  String get commonBlocked => 'Nablock';

  @override
  String get commonUnenrolled => 'Walay rehistro';

  @override
  String get commonAll => 'Tanan';

  @override
  String get commonSignedIn => 'Nakasulod';

  @override
  String get commonSaving => 'Nagasave…';

  @override
  String commonSaveFailed(String error) {
    return 'Nakapakyas sa pag-save: $error';
  }

  @override
  String get commonSection => 'Seksyon';

  @override
  String get commonIdLabel => 'ID';

  @override
  String get commonContinueButton => 'Padayon';

  @override
  String get changePasswordIntro =>
      'Ibutang ang imong kasamtangang password, unya pilia ang usa ka bag-ong password.';

  @override
  String get changePasswordCurrentLabel => 'Karon nga password';

  @override
  String get changePasswordCurrentHint => 'Ang imong kasamtangang password';

  @override
  String get changePasswordNewLabel => 'Bag-ong password';

  @override
  String get changePasswordNewHint => 'Dapat labing menos 8 ka karakter';

  @override
  String get changePasswordConfirmLabel => 'Kumpirmaha ang bag-ong password';

  @override
  String get changePasswordConfirmHint => 'Ibalik ang imong bag-ong password';

  @override
  String get changePasswordUpdateButton => 'I-update ang Password';

  @override
  String get changePasswordMustDiffer =>
      'Ang bag-ong password kinahanglan lahi sa imong kasamtangang password.';

  @override
  String get changePasswordFailed =>
      'Dili mausab ang password. Palihug sulayi pag-usab.';

  @override
  String get changePasswordSuccess => 'Nausab na ang password nga malampuson.';

  @override
  String get pendingApprovalsAnnouncements => 'Mga Anunsyo';

  @override
  String get pendingApprovalsGroupAlerts => 'Mga pahibalo sa grupo';

  @override
  String get pendingApprovalsSchoolWide => 'Tibuok eskwelahan';

  @override
  String get pendingApprovalsEmpty =>
      'Walay bisan unsang naghulat nga pag-apruba';

  @override
  String get pendingApprovalsNoPermission =>
      'Wala kay permiso aron maaprobahan ang sulod.';

  @override
  String get pendingApprovalsRejectAnnouncement => 'Ibalibad ang anunsyo';

  @override
  String get pendingApprovalsRejectReminder => 'Pagdumili nga pahimangno';

  @override
  String get pendingApprovalsRejectReasonHint =>
      'Ipahibalo ang awtor kung nganong…';

  @override
  String pendingApprovalsLoadFailed(String error) {
    return 'Nakapakyas sa pag-load: $error';
  }

  @override
  String get composeAnnouncementTitle => 'Ibutang ang Anunsyo';

  @override
  String get composeAnnouncementNoPermission =>
      'Wala kay permiso sa pag-post og mga anunsyo sa tibuok eskwelahan.';

  @override
  String get composeAnnouncementIntro =>
      'Ang mga anunsyo sa tibuok eskwelahan makita sa tanan nga miyembro.';

  @override
  String get composeAnnouncementApprovalBanner =>
      'Ang imong organisasyon nagkinahanglan og pag-apruba sa dili pa mag-live ang mga anunsyo.';

  @override
  String get composeAnnouncementTitleHint =>
      'Pananglitan: Apil sa among club karong semestro';

  @override
  String get composeAnnouncementMessageHint =>
      'Ibahin ang impormasyon sa pag-recruit, balita, o mga update…';

  @override
  String get composeAnnouncementPinTitle => 'I-pin sa ibabaw sa mga anunsyo';

  @override
  String get composeAnnouncementPinSubtitle =>
      'Ang mga nakapin nga post magpakita una para sa tanan nga mga miyembro';

  @override
  String get composeAnnouncementPublish => 'I-publish';

  @override
  String get composeAnnouncementSubmitted =>
      'Gipasa ang anunsyo alang sa pag-apruba.';

  @override
  String get composeAnnouncementScheduled => 'Naka-iskedyul ang anunsyo.';

  @override
  String get composeAnnouncementPublished => 'Nakapagmantala og anunsyo.';

  @override
  String composeAnnouncementSendFailed(String error) {
    return 'Napakyas sa pag-post: $error';
  }

  @override
  String get composeAnnouncementImageLoadFailed =>
      'Dili ma-load ang maong hulagway. Sulayi ang laing litrato.';

  @override
  String get composeAnnouncementGroupRequired =>
      'Kinahanglan ka magdumala og grupo sa dili pa mag-post og mga anunsyo.';

  @override
  String get composeAnnouncementGroupOptional => 'Grupo (opsyonal)';

  @override
  String get composeAnnouncementOnBehalfOf => 'Sa ngalan ni';

  @override
  String get composeAnnouncementMustLeadGroup =>
      'Makahimo ka lamang og post alang sa mga grupo nga imong gipangulohan.';

  @override
  String get composeAnnouncementValidationTitleMin =>
      'Kinahanglan ang titulo nga labing menos 3 ka karakter.';

  @override
  String get composeAnnouncementValidationMessageMin =>
      'Ang mensahe kinahanglan nga labing menos 5 ka karakter.';

  @override
  String get composeAnnouncementValidationExpiration =>
      'Mag-set ug balido nga petsa ug oras sa pag-expire.';

  @override
  String get composeAnnouncementValidationResponse =>
      'Kumpletuhon ang mga opsyonal nga setting sa tubag o i-disable kini.';

  @override
  String get schoolGradesIntro =>
      'I-define kung unsang mga grado ang gigamit sa imong eskwelahan. Magpakita kini sa Student Roster ug Member Management filters.';

  @override
  String get schoolGradesNonSchoolNote =>
      'Ang mga munisipyo, barangay, ug NGO dili mogamit og grado.';

  @override
  String get schoolGradesCurrent => 'Kasalukuyang mga grado';

  @override
  String get schoolGradesEmpty => 'Wala pa\'y na-configure nga mga grado.';

  @override
  String schoolGradesGradeChip(int level) {
    return 'Baitang $level';
  }

  @override
  String get schoolGradesAddLabel => 'Idugang ang lebel sa grado';

  @override
  String get schoolGradesAddHint => 'sama sa 7';

  @override
  String get schoolGradesAddButton => 'Idugang ang grado';

  @override
  String get schoolGradesResetDefault =>
      'I-reset sa default sa high school (7–12)';

  @override
  String get schoolGradesSave => 'I-save ang mga grado';

  @override
  String get schoolGradesSaving => 'Nag-save…';

  @override
  String schoolGradesSaveFailed(String error) {
    return 'Nakapakyas sa pag-save: $error';
  }

  @override
  String get schoolGradesSaveSuccess => 'Na-update ang mga grado';

  @override
  String get schoolGradesInvalidNumber =>
      'Sulati ang usa ka balido nga numero sa grado';

  @override
  String get schoolGradesSaveDialogTitle => 'I-save ang mga grado nga lebel?';

  @override
  String get schoolGradesSaveDialogBody =>
      'Ang mga estudyante mahimong ma-filter ug ma-assign pinaagi sa:';

  @override
  String get schoolGradesNotSchool =>
      'Ang mga grado nga lebel gigamit lamang sa mga organisasyon nga tipo sa eskwelahan. Kini nga setting dili magamit para sa imong tipo sa organisasyon.';

  @override
  String get schoolGradesNoPermission =>
      'Wala kay permiso sa pagdumala sa mga setting sa organisasyon.';

  @override
  String schoolGradesLoadFailed(String error) {
    return 'Nakapakyas sa pag-load sa mga setting: $error';
  }

  @override
  String get submitConcernTitle => 'Ipadala ang Usa ka Kab worry';

  @override
  String get submitConcernStepDetails => 'Mga Detalye';

  @override
  String get submitConcernStepPhotos => 'Mga Litrato';

  @override
  String get submitConcernStepReview => 'Susiha';

  @override
  String get submitConcernCategoryPrompt => 'Unsa nga klase sa kabalaka kini?';

  @override
  String get submitConcernLoadCategoriesFailed =>
      'Nakapakyas sa pag-load sa mga kategorya';

  @override
  String get submitConcernTitleHint =>
      'Mubo nga buod sa imong kabalaka (min 5 ka karakter)';

  @override
  String get submitConcernDescriptionLabel => 'Deskripsyon';

  @override
  String get submitConcernDescriptionHint =>
      'Ilaraw ang kabalaka sa detalye (min 10 ka karakter)';

  @override
  String get submitConcernTitleMinLength =>
      'Kinahanglan nga ang titulo adunay labing menos 5 ka karakter';

  @override
  String get submitConcernDescriptionMinLength =>
      'Kinahanglan ang deskripsyon nga labing menos 10 ka karakter';

  @override
  String get submitConcernPhotosTitle => 'Idugang ang mga Litrato (opsyonal)';

  @override
  String submitConcernPhotosLimit(int count) {
    return 'Hangtod sa $count ka mga litrato';
  }

  @override
  String get submitConcernAnonymousTitle => 'Ipadala nga Walay Ngalan';

  @override
  String get submitConcernAnonymousSubtitle =>
      'Ang imong ngalan ug account dili ikonekta sa kini nga report.';

  @override
  String get submitConcernTakePhoto => 'Kuhaa ang Litrato';

  @override
  String get submitConcernChooseGallery => 'Pili-a gikan sa Gallery';

  @override
  String get submitConcernReviewTitle => 'Susiha ang Imong Ulat';

  @override
  String get submitConcernReviewCategory => 'Kategorya';

  @override
  String get submitConcernReviewPhotos => 'Mga Litrato';

  @override
  String get submitConcernReviewSubmittedAs => 'Gisumiter ingon nga';

  @override
  String get submitConcernReviewAnonymousWarning =>
      'Ang mga ulat nga wala’y ngalan dili masubay. I-save ang imong numero sa reperensya.';

  @override
  String get submitConcernSubmitButton => 'Ipadala ang Ulat';

  @override
  String get submitConcernStep1Incomplete =>
      'Palihug kumpletuhon ang Hakbang 1: pagpili og kategorya, titulo (min 5 ka karakter), ug deskripsyon (min 10 ka karakter).';

  @override
  String submitConcernSubmissionFailed(String error) {
    return 'Nakapag-submit nga wala: $error';
  }

  @override
  String submitConcernPhotosAttached(int count) {
    return '$count nga nakadugtong';
  }

  @override
  String get adminDashboardJoinApplicationsTooltip => 'Apil sa mga Aplikasyon';

  @override
  String get adminDashboardPendingApprovalsTooltip =>
      'Mga Naghulat nga Pag-apruba';

  @override
  String get adminDashboardMemberManagementTooltip =>
      'Pagdumala sa mga Miyembro';

  @override
  String get adminDashboardStudentRosterTooltip => 'Listahan sa mga Estudyante';

  @override
  String get adminDashboardSchoolGradesTooltip => 'Mga Grado sa Eskwela';

  @override
  String get adminDashboardRolesTooltip => 'Mga Papel ug Mga Tugot';

  @override
  String get adminDashboardOrgSettingsTooltip => 'Mga Setting sa Organisasyon';

  @override
  String get adminDashboardTabAll => 'Tanan';

  @override
  String get adminDashboardTabSubmitted => 'Gipasa';

  @override
  String get adminDashboardTabUnderReview => 'Sa Ilalim sa Repaso';

  @override
  String get adminDashboardTabInProgress => 'Sa Progreso';

  @override
  String get adminDashboardTabResolved => 'Naresolba';

  @override
  String get adminDashboardTabClosed => 'Nagsira';

  @override
  String get adminDashboardStatTotal => 'Kinatibuk-an';

  @override
  String get adminDashboardStatSubmitted => 'Gisumite';

  @override
  String get adminDashboardStatUnderReview => 'Sa Ilalim sa Pagsusi';

  @override
  String get adminDashboardStatInProgress => 'Sa Progreso';

  @override
  String get adminDashboardStatResolved => 'Nasulbad';

  @override
  String get adminDashboardStatClosed => 'Nagsira';

  @override
  String get adminDashboardSearchHint =>
      'Pangitaa pinaagi sa titulo o numero sa reperensya...';

  @override
  String get adminDashboardLoadingReports => 'Nag-load sa mga report...';

  @override
  String get adminDashboardLoadFailed => 'Nakapakyas sa pag-load sa mga report';

  @override
  String get adminDashboardNoResults => 'Walay resulta';

  @override
  String get adminDashboardNoReports => 'Walay mga report';

  @override
  String adminDashboardNoReportsMatch(String query) {
    return 'Walay mga report nga nagtugma sa \"$query\".';
  }

  @override
  String get adminDashboardNoActiveReports =>
      'Walay mga aktibong report nga gisumite hangtod karon.';

  @override
  String get adminDashboardNoClosedReports => 'Walay saradong mga report.';

  @override
  String adminDashboardNoTabReports(String tab) {
    return 'Walay \"$tab\" nga mga report.';
  }

  @override
  String adminDashboardUpdateStatusFailed(String error) {
    return 'Napalpak ang pag-update sa estado: $error';
  }

  @override
  String adminDashboardReportsCount(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mga report',
      one: '1 report',
    );
    return '$label: $_temp0';
  }

  @override
  String get adminDashboardReportPriorityLow => 'Mababa';

  @override
  String get adminDashboardReportPriorityMedium => 'Tunga-tunga';

  @override
  String get adminDashboardReportPriorityHigh => 'Mataas';

  @override
  String get adminDashboardReportPriorityUrgent => 'Dali nga kinahanglanon';

  @override
  String get memberManagementSearchHint =>
      'Pangitaa pinaagi sa ngalan o email…';

  @override
  String memberManagementUpdatedCount(int count) {
    return 'Na-update ang $count nga miyembro(s)';
  }

  @override
  String get memberManagementUpdated => 'Nabag-o ang miyembro';

  @override
  String get memberManagementBlocked => 'Nablock ang miyembro';

  @override
  String get memberManagementUnblocked => 'Na-unblock ang miyembro';

  @override
  String memberManagementLoadFailed(String error) {
    return 'Nakapakyas sa pag-load: $error';
  }

  @override
  String get memberManagementEmptyActive =>
      'Walay aktibong mga miyembro nga nakit-an.';

  @override
  String get memberManagementEmptyBlocked =>
      'Walay nakablok nga mga miyembro nga nakuha.';

  @override
  String get memberManagementEmptyUnenrolled =>
      'Walay nakab-ot nga mga miyembro nga wala magparehistro.';

  @override
  String get memberManagementEmptyFiltered =>
      'Walay mga miyembro nga nagtugma sa imong mga filter.';

  @override
  String memberManagementSelectedCount(int count) {
    return '$count napili';
  }

  @override
  String get memberManagementBulkBlock => 'I-block';

  @override
  String get memberManagementBulkUnenroll => 'I-unenroll';

  @override
  String get memberManagementBulkReenroll => 'I-re-enroll';

  @override
  String get memberManagementBulkAssignGrade => 'Ihatag ang grado';

  @override
  String get memberManagementReenroll => 'Mag-re-enroll';

  @override
  String get memberManagementUnblock => 'I-unblock';

  @override
  String get memberManagementUnenroll => 'Ihawa';

  @override
  String get memberManagementAssignGrade => 'Ihatag ang grado';

  @override
  String get memberManagementBlock => 'I-block';

  @override
  String get memberManagementEditProfile => 'Usba ang profile…';

  @override
  String get memberManagementResetPassword => 'I-reset ang password…';

  @override
  String memberManagementBlockDialogTitle(String name) {
    return 'I-block si $name?';
  }

  @override
  String memberManagementUnenrollDialogTitle(String name) {
    return 'I-unenroll si $name?';
  }

  @override
  String memberManagementReenrollDialogTitle(String name) {
    return 'I-re-enroll si $name?';
  }

  @override
  String memberManagementAssignGradeDialogTitle(String name) {
    return 'Ihatag ang grado kang $name';
  }

  @override
  String get memberManagementGradeAssigned => 'Nakatakdang grado';

  @override
  String get memberManagementNoAccess =>
      'Wala kay permiso sa pagdumala sa mga nakarehistrong miyembro.';

  @override
  String get memberManagementBlockReasonHint =>
      'Ngano nga gi-block ang kini nga account?';

  @override
  String get memberManagementConfirmBlockTitle => 'Kumpirmaha ang pag-block';

  @override
  String memberManagementConfirmBlockMessage(String name) {
    return '$name mawagtang ang access dayon.';
  }

  @override
  String get memberManagementConfirmBlockAction => 'Kumpirmaha ang pag-block';

  @override
  String get memberManagementUnblockMessage =>
      'Makaangkon pag-usab ang miyembro nga kini og access sa organisasyon.';

  @override
  String memberManagementUnenrollTitleOne(String name) {
    return 'I-unenroll si $name?';
  }

  @override
  String memberManagementUnenrollTitleMany(int count) {
    return 'I-unenroll ang $count nga mga miyembro?';
  }

  @override
  String get memberManagementUnenrollHint =>
      'e.g. Nakatapos, nagbalhin, mibiya sa eskwelahan';

  @override
  String get memberManagementConfirmUnenrollTitle =>
      'Kumpirmaha ang pag-undang sa enrollment';

  @override
  String get memberManagementConfirmUnenrollMessageOne =>
      'Mawala ang access sa miyembrong kini dayon.';

  @override
  String memberManagementConfirmUnenrollMessageMany(int count) {
    return '$count nga mga miyembro ang mawala sa access dayon.';
  }

  @override
  String get memberManagementConfirmUnenrollAction =>
      'Kumpirmaha ang pag-undang sa enrollment';

  @override
  String memberManagementBulkBlockTitle(int count) {
    return 'I-block ang $count nga mga miyembro?';
  }

  @override
  String get memberManagementBulkBlockHint =>
      'Ngano nga kini nga mga account gi-block?';

  @override
  String memberManagementBulkBlockConfirmMessage(int count) {
    return '$count ka myembro ang mawadan og access dayon.';
  }

  @override
  String memberManagementBulkUnblockTitle(int count) {
    return 'I-unblock ang $count nga mga miyembro?';
  }

  @override
  String get memberManagementBulkUnblockMessage =>
      'Makaangkon na og access ang mga miyembro sa organisasyon.';

  @override
  String get memberManagementConfirmUnblockAction =>
      'Kumpirmaha ang pag-unblock';

  @override
  String memberManagementReenrollTitleOne(String name) {
    return 'Mag-re-enroll ba ka sa $name?';
  }

  @override
  String memberManagementReenrollTitleMany(int count) {
    return 'I-re-enroll ang $count nga mga miyembro?';
  }

  @override
  String get memberManagementReenrollMessageOne =>
      'Makaangkon kini nga miyembro og hingpit nga access sa organisasyon.';

  @override
  String memberManagementReenrollMessageMany(int count) {
    return '$count nga mga miyembro ang makabawi sa tibuok nga access.';
  }

  @override
  String get memberManagementConfirmReenrollAction =>
      'Kumpirmaha ang pag-re-enroll';

  @override
  String get memberManagementConfirmGradeTitle =>
      'Kumpirmaha ang pag-assign sa grado';

  @override
  String memberManagementConfirmGradeOne(String name, int grade) {
    return 'I-set si $name sa Baitang $grade?';
  }

  @override
  String memberManagementConfirmGradeMany(int count, int grade) {
    return 'I-set ang $count ka mga miyembro sa Baitang $grade?';
  }

  @override
  String memberManagementBlockReasonLabel(String reason) {
    return 'Rason sa pag-block: $reason';
  }

  @override
  String memberManagementUnenrollReasonLabel(String reason) {
    return 'Nawala sa enrollment: $reason';
  }

  @override
  String memberManagementPreviewAndMore(int count) {
    return '…ug $count pa';
  }

  @override
  String get studentRosterSearchHint =>
      'Pangitaa pinaagi sa ngalan o ID sa estudyante…';

  @override
  String get studentRosterAssignSelected => 'I-assign ang grado sa napili';

  @override
  String get studentRosterAddStudent => 'Dugang Estudyante';

  @override
  String get studentRosterAssignGradeTitle => 'Ihatag ang grado';

  @override
  String studentRosterAllSelected(int count) {
    return 'Tanan $count napili';
  }

  @override
  String studentRosterOfficialPhotoTitle(String name) {
    return 'Opisyal nga litrato — $name';
  }

  @override
  String studentRosterSectionLabel(String section) {
    return 'Seksyon: $section';
  }

  @override
  String studentRosterAssignFailed(String error) {
    return 'Nakapakyas sa pag-assign sa mga grado: $error';
  }

  @override
  String studentRosterUpdatedCount(int count) {
    return 'Na-update ang $count estudyante(s)';
  }

  @override
  String studentRosterLoadFailed(String error) {
    return 'Nakapakyas sa pag-load: $error';
  }

  @override
  String get studentRosterNoPermission =>
      'Wala kay permiso sa pagdumala sa listahan sa mga estudyante.';

  @override
  String get studentRosterNotSchool =>
      'Ang listahan sa mga estudyante ug mga grado kay magamit ra para sa mga organisasyon nga tipo sa eskwelahan.';

  @override
  String get studentRosterEmpty =>
      'Wala pa\'y mga estudyante. I-tap ang Add Student aron makahatag og account.';

  @override
  String get studentRosterNoMatch =>
      'Walay estudyante nga nagtugma sa imong mga filter.';

  @override
  String studentRosterAssignGradeWhichGroup(int count) {
    return '$count nga estudyante ang napili. Asa nga grupo ang ihatag nga grado?';
  }

  @override
  String studentRosterOnlyNamed(String name) {
    return 'Lang $name ra';
  }

  @override
  String get studentRosterOnlyThisStudent => 'Kining estudyante ra';

  @override
  String studentRosterAssignGradeToOne(String name) {
    return 'Ihatag ang grado kang $name';
  }

  @override
  String studentRosterAssignGradeToMany(int count) {
    return 'I-assign ang grado sa $count nga estudyante';
  }

  @override
  String get studentRosterConfirmGradeTitle =>
      'Kumpirmaha ang pag-assign sa grado';

  @override
  String studentRosterConfirmGradeOne(String name, int grade) {
    return 'I-set si $name sa Baitang $grade?';
  }

  @override
  String studentRosterConfirmGradeMany(int count, int grade) {
    return 'I-set ang $count nga estudyante sa Baitang $grade?';
  }

  @override
  String studentRosterPreviewAndMore(int count) {
    return '…ug $count pa';
  }

  @override
  String get rolesManagementTitle => 'Mga Papel ug Mga Tugot';

  @override
  String get rolesAssignments => 'Mga Takdang Aralin';

  @override
  String get rolesCapabilities => 'Mga Kahanas';

  @override
  String get rolesCreateRole => 'Magtukod og Papel';

  @override
  String get rolesSystemRoles => 'Mga Sistema nga Papel';

  @override
  String get rolesCustomRoles => 'Mga Pasadya nga Papel';

  @override
  String get rolesNoCapabilities => 'Walay mga kakayahan nga gihatag';

  @override
  String rolesMoreCapabilities(int count) {
    return '+$count pa';
  }

  @override
  String get rolesAssignUsers => 'I-assign ang mga Gumagamit';

  @override
  String rolesSeedFailed(String error) {
    return 'Nabigo ang seed: $error';
  }

  @override
  String get rolesSeedSuccess =>
      'Madalas nga mga papel nga nadugang nga malampuson';

  @override
  String get rolesCreateManually => 'Manually nga Paghimo og Papel';

  @override
  String get rolesNoRolesEmpty => 'Walay mga papel nga gihimo pa';

  @override
  String get rolesSystemBadge => 'Sistema';

  @override
  String get rolesSeedDefaultRoles => 'Itanum ang mga Default nga Papel';

  @override
  String get rolesSeeding => 'Nag-seed…';

  @override
  String get rolesEmptyDescription =>
      'Magmahi ang imong unang pasadya nga papel aron hatagan ang mga kawani og espesipikong mga kakayahan sulod niining organisasyon.';

  @override
  String rolesAllCapabilitiesTitle(String roleName) {
    return '$roleName — Tanang Kakayahan';
  }

  @override
  String get roleAssignmentsTitle => 'Mga Talaan sa Papel sa Gumagamit';

  @override
  String get roleAssignmentsNoUsers =>
      'Walay nakaprobahan nga mga tiggamit nga nakit-an.';

  @override
  String get roleAssignmentsNoRoles => 'Walay gihatag nga mga papel';

  @override
  String assignRoleTitle(String roleName) {
    return 'I-assign: $roleName';
  }

  @override
  String get assignRoleSuccess => 'Malampusong na-assign ang papel';

  @override
  String assignRoleFailed(String error) {
    return 'Nakapakyas ang pag-assign: $error';
  }

  @override
  String get assignRoleScopeType => 'Tipo sa Sakop';

  @override
  String get assignRoleRemoveTitle => 'Tangtangon ang Asaynment?';

  @override
  String assignRoleRemoveConfirm(Object scope) {
    return 'Ikuha ang tahas nga pag-assign ($scope)? Ang tiggamit dayon mawagtang ang mga katungod nga gihatag sa niini nga tahas.';
  }

  @override
  String get capabilitiesTitle => 'Mga Kakayahan';

  @override
  String get capabilitiesTabCustom => 'Pasadya';

  @override
  String get capabilitiesTabBuiltins => 'Mga Nakatakdang Kahon';

  @override
  String get capabilitiesDeleteTitle => 'I-delete ang Kakayahan?';

  @override
  String capabilitiesDeleteBody(String name) {
    return 'Ang \"$name\" kay tangtangon. Ang mga papel nga naggamit niini mawagtang ang kini nga katungdanan.';
  }

  @override
  String get capabilitiesCreateLabel => 'Magmahimo og Custom nga Kakayahan';

  @override
  String get capabilitiesBackedByLabel =>
      'Gisuportahan sa (naka-built-in nga aksyon)';

  @override
  String get capabilitiesBuiltinsIntro =>
      'Kini ang mga nakabuilt-in nga kakayahan nga magamit sa tanang organisasyon sa SpeakUp Connect. Dili kini mausab o matangtang — mahimo lamang maghimo og mga pasikad nga alias sa kakayahan ibabaw niini.';

  @override
  String get roleEditorCreateTitle => 'Magtukod og Papel';

  @override
  String get roleEditorEditTitle => 'Usba ang Papel';

  @override
  String get roleEditorRoleDetails => 'Mga Detalye sa Papel';

  @override
  String get roleEditorRoleName => 'Ngalan sa Papel';

  @override
  String get roleEditorDescription => 'Paglaraw';

  @override
  String get roleEditorCapabilities => 'Mga Kakayahan';

  @override
  String get roleEditorManageCustom => 'Pagdumala sa Custom';

  @override
  String get roleEditorCapabilitiesHint =>
      'Pilia ang mga nakabuilt-in nga kakayahan nga gihatag sa kini nga papel.';

  @override
  String get roleEditorCustomCapabilities => 'Mga Pasikaran nga Kahanas';

  @override
  String get roleEditorCustomCapabilitiesHint =>
      'Mga alias sa kakayahan nga gihimo sa org nga gibase sa mga nakabuilt-in.';

  @override
  String get roleEditorNoCustomCaps => 'Wala pang mga pasadya nga kakayahan.';

  @override
  String get roleEditorCreateCustomCap => 'Magmahi og custom nga kakayahan';

  @override
  String get roleEditorSaveRole => 'I-save ang Papel';

  @override
  String get roleEditorSaving => 'Nag-save…';

  @override
  String get roleEditorSaved => 'Nakatipig na ang papel';

  @override
  String roleEditorSaveFailed(String error) {
    return 'Nakapakyas ang pag-save: $error';
  }

  @override
  String get roleEditorAssignUsers => 'I-assign ang mga Gumagamit';

  @override
  String roleEditorBasedOn(String permission) {
    return 'Nakasalig sa: $permission';
  }

  @override
  String get orgSettingsTitle => 'Mga Setting sa Organisasyon';

  @override
  String get orgSettingsDisplayName => 'Ngalan sa Pagpakita';

  @override
  String get orgSettingsDisplayNameHint => 'e.g. Riverside High';

  @override
  String get orgSettingsBrandingUpdated =>
      'Na-update ang branding nga malampuson';

  @override
  String orgSettingsSaveFailed(String error) {
    return 'Nakapakyas sa pag-save: $error';
  }

  @override
  String get orgSettingsContrastWarning => 'Babag sa Kontrasto';

  @override
  String get orgSettingsSaveAnyway => 'I-save gihapon';

  @override
  String get orgSettingsAutoAdjustSave => 'Awto-adjust ug I-save';

  @override
  String orgSettingsSeedCategoriesFailed(String error) {
    return 'Nabigo ang pag-seed: $error';
  }

  @override
  String get orgSettingsSeedCategoriesSuccess =>
      'Madalas nga mga kategorya nga nadugang nga malampuson';

  @override
  String get orgSettingsChangeOrgTypeTitle => 'Usbon ang tipo sa organisasyon?';

  @override
  String orgSettingsChangeOrgTypeConfirm(
      String fromType, String toType, String description) {
    return 'Usba gikan sa $fromType ngadto sa $toType?\n\n$description\n\nKini makaapekto sa mga admin nga bahin nga magamit (sama sa mga grado sa estudyante ug roster para sa mga eskwelahan).';
  }

  @override
  String orgSettingsOrgTypeSaved(String type) {
    return 'Nakatakda ang tipo sa organisasyon sa $type';
  }

  @override
  String orgSettingsOrgTypeFailed(String error) {
    return 'Nakapakyas ang pag-update: $error';
  }

  @override
  String get orgSettingsTypeLabel => 'Tipo';

  @override
  String get orgSettingsSaveType => 'I-save ang tipo';

  @override
  String get orgSettingsAllowPersonalPhotos =>
      'Tugoti ang mga personal nga litrato sa profile';

  @override
  String get orgSettingsRequireApproval =>
      'Kinahanglan ang pag-apruba sa dili pa ipagawas';

  @override
  String get orgSettingsOrgNameTitle => 'Ngalan sa Organisasyon';

  @override
  String get orgSettingsOrgNameSubtitle =>
      'Ipakita sa splash screen nga \"SpeakUp [Name]\".';

  @override
  String get orgSettingsBrandColorsTitle => 'Mga Kulay sa Brand';

  @override
  String get orgSettingsBrandColorsSubtitle =>
      'Ibutang ang 6-digit nga hex codes gikan sa brand guide sa organisasyon (pananglitan, #1A73E8). Ang mga kausaban magamit sa tanan nga nakonektang mga device sa tinuod nga oras ug gi-cache lokal alang sa dali nga pagsugod.';

  @override
  String get orgSettingsPrimaryColor => 'Pangunang Kulay';

  @override
  String get orgSettingsSecondaryColor => 'Ikaduhang Kulay';

  @override
  String get orgSettingsColorHint => 'e.g. #1A73E8';

  @override
  String get orgSettingsSecondaryColorHint => 'pananglitan: #000000';

  @override
  String get orgSettingsSaveBranding => 'I-save ang Branding';

  @override
  String get orgSettingsSaving => 'Nag-save…';

  @override
  String get orgSettingsBrandingInfo =>
      'Pagkahuman sa pag-save, ang bag-ong mga kolor magpakita dayon sa tanan nga nakonektang mga device. Sa kini nga device, ang branding isulat usab sa lokal nga storage, aron kini ma-load nga husto sa sunod nga paglansad sa app sa wala pa mag-reply ang Firestore.';

  @override
  String get orgSettingsReportCategoriesTitle => 'Mga Kategorya sa Ulat';

  @override
  String get orgSettingsReportCategoriesSubtitle =>
      'Kinahanglan ang mga kategorya aron makasumite ang mga tiggamit og mga kabalaka. I-tap ang buton sa ubos aron mapuno ang default nga set.';

  @override
  String orgSettingsCategoriesConfigured(int count) {
    return '$count nga kategorya ang na-configure';
  }

  @override
  String get orgSettingsAddDefaultCategories =>
      'Idugang ang mga Default nga Kategorya';

  @override
  String get orgSettingsAddingCategories => 'Nagdugang…';

  @override
  String get orgSettingsOrgTypeTitle => 'Uri sa Organisasyon';

  @override
  String get orgSettingsOrgTypeSubtitle =>
      'Nagdeterminar kung unsang mga bahin ang magamit. Ang mga eskwelahan makagamit sa mga grado sa estudyante ug roster; ang mga munisipyo ug NGO maggamit sa pagdumala sa mga miyembro nga walay mga grado.';

  @override
  String get orgSettingsMemberPhotosTitle =>
      'Mga Larawan sa Profile sa Miyembro';

  @override
  String get orgSettingsMemberPhotosSubtitle =>
      'Kung nakabukas, ang mga estudyante mahimong mag-upload og personal nga badge sa Settings. Ang opisyal nga mga litrato sa eskwelahan nga gi-upload sa mga kawani magpabilin nga usa ka lahi nga permanente nga rekord ug dili gayud mapulihan.';

  @override
  String get orgSettingsMemberPhotosOn =>
      'Karon NAKA-ON — ang mga miyembro makadugang og personal nga badge sa Mga Setting';

  @override
  String get orgSettingsMemberPhotosOff =>
      'Karon NAKA-OFF — ang mga opisyal nga litrato sa eskwelahan ra ang ipakita';

  @override
  String get orgSettingsMemberPhotosEnabled =>
      'Ang mga miyembro makapadugang na og personal nga mga litrato sa profile.';

  @override
  String get orgSettingsMemberPhotosDisabled =>
      'Gidisable ang personal nga profile photos para sa mga miyembro';

  @override
  String get orgSettingsReminderApprovalTitle => 'Pahimangno sa Pag-apruba';

  @override
  String get orgSettingsReminderApprovalSubtitle =>
      'Kung nakabukas, ang mga miyembro nga makapadala og mga pahimangno apan dili makapapprove niini kinahanglan mag-submit og mga pahimangno alang sa pagrepaso sa dili pa kini ipagawas.';

  @override
  String get orgSettingsReminderApprovalOn =>
      'Karon NAKA-ON — ang mga pahimangno gikan sa mga dili mag-aproba gipugngan alang sa pagrepaso';

  @override
  String get orgSettingsReminderApprovalOff =>
      'Karon OFF — ang mga pahimangno gipagawas dayon';

  @override
  String get orgSettingsReminderApprovalEnabled =>
      'Ang mga pahimangno karon nagkinahanglan og pag-apruba sa dili pa ipagawas.';

  @override
  String get orgSettingsReminderApprovalDisabled =>
      'Ang mga pahimangno karon direkta nang gipagawas';

  @override
  String get orgSettingsPermissionDenied =>
      'Wala kay permiso sa pag-usab niining settinga.';

  @override
  String get orgSettingsPrimarySwatch => 'Panguna';

  @override
  String get orgSettingsSecondarySwatch => 'Ikaduhang';

  @override
  String get orgSettingsRequired => 'Kinahanglanon';

  @override
  String get orgSettingsHexInvalid =>
      'Isulod ang balido nga 6-digit nga hex (pananglitan, #1A73E8)';

  @override
  String get orgSettingsPrimaryHexInvalid =>
      'Ang pangunang kolor kinahanglan usa ka balido nga 6-digit nga hex (pananglitan #1A73E8).';

  @override
  String get orgSettingsSecondaryHexInvalid =>
      'Ang ikaduhang kolor kinahanglan usa ka balido nga 6-digit nga hex (sama sa #000000).';

  @override
  String get orgSettingsContrastLightBackgrounds => 'hayag nga mga background';

  @override
  String get orgSettingsContrastDarkBackgrounds =>
      'madulong nga mga background';

  @override
  String get orgSettingsContrastLightAndDarkBackgrounds =>
      'hayag ug ngitngit nga mga background';

  @override
  String orgSettingsContrastSecondaryFallback(
      String primary, String secondary, String surfaces) {
    return 'Ang imong pangunahing kolor ($primary) dili igo nga makita sa $surfaces — kini maghiusa sa background.\n\nAng imong sekondaryang kolor ($secondary) gamiton isip fallback para sa mga buton ug mga icon, apan mahimo nimong gustohon ang mas angay nga pangunahing kolor.\n\nMakahimo ka gihapon sa pag-save o pasagdan ang app nga ilisan ang pangunahing kolor ngadto sa labing duol nga ligtas nga shade sa contrast.';
  }

  @override
  String orgSettingsContrastNeither(
      String primary, String secondary, String surfaces) {
    return 'Wala’y bisan unsa sa imong panguna ($primary) o sekondarya ($secondary) nga kolor nga naghatag og igo nga ka-kontra batok sa $surfaces. Ang mga butones, link, ug icon mahimong lisod makita.\n\nMahimo ka magtipig bisan unsa, o pasagdan ang app nga ibalhin ang pangunang kolor sa labing duol nga luwas nga anino sa ka-kontra.';
  }

  @override
  String get orgSettingsProfilePhotoSaveFailed =>
      'Wala masulod ang setting sa profile photo.';

  @override
  String get orgSettingsReminderApprovalSaveFailed =>
      'Wala masulod ang setting sa pag-apruba sa pahimangno.';

  @override
  String get orgTypeAdminSchool => 'Eskwela';

  @override
  String get orgTypeAdminUniversity => 'Unibersidad';

  @override
  String get orgTypeAdminLgu => 'Munisipyo / LGU';

  @override
  String get orgTypeAdminNgo => 'NGO';

  @override
  String get orgTypeAdminChurch => 'Simbahan';

  @override
  String get orgTypeAdminCorporation => 'Korporasyon';

  @override
  String get orgTypeAdminOther => 'Uban pa';

  @override
  String get orgTypeAdminSchoolDesc =>
      'Nag-enable sa mga grado sa estudyante, roster, ug mga feature nga nakabase sa klase.';

  @override
  String get orgTypeAdminUniversityDesc =>
      'Nag-enable sa mga grado sa estudyante, roster, ug mga feature nga nakabase sa klase.';

  @override
  String get orgTypeAdminLguDesc =>
      'Para sa mga munisipyo, barangay, ug mga yunit sa lokal nga gobyerno.';

  @override
  String get orgTypeAdminNgoDesc =>
      'Para sa mga non-profit ug mga organisasyon sa komunidad.';

  @override
  String get orgTypeAdminChurchDesc =>
      'Para sa mga simbahan ug mga komunidad nga nakabase sa pagtuo.';

  @override
  String get orgTypeAdminCorporationDesc =>
      'Para sa mga kumpanya ug mga komunidad sa trabaho.';

  @override
  String get orgTypeAdminOtherDesc =>
      'Heneral nga organisasyon nga walay mga bahin nga espesipiko sa tipo.';

  @override
  String get commonClose => 'Isira';

  @override
  String get commonEdit => 'Usba';

  @override
  String get commonRequired => 'Kinahanglanon';

  @override
  String commonErrorPrefix(String error) {
    return 'Sayup: $error';
  }

  @override
  String get commonRole => 'Papel';

  @override
  String get commonNameRequired => 'Kinahanglan ang ngalan';

  @override
  String adminDashboardAnonymousDate(String date) {
    return 'Walay ngalan · $date';
  }

  @override
  String adminDashboardSubmitterDate(String name, String date) {
    return '$name · $date';
  }

  @override
  String get reportCategoryFacility => 'Pasilidad ug Inprastruktura';

  @override
  String get reportCategorySafety => 'Kaluwasan ug Seguridad';

  @override
  String get reportCategoryAcademic => 'Sangputanan sa Akademiko';

  @override
  String get reportCategoryBullying => 'Pangharas ug Pagpangdaut';

  @override
  String get reportCategorySanitation => 'Kahimsog ug Kalimpyo';

  @override
  String get reportCategoryConduct => 'Pamatasan sa Kawani / Magtutudlo';

  @override
  String get reportCategoryAdministrative => 'Administratibo';

  @override
  String get reportCategoryOther => 'Uban pa';

  @override
  String get adminReportDetailTitle => 'Detalye sa Report';

  @override
  String get adminReportDetailLoading => 'Nag-load sa report...';

  @override
  String get adminReportDetailLoadFailed => 'Nakapakyas sa pag-load sa report';

  @override
  String adminReportDetailSubmittedDate(String date) {
    return 'Gisumite $date';
  }

  @override
  String get adminReportDetailAnonymousSubmission =>
      'Dihang walay ngalan nga gisumite';

  @override
  String adminReportDetailBySubmitter(String name) {
    return 'Ni: $name';
  }

  @override
  String get adminReportDetailDescription => 'Deskripsyon';

  @override
  String adminReportDetailPhotos(int count) {
    return 'Mga Litrato ($count)';
  }

  @override
  String get adminReportDetailAdminActions => 'Mga Aksyon sa Admin';

  @override
  String get adminReportDetailUpdateStatus => 'I-update ang Kahimtang';

  @override
  String get adminReportDetailAddNote => 'Magdugang og Nota';

  @override
  String get adminReportDetailAssignToAdmin => 'I-assign sa Admin';

  @override
  String get adminReportDetailReassign => 'Ibalik ang tahas';

  @override
  String get adminReportDetailUnassigned => 'Walay nakatalaga';

  @override
  String adminReportDetailAssignedTo(String name) {
    return 'Ginatag sa: $name';
  }

  @override
  String adminReportDetailAdminNotes(int count) {
    return 'Mga Nota sa Admin ($count)';
  }

  @override
  String get adminReportDetailStatusHistory => 'Kasaysayan sa Estado';

  @override
  String get adminReportDetailAddAdminNote => 'Magdugang og Admin nga Nota';

  @override
  String adminReportDetailCurrentStatus(String status) {
    return 'Karon: $status';
  }

  @override
  String get adminReportDetailNewStatus => 'Bag-ong Kahimtang';

  @override
  String get adminReportDetailStatusChangeNoteHint =>
      'Magdugang og nota bahin sa kini nga pagbag-o sa estado…';

  @override
  String get adminReportDetailAssignTitle => 'I-assign sa Admin';

  @override
  String get adminReportDetailSearchAdmins => 'Pangita ang mga admin…';

  @override
  String get adminReportDetailNoAdmins => 'Walay nakitang mga admin.';

  @override
  String adminReportDetailLoadAdminsFailed(String error) {
    return 'Nakapakyas sa pag-load sa mga admin: $error';
  }

  @override
  String adminReportDetailAssignFailed(String error) {
    return 'Napalpak ang pag-assign sa report: $error';
  }

  @override
  String adminReportDetailUpdateStatusFailed(String error) {
    return 'Nakapakyas sa pag-update sa estado: $error';
  }

  @override
  String adminReportDetailAddNoteFailed(String error) {
    return 'Napakyas sa pagdugang og nota: $error';
  }

  @override
  String get adminReportDetailNoteLabel => 'Nota';

  @override
  String get adminReportDetailEnterNote => 'Isulod ang imong nota…';

  @override
  String get reportDetailsTitle => 'Detalye sa Report';

  @override
  String get reportDetailsLoading => 'Nag-load sa report...';

  @override
  String get reportDetailsLoadFailed => 'Nakapakyas sa pag-load sa report';

  @override
  String get myReportsTitle => 'Ang Akong mga Report';

  @override
  String get myReportsNoReportsYet => 'Wala pa\'y mga report';

  @override
  String get myReportsTabAll => 'Tanan';

  @override
  String get myReportsTabInProgress => 'Sa Progreso';

  @override
  String get myReportsTabResolved => 'Nasulbad';

  @override
  String get myReportsNewReport => 'Bag-ong Ulat';

  @override
  String get myReportsEmptyAll =>
      'Wala ka pa nakasumite og bisan unsang report.';

  @override
  String myReportsEmptyFiltered(String status) {
    return 'Walay mga report nga adunay status nga \"$status\".';
  }

  @override
  String get rolesEdit => 'Usba';

  @override
  String get roleEditorNameHint => 'e.g. Tagapayo sa mga Estudyante';

  @override
  String get roleEditorDescriptionHint =>
      'Ilaraw ang hinungdan kung kinsa kini nga papel.';

  @override
  String get assignRoleSelectUser => 'Pili-a ang Gumagamit';

  @override
  String get assignRoleSearchHint =>
      'Pangitaa pinaagi sa ngalan o ID sa estudyante';

  @override
  String get assignRoleConfirmAssignment => 'Kumpirmahi ang Pag-assign';

  @override
  String get assignRoleAssigning => 'Nag-assign…';

  @override
  String get assignRoleNoUsersFound => 'Walay nakitang mga gumagamit.';

  @override
  String get assignRoleScopeTitle => 'Sakop sa Papel';

  @override
  String get assignRoleScopeSubtitle =>
      'I-define kung unsa ka lapad ang pag-aplikar sa kini nga papel alang sa kini nga tiggamit.';

  @override
  String get assignRoleScopeOptionOrg => 'Tibuok Org';

  @override
  String get assignRoleScopeOptionTag => 'Espesipikong tag';

  @override
  String get assignRoleScopeOptionClass => 'Espesipikong klase / seksyon';

  @override
  String get assignRoleScopeOptionGroup => 'Espesipikong grupo / klub';

  @override
  String get assignRoleScopeOptionDepartment => 'Espesipikong departamento';

  @override
  String get assignRoleScopeOptionBarangay => 'Espesipikong barangay';

  @override
  String get assignRoleScopeFieldTag => 'Tag';

  @override
  String get assignRoleScopeFieldClassId => 'ID sa Klase';

  @override
  String get assignRoleScopeFieldGroupId => 'ID sa Grupo';

  @override
  String get assignRoleScopeFieldDepartmentId => 'ID sa Departamento';

  @override
  String get assignRoleScopeFieldBarangayId => 'ID sa Barangay';

  @override
  String get assignRoleScopeHintTag => 'panudlo';

  @override
  String get assignRoleScopeHintClass =>
      'ID sa dokumento sa klase sa Firestore';

  @override
  String get assignRoleScopeHintGroup =>
      'ID sa dokumento sa grupo sa Firestore';

  @override
  String get assignRoleScopeHintDepartment =>
      'ID sa dokumento sa departamento sa Firestore';

  @override
  String get assignRoleScopeHintBarangay =>
      'ID sa dokumento sa barangay sa Firestore';

  @override
  String get assignRoleScopeChipOrg => 'Tibuok organisaasyon';

  @override
  String get assignRoleScopeChipTag => 'Tag';

  @override
  String get assignRoleScopeChipClass => 'Klase';

  @override
  String get assignRoleScopeChipGroup => 'Grupo';

  @override
  String get assignRoleScopeChipDepartment => 'Departamento';

  @override
  String get assignRoleScopeChipDept => 'Departamento';

  @override
  String get assignRoleScopeChipBarangay => 'Barangay';

  @override
  String assignRoleScopeValueTag(String id) {
    return 'Tag: $id';
  }

  @override
  String assignRoleScopeValueClass(String id) {
    return 'Klase: $id';
  }

  @override
  String assignRoleScopeValueGroup(String id) {
    return 'Grupo: $id';
  }

  @override
  String assignRoleScopeValueDepartment(String id) {
    return 'Departamento: $id';
  }

  @override
  String assignRoleScopeValueBarangay(String id) {
    return 'Barangay: $id';
  }

  @override
  String get assignRoleCurrentAssignments => 'Kasalukuyang mga Takdang Aralin';

  @override
  String assignRoleAssignedDate(String date) {
    return 'Gipahimutang $date';
  }

  @override
  String get assignRoleRemoveTooltip => 'Tangtanga ang tahas';

  @override
  String get assignRoleRevokeHint =>
      'I-tap ang − aron kuhaon ang kasamtangang tahas.';

  @override
  String assignRoleRoleChip(String role, String scope) {
    return '$role · $scope';
  }

  @override
  String capabilitiesLoadFailed(String error) {
    return 'Dili ma-load ang mga custom nga kakayahan: $error';
  }

  @override
  String get capabilitiesDeleteTooltip => 'I-delete';

  @override
  String get capabilitiesNewCustomTitle => 'Bag-ong Custom nga Kakayahan';

  @override
  String get capabilitiesNameLabel => 'Ngalan sa Kakayahan';

  @override
  String get capabilitiesNameHint => 'Halimbawa: Pagsusi sa Giya sa Referral';

  @override
  String get capabilitiesNameRequired => 'Kinahanglan ang ngalan';

  @override
  String get capabilitiesDescriptionLabel => 'Paglaraw (opsyonal)';

  @override
  String get capabilitiesSelectBacking => 'Pili-a ang aksyon nga suportado';

  @override
  String get capabilitiesRestrictTagLabel => 'Limitahi sa tag (opsyonal)';

  @override
  String get capabilitiesRestrictTagHint => 'panudlo';

  @override
  String get capabilitiesRestrictTagHelper =>
      'Biyaan nga walay sulod aron maaplikar sa tanan nga sulod nga adunay kini nga aksyon.';

  @override
  String get capabilitiesCreating => 'Naghimo…';

  @override
  String get capabilitiesNoCustomYet =>
      'Wala pay mga pasilidad nga na-customize.';

  @override
  String get capabilitiesNoCustomDescription =>
      'Magtukod og alias sa kakayahan aron hatagan og ngalan nga espesipiko sa eskwelahan ang mga nakabuilt-in nga aksyon.';

  @override
  String get permissionViewAllReports => 'Tan-awa ang tanan nga report sa org';

  @override
  String get permissionViewGroupReports =>
      'Tan-awa ang mga report sa gihatag nga mga grupo';

  @override
  String get permissionApproveReport => 'Aprobahi / isira ang mga report';

  @override
  String get permissionManageReports =>
      'I-update ang estado, i-escalate & magdugang og mga nota';

  @override
  String get permissionPostBulletinOrgWide =>
      'Mag-post og mga bulletin sa tibuok organisasyon';

  @override
  String get permissionPostBulletinToGroup =>
      'Mag-post og mga bulletin sa kaugalingong grupo';

  @override
  String get permissionBroadcastReminders => 'Ipadala ang mga pahimangno';

  @override
  String get permissionApproveReminders =>
      'Aprobahi / i-reject ang mga pahimangno';

  @override
  String get permissionManageGroupRoster =>
      'Pagdumala sa kaugalingong grupo nga listahan';

  @override
  String get permissionManageClassRoster =>
      'Pagdumala sa listahan sa klase (eskwelahan ra)';

  @override
  String get permissionApproveApplications =>
      'Aprobahi ang mga aplikasyon sa pag-apil';

  @override
  String get permissionBlockUsers => 'I-suspend o i-block ang mga gumagamit';

  @override
  String get permissionManageOrganizationSettings =>
      'Pagdumala sa mga setting sa organisasyon ug branding';

  @override
  String get permissionManageRoles =>
      'Pagdumala sa mga papel ug pag-assign sa mga permiso';

  @override
  String get permissionManageTranslations =>
      'Moderator sa hubad (edit UI strings)';

  @override
  String get permissionViewAuditLogs => 'Tan-awa ang mga audit log';

  @override
  String get permissionGroupReports => 'Mga report';

  @override
  String get permissionGroupBulletins => 'Mga Bulletin ug Balita';

  @override
  String get permissionGroupReminders => 'Mga pahimangno';

  @override
  String get permissionGroupRosterUsers => 'Lista ug mga Gumagamit';

  @override
  String get permissionGroupAdministration => 'Administrasyon';

  @override
  String get translationSearchHint =>
      'Pangitaon ang mga yawe o Ingles nga teksto';

  @override
  String get translationBatchAi => 'Isalin ang kulang (AI)';

  @override
  String get translationBatchAiNoneMissing =>
      'Walay mga nawawalang string nga isalin.';

  @override
  String translationBatchAiResult(int succeeded, int total) {
    return 'AI draft: $succeeded sa $total nga nagmalampuson';
  }

  @override
  String get translationExportArb => 'I-export ang ARB (kopyaha ang JSON)';

  @override
  String get translationExportCopied => 'Na-clipboard na ang ARB JSON';

  @override
  String translationEntryCount(int count) {
    return '$count nga mga string ang na-load';
  }

  @override
  String get translationNoEntries =>
      'Wala pa\'y mga entry sa hubad. Una nga i-import sa mga operator sa plataporma ang app_en.arb.';

  @override
  String get translationTargetLabel => 'Pagsalin';

  @override
  String get translationAiDraft => 'AI draft';

  @override
  String get translationApprove => 'Aprobahan';
}
