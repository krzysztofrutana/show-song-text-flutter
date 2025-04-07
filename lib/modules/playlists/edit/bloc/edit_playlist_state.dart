part of 'edit_playlist_bloc.dart';

class EditPlaylistState {
  Playlist? data;

  EditPlaylistState(
      {this.data});

  EditPlaylistState copyWith(
      Playlist? data) {

    return EditPlaylistState(
        data: data ?? this.data);
  }
}

final class EditPlaylistInitialState
    extends EditPlaylistState {
  EditPlaylistInitialState({String? playlistId})
      : super()
      {
        if(playlistId != null)
        {
          var playlist = Hive.box<Playlist>('playlists').get(playlistId);
          if(playlist != null)
          {
            data = playlist;
          }
        }
      }
}
