import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class DataCollections {
  static String songsKey = "songs";
  static String playlistsKey = "playlists";

  static Future initCollections() async {
    await Hive.initFlutter();

    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(PlaylistAdapter());

    await Hive.openBox<Song>(songsKey);
    await Hive.openBox<Playlist>(playlistsKey);
  }

  static Box<Playlist> playlists() {
    return Hive.box<Playlist>(playlistsKey);
  }

  static Box<Song> songs() {
    return Hive.box<Song>(songsKey);
  }
}
