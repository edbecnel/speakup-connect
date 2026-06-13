import 'package:flutter/material.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

export 'form_validators.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
