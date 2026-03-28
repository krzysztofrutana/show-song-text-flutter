part of 'playlists_list_component_bloc.dart';

abstract class PlaylistsListComponentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPlaylistsEvent extends PlaylistsListComponentEvent {}

class SearchPlaylistsEvent extends PlaylistsListComponentEvent {
  SearchPlaylistsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ChoosePlaylistChangeEvent extends PlaylistsListComponentEvent {
  ChoosePlaylistChangeEvent({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class SelectPlaylistEvent extends PlaylistsListComponentEvent {
  SelectPlaylistEvent({required this.playlist});
  final Playlist playlist;

  @override
  List<Object?> get props => [playlist];
}

class UnelectPlaylistEvent extends PlaylistsListComponentEvent {
  UnelectPlaylistEvent({required this.playlist});
  final Playlist playlist;

  @override
  List<Object?> get props => [playlist];
}

class RemoveSelectedPlaylistsEvent extends PlaylistsListComponentEvent {}

class ReloadListEvent extends PlaylistsListComponentEvent {}

class ClearSelectedPlaylists extends PlaylistsListComponentEvent {}
