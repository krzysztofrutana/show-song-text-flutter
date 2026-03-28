part of 'add_playlist_bloc.dart';

sealed class AddPlaylistEvent extends Equatable {
  const AddPlaylistEvent();

  @override
  List<Object?> get props => [];
}

class AddPlaylistReset extends AddPlaylistEvent {}

class PlaylistSetSelectedSongs extends AddPlaylistEvent {
  const PlaylistSetSelectedSongs(this.songsIds);

  final List<String> songsIds;

  @override
  List<Object?> get props => [songsIds];
}

class PlaylistAddNameChange extends AddPlaylistEvent {
  const PlaylistAddNameChange(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class AddPlaylistSave extends AddPlaylistEvent {}

class AddPlaylistUpdateAutovalidateMode extends AddPlaylistEvent {
  const AddPlaylistUpdateAutovalidateMode(this.autovalidateMode);

  final AutovalidateMode autovalidateMode;

  @override
  List<Object?> get props => [autovalidateMode];
}
