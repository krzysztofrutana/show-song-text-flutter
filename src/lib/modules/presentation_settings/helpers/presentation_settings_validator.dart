import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

mixin PresentationSettingsValidator {
  String? validateFontSize(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.fontSizeMustBeGreaterThan5;
    }
    if (int.tryParse(value) == null) {
      return localizations.theValueEnteredIsNotNumber;
    }

    if (int.parse(value) < 5) {
      return localizations.fontSizeMustBeGreaterThan5;
    }

    return null;
  }
}
