part of 'song_search_cubit.dart';

class SongSearchState {
  List<FindedSongModel> songsToChoose = [];
  List<FindedArtistModel> artistToChoose = [];
  SongToFindModel? song;
  ResultState status;
  String? findedText;
  FindedArtistModel? choosenArtist;
  FindedSongModel? choosenSong;

  SongSearchState(
      {required this.song,
      required this.status,
      required this.songsToChoose,
      required this.artistToChoose,
      required this.findedText,
      this.choosenArtist,
      this.choosenSong});

  SongSearchState copyWith(
      {List<FindedSongModel>? songsToChoose,
      List<FindedArtistModel>? artistToChoose,
      SongToFindModel? song,
      ResultState? state,
      String? findedText,
      FindedArtistModel? choosenArtist,
      FindedSongModel? choosenSong}) {
    return SongSearchState(
        songsToChoose: songsToChoose ?? this.songsToChoose,
        artistToChoose: artistToChoose ?? this.artistToChoose,
        song: song ?? this.song,
        status: state ?? this.status,
        findedText: findedText ?? this.findedText,
        choosenArtist: choosenArtist ?? this.choosenArtist,
        choosenSong: choosenSong ?? this.choosenSong);
  }
}

final class SongSearchStateInitial extends SongSearchState {
  SongSearchStateInitial()
      : super(
            artistToChoose: [],
            song: null,
            songsToChoose: [],
            status: ResultState.searchStarted,
            findedText: null,
            choosenArtist: null,
            choosenSong: null);
}
