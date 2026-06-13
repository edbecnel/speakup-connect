import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// Locale used for Material / Cupertino / widget chrome when Flutter has no
/// built-in translations (e.g. `ceb` for app ARB strings only).
const kMaterialFallbackLocale = Locale('en', 'US');

/// App + Flutter global delegates. Material/Cupertino/Widgets fall back to
/// English for locales Flutter does not ship (prevents BottomNavigationBar
/// and other Material widgets from crashing on partial locales like Cebuano).
const List<LocalizationsDelegate<dynamic>> kAppLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  FallbackMaterialLocalizationsDelegate(),
  FallbackCupertinoLocalizationsDelegate(),
  FallbackWidgetsLocalizationsDelegate(),
];

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    const delegate = GlobalMaterialLocalizations.delegate;
    if (delegate.isSupported(locale)) {
      return delegate.load(locale);
    }
    return delegate.load(kMaterialFallbackLocale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    const delegate = GlobalCupertinoLocalizations.delegate;
    if (delegate.isSupported(locale)) {
      return delegate.load(locale);
    }
    return delegate.load(kMaterialFallbackLocale);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    const delegate = GlobalWidgetsLocalizations.delegate;
    if (delegate.isSupported(locale)) {
      return delegate.load(locale);
    }
    return delegate.load(kMaterialFallbackLocale);
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}
