import 'package:pomocnik_wokalisty/helpers/data_collections.dart';

mixin PlaylistEditValidator {
  String? validateName(String? value, String playlistId) {
    if (value == null || value.isEmpty) return 'Nazwa jest wymagana';

    var box = DataCollections.playlists();
    if (box.values.any((s) => s.name == value && s.uuid != playlistId)) {
      return 'Istnieje już lista odtwarzania z tą nazwą';
    }

    return null;
  }
}
