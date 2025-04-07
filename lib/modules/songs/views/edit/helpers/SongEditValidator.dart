import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

mixin SongEditValidator {
  String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) return 'Autor jest wymagany';
    return null;
  }

  String? validateTitle(String? value, String songId) {
    if (value == null || value.isEmpty) return 'Tytuł jest wymagany';

    var box = Hive.box<Song>('songs');
    if (box.values.any((s) => s.title == value && s.uuid != songId)) {
      return 'Istnieje już utwór z tym tytułem';
    }

    return null;
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) return 'Tekst jest wymagany';
    return null;
  }
}
