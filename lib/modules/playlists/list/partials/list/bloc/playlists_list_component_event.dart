part of 'playlists_list_component_bloc.dart';

abstract class PlaylistsListComponentEvent {}

class FilterPlaylistsListComponentEvent extends PlaylistsListComponentEvent {
  final List<Playlist> filteredList;

  FilterPlaylistsListComponentEvent({required this.filteredList});
}

class ChoosePlaylistChangeEvent extends PlaylistsListComponentEvent {
  final bool value;

  ChoosePlaylistChangeEvent({required this.value});
}

class SelectPlaylistEvent extends PlaylistsListComponentEvent {
  final Playlist playlist;

  SelectPlaylistEvent({required this.playlist});
}

class UnelectPlaylistEvent extends PlaylistsListComponentEvent {
  final Playlist playlist;

  UnelectPlaylistEvent({required this.playlist});
}

class RemoveSelectedPlaylistsEvent extends PlaylistsListComponentEvent {}

class ReloadListEvent extends PlaylistsListComponentEvent {
  ReloadListEvent();
}
