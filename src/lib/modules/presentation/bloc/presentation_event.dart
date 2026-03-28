part of 'presentation_bloc.dart';

sealed class PresentationEvent {}

class PlaylistPresentation extends PresentationEvent {
  PlaylistPresentation({required this.playlist});
  final Playlist playlist;
}

class SongPresentation extends PresentationEvent {
  SongPresentation({required this.song});
  final Song song;
}

class SongsPresentation extends PresentationEvent {
  SongsPresentation({required this.songs});
  final List<Song> songs;
}

class ClearPresentationStore extends PresentationEvent {}
