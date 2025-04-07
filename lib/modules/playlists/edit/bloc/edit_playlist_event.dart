part of 'edit_playlist_bloc.dart';

sealed class EditPlaylistEvent {}

class LoadPlaylistData extends EditPlaylistEvent {
  final String playlistId;

  LoadPlaylistData(this.playlistId);
}

class AddSelectedSongsToPlaylist extends EditPlaylistEvent {
  final String playlistId;
  final List<String> songsIds;

  AddSelectedSongsToPlaylist(this.playlistId, this.songsIds);
}

