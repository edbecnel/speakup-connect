import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/translations/data/datasources/translation_remote_datasource.dart';

final translationRemoteDataSourceProvider =
    Provider<TranslationRemoteDataSource>(
  (ref) => TranslationRemoteDataSource(),
);

/// Org admins or users with [AppPermission.manageTranslations].
final canManageTranslationsProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  return ref.watch(hasPermissionProvider(AppPermission.manageTranslations));
});

class TranslationWorkspaceState {
  const TranslationWorkspaceState({
    required this.locale,
    required this.allowedLocales,
    required this.entries,
    required this.canExportArb,
    required this.canBatchAi,
  });

  final String locale;
  final List<String> allowedLocales;
  final List<Map<String, dynamic>> entries;
  final bool canExportArb;
  final bool canBatchAi;
}

class TranslationWorkspaceNotifier
    extends AsyncNotifier<TranslationWorkspaceState> {
  String _locale = 'ceb';
  String _search = '';

  String _resolveOrganizationId() {
    final profileOrg = ref.read(userProfileProvider).value?.organizationId;
    if (profileOrg != null && profileOrg.isNotEmpty) return profileOrg;
    return AppConfig.defaultOrganizationId;
  }

  @override
  Future<TranslationWorkspaceState> build() async {
    final organizationId = _resolveOrganizationId();
    if (organizationId.isEmpty) {
      throw StateError(
        'Organization is not configured for this app build.',
      );
    }

    final ds = ref.read(translationRemoteDataSourceProvider);
    final access = await ds.getWorkspaceAccess(
      organizationId: organizationId,
      targetLocale: _locale,
    );
    final allowed = (access['allowedLocales'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((c) => c != 'en')
            .toList() ??
        supportedAppLanguageCodes.where((c) => c != 'en').toList();

    if (allowed.isEmpty) {
      throw StateError(
        'No translation locales are enabled for this organization. '
        'Ask an admin to add Cebuano or Tagalog under Organization Settings.',
      );
    }

    if (!allowed.contains(_locale)) {
      _locale = allowed.first;
    }

    final entries = await ds.listEntries(
      organizationId: organizationId,
      targetLocale: _locale,
      search: _search.isEmpty ? null : _search,
    );

    return TranslationWorkspaceState(
      locale: _locale,
      allowedLocales: allowed,
      entries: entries,
      canExportArb: access['canExportArb'] == true,
      canBatchAi: access['canBatchAi'] == true,
    );
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    ref.invalidateSelf();
    await future;
  }

  Future<void> setSearch(String query) async {
    _search = query;
    ref.invalidateSelf();
    await future;
  }

  Future<void> save({
    required String stringKey,
    required String targetValue,
    required bool approve,
  }) async {
    final ds = ref.read(translationRemoteDataSourceProvider);
    await ds.saveEntry(
      organizationId: _resolveOrganizationId(),
      targetLocale: _locale,
      stringKey: stringKey,
      targetValue: targetValue,
      status: approve ? 'approved' : 'in_review',
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> draft(String stringKey) async {
    final ds = ref.read(translationRemoteDataSourceProvider);
    await ds.draftEntry(
      organizationId: _resolveOrganizationId(),
      targetLocale: _locale,
      stringKey: stringKey,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<Map<String, dynamic>> batchDraft() async {
    final ds = ref.read(translationRemoteDataSourceProvider);
    final result = await ds.batchDraft(
      organizationId: _resolveOrganizationId(),
      targetLocale: _locale,
    );
    ref.invalidateSelf();
    await future;
    return result;
  }

  Future<Map<String, dynamic>> exportArb() async {
    final ds = ref.read(translationRemoteDataSourceProvider);
    return ds.exportArb(
      organizationId: _resolveOrganizationId(),
      targetLocale: _locale,
    );
  }
}

final translationWorkspaceProvider = AsyncNotifierProvider<
    TranslationWorkspaceNotifier, TranslationWorkspaceState>(
  TranslationWorkspaceNotifier.new,
);
