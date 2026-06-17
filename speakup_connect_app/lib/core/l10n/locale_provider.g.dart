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

String _$appLocaleHash() => r'e11656fe2bbbe1ec972c875c03835c5da6ceeeab';

/// Persists and exposes the active app [Locale] for ARB and help markdown.

abstract class _$AppLocale extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale, Locale>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Locale, Locale>, Locale, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
