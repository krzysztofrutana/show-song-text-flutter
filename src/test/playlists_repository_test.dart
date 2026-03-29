import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';

class MockBox extends Mock implements Box<Playlist> {}

class PlaylistFake extends Fake implements Playlist {}

void main() {
  setUpAll(() {
    registerFallbackValue(PlaylistFake());
  });

  group('PlaylistsRepository', () {
    late MockBox mockBox;
    late PlaylistsRepository playlistsRepository;

    final testPlaylist = const Playlist(
      uuid: '1',
      name: 'Test Playlist',
      songsIds: ['s1', 's2'],
    );

    setUp(() {
      mockBox = MockBox();
      playlistsRepository = PlaylistsRepository(box: mockBox);
    });

    test('getAllPlaylists returns list of playlists from box', () {
      when(() => mockBox.values).thenReturn([testPlaylist]);

      final result = playlistsRepository.getAllPlaylists();

      expect(result, [testPlaylist]);
      verify(() => mockBox.values).called(1);
    });

    test('addPlaylist puts playlist into box using uuid as key', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      await playlistsRepository.addPlaylist(testPlaylist);

      verify(() => mockBox.put(testPlaylist.uuid, testPlaylist)).called(1);
    });

    test('deletePlaylist deletes playlist from box using uuid', () async {
      when(() => mockBox.delete(any())).thenAnswer((_) async => {});

      await playlistsRepository.deletePlaylist('1');

      verify(() => mockBox.delete('1')).called(1);
    });

    test('updatePlaylist puts updated playlist into box', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      await playlistsRepository.updatePlaylist(testPlaylist);

      verify(() => mockBox.put(testPlaylist.uuid, testPlaylist)).called(1);
    });
  });
}
