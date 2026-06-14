import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';

/// Remote calls for Translation Helper (org admins + manageTranslations).
class TranslationRemoteDataSource {
  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable(name)
          .call<Map<String, dynamic>>(data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionException(message: e.message ?? 'Permission denied');
      }
      throw DatabaseException(
        message: e.message ?? 'Translation request failed',
        code: e.code,
      );
    }
  }

  Map<String, dynamic> _orgPayload({
    required String organizationId,
    Map<String, dynamic>? extra,
  }) =>
      {
        'organizationId': organizationId,
        ...?extra,
      };

  Future<Map<String, dynamic>> getWorkspaceAccess({
    required String organizationId,
    String? targetLocale,
  }) =>
      _call('getTranslationWorkspaceAccess', _orgPayload(
        organizationId: organizationId,
        extra: {
          if (targetLocale != null) 'targetLocale': targetLocale,
        },
      ));

  Future<List<Map<String, dynamic>>> listEntries({
    required String organizationId,
    required String targetLocale,
    String? status,
    String? search,
  }) async {
    final data = await _call('listTranslationEntries', _orgPayload(
      organizationId: organizationId,
      extra: {
        'targetLocale': targetLocale,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    ));
    final entries = data['entries'];
    if (entries is! List) return [];
    final parsed = <Map<String, dynamic>>[];
    for (final item in entries) {
      if (item is Map) {
        parsed.add(Map<String, dynamic>.from(item));
      }
    }
    return parsed;
  }

  Future<void> saveEntry({
    required String organizationId,
    required String targetLocale,
    required String stringKey,
    String? targetValue,
    String? status,
    String? context,
    bool updateContext = false,
  }) =>
      _call('saveTranslationEntry', _orgPayload(
        organizationId: organizationId,
        extra: {
          'targetLocale': targetLocale,
          'stringKey': stringKey,
          if (targetValue != null) 'targetValue': targetValue,
          if (status != null) 'status': status,
          if (updateContext) 'context': context ?? '',
        },
      ));

  Future<void> draftEntry({
    required String organizationId,
    required String targetLocale,
    required String stringKey,
  }) =>
      _call('draftTranslation', _orgPayload(
        organizationId: organizationId,
        extra: {
          'targetLocale': targetLocale,
          'stringKey': stringKey,
        },
      ));

  Future<Map<String, dynamic>> batchDraft({
    required String organizationId,
    required String targetLocale,
  }) async {
    var totalSucceeded = 0;
    var totalProcessed = 0;
    final allResults = <Map<String, dynamic>>[];
    var hasMore = true;

    while (hasMore) {
      final data = await _call('batchDraftTranslations', _orgPayload(
        organizationId: organizationId,
        extra: {
          'targetLocale': targetLocale,
          'onlyMissing': true,
        },
      ));
      final total = (data['total'] as num?)?.toInt() ?? 0;
      final succeeded = (data['succeeded'] as num?)?.toInt() ?? 0;
      totalProcessed += total;
      totalSucceeded += succeeded;
      final results = data['results'];
      if (results is List) {
        allResults.addAll(results.cast<Map<String, dynamic>>());
      }
      if (total == 0) break;
      hasMore = data['hasMore'] == true;
    }

    return {
      'ok': true,
      'total': totalProcessed,
      'succeeded': totalSucceeded,
      'results': allResults,
    };
  }

  Future<Map<String, dynamic>> exportArb({
    required String organizationId,
    required String targetLocale,
  }) =>
      _call('exportTranslationArb', _orgPayload(
        organizationId: organizationId,
        extra: {
          'targetLocale': targetLocale,
          'includeEnglishFallback': true,
        },
      ));

  Future<List<Map<String, dynamic>>> listScreens({
    required String organizationId,
  }) async {
    final data = await _call('listTranslationScreens', _orgPayload(
      organizationId: organizationId,
    ));
    final screens = data['screens'];
    if (screens is! List) return [];
    return screens
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> createScreen({
    required String organizationId,
    required String name,
  }) async {
    final data = await _call('createTranslationScreen', _orgPayload(
      organizationId: organizationId,
      extra: {'name': name},
    ));
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateScreen({
    required String organizationId,
    required String screenId,
    String? name,
    String? assignedRoute,
    bool unassignRoute = false,
    bool? badgeEnabled,
  }) async {
    final extra = <String, dynamic>{'screenId': screenId};
    if (name != null) extra['name'] = name;
    if (unassignRoute) {
      extra['assignedRoute'] = null;
    } else if (assignedRoute != null) {
      extra['assignedRoute'] = assignedRoute;
    }
    if (badgeEnabled != null) extra['badgeEnabled'] = badgeEnabled;
    final data = await _call('updateTranslationScreen', _orgPayload(
      organizationId: organizationId,
      extra: extra,
    ));
    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteScreen({
    required String organizationId,
    required String screenId,
  }) =>
      _call('deleteTranslationScreen', _orgPayload(
        organizationId: organizationId,
        extra: {'screenId': screenId},
      ));
}
