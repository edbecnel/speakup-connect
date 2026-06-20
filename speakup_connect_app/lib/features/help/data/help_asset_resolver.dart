import 'dart:convert';

import 'package:flutter/services.dart';

/// Resolves bundled markdown help assets per organization type and locale.
///
/// Lookup order for non-English [languageCode] (e.g. `ceb`):
/// 1. `assets/help/{organizationType}/{articleName}_{languageCode}.md`
/// 2. `assets/help/{organizationType}/{articleName}.md`
/// 3. `assets/help/_default/{articleName}_{languageCode}.md`
/// 4. `assets/help/_default/{articleName}.md`
///
/// If [organizationType] is null/empty, resolution uses `_default` only.
abstract class HelpAssetResolver {
  static Set<String>? _assetManifestKeysCache;

  static String organizationTypePath(
    String organizationType,
    String articleName, {
    String? languageCode,
  }) {
    final suffix = _filenameSuffix(languageCode);
    return 'assets/help/$organizationType/$articleName$suffix.md';
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
    String? organizationType,
    required String articleName,
    required String languageCode,
  }) {
    final paths = <String>[];
    final normalizedOrgType = _normalizeOrganizationType(organizationType);

    void addGroup(String? localizedCode) {
      if (normalizedOrgType != null) {
        paths.add(
          organizationTypePath(
            normalizedOrgType,
            articleName,
            languageCode: localizedCode,
          ),
        );
      }
      paths.add(defaultPath(articleName, languageCode: localizedCode));
    }

    if (languageCode != 'en') {
      addGroup(languageCode);
    }
    addGroup(null);

    return paths;
  }

  static String? _normalizeOrganizationType(String? organizationType) {
    final normalized = organizationType?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static Future<String> loadMarkdown({
    String? organizationType,
    required String articleName,
    required String languageCode,
  }) async {
    final candidates = candidatePaths(
      organizationType: organizationType,
      articleName: articleName,
      languageCode: languageCode,
    );
    final attempted = <String>[];

    Object? lastError;
    for (final path in candidates) {
      try {
        attempted.add(path);
        return await _loadStringWithCaseInsensitiveFallback(path);
      } catch (e) {
        lastError = e;
      }
    }

    throw HelpAssetNotFoundException(
      organizationType: organizationType,
      articleName: articleName,
      languageCode: languageCode,
      attemptedCandidates: attempted,
      cause: lastError,
    );
  }

  static Future<String> _loadStringWithCaseInsensitiveFallback(String path) async {
    Object? originalError;
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      originalError = e;
    }

    final keys = await _assetManifestKeys();
    final matched = keys.lookup(path) ??
        keys.firstWhere(
          (k) => k.toLowerCase() == path.toLowerCase(),
          orElse: () => '',
        );
    if (matched.isEmpty) {
      throw originalError ?? StateError('Asset not found: $path');
    }
    return rootBundle.loadString(matched);
  }

  static Future<Set<String>> _assetManifestKeys() async {
    final cached = _assetManifestKeysCache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('AssetManifest.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      _assetManifestKeysCache = <String>{};
      return _assetManifestKeysCache!;
    }

    _assetManifestKeysCache = decoded.keys.toSet();
    return _assetManifestKeysCache!;
  }
}

class HelpAssetNotFoundException implements Exception {
  HelpAssetNotFoundException({
    this.organizationType,
    required this.articleName,
    required this.languageCode,
    this.attemptedCandidates = const <String>[],
    this.cause,
  });

  final String? organizationType;
  final String articleName;
  final String languageCode;
  final List<String> attemptedCandidates;
  final Object? cause;

  @override
  String toString() =>
      'No help article found for orgType "${organizationType ?? '_default'}" article "$articleName" '
      'language "$languageCode". Tried: ${attemptedCandidates.join(', ')}';
}
