import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

mixin SongEditValidator {
  String? validateAuthor(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.authorIsRequired;
    }

    return null;
  }

  String? validateTitle(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.titleIsRequired;
    }

    return null;
  }

  String? validateText(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.textIsRequired;
    }

    return null;
  }
}
