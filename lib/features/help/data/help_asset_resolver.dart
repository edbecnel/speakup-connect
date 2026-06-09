import 'package:flutter/services.dart';

/// Resolves bundled markdown help assets per organization.
///
/// Lookup order:
/// 1. `assets/help/orgs/{organizationId}/{articleId}_guide.md`
/// 2. `assets/help/_default/{articleId}_guide.md` (generic fallback)
abstract class HelpAssetResolver {
  static String orgPath(String organizationId, String articleId) =>
      'assets/help/orgs/$organizationId/${articleId}_guide.md';

  static String defaultPath(String articleId) =>
      'assets/help/_default/${articleId}_guide.md';

  static Future<String> loadMarkdown({
    required String organizationId,
    required String articleId,
  }) async {
    final candidates = <String>[
      if (organizationId.isNotEmpty)
        orgPath(organizationId, articleId),
      defaultPath(articleId),
    ];

    Object? lastError;
    for (final path in candidates) {
      try {
        return await rootBundle.loadString(path);
      } catch (e) {
        lastError = e;
      }
    }

    throw HelpAssetNotFoundException(
      organizationId: organizationId,
      articleId: articleId,
      cause: lastError,
    );
  }
}

class HelpAssetNotFoundException implements Exception {
  HelpAssetNotFoundException({
    required this.organizationId,
    required this.articleId,
    this.cause,
  });

  final String organizationId;
  final String articleId;
  final Object? cause;

  @override
  String toString() =>
      'No help guide found for org "$organizationId" article "$articleId"';
}
