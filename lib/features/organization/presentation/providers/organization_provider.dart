import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/organization/data/models/organization_config_model.dart';
import 'package:speakup_connect/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:speakup_connect/features/organization/data/services/org_config_cache_service.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/organization_repository.dart';

part 'organization_provider.g.dart';

// --- Infrastructure Providers ---

@riverpod
OrganizationRepository organizationRepository(Ref ref) {
  return OrganizationRepositoryImpl(FirebaseFirestore.instance);
}

// --- Organization Config Provider ---

/// Loads and caches the active organization's configuration.
///
/// Startup strategy:
/// 1. SharedPreferences cache is read first (~1 ms) and set as the immediate
///    state, so the correct brand colors appear from frame 1 on subsequent
///    launches — no loading flash.
/// 2. A live Firestore listener is then started. Every time the org document
///    changes, all widgets rebuild with the new config in real time.
/// 3. After each Firestore load the cache is refreshed, so the next launch
///    is always up to date.
@riverpod
class OrganizationConfig extends _$OrganizationConfig {
  StreamSubscription<OrganizationConfigEntity>? _configSub;

  @override
  Future<OrganizationConfigEntity> build() async {
    const orgId = AppConfig.defaultOrganizationId;
    final repository = ref.read(organizationRepositoryProvider);

    ref.onDispose(() => _configSub?.cancel());

    // ── 1. Warm up from local cache (fast path) ────────────────────────────
    // SharedPreferences.getInstance() is cached after the first call and
    // typically resolves in < 1 ms on device. If branding data is present we
    // immediately publish it as the current state so the MaterialApp can
    // apply the correct theme before the Firestore round-trip completes.
    final cached = await OrgConfigCacheService.load();
    if (cached != null) {
      final cachedConfig = OrganizationConfigModel(
        organizationId: orgId,
        displayName: cached.displayName,
        type: OrganizationType.school, // non-branding field; overwritten below
        themeColors: cached.colors,
        allowAnonymousReports: true,
        reportCodePrefix: 'ORG',
      );
      // Set state immediately — widgets watching this provider will rebuild
      // with the cached branding before Firestore data arrives.
      state = AsyncValue.data(cachedConfig);
    }

    // ── 2. Live Firestore listener (real-time updates) ─────────────────────
    _configSub?.cancel();
    _configSub = repository.watchOrganizationConfig(orgId).listen(
      (config) {
        state = AsyncValue.data(config);
        // Keep the local cache fresh so the next launch loads instantly.
        OrgConfigCacheService.save(config);
      },
      onError: (Object err, StackTrace st) =>
          state = AsyncValue.error(err, st),
    );

    // ── 3. Initial fetch (may use Firestore offline cache) ─────────────────
    try {
      final config = await repository.getOrganizationConfig(orgId);
      await OrgConfigCacheService.save(config);
      return config;
    } catch (_) {
      // If Firestore is unreachable but we have a cached config, use it.
      if (cached != null) {
        return OrganizationConfigModel(
          organizationId: orgId,
          displayName: cached.displayName,
          type: OrganizationType.school,
          themeColors: cached.colors,
          allowAnonymousReports: true,
          reportCodePrefix: 'ORG',
        );
      }
      // Last resort: return an offline placeholder so the app stays usable.
      // The org ID and default colors come from AppConfig — the single place
      // in the codebase where deployment-specific values are configured.
      return OrganizationConfigModel.offline();
    }
  }
}
