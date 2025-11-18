import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

enum ResultState {
  searchStarted,
  connectionError,
  invalidRequestData,
  textFinded,
  chooseSongFromList,
  cannotFindText,
  cannotFindAnyArtists,
  cannotFindAnySongs,
  toManyArtistOnList,
  artistsToChooseFinded,
  songsToChooseFinded,
  unexpectedError
}

class FindedSongModel {
  String fullName;
  String title;
  String? artist;
  String? text;
  String link;

  FindedSongModel(
      {required this.fullName,
      required this.title,
      this.artist,
      this.text,
      required this.link});
}

class FindedArtistModel {
  String encodeName;
  String name;
  String link;

  FindedArtistModel(
      {required this.encodeName, required this.name, required this.link});
}

class SearchResultModel {
  SongToFindModel song;
  ResultState state;
  String? text;
  List<FindedSongModel> songsToChoose = [];
  List<FindedArtistModel> artistToChoose = [];

  SearchResultModel({required this.song, required this.state});
}
