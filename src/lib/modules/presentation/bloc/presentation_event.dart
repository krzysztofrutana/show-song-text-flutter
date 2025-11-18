part of 'presentation_bloc.dart';

sealed class PresetationEvent {}

class PlaylistPresentation extends PresetationEvent {
  final Playlist playlist;

  PlaylistPresentation({required this.playlist});
}

class SongPresentation extends PresetationEvent {
  final Song song;

  SongPresentation({required this.song});
}

class SongsPresentation extends PresetationEvent {
  final List<Song> songs;

  SongsPresentation({required this.songs});
}

class ClearPresentationStore extends PresetationEvent {}
