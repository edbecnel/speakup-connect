import 'package:speakup_connect/l10n/app_localizations.dart';

/// Localizes seeded report category IDs. Falls back to [fallbackLabel] for
/// custom org-defined categories stored in Firestore.
String localizedReportCategoryLabel(
  AppLocalizations l10n,
  String categoryId, {
  String? fallbackLabel,
}) {
  return switch (categoryId) {
    'facility' => l10n.reportCategoryFacility,
    'safety' => l10n.reportCategorySafety,
    'academic' => l10n.reportCategoryAcademic,
    'bullying' => l10n.reportCategoryBullying,
    'sanitation' => l10n.reportCategorySanitation,
    'conduct' => l10n.reportCategoryConduct,
    'administrative' => l10n.reportCategoryAdministrative,
    'other' => l10n.reportCategoryOther,
    _ => fallbackLabel ?? categoryId,
  };
}
