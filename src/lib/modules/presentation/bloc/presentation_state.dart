part of 'presentation_bloc.dart';

sealed class PresentationState {
  late List<Song> songs;
}

final class PresentationInitial extends PresentationState {}

final class PresentationActive extends PresentationState {
  PresentationActive({required List<Song> songs}) : super() {
    this.songs = songs;
  }
}
