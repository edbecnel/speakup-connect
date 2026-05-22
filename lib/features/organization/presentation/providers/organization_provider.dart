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
/// 1. SharedPreferences cache is read first (~1 ms). If present, it is
///    returned immediately as the build value so the correct brand colors
///    are applied from the very first frame on subsequent launches.
/// 2. A live Firestore stream is started in the background (deferred with
///    Future.microtask so it never races the build return). Every update
///    refreshes both the UI state and the local cache.
/// 3. If Firestore fails and no cache exists, an offline placeholder is
///    returned so the app stays usable.
@riverpod
class OrganizationConfig extends _$OrganizationConfig {
  StreamSubscription<OrganizationConfigEntity>? _configSub;

  @override
  Future<OrganizationConfigEntity> build() async {
    const orgId = AppConfig.defaultOrganizationId;
    final repository = ref.read(organizationRepositoryProvider);

    ref.onDispose(() => _configSub?.cancel());

    // ── 1. Read local cache (fast path) ───────────────────────────────────
    final cached = await OrgConfigCacheService.load();

    // ── 2. Start live Firestore stream (deferred so it never races build) ─
    // Future.microtask ensures the stream listener is attached only AFTER
    // build() has returned its initial value, preventing the Riverpod
    // "Only one task can be scheduled at a time" assertion that occurs when
    // state is mutated while the build future is still pending.
    Future.microtask(() {
      _configSub?.cancel();
      _configSub = repository.watchOrganizationConfig(orgId).listen(
        (config) {
          state = AsyncValue.data(config);
          OrgConfigCacheService.save(config);
        },
        onError: (Object err, StackTrace st) =>
            state = AsyncValue.error(err, st),
      );
    });

    // ── 3. Return initial value ────────────────────────────────────────────
    // Try Firestore first (may serve from its own offline cache instantly).
    try {
      final config = await repository.getOrganizationConfig(orgId);
      await OrgConfigCacheService.save(config);
      return config;
    } catch (_) {
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
      return OrganizationConfigModel.offline();
    }
  }
}
