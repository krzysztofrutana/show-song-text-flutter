import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

mixin PlaylistEditValidator {
  String? validateName(String? value, String playlistId) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.nameIsRequired;
    }

    var box = DataCollections.playlists();
    if (box.values.any((s) => s.name == value && s.uuid != playlistId)) {
      return LocalizationManager
          .instance.appLocalization.thereIsAlreadyPlaylistWithThisName;
    }

    return null;
  }
}
