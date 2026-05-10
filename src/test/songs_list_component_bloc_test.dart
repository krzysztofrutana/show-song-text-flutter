import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSongsRepository extends Mock implements SongsRepository {}

class MockPlaylistsRepository extends Mock implements PlaylistsRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SongsListComponentBloc', () {
    late MockSongsRepository mockSongsRepository;
    late MockPlaylistsRepository mockPlaylistsRepository;
    late MockSharedPreferences mockSharedPreferences;
    late SongsListComponentBloc bloc;

    final testSong = const Song(
      uuid: '1',
      title: 'Test Title',
      author: 'Test Author',
      text: 'Test Text',
    );

    setUpAll(() {
      mockSharedPreferences = MockSharedPreferences();
      sl.registerLazySingleton<SharedPreferences>(() => mockSharedPreferences);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(null);
    });

    setUp(() {
      mockSongsRepository = MockSongsRepository();
      mockPlaylistsRepository = MockPlaylistsRepository();
      bloc = SongsListComponentBloc(
        songsRepository: mockSongsRepository,
        playlistsRepository: mockPlaylistsRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, SongsListStatus.initial);
      expect(bloc.state.data, isEmpty);
      expect(bloc.state.selectedSongs, isEmpty);
    });

    blocTest<SongsListComponentBloc, SongsListComponentState>(
      'emits success status and songs when LoadSongsEvent is added',
      setUp: () {
        when(() => mockSongsRepository.getAllSongs()).thenReturn([testSong]);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(LoadSongsEvent()),
      expect:
          () => [
            const SongsListComponentState(
              status: SongsListStatus.loading,
              data: [],
              chooseSongs: false,
              selectedSongs: [],
            ),
            SongsListComponentState(
              status: SongsListStatus.success,
              data: [testSong],
              chooseSongs: false,
              selectedSongs: const [],
            ),
          ],
    );

    blocTest<SongsListComponentBloc, SongsListComponentState>(
      'filters songs when SearchSongsEvent is added',
      setUp: () {
        when(() => mockSongsRepository.getAllSongs()).thenReturn([
          testSong,
          const Song(uuid: '2', title: 'Other', author: 'Author', text: ''),
        ]);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(SearchSongsEvent('Test')),
      wait: const Duration(milliseconds: 400), // debounce
      expect:
          () => [
            SongsListComponentState(
              searchQuery: 'Test',
              data: [testSong],
              chooseSongs: false,
              selectedSongs: const [],
            ),
          ],
    );

    blocTest<SongsListComponentBloc, SongsListComponentState>(
      'adds song to selected when SelectSongEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(SelectSongEvent(song: testSong)),
      expect:
          () => [
            const SongsListComponentState(
              selectedSongs: ['1'],
              data: [],
              chooseSongs: false,
            ),
          ],
    );

    blocTest<SongsListComponentBloc, SongsListComponentState>(
      'removes song from selected when UnselectSongEvent is added',
      seed:
          () => const SongsListComponentState(
            selectedSongs: ['1'],
            data: [],
            chooseSongs: false,
          ),
      build: () => bloc,
      act: (bloc) => bloc.add(UnselectSongEvent(song: testSong)),
      expect:
          () => [
            const SongsListComponentState(
              selectedSongs: [],
              data: [],
              chooseSongs: false,
            ),
          ],
    );

    blocTest<SongsListComponentBloc, SongsListComponentState>(
      'clears selected songs when ClearSelectedSongs is added',
      seed:
          () => const SongsListComponentState(
            selectedSongs: ['1'],
            chooseSongs: true,
            data: [],
          ),
      build: () => bloc,
      act: (bloc) => bloc.add(ClearSelectedSongs()),
      expect:
          () => [
            const SongsListComponentState(
              selectedSongs: [],
              chooseSongs: false,
              data: [],
            ),
          ],
    );
  });
}
