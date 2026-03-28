part of 'presentation_bloc.dart';

sealed class PresentationState extends Equatable {
  const PresentationState({required this.songs});

  final List<Song> songs;

  @override
  List<Object?> get props => [songs];
}

final class PresentationInitial extends PresentationState {
  PresentationInitial() : super(songs: []);
}

final class PresentationActive extends PresentationState {
  const PresentationActive({required super.songs});
}
