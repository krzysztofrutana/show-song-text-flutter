import 'package:hive_ce_flutter/adapters.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

class PlaylistsRepository {
  PlaylistsRepository({Box<Playlist>? box})
    : _box = box ?? DataCollections.playlists();

  final Box<Playlist> _box;

  List<Playlist> getAllPlaylists() {
    try {
      return _box.values.toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPlaylist(Playlist playlist) async {
    try {
      await _box.put(playlist.uuid, playlist);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlaylist(String uuid) async {
    try {
      await _box.delete(uuid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    try {
      await _box.put(playlist.uuid, playlist);
    } catch (e) {
      rethrow;
    }
  }

  Playlist? getPlaylist(String uuid) {
    try {
      return _box.get(uuid);
    } catch (e) {
      rethrow;
    }
  }
}
