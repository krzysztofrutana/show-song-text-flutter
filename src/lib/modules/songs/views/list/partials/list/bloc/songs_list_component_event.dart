part of 'songs_list_component_bloc.dart';

abstract class SongsListComponentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSongsEvent extends SongsListComponentEvent {}

class SearchSongsEvent extends SongsListComponentEvent {
  SearchSongsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ChooseSongChangeEvent extends SongsListComponentEvent {
  ChooseSongChangeEvent({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}

class SelectSongEvent extends SongsListComponentEvent {
  SelectSongEvent({required this.song});

  final Song song;

  @override
  List<Object?> get props => [song];
}

class UnselectSongEvent extends SongsListComponentEvent {
  UnselectSongEvent({required this.song});

  final Song song;

  @override
  List<Object?> get props => [song];
}

class RemoveSelectedSongsEvent extends SongsListComponentEvent {}

class ReloadListEvent extends SongsListComponentEvent {}

class ClearSelectedSongs extends SongsListComponentEvent {}

class ChangeSortEvent extends SongsListComponentEvent {
  ChangeSortEvent(this.sortOption);

  final SongsSortOption sortOption;

  @override
  List<Object?> get props => [sortOption];
}
