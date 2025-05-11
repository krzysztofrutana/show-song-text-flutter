import 'package:pomocnik_wokalisty/helpers/data_collections.dart';

mixin PlaylistEditValidator {
  String? validateName(String? value, String playlistId) {
    if (value == null || value.isEmpty) return 'Nazwa jest wymagana';

    var box = DataCollections.songs();
    if (box.values.any((s) => s.title == value && s.uuid != playlistId)) {
      return 'Istnieje już utwór z tym tytułem';
    }

    return null;
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) return 'Tekst jest wymagany';
    return null;
  }
}
