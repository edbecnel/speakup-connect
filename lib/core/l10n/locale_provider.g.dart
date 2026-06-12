// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists and exposes the active app [Locale] for ARB and help markdown.

@ProviderFor(AppLocale)
final appLocaleProvider = AppLocaleProvider._();

/// Persists and exposes the active app [Locale] for ARB and help markdown.
final class AppLocaleProvider extends $NotifierProvider<AppLocale, Locale> {
  /// Persists and exposes the active app [Locale] for ARB and help markdown.
  AppLocaleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appLocaleProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  AppLocale create() => AppLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$appLocaleHash() => r'190342fbb45323716f1ab9124680240e2abd1e0e';

/// Persists and exposes the active app [Locale] for ARB and help markdown.

abstract class _$AppLocale extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale, Locale>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Locale, Locale>, Locale, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
