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
/// 1. SharedPreferences cache is read first (~1 ms). If present, it is
///    returned immediately as the build value so the correct brand colors
///    are applied from the very first frame on subsequent launches.
/// 2. A live Firestore stream is started in the background (deferred with
///    Future.microtask so it never races the build return). Every update
///    refreshes both the UI state and the local cache.
/// 3. If Firestore fails and no cache exists, an offline placeholder is
///    returned so the app stays usable.

@ProviderFor(OrganizationConfig)
final organizationConfigProvider = OrganizationConfigProvider._();

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
final class OrganizationConfigProvider extends $AsyncNotifierProvider<
    OrganizationConfig, OrganizationConfigEntity> {
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
    r'98f6e5a09fdb8307d2bd21276dde1335ed6954c0';

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

abstract class _$OrganizationConfig
    extends $AsyncNotifier<OrganizationConfigEntity> {
  FutureOr<OrganizationConfigEntity> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<OrganizationConfigEntity>, OrganizationConfigEntity>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<OrganizationConfigEntity>,
            OrganizationConfigEntity>,
        AsyncValue<OrganizationConfigEntity>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
