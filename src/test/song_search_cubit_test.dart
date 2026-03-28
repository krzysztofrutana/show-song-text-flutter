import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_service.dart';

class MockTekstowoService extends Mock implements TekstowoService {}

void main() {
  setUpAll(() {
    registerFallbackValue(SongToFindModelFake());
  });

  group('SongSearchCubit', () {
    late TekstowoService mockService;
    late SongSearchCubit cubit;

    final songToFind = SongToFindModel('Happysad', 'Długa droga w dół');
    final findedSong = FindedSongModel(
      fullName: 'Happysad - Długa droga w dół',
      title: 'Długa droga w dół',
      artist: 'Happysad',
      link: 'happysad/dluga-droga-w-dol',
    );

    setUp(() {
      mockService = MockTekstowoService();
      cubit = SongSearchCubit(tekstowoService: mockService);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is SongSearchStateInitial', () {
      expect(cubit.state, isA<SongSearchStateInitial>());
    });

    blocTest<SongSearchCubit, SongSearchState>(
      'initSearch updates the state with song and status',
      build: () => cubit,
      act: (cubit) => cubit.initSearch(songToFind),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.song, 'song', songToFind)
            .having((s) => s.status, 'status', ResultState.searchStarted),
      ],
    );

    blocTest<SongSearchCubit, SongSearchState>(
      'searchByArtists emits chooseSongFromList when successful',
      setUp: () {
        final result = SearchResultModel(
          song: songToFind,
          state: ResultState.artistsToChooseFinded,
        );
        result.songsToChoose = [findedSong];
        when(() => mockService.searchByArtist(any()))
            .thenAnswer((_) async => result);
      },
      build: () => cubit,
      seed: () => cubit.state.copyWith(song: songToFind),
      act: (cubit) => cubit.searchByArtists(),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.status, 'status', ResultState.chooseSongFromList)
            .having((s) => s.songsToChoose, 'songsToChoose', [findedSong]),
      ],
    );

    blocTest<SongSearchCubit, SongSearchState>(
      'searchSongByTitle emits chooseSongFromList when successful',
      setUp: () {
        final result = SearchResultModel(
          song: songToFind,
          state: ResultState.songsToChooseFinded,
        );
        result.songsToChoose = [findedSong];
        when(() => mockService.searchByTitle(any()))
            .thenAnswer((_) async => result);
      },
      build: () => cubit,
      seed: () => cubit.state.copyWith(song: songToFind),
      act: (cubit) => cubit.searchSongByTitle(),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.status, 'status', ResultState.chooseSongFromList)
            .having((s) => s.songsToChoose, 'songsToChoose', [findedSong]),
      ],
    );

    blocTest<SongSearchCubit, SongSearchState>(
      'searchSongByArtistAndTitle emits chooseSongFromList when successful',
      setUp: () {
        final result = SearchResultModel(
          song: songToFind,
          state: ResultState.artistsToChooseFinded,
        );
        result.songsToChoose = [findedSong];
        when(() => mockService.searchByArtistAndTitle(any(), any()))
            .thenAnswer((_) async => result);
      },
      build: () => cubit,
      seed: () => cubit.state.copyWith(song: songToFind),
      act: (cubit) => cubit.searchSongByArtistAndTitle(),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.status, 'status', ResultState.chooseSongFromList)
            .having((s) => s.songsToChoose, 'songsToChoose', [findedSong]),
      ],
    );

    blocTest<SongSearchCubit, SongSearchState>(
      'searchByChoosenSong emits textFinded when successful (search by link)',
      setUp: () {
        final result = SearchResultModel(
          song: songToFind,
          state: ResultState.textFinded,
        );
        result.text = 'Przykładowy tekst piosenki';
        when(() => mockService.searchTextByLink(any(), any()))
            .thenAnswer((_) async => result);
      },
      build: () => cubit,
      seed: () => cubit.state.copyWith(
        song: songToFind,
        choosenSong: findedSong,
      ),
      act: (cubit) => cubit.searchByChoosenSong(),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.status, 'status', ResultState.textFinded)
            .having((s) => s.findedText, 'findedText', 'Przykładowy tekst piosenki'),
      ],
    );

    blocTest<SongSearchCubit, SongSearchState>(
      'searchByArtists emits error status when search fails',
      setUp: () {
        final result = SearchResultModel(
          song: songToFind,
          state: ResultState.cannotFindAnyArtists,
        );
        when(() => mockService.searchByArtist(any()))
            .thenAnswer((_) async => result);
      },
      build: () => cubit,
      seed: () => cubit.state.copyWith(song: songToFind),
      act: (cubit) => cubit.searchByArtists(),
      expect: () => [
        isA<SongSearchState>()
            .having((s) => s.status, 'status', ResultState.cannotFindAnyArtists)
            .having((s) => s.songsToChoose, 'songsToChoose', isEmpty),
      ],
    );
  });
}

// Fallback for mocktail
class SongToFindModelFake extends Fake implements SongToFindModel {}
