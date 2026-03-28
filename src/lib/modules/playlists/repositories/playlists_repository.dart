import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

class PlaylistsRepository {
  PlaylistsRepository({Box<Playlist>? box})
      : _box = box ?? DataCollections.playlists();

  final Box<Playlist> _box;

  List<Playlist> getAllPlaylists() {
    return _box.values.toList();
  }

  Future<void> addPlaylist(Playlist playlist) async {
    await _box.put(playlist.uuid, playlist);
  }

  Future<void> deletePlaylist(String uuid) async {
    await _box.delete(uuid);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _box.put(playlist.uuid, playlist);
  }

  Playlist? getPlaylist(String uuid) {
    return _box.get(uuid);
  }
}
