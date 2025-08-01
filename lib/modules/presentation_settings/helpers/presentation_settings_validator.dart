import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

mixin PresentationSettingsValidator {
  String? validateFontSize(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationManager
          .instance.appLocalization.fontSizeMustBeGreaterThan5;
    }
    if (int.tryParse(value) == null) {
      return LocalizationManager
          .instance.appLocalization.theValueEnteredIsNotNumber;
    }

    if (int.parse(value) < 5) {
      return LocalizationManager
          .instance.appLocalization.fontSizeMustBeGreaterThan5;
    }

    return null;
  }
}
