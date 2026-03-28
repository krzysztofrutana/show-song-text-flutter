import 'package:flutter_test/flutter_test.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_service.dart';

void main() {
  group('TekstowoService Online Tests', () {
    final service = TekstowoService();

    test('searchByArtist returns results for Happysad', () async {
      final songToFind = SongToFindModel('Happysad', '');
      final result = await service.searchByArtist(songToFind);

      expect(result.state, ResultState.artistsToChooseFinded);
      expect(result.songsToChoose, isNotEmpty);

      final found = result.songsToChoose.any((song) =>
          song.fullName == 'happysad - Długa droga w dół' &&
          song.link == "happysad/dluga_droga_w_dol");
      expect(found, isTrue);
    }, tags: 'online');

    test('searchByTitle returns results for Długa droga w dół', () async {
      final songToFind = SongToFindModel('', 'Długa droga w dół');
      final result = await service.searchByTitle(songToFind);

      expect(result.state, ResultState.songsToChooseFinded);
      expect(result.songsToChoose, isNotEmpty);

      final found = result.songsToChoose.any((song) =>
          song.fullName == 'happysad - Długa droga w dół' &&
          song.link == "happysad/dluga_droga_w_dol");
      expect(found, isTrue);
    }, tags: 'online');

    test(
        'searchByArtistAndTitle returns results for Happysad - Długa droga w dół',
        () async {
      final songToFind = SongToFindModel('Happysad', 'Długa droga w dół');
      final result = await service.searchByArtistAndTitle(songToFind, false);

      expect(result.state, ResultState.artistsToChooseFinded);
      expect(result.songsToChoose, isNotEmpty);

      final found = result.songsToChoose.any((song) =>
          song.fullName == 'happysad - Długa droga w dół' &&
          song.link == "happysad/dluga_droga_w_dol");
      expect(found, isTrue);
    }, tags: 'online');

    test('searchTextByLink returns lyrics for Happysad - Długa droga w dół',
        () async {
      final songToFind = SongToFindModel('Happysad', 'Długa droga w dół');
      songToFind.linkToSong = 'happysad/dluga_droga_w_dol';

      final result = await service.searchTextByLink(songToFind, true);

      expect(result.state, ResultState.textFinded);
      expect(result.text, isNotNull);
      expect(result.text, isNotEmpty);
      expect(result.text!.contains('Tak często Cię widzę'), isTrue);
    }, tags: 'online');

    test('SongSearchCubit online search flow', () async {
      final cubit = SongSearchCubit(tekstowoService: service);
      final songToFind = SongToFindModel('Happysad', 'Długa droga w dół');

      cubit.initSearch(songToFind);
      expect(cubit.state.status, ResultState.searchStarted);

      final searchResult = await cubit.searchSongByArtistAndTitle();
      expect(searchResult, isTrue);
      expect(cubit.state.status, ResultState.chooseSongFromList);
      expect(cubit.state.songsToChoose, isNotEmpty);

      final chosen = cubit.state.songsToChoose.firstWhere(
        (s) => s.link.contains('dluga_droga_w_dol'),
      );

      cubit.setChoosenSong(chosen);
      expect(cubit.state.choosenSong, chosen);

      final lyricsResult = await cubit.searchByChoosenSong();
      expect(lyricsResult, isTrue);
      expect(cubit.state.status, ResultState.textFinded);
      expect(cubit.state.findedText, isNotNull);
      expect(cubit.state.findedText!.contains('Tak często Cię widzę'), isTrue);

      await cubit.close();
    }, tags: 'online');
  });
}
