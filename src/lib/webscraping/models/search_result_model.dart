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
  FindedSongModel(
      {required this.fullName,
      required this.title,
      this.artist,
      this.text,
      required this.link});

  String fullName;
  String title;
  String? artist;
  String? text;
  String link;
}

class FindedArtistModel {
  FindedArtistModel(
      {required this.encodeName, required this.name, required this.link});

  String encodeName;
  String name;
  String link;
}

class SearchResultModel {
  SearchResultModel({required this.song, required this.state});

  SongToFindModel song;
  ResultState state;
  String? text;
  List<FindedSongModel> songsToChoose = [];
  List<FindedArtistModel> artistToChoose = [];
}
