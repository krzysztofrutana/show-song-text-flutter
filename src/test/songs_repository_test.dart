import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

class MockBox extends Mock implements Box<Song> {}

class SongFake extends Fake implements Song {}

void main() {
  setUpAll(() {
    registerFallbackValue(SongFake());
  });

  group('SongsRepository', () {
    late MockBox mockBox;
    late SongsRepository songsRepository;

    final testSong = const Song(
      uuid: '1',
      title: 'Test Title',
      author: 'Test Author',
      text: 'Test Text',
    );

    setUp(() {
      mockBox = MockBox();
      songsRepository = SongsRepository(box: mockBox);
    });

    test('getAllSongs returns list of songs from box', () {
      when(() => mockBox.values).thenReturn([testSong]);

      final result = songsRepository.getAllSongs();

      expect(result, [testSong]);
      verify(() => mockBox.values).called(1);
    });

    test('addSong puts song into box using uuid as key', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      await songsRepository.addSong(testSong);

      verify(() => mockBox.put(testSong.uuid, testSong)).called(1);
    });

    test('deleteSong deletes song from box using uuid', () async {
      when(() => mockBox.delete(any())).thenAnswer((_) async => {});

      await songsRepository.deleteSong('1');

      verify(() => mockBox.delete('1')).called(1);
    });

    test('getSong returns song from box using uuid', () {
      when(() => mockBox.get(any())).thenReturn(testSong);

      final result = songsRepository.getSong('1');

      expect(result, testSong);
      verify(() => mockBox.get('1')).called(1);
    });
  });
}
