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
