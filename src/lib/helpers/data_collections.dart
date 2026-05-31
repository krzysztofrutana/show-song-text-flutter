import 'package:hive_ce_flutter/adapters.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/recording_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class DataCollections {
  static String songsKey = "songs";
  static String playlistsKey = "playlists";
  static String recordingsKey = "recordings";

  static Future initCollections() async {
    await Hive.initFlutter();

    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(RecordingAdapter());

    await Hive.openBox<Song>(songsKey);
    await Hive.openBox<Playlist>(playlistsKey);
    await Hive.openBox<Recording>(recordingsKey);
  }

  static Box<Playlist> playlists() {
    return Hive.box<Playlist>(playlistsKey);
  }

  static Box<Song> songs() {
    return Hive.box<Song>(songsKey);
  }

  static Box<Recording> recordings() {
    return Hive.box<Recording>(recordingsKey);
  }
}
