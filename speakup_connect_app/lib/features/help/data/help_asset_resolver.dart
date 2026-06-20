import 'package:flutter/services.dart';

/// Resolves bundled markdown help assets per organization and locale.
///
/// Lookup order for non-English [languageCode] (e.g. `ceb`):
/// 1. `assets/help/orgs/{organizationId}/{articleName}_{languageCode}.md`
/// 2. `assets/help/orgs/{organizationId}/{articleName}.md`
/// 3. `assets/help/school/{articleName}_{languageCode}.md`
/// 4. `assets/help/school/{articleName}.md`
/// 5. `assets/help/_default/{articleName}_{languageCode}.md`
/// 6. `assets/help/_default/{articleName}.md`
///
/// For English (`en`), the same order applies without locale suffix.
abstract class HelpAssetResolver {
  static String orgPath(String organizationId, String articleName, {String? languageCode}) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/orgs/$organizationId/$articleName$suffix.md';
  }

  static String schoolPath(String articleName, {String? languageCode}) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/school/$articleName$suffix.md';
  }

  static String defaultPath(String articleName, {String? languageCode}) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/_default/$articleName$suffix.md';
  }

  static String _filenameSuffix(String? languageCode) {
    if (languageCode == null || languageCode == 'en') return '';
    return '_$languageCode';
  }

  static List<String> candidatePaths({
    required String organizationId,
    required String articleName,
    required String languageCode,
  }) {
    final paths = <String>[];

    void addGroup(String? localizedCode) {
      if (organizationId.isNotEmpty) {
        paths.add(orgPath(organizationId, articleName, languageCode: localizedCode));
      }
      paths.add(schoolPath(articleName, languageCode: localizedCode));
      paths.add(defaultPath(articleName, languageCode: localizedCode));
    }

    if (languageCode != 'en') {
      addGroup(languageCode);
    }
    addGroup(null);

    return paths;
  }

  static Future<String> loadMarkdown({
    required String organizationId,
    required String articleName,
    required String languageCode,
  }) async {
    final candidates = candidatePaths(
      organizationId: organizationId,
      articleName: articleName,
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
      articleName: articleName,
      languageCode: languageCode,
      cause: lastError,
    );
  }
}

class HelpAssetNotFoundException implements Exception {
  HelpAssetNotFoundException({
    required this.organizationId,
    required this.articleName,
    required this.languageCode,
    this.cause,
  });

  final String organizationId;
  final String articleName;
  final String languageCode;
  final Object? cause;

  @override
  String toString() =>
      'No help article found for org "$organizationId" article "$articleName" '
      'language "$languageCode"';
}
