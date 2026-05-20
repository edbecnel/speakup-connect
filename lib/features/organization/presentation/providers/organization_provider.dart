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
/// This is an [AsyncNotifier] so the UI can react to loading/error/data states.
/// The loaded config drives the app theme, branding, and feature availability.
@riverpod
class OrganizationConfig extends _$OrganizationConfig {
  @override
  Future<OrganizationConfigEntity> build() async {
    // In a full multi-tenant app, the org ID would be determined by
    // deep link, stored preference, or org selection screen.
    // For the MONHS pilot, we use the default org ID from AppConfig.
    const orgId = AppConfig.defaultOrganizationId;
    final repository = ref.read(organizationRepositoryProvider);

    try {
      return await repository.getOrganizationConfig(orgId);
    } catch (_) {
      // During development, fall back to the dev config if Firestore is
      // unreachable (e.g., emulator not running).
      return OrganizationConfigModel.monhsDev();
    }
  }
}
