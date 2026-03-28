import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class SongsRepository {
  SongsRepository({Box<Song>? box}) : _box = box ?? DataCollections.songs();

  final Box<Song> _box;

  List<Song> getAllSongs() {
    return _box.values.toList();
  }

  Future<void> addSong(Song song) async {
    await _box.put(song.uuid, song);
  }

  Future<void> deleteSong(String uuid) async {
    await _box.delete(uuid);
  }

  Future<void> updateSong(Song song) async {
    await _box.put(song.uuid, song);
  }

  Song? getSong(String uuid) {
    return _box.get(uuid);
  }
}
