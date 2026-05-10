import 'package:hive_ce_flutter/adapters.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class SongsRepository {
  SongsRepository({Box<Song>? box}) : _box = box ?? DataCollections.songs();

  final Box<Song> _box;

  List<Song> getAllSongs() {
    try {
      return _box.values.toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSong(Song song) async {
    try {
      await _box.put(song.uuid, song);
    } catch (e) {
      // Re-throw or handle accordingly
      rethrow;
    }
  }

  Future<void> deleteSong(String uuid) async {
    try {
      await _box.delete(uuid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSong(Song song) async {
    try {
      await _box.put(song.uuid, song);
    } catch (e) {
      rethrow;
    }
  }

  Song? getSong(String uuid) {
    try {
      return _box.get(uuid);
    } catch (e) {
      rethrow;
    }
  }
}
