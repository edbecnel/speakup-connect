import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// Resolves the home welcome hero copy for the active UI locale.
///
/// Firestore `welcomeMessage` is admin-authored English only in phase 1, so
/// non-English locales always use the localized ARB template instead.
String homeWelcomeMessageForConfig(
  OrganizationConfigEntity? orgConfig,
  AppLocalizations l10n, {
  required String languageCode,
}) {
  if (orgConfig == null) {
    return l10n.homeDefaultWelcomeMessage;
  }
  if (languageCode != 'en') {
    return l10n.homeWelcomeMessageWithOrgType(orgConfig.type.word(l10n));
  }
  return orgConfig.welcomeMessage ??
      l10n.homeWelcomeMessageWithOrgType(orgConfig.type.word(l10n));
}

extension OrganizationTypeL10n on OrganizationType {
  /// Lowercase org-type word for welcome message copy (e.g. "school").
  String word(AppLocalizations l10n) => switch (this) {
        OrganizationType.school => l10n.orgTypeWordSchool,
        OrganizationType.university => l10n.orgTypeWordUniversity,
        OrganizationType.lgu => l10n.orgTypeWordLgu,
        OrganizationType.ngo => l10n.orgTypeWordNgo,
        OrganizationType.church => l10n.orgTypeWordChurch,
        OrganizationType.corporation => l10n.orgTypeWordCorporation,
        OrganizationType.other => l10n.orgTypeWordOther,
      };
}
