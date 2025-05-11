import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_helper.dart';

part 'song_search_state.dart';

class SongSearchCubit extends Cubit<SongSearchState> {
  SongSearchCubit() : super(SongSearchStateInitial());

  void initSearch(SongToFindModel songToFind) {
    emit(state.copyWith(song: songToFind, state: ResultState.searchStarted));
  }

  void setChoosenSong(FindedSongModel choosenSong) {
    emit(state.copyWith(choosenSong: choosenSong));
  }

  Future<bool> searchByArtists() async {
    try {
      var searchResult = await TekstowoHelper.searchByArtist(state.song!);

      if (resultHasError(searchResult)) {
        processError(searchResult);
        return false;
      }

      emit(state.copyWith(
          state: ResultState.chooseSongFromList,
          songsToChoose: searchResult.songsToChoose));

      return true;
    } catch (ex) {
      emit(state.copyWith(
          state: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: [],
          choosenArtist: null,
          choosenSong: null));

      return false;
    }
  }

  Future<bool> searchSongByArtistAndTitle() async {
    try {
      var textResult =
          await TekstowoHelper.findTextFromArtistAndTitle(state.song!, false);

      if (resultHasError(textResult)) {
        processError(textResult);
        return false;
      }

      emit(state.copyWith(
          state: ResultState.textFinded,
          songsToChoose: [],
          artistToChoose: [],
          findedText: textResult.text));
    } catch (ex) {
      emit(state.copyWith(
          state: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: [],
          choosenArtist: null,
          choosenSong: null));

      return false;
    }

    return true;
  }

  Future<bool> searchByChoosenSong() async {
    try {
      SongToFindModel songToFind =
          SongToFindModel(state.choosenSong!.artist, state.choosenSong!.title);
      songToFind.linkToSong = state.choosenSong!.link;

      var textResult =
          await TekstowoHelper.findTextFromArtistAndTitle(songToFind, true);

      if (resultHasError(textResult)) {
        processError(textResult);
        return false;
      }

      emit(state.copyWith(
          state: ResultState.textFinded,
          songsToChoose: [],
          artistToChoose: [],
          findedText: textResult.text));

      return true;
    } catch (ex) {
      emit(state.copyWith(
          state: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: [],
          choosenArtist: null,
          choosenSong: null));

      return false;
    }
  }

  Future<bool> searchSongByTitle() async {
    var searchSongResult = await TekstowoHelper.searchSong(state.song!);

    if (resultHasError(searchSongResult)) {
      processError(searchSongResult);
      return false;
    }

    emit(state.copyWith(
        state: ResultState.chooseSongFromList,
        songsToChoose: searchSongResult.songsToChoose));

    return true;
  }

  bool resultHasError(SearchResultModel searchResult) {
    var errorsStatuses = [
      ResultState.toManyArtistOnList,
      ResultState.cannotFindAnyArtists,
      ResultState.cannotFindAnySongs,
      ResultState.cannotFindText,
      ResultState.connectionError,
      ResultState.invalidRequestData
    ];

    if (errorsStatuses.contains(searchResult.state)) {
      return true;
    }

    return false;
  }

  void processError(SearchResultModel searchResult) {
    emit(state.copyWith(
        state: searchResult.state,
        artistToChoose: [],
        songsToChoose: [],
        choosenArtist: null,
        choosenSong: null));
  }

  void clear() {
    emit(SongSearchStateInitial());
  }
}
