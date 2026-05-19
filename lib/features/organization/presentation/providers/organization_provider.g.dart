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
/// This is an [AsyncNotifier] so the UI can react to loading/error/data states.
/// The loaded config drives the app theme, branding, and feature availability.

@ProviderFor(OrganizationConfig)
final organizationConfigProvider = OrganizationConfigProvider._();

/// Loads and caches the active organization's configuration.
///
/// This is an [AsyncNotifier] so the UI can react to loading/error/data states.
/// The loaded config drives the app theme, branding, and feature availability.
final class OrganizationConfigProvider extends $AsyncNotifierProvider<
    OrganizationConfig, OrganizationConfigEntity> {
  /// Loads and caches the active organization's configuration.
  ///
  /// This is an [AsyncNotifier] so the UI can react to loading/error/data states.
  /// The loaded config drives the app theme, branding, and feature availability.
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
    r'd466dfc4912d78fb98828dbe446d5577bc516539';

/// Loads and caches the active organization's configuration.
///
/// This is an [AsyncNotifier] so the UI can react to loading/error/data states.
/// The loaded config drives the app theme, branding, and feature availability.

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
