import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart' as di;
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_service.dart';

part 'song_search_state.dart';

class SongSearchCubit extends Cubit<SongSearchState> {
  SongSearchCubit({TekstowoService? tekstowoService})
      : _tekstowoService = tekstowoService ?? di.sl<TekstowoService>(),
        super(SongSearchStateInitial());

  final TekstowoService _tekstowoService;

  void initSearch(SongToFindModel songToFind) {
    emit(state.copyWith(song: songToFind, status: ResultState.searchStarted));
  }

  void setChoosenSong(FindedSongModel choosenSong) {
    emit(state.copyWith(choosenSong: choosenSong));
  }

  Future<bool> searchByArtists() async {
    try {
      final searchResult = await _tekstowoService.searchByArtist(state.song!);

      if (resultHasError(searchResult)) {
        processError(searchResult);
        return false;
      }

      emit(state.copyWith(
          status: ResultState.chooseSongFromList,
          songsToChoose: searchResult.songsToChoose));

      return true;
    } catch (ex) {
      emit(state.copyWith(
          status: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: []));

      return false;
    }
  }

  Future<bool> searchSongByArtistAndTitle() async {
    try {
      final searchResult =
          await _tekstowoService.searchByArtistAndTitle(state.song!, false);

      if (resultHasError(searchResult)) {
        processError(searchResult);
        return false;
      }

      emit(state.copyWith(
          status: ResultState.chooseSongFromList,
          songsToChoose: searchResult.songsToChoose));

      return true;
    } catch (ex) {
      emit(state.copyWith(
          status: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: []));

      return false;
    }
  }

  Future<bool> searchSongByTitle() async {
    final searchSongResult = await _tekstowoService.searchByTitle(state.song!);

    if (resultHasError(searchSongResult)) {
      processError(searchSongResult);
      return false;
    }

    emit(state.copyWith(
        status: ResultState.chooseSongFromList,
        songsToChoose: searchSongResult.songsToChoose));

    return true;
  }

  bool resultHasError(SearchResultModel searchResult) {
    final errorsStatuses = [
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

  Future<bool> searchByChoosenSong() async {
    try {
      final songToFind =
          SongToFindModel(state.choosenSong!.artist, state.choosenSong!.title);
      songToFind.linkToSong = state.choosenSong!.link;

      final textResult =
          await _tekstowoService.searchTextByLink(songToFind, true);

      if (resultHasError(textResult)) {
        processError(textResult);
        return false;
      }

      emit(state.copyWith(
          status: ResultState.textFinded,
          songsToChoose: [],
          artistToChoose: [],
          findedText: textResult.text));

      return true;
    } catch (ex) {
      emit(state.copyWith(
          status: ResultState.unexpectedError,
          artistToChoose: [],
          songsToChoose: []));

      return false;
    }
  }

  void processError(SearchResultModel searchResult) {
    emit(state.copyWith(
        status: searchResult.state, artistToChoose: [], songsToChoose: []));
  }

  void clear() {
    emit(SongSearchStateInitial());
  }
}
