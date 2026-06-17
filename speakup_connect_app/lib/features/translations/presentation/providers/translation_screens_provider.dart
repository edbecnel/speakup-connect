import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/translation_assignable_routes.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/translations/data/datasources/translation_remote_datasource.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';

class TranslationScreenEntity {
  const TranslationScreenEntity({
    required this.screenId,
    required this.name,
    this.assignedRoute,
    this.assignedRouteLabel,
    this.badgeEnabled = false,
  });

  final String screenId;
  final String name;
  final String? assignedRoute;
  final String? assignedRouteLabel;
  final bool badgeEnabled;

  factory TranslationScreenEntity.fromMap(Map<String, dynamic> map) {
    return TranslationScreenEntity(
      screenId: map['screenId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      assignedRoute: map['assignedRoute'] as String?,
      assignedRouteLabel: map['assignedRouteLabel'] as String?,
      badgeEnabled: map['badgeEnabled'] == true,
    );
  }
}

class TranslationScreensState {
  const TranslationScreensState({
    required this.screens,
    required this.assignableRoutes,
  });

  final List<TranslationScreenEntity> screens;
  final List<TranslationAssignableRoute> assignableRoutes;

  TranslationScreenEntity? screenForRoute(String route) {
    for (final screen in screens) {
      if (screen.assignedRoute == route) return screen;
    }
    return null;
  }

  List<TranslationScreenEntity> availableForRoute(String route) {
    final current = screenForRoute(route);
    return screens
        .where(
          (s) => s.assignedRoute == null || s.screenId == current?.screenId,
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<TranslationScreenEntity> sortedNames() {
    final copy = [...screens]..sort((a, b) => a.name.compareTo(b.name));
    return copy;
  }

  /// Routes where in-app translation mode shows edit badges.
  Set<String> get badgeEnabledRoutes => screens
      .where((s) => s.badgeEnabled && s.assignedRoute != null)
      .map((s) => s.assignedRoute!)
      .toSet();
}

class TranslationScreensNotifier
    extends AsyncNotifier<TranslationScreensState> {
  String _resolveOrganizationId() {
    final profileOrg = ref.read(userProfileProvider).value?.organizationId;
    if (profileOrg != null && profileOrg.isNotEmpty) return profileOrg;
    return AppConfig.defaultOrganizationId;
  }

  TranslationRemoteDataSource get _ds =>
      ref.read(translationRemoteDataSourceProvider);

  @override
  Future<TranslationScreensState> build() async {
    final organizationId = _resolveOrganizationId();
    final raw = await _ds.listScreens(organizationId: organizationId);
    final screens = raw.map(TranslationScreenEntity.fromMap).toList();
    return TranslationScreensState(
      screens: screens,
      assignableRoutes: kTranslationAssignableRoutes,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Map<String, dynamic>> seedFromContexts({
    bool assignRoutes = true,
  }) async {
    final result = await _ds.seedScreensFromContexts(
      organizationId: _resolveOrganizationId(),
      assignRoutes: assignRoutes,
    );
    await refresh();
    return result;
  }

  Future<void> create(String name) async {
    await _ds.createScreen(
      organizationId: _resolveOrganizationId(),
      name: name,
    );
    await refresh();
  }

  Future<int> rename({
    required String screenId,
    required String name,
  }) async {
    final result = await _ds.updateScreen(
      organizationId: _resolveOrganizationId(),
      screenId: screenId,
      name: name,
    );
    await refresh();
    return (result['contextsRenamed'] as num?)?.toInt() ?? 0;
  }

  Future<void> assignRoute({
    required String screenId,
    required String route,
  }) async {
    await _ds.updateScreen(
      organizationId: _resolveOrganizationId(),
      screenId: screenId,
      assignedRoute: route,
    );
    await refresh();
  }

  Future<void> unassignRoute(String screenId) async {
    await _ds.updateScreen(
      organizationId: _resolveOrganizationId(),
      screenId: screenId,
      unassignRoute: true,
    );
    await refresh();
  }

  Future<void> setBadgeEnabled({
    required String screenId,
    required bool enabled,
  }) async {
    await _ds.updateScreen(
      organizationId: _resolveOrganizationId(),
      screenId: screenId,
      badgeEnabled: enabled,
    );
    await refresh();
  }

  Future<void> delete(String screenId) async {
    await _ds.deleteScreen(
      organizationId: _resolveOrganizationId(),
      screenId: screenId,
    );
    await refresh();
  }
}

final translationScreensProvider = AsyncNotifierProvider<
    TranslationScreensNotifier, TranslationScreensState>(
  TranslationScreensNotifier.new,
);

/// Routes that show translation edit badges during in-app translation mode.
final translationBadgeEnabledRoutesProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(translationScreensProvider);
  return async.asData?.value.badgeEnabledRoutes ?? const {};
});