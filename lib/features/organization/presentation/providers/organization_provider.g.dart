// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationRepository)
final organizationRepositoryProvider = OrganizationRepositoryProvider._();

final class OrganizationRepositoryProvider extends $FunctionalProvider<
    OrganizationRepository,
    OrganizationRepository,
    OrganizationRepository> with $Provider<OrganizationRepository> {
  OrganizationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrganizationRepository create(Ref ref) {
    return organizationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationRepository>(value),
    );
  }
}

String _$organizationRepositoryHash() =>
    r'4216df26817735b0f944ffe772e3e4bef1a30528';

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

@ProviderFor(OrganizationConfig)
final organizationConfigProvider = OrganizationConfigProvider._();

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
final class OrganizationConfigProvider extends $AsyncNotifierProvider<
    OrganizationConfig, OrganizationConfigEntity> {
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
  OrganizationConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationConfigHash();

  @$internal
  @override
  OrganizationConfig create() => OrganizationConfig();
}

String _$organizationConfigHash() =>
    r'2f0e7eb7bdd645bfc72aecc6e3b770b0cbf2e598';

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

abstract class _$OrganizationConfig
    extends $AsyncNotifier<OrganizationConfigEntity> {
  FutureOr<OrganizationConfigEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<OrganizationConfigEntity>, OrganizationConfigEntity>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<OrganizationConfigEntity>,
            OrganizationConfigEntity>,
        AsyncValue<OrganizationConfigEntity>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
