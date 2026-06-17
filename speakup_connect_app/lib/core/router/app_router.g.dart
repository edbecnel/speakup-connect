// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [GoRouter] instance for the entire app.
///
/// The router watches [authStateChangesProvider] and [currentUserRoleProvider]
/// to determine whether to redirect to login or admin screens.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the [GoRouter] instance for the entire app.
///
/// The router watches [authStateChangesProvider] and [currentUserRoleProvider]
/// to determine whether to redirect to login or admin screens.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the [GoRouter] instance for the entire app.
  ///
  /// The router watches [authStateChangesProvider] and [currentUserRoleProvider]
  /// to determine whether to redirect to login or admin screens.
  AppRouterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appRouterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'db270f1b95cbdd3df892815d4da61d7ce7dad329';
