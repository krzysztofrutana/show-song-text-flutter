import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

class LocalizationManager {
  static final LocalizationManager instance = LocalizationManager._();
  LocalizationManager._();

  late AppLocalizations _localization;

  AppLocalizations get appLocalization => _localization;

  void setLocalization(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
  }
}
