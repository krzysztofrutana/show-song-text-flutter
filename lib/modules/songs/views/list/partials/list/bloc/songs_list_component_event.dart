part of 'songs_list_component_bloc.dart';

abstract class SongsListComponentEvent {}

class FilterSongListComponentEvent extends SongsListComponentEvent {
  final List<Song> filteredList;

  FilterSongListComponentEvent({required this.filteredList});
}

class ChooseSongChangeEvent extends SongsListComponentEvent {
  final bool value;

  ChooseSongChangeEvent({required this.value});
}

class SelectSongEvent extends SongsListComponentEvent {
  final Song song;

  SelectSongEvent({required this.song});
}

class UnelectSongEvent extends SongsListComponentEvent {
  final Song song;

  UnelectSongEvent({required this.song});
}

class RemoveSelectedSongsEvent extends SongsListComponentEvent {}

class ReloadListEvent extends SongsListComponentEvent {
  ReloadListEvent();
}
