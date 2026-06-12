import 'package:flutter/services.dart';

/// Resolves bundled markdown help assets per organization and locale.
///
/// Lookup order for non-English [languageCode] (e.g. `ceb`):
/// 1. `assets/help/orgs/{organizationId}/{articleId}_guide_{languageCode}.md`
/// 2. `assets/help/orgs/{organizationId}/{articleId}_guide.md`
/// 3. `assets/help/_default/{articleId}_guide_{languageCode}.md`
/// 4. `assets/help/_default/{articleId}_guide.md`
///
/// For English (`en`), steps 1–2 only (org then `_default`).
abstract class HelpAssetResolver {
  static String orgPath(
    String organizationId,
    String articleId, {
    String? languageCode,
  }) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/orgs/$organizationId/${articleId}_guide$suffix.md';
  }

  static String defaultPath(String articleId, {String? languageCode}) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/_default/${articleId}_guide$suffix.md';
  }

  static String _filenameSuffix(String? languageCode) {
    if (languageCode == null || languageCode == 'en') return '';
    return '_$languageCode';
  }

  static List<String> candidatePaths({
    required String organizationId,
    required String articleId,
    required String languageCode,
  }) {
    final paths = <String>[];

    void addPair(String? localizedCode) {
      if (organizationId.isNotEmpty) {
        paths.add(orgPath(organizationId, articleId, languageCode: localizedCode));
      }
      paths.add(defaultPath(articleId, languageCode: localizedCode));
    }

    if (languageCode != 'en') {
      addPair(languageCode);
    }
    addPair(null);

    return paths;
  }

  static Future<String> loadMarkdown({
    required String organizationId,
    required String articleId,
    required String languageCode,
  }) async {
    final candidates = candidatePaths(
      organizationId: organizationId,
      articleId: articleId,
      languageCode: languageCode,
    );

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
      languageCode: languageCode,
      cause: lastError,
    );
  }
}

class HelpAssetNotFoundException implements Exception {
  HelpAssetNotFoundException({
    required this.organizationId,
    required this.articleId,
    required this.languageCode,
    this.cause,
  });

  final String organizationId;
  final String articleId;
  final String languageCode;
  final Object? cause;

  @override
  String toString() =>
      'No help guide found for org "$organizationId" article "$articleId" '
      'language "$languageCode"';
}
