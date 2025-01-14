import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:uuid/uuid.dart';

part 'add_playlist_event.dart';
part 'add_playlist_state.dart';

class AddPlaylistBloc extends Bloc<AddPlaylistEvent, AddPlaylistState> {
  AddPlaylistBloc() : super(AddPlaylistInitial()) {
    on<AddPlaylistEvent>((event, emit) {
      if (event is PlaylistAddNameChange) {
        emit(PlaylistAddWithName(event.name, state.playlist));
      }

      if (event is PlaylistSetSelectedSongs) {
        emit(PlaylistAddWithSongs(event.songsIds, state.playlist));
      }

      if (event is AddPlaylistSave) {
        var box = Hive.box<Playlist>('playlists');
        box.put(state.playlist.uuid, state.playlist);
      }

      if (event is AddPlaylistReset) {
        emit(AddPlaylistInitial());
      }
    });
  }
}
