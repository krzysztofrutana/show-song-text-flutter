part of 'add_playlist_bloc.dart';

sealed class AddPlaylistState {
  late Playlist playlist;
}

final class AddPlaylistInitial extends AddPlaylistState {
  AddPlaylistInitial({Playlist? playlistState}) {
    if (playlistState == null) {
      var uuid = const Uuid();
      playlist = Playlist(uuid: uuid.v8(), name: '', songsIds: []);
    } else {
      playlist = playlistState;
    }
  }
}

final class PlaylistAddWithSongs extends AddPlaylistInitial {
  PlaylistAddWithSongs(List<String> songsIds, Playlist beforePlaylistState)
      : super(playlistState: beforePlaylistState) {
    playlist.songsIds = songsIds;
  }
}

final class PlaylistAddWithName extends AddPlaylistInitial {
  PlaylistAddWithName(String name, Playlist beforePlaylistState)
      : super(playlistState: beforePlaylistState) {
    playlist.name = name;
  }
}
