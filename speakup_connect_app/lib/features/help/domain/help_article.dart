import 'package:flutter/material.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// A bundled markdown help article shown in the in-app Help Center.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.assetName,
    required this.icon,
    required this.audience,
  });

  final String id;
  final String assetName;
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
  menuBook,
  school,
}

extension HelpArticleIconX on HelpArticleIcon {
  IconData get data => switch (this) {
        HelpArticleIcon.people => Icons.people_outline,
        HelpArticleIcon.adminPanel => Icons.admin_panel_settings_outlined,
        HelpArticleIcon.menuBook => Icons.menu_book_outlined,
        HelpArticleIcon.school => Icons.school_outlined,
      };
}

extension HelpArticleL10n on HelpArticle {
  String title(AppLocalizations l10n) => switch (id) {
        'member' => l10n.helpMemberGuideTitle,
        'admin' => l10n.helpAdminGuideTitle,
        'member_tutorial' => l10n.helpMemberTutorialTitle,
        'admin_tutorial' => l10n.helpAdminTutorialTitle,
        _ => id,
      };

  String subtitle(AppLocalizations l10n) => switch (id) {
        'member' => l10n.helpMemberGuideSubtitle,
        'admin' => l10n.helpAdminGuideSubtitle,
        'member_tutorial' => l10n.helpMemberTutorialSubtitle,
        'admin_tutorial' => l10n.helpAdminTutorialSubtitle,
        _ => '',
      };
}

/// Catalog of in-app help articles (content resolved per org via [HelpAssetResolver]).
abstract class HelpArticles {
  static const member = HelpArticle(
    id: 'member',
    assetName: 'member_guide',
    icon: HelpArticleIcon.menuBook,
    audience: HelpAudience.member,
  );

  static const admin = HelpArticle(
    id: 'admin',
    assetName: 'admin_guide',
    icon: HelpArticleIcon.adminPanel,
    audience: HelpAudience.admin,
  );

  static const memberTutorial = HelpArticle(
    id: 'member_tutorial',
    assetName: 'member_tutorial',
    icon: HelpArticleIcon.school,
    audience: HelpAudience.member,
  );

  static const adminTutorial = HelpArticle(
    id: 'admin_tutorial',
    assetName: 'admin_tutorial',
    icon: HelpArticleIcon.school,
    audience: HelpAudience.admin,
  );

  static const all = [member, admin, memberTutorial, adminTutorial];

  static HelpArticle? byId(String id) {
    for (final article in all) {
      if (article.id == id) return article;
    }
    return null;
  }
}
