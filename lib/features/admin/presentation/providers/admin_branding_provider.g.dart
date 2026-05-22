// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_branding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for the admin branding save operation.
///
/// `AsyncData(null)` = idle (initial or after a successful save).
/// `AsyncLoading`    = save in progress.
/// `AsyncError`      = save failed; message is in the error object.

@ProviderFor(AdminBranding)
final adminBrandingProvider = AdminBrandingProvider._();

/// State for the admin branding save operation.
///
/// `AsyncData(null)` = idle (initial or after a successful save).
/// `AsyncLoading`    = save in progress.
/// `AsyncError`      = save failed; message is in the error object.
final class AdminBrandingProvider
    extends $NotifierProvider<AdminBranding, AsyncValue<void>> {
  /// State for the admin branding save operation.
  ///
  /// `AsyncData(null)` = idle (initial or after a successful save).
  /// `AsyncLoading`    = save in progress.
  /// `AsyncError`      = save failed; message is in the error object.
  AdminBrandingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'adminBrandingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adminBrandingHash();

  @$internal
  @override
  AdminBranding create() => AdminBranding();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$adminBrandingHash() => r'c063fb3a1e8fa8a8ab8cba1120a69828142eadaa';

/// State for the admin branding save operation.
///
/// `AsyncData(null)` = idle (initial or after a successful save).
/// `AsyncLoading`    = save in progress.
/// `AsyncError`      = save failed; message is in the error object.

abstract class _$AdminBranding extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// State for the one-time "seed default categories" operation.

@ProviderFor(SeedCategories)
final seedCategoriesProvider = SeedCategoriesProvider._();

/// State for the one-time "seed default categories" operation.
final class SeedCategoriesProvider
    extends $NotifierProvider<SeedCategories, AsyncValue<void>> {
  /// State for the one-time "seed default categories" operation.
  SeedCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'seedCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$seedCategoriesHash();

  @$internal
  @override
  SeedCategories create() => SeedCategories();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$seedCategoriesHash() => r'414697bec98ed474ae23a64425e990dcd3c870a7';

/// State for the one-time "seed default categories" operation.

abstract class _$SeedCategories extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
