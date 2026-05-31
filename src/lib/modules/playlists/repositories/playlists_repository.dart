import 'package:hive_ce_flutter/adapters.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/models/playlist_include_song_model.dart';

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

  List<PlaylistIncludeSongModel> getBySongId(String songId) {
    final result = <PlaylistIncludeSongModel>[];
    for (final playlist in _box.values) {
      for (var i = 0; i < playlist.songsIds.length; i++) {
        if (playlist.songsIds[i] == songId) {
          result.add(PlaylistIncludeSongModel(playlist: playlist, position: i));
        }
      }
    }
    return result;
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
