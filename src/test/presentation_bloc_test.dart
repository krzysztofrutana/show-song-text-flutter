import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

class MockSongsRepository extends Mock implements SongsRepository {}

class MockPlaylistsRepository extends Mock implements PlaylistsRepository {}

void main() {
  group('PresentationBloc', () {
    late MockSongsRepository mockSongsRepository;
    late MockPlaylistsRepository mockPlaylistsRepository;
    late PresentationBloc bloc;

    final testSong = const Song(
      uuid: '1',
      title: 'Test Title',
      author: 'Test Author',
      text: 'Test Text',
    );

    final testPlaylist = const Playlist(
      uuid: 'p1',
      name: 'Test Playlist',
      songsIds: ['1'],
    );

    setUp(() {
      mockSongsRepository = MockSongsRepository();
      mockPlaylistsRepository = MockPlaylistsRepository();
      bloc = PresentationBloc(
        songsRepository: mockSongsRepository,
        playlistsRepository: mockPlaylistsRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is PresentationInitial', () {
      expect(bloc.state, isA<PresentationInitial>());
    });

    blocTest<PresentationBloc, PresentationState>(
      'emits PresentationActive with single song when SongPresentation is added',
      build: () => bloc,
      act: (bloc) => bloc.add(SongPresentation(song: testSong)),
      expect: () => [
        PresentationActive(songs: [testSong]),
      ],
    );

    blocTest<PresentationBloc, PresentationState>(
      'emits PresentationActive with songs from playlist when PlaylistPresentation is added',
      setUp: () {
        when(() => mockPlaylistsRepository.getPlaylist('p1'))
            .thenReturn(testPlaylist);
        when(() => mockSongsRepository.getAllSongs()).thenReturn([testSong]);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PlaylistPresentation(playlist: testPlaylist)),
      expect: () => [
        PresentationActive(songs: [testSong]),
      ],
    );

    blocTest<PresentationBloc, PresentationState>(
      'emits PresentationInitial when ClearPresentationStore is added',
      seed: () => PresentationActive(songs: [testSong]),
      build: () => bloc,
      act: (bloc) => bloc.add(ClearPresentationStore()),
      expect: () => [
        isA<PresentationInitial>(),
      ],
    );
  });
}
