import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart'
    show reportRepositoryProvider;

part 'admin_branding_provider.g.dart';

/// State for the admin branding save operation.
///
/// `AsyncData(null)` = idle (initial or after a successful save).
/// `AsyncLoading`    = save in progress.
/// `AsyncError`      = save failed; message is in the error object.
@riverpod
class AdminBranding extends _$AdminBranding {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Persists [displayName], [primaryHex], and [secondaryHex] to both
  /// Firestore (so all connected clients update in real time) and to the
  /// local SharedPreferences cache (so this device shows correct colors
  /// instantly on the next app launch, without a Firestore round-trip).
  ///
  /// The [OrganizationConfig] provider's Firestore stream listener will
  /// automatically refresh the local cache when the document write
  /// propagates — no manual cache update is needed here.
  Future<void> save({
    required String displayName,
    required String primaryHex,
    required String secondaryHex,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(organizationRepositoryProvider);
      await repo.updateBranding(
        organizationId: AppConfig.defaultOrganizationId,
        displayName: displayName,
        primaryHex: primaryHex,
        secondaryHex: secondaryHex,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// State for the one-time "seed default categories" operation.
@riverpod
class SeedCategories extends _$SeedCategories {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> seed() async {
    state = const AsyncLoading();
    try {
      await ref
          .read(reportRepositoryProvider)
          .seedDefaultCategories(AppConfig.defaultOrganizationId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
