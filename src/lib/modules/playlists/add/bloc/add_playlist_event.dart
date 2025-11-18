part of 'add_playlist_bloc.dart';

sealed class AddPlaylistEvent {}

class AddPlaylistReset extends AddPlaylistEvent {
  AddPlaylistReset();
}

class PlaylistSetSelectedSongs extends AddPlaylistEvent {
  final List<String> songsIds;

  PlaylistSetSelectedSongs(this.songsIds);
}

class PlaylistAddNameChange extends AddPlaylistEvent {
  final String name;

  PlaylistAddNameChange(this.name);
}

class AddPlaylistSave extends AddPlaylistEvent {
  AddPlaylistSave();
}
