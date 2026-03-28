import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';

mixin PlaylistEditValidator {
  String? validateName(
      String? value, String playlistId, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.nameIsRequired;
    }

    final playlistsRepository = sl<PlaylistsRepository>();
    if (playlistsRepository
        .getAllPlaylists()
        .any((s) => s.name == value && s.uuid != playlistId)) {
      return localizations.thereIsAlreadyPlaylistWithThisName;
    }

    return null;
  }
}
