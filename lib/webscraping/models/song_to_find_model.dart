import 'package:pomocnik_wokalisty/webscraping/helpers/text_helper.dart';

class SongToFindModel {
  String? fullSongName;
  String? artist;
  String? title;
  String? normalizedArtist;
  String? normalizedTitle;
  String? linkToSong;

  SongToFindModel(this.artist, this.title) {
    if (artist != null && artist!.isNotEmpty) {
      normalizedArtist =
          TextHelper.normalizeTextWithoutPolishSpecialChar(artist!)
              .replaceAll(" ", "_");
    }

    if (title != null && title!.isNotEmpty) {
      normalizedTitle = TextHelper.normalizeTextWithoutPolishSpecialChar(title!)
          .replaceAll(" ", "_");
    }
  }
}
