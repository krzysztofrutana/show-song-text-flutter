import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

mixin SongEditValidator {
  String? validateAuthor(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.authorIsRequired;
    }

    return null;
  }

  String? validateTitle(
      String? value, String songId, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.titleIsRequired;
    }

    final songsRepository = sl<SongsRepository>();
    if (songsRepository
        .getAllSongs()
        .any((s) => s.title == value && s.uuid != songId)) {
      return localizations.thereIsAlreadySongWithThisTitle;
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
