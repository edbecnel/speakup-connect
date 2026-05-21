import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/organization/data/models/organization_config_model.dart';
import 'package:speakup_connect/features/organization/data/repositories/organization_repository_impl.dart';
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
/// After the initial load, a Firestore snapshot listener is kept alive for
/// the lifetime of this provider. Any time a super_admin writes new theme
/// fields to the org document, all widgets watching this provider automatically
/// rebuild — the new colors propagate to every connected client in real time
/// without an app restart.
@riverpod
class OrganizationConfig extends _$OrganizationConfig {
  StreamSubscription<OrganizationConfigEntity>? _configSub;

  @override
  Future<OrganizationConfigEntity> build() async {
    const orgId = AppConfig.defaultOrganizationId;
    final repository = ref.read(organizationRepositoryProvider);

    // Cancel any previous subscription when this provider is rebuilt or
    // disposed (e.g., after a hot-reload or when the ProviderScope is
    // destroyed).
    ref.onDispose(() => _configSub?.cancel());

    // Set up a live Firestore listener. Any subsequent document change
    // (e.g., admin updating primaryColor) pushes a new AsyncValue.data to
    // all watchers, which triggers MaterialApp to rebuild with the new theme.
    _configSub?.cancel();
    _configSub = repository
        .watchOrganizationConfig(orgId)
        .listen(
          (config) => state = AsyncValue.data(config),
          onError: (Object err, StackTrace st) =>
              state = AsyncValue.error(err, st),
        );

    // Perform the initial fetch (may resolve faster than the first snapshot
    // event on slow connections).
    try {
      return await repository.getOrganizationConfig(orgId);
    } catch (_) {
      // During development / if Firestore is unreachable, fall back to the
      // hard-coded MONHS dev preset so the app remains usable.
      return OrganizationConfigModel.monhsDev();
    }
  }
}
