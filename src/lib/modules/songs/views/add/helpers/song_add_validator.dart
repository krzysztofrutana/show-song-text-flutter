import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

mixin SongAddValidator {
  String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.authorIsRequired;
    }

    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationManager.instance.appLocalization.titleIsRequired;
    }

    var box = DataCollections.songs();
    if (box.values.any((s) => s.title == value)) {
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
