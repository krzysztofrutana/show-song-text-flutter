import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

mixin SongEditValidator {
  String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.authorIsRequired;
    }

    return null;
  }

  String? validateTitle(String? value, String songId) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.titleIsRequired;
    }

    var box = DataCollections.songs();
    if (box.values.any((s) => s.title == value && s.uuid != songId)) {
      return LocalizationManager
          .instance.appLocalization.thereIsAlreadySongWithThisTitle;
    }

    return null;
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.textIsRequired;
    }

    return null;
  }
}
