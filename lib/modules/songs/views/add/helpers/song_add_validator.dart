import 'package:pomocnik_wokalisty/helpers/data_collections.dart';

mixin SongAddValidator {
  String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) return 'Autor jest wymagany';
    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) return 'Tytuł jest wymagany';

    var box = DataCollections.songs();
    if (box.values.any((s) => s.title == value)) {
      return 'Istnieje już utwór z tym tytułem';
    }

    return null;
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) return 'Tekst jest wymagany';
    return null;
  }
}
