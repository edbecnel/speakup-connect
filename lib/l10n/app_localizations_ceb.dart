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
  String get schoolGradesIntro =>
      'Define which grade levels your school uses. These appear in Student Roster and Member Management filters.';

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
  String get studentRosterSearchHint => 'Search by name or student ID…';

  @override
  String get studentRosterAssignSelected => 'Assign grade to selected';

  @override
  String get studentRosterAddStudent => 'Add Student';

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
