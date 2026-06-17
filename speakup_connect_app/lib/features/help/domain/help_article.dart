import 'package:flutter/material.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// A bundled markdown help article shown in the in-app Help Center.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.icon,
    required this.audience,
  });

  final String id;
  final HelpAudience audience;
  final HelpArticleIcon icon;
}

enum HelpAudience {
  /// All approved members.
  member,

  /// Org admins and staff with administration menu access.
  admin,
}

enum HelpArticleIcon {
  people,
  adminPanel,
}

extension HelpArticleIconX on HelpArticleIcon {
  IconData get data => switch (this) {
        HelpArticleIcon.people => Icons.people_outline,
        HelpArticleIcon.adminPanel => Icons.admin_panel_settings_outlined,
      };
}

extension HelpArticleL10n on HelpArticle {
  String title(AppLocalizations l10n) => switch (id) {
        'member' => l10n.helpMemberGuideTitle,
        'admin' => l10n.helpAdminGuideTitle,
        _ => id,
      };

  String subtitle(AppLocalizations l10n) => switch (id) {
        'member' => l10n.helpMemberGuideSubtitle,
        'admin' => l10n.helpAdminGuideSubtitle,
        _ => '',
      };
}

/// Catalog of in-app help articles (content resolved per org via [HelpAssetResolver]).
abstract class HelpArticles {
  static const member = HelpArticle(
    id: 'member',
    icon: HelpArticleIcon.people,
    audience: HelpAudience.member,
  );

  static const admin = HelpArticle(
    id: 'admin',
    icon: HelpArticleIcon.adminPanel,
    audience: HelpAudience.admin,
  );

  static const all = [member, admin];

  static HelpArticle? byId(String id) {
    for (final article in all) {
      if (article.id == id) return article;
    }
    return null;
  }
}
