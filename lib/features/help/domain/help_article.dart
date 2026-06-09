import 'package:flutter/material.dart';

/// A bundled markdown help article shown in the in-app Help Center.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.audience,
  });

  final String id;
  final String title;
  final String subtitle;
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

/// Catalog of in-app help articles (content resolved per org via [HelpAssetResolver]).
abstract class HelpArticles {
  static const member = HelpArticle(
    id: 'member',
    title: 'Member Guide',
    subtitle: 'Sign in, submit reports, and use alerts',
    icon: HelpArticleIcon.people,
    audience: HelpAudience.member,
  );

  static const admin = HelpArticle(
    id: 'admin',
    title: 'Administrator Guide',
    subtitle: 'Roster, groups, reports, and reminders',
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
