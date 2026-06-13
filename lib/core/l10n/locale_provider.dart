import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

const _kPreferredLanguageKey = 'preferred_language_code';

/// Supported UI language codes bundled in the app (phase 1b).
const supportedAppLanguageCodes = ['en', 'ceb'];

/// Native display names for language pickers — not localized so every option
/// stays recognizable regardless of the active UI locale.
///
/// Required when adding a language: update [supportedAppLanguageCodes] and this
/// map together. Do not use ARB for picker option labels — see
/// docs/INTERNATIONALIZATION.md §6.1.
const kLanguageNativeLabels = <String, String>{
  'en': 'English',
  'ceb': 'Bisaya / Cebuano',
};

/// Persists and exposes the active app [Locale] for ARB and help markdown.
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  Locale build() {
    _loadSaved();
    return const Locale('en', 'US');
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPreferredLanguageKey);
      if (saved != null && supportedAppLanguageCodes.contains(saved)) {
        state = localeFromLanguageCode(saved);
      }
    } catch (_) {
      await resetToEnglish();
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (!supportedAppLanguageCodes.contains(code)) return;
    final previous = state;
    try {
      state = localeFromLanguageCode(code);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPreferredLanguageKey, code);
    } catch (_) {
      state = previous;
      await resetToEnglish();
      rethrow;
    }
  }

  /// Clears a broken saved preference and restores US English.
  Future<void> resetToEnglish() async {
    state = const Locale('en', 'US');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredLanguageKey, 'en');
  }
}

/// Maps a BCP 47 language code to a Flutter [Locale].
Locale localeFromLanguageCode(String code) => switch (code) {
      'ceb' => const Locale('ceb'),
      _ => const Locale('en', 'US'),
    };

/// Short language code for help markdown filenames (`member_guide_ceb.md`).
String helpLanguageCodeForLocale(Locale locale) {
  final code = locale.languageCode;
  if (code == 'en') return 'en';
  if (supportedAppLanguageCodes.contains(code)) return code;
  return 'en';
}