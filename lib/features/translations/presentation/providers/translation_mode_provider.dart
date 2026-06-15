import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/translations/domain/translation_session_edit.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';

class TranslationModeState {
  const TranslationModeState({
    this.isActive = false,
    this.targetLocale = 'ceb',
    this.previewLocale = 'en',
    this.previousLocaleCode = 'en',
    this.isLoadingEntries = false,
    this.entryCache = const {},
    this.sessionEdits = const {},
  });

  const TranslationModeState.inactive()
      : isActive = false,
        targetLocale = 'ceb',
        previewLocale = 'en',
        previousLocaleCode = 'en',
        isLoadingEntries = false,
        entryCache = const {},
        sessionEdits = const {};

  final bool isActive;
  /// Locale being translated (e.g. `ceb`).
  final String targetLocale;
  /// Active UI preview — `en` for source meaning or [targetLocale] for translation preview.
  final String previewLocale;
  final String previousLocaleCode;
  final bool isLoadingEntries;
  final Map<String, Map<String, dynamic>> entryCache;
  final Map<String, TranslationSessionEdit> sessionEdits;

  int get pendingCount => sessionEdits.length;

  bool get isPreviewingTarget => previewLocale == targetLocale;

  bool get hasUnsavedEdits =>
      sessionEdits.values.any((edit) => edit.isChanged || edit.approve);

  String displayText(String stringKey, String arbText) {
    if (!isPreviewingTarget) return arbText;
    final edit = sessionEdits[stringKey];
    if (edit != null) return edit.targetValue;
    return arbText;
  }

  String sourceForKey(String stringKey, {String fallback = ''}) {
    final entry = entryCache[stringKey];
    final source = entry?['sourceValue'] as String?;
    if (source != null && source.trim().isNotEmpty) return source;
    return fallback;
  }

  String baselineTarget(String stringKey, {String fallback = ''}) {
    final edit = sessionEdits[stringKey];
    if (edit != null) return edit.originalTarget;

    final entry = entryCache[stringKey];
    final target = entry?['targetValue'] as String?;
    if (target != null && target.trim().isNotEmpty) return target;
    final draft = entry?['aiDraft'] as String?;
    if (draft != null && draft.trim().isNotEmpty) return draft;
    return fallback;
  }

  TranslationModeState copyWith({
    bool? isActive,
    String? targetLocale,
    String? previewLocale,
    String? previousLocaleCode,
    bool? isLoadingEntries,
    Map<String, Map<String, dynamic>>? entryCache,
    Map<String, TranslationSessionEdit>? sessionEdits,
  }) =>
      TranslationModeState(
        isActive: isActive ?? this.isActive,
        targetLocale: targetLocale ?? this.targetLocale,
        previewLocale: previewLocale ?? this.previewLocale,
        previousLocaleCode: previousLocaleCode ?? this.previousLocaleCode,
        isLoadingEntries: isLoadingEntries ?? this.isLoadingEntries,
        entryCache: entryCache ?? this.entryCache,
        sessionEdits: sessionEdits ?? this.sessionEdits,
      );
}

class TranslationModeNotifier extends Notifier<TranslationModeState> {
  /// Best-effort route learning while translators edit strings in-context.
  /// Stored outside state so it doesn't trigger rebuilds.
  final Map<String, String> _capturedRouteByKey = {};

  String _resolveOrganizationId() {
    final profileOrg = ref.read(userProfileProvider).value?.organizationId;
    if (profileOrg != null && profileOrg.isNotEmpty) return profileOrg;
    return AppConfig.defaultOrganizationId;
  }

  @override
  TranslationModeState build() => const TranslationModeState.inactive();

  Future<void> enterMode(String targetLocale) async {
    if (!ref.read(canManageTranslationsProvider)) {
      throw StateError('Translation mode requires translation permissions.');
    }

    final previous = ref.read(appLocaleProvider).languageCode;
    // Start in English so translators see source meaning in context.
    await ref.read(appLocaleProvider.notifier).setLanguageCode('en');

    state = TranslationModeState(
      isActive: true,
      targetLocale: targetLocale,
      previousLocaleCode: previous,
      isLoadingEntries: true,
    );
    _capturedRouteByKey.clear();

    try {
      await ref.read(translationScreensProvider.notifier).refresh();
      final ds = ref.read(translationRemoteDataSourceProvider);
      final entries = await ds.listEntries(
        organizationId: _resolveOrganizationId(),
        targetLocale: targetLocale,
      );
      final cache = <String, Map<String, dynamic>>{};
      for (final entry in entries) {
        final key = entry['stringKey'] as String?;
        if (key != null && key.isNotEmpty) {
          cache[key] = entry;
        }
      }
      state = state.copyWith(
        isLoadingEntries: false,
        entryCache: cache,
      );
    } catch (_) {
      state = state.copyWith(isLoadingEntries: false);
      rethrow;
    }
  }

