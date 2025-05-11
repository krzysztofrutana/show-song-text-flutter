import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

part 'edit_playlist_event.dart';
part 'edit_playlist_state.dart';

class EditPlaylistBloc extends Bloc<EditPlaylistEvent, EditPlaylistState> {
  EditPlaylistBloc() : super(EditPlaylistInitialState()) {
    on<EditPlaylistEvent>((event, emit) {
      if (event is LoadPlaylistData) {
        emit(EditPlaylistInitialState(playlistId: event.playlistId));
      }

      if (event is AddSelectedSongsToPlaylist) {
        var playlists = DataCollections.playlists();
        var playlist = playlists.get(event.playlistId);

        playlist!.songsIds.addAll(event.songsIds);

        playlists.put(playlist.uuid, playlist);
      }
    });
  }
}