  Future<void> setPreviewLocale(String localeCode) async {
    if (!state.isActive) return;
    if (localeCode != 'en' && localeCode != state.targetLocale) return;

    if (localeCode == state.previewLocale) return;

    await ref.read(appLocaleProvider.notifier).setLanguageCode(localeCode);
    state = state.copyWith(previewLocale: localeCode);
  }

  Future<void> exitMode() async {
    if (!state.isActive) return;

    final restore = state.previousLocaleCode;
    state = const TranslationModeState.inactive();
    _capturedRouteByKey.clear();

    if (restore != ref.read(appLocaleProvider).languageCode) {
      await ref.read(appLocaleProvider.notifier).setLanguageCode(restore);
    }
  }

  /// Records the current route for this key so the backend can learn it.
  ///
  /// This is intentionally best-effort: it avoids duplicate writes and does not
  /// block the UI if the network call fails.
  void captureRouteForKey({
    required String stringKey,
    required String route,
  }) {
    if (!state.isActive) return;
    final trimmed = route.trim();
    if (trimmed.isEmpty) return;

    final previous = _capturedRouteByKey[stringKey];
    if (previous == trimmed) return;
    _capturedRouteByKey[stringKey] = trimmed;

    unawaited(_persistCapturedRoute(stringKey: stringKey, route: trimmed));
  }

  Future<void> _persistCapturedRoute({
    required String stringKey,
    required String route,
  }) async {
    try {
      final ds = ref.read(translationRemoteDataSourceProvider);
      await ds.saveEntry(
        organizationId: _resolveOrganizationId(),
        targetLocale: state.targetLocale,
        stringKey: stringKey,
        route: route,
        updateRoute: true,
      );
    } catch (_) {
      // Best-effort. If this fails, we can learn it again on a later edit.
    }
  }

  void queueEdit({
    required String stringKey,
    required String sourceValue,
    required String originalTarget,
    required String targetValue,
    bool approve = false,
  }) {
    if (!state.isActive) return;

    final trimmed = targetValue.trim();
    if (trimmed.isEmpty) return;

    final unchanged =
        trimmed == originalTarget.trim() && !approve;
    final updated = Map<String, TranslationSessionEdit>.from(state.sessionEdits);

    if (unchanged) {
      updated.remove(stringKey);
    } else {
      updated[stringKey] = TranslationSessionEdit(
        stringKey: stringKey,
        sourceValue: sourceValue,
        originalTarget: originalTarget,
        targetValue: trimmed,
        approve: approve,
      );
    }

    state = state.copyWith(sessionEdits: updated);
  }

  void updateSessionEdit(String stringKey, TranslationSessionEdit edit) {
    if (!state.isActive) return;
    final updated = Map<String, TranslationSessionEdit>.from(state.sessionEdits);
    if (!edit.isChanged && !edit.approve) {
      updated.remove(stringKey);
    } else {
      updated[stringKey] = edit;
    }
    state = state.copyWith(sessionEdits: updated);
  }

  void removeSessionEdit(String stringKey) {
    if (!state.sessionEdits.containsKey(stringKey)) return;
    final updated = Map<String, TranslationSessionEdit>.from(state.sessionEdits)
      ..remove(stringKey);
    state = state.copyWith(sessionEdits: updated);
  }

  Future<int> commitSession() async {
    if (!state.isActive || state.sessionEdits.isEmpty) return 0;

    final ds = ref.read(translationRemoteDataSourceProvider);
    final organizationId = _resolveOrganizationId();
    var saved = 0;

    for (final edit in state.sessionEdits.values) {
      await ds.saveEntry(
        organizationId: organizationId,
        targetLocale: state.targetLocale,
        stringKey: edit.stringKey,
        targetValue: edit.targetValue,
        status: edit.approve ? 'approved' : 'in_review',
      );
      saved++;
    }

    state = state.copyWith(sessionEdits: {});
    return saved;
  }
}

final translationModeProvider =
    NotifierProvider<TranslationModeNotifier, TranslationModeState>(
  TranslationModeNotifier.new,
);
