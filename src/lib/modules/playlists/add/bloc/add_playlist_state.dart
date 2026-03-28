part of 'add_playlist_bloc.dart';

class AddPlaylistState extends Equatable {
  const AddPlaylistState({
    required this.playlist,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final Playlist playlist;
  final AutovalidateMode autovalidateMode;

  AddPlaylistState copyWith({
    Playlist? playlist,
    AutovalidateMode? autovalidateMode,
  }) {
    return AddPlaylistState(
      playlist: playlist ?? this.playlist,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }

  @override
  List<Object?> get props => [playlist, autovalidateMode];
}

final class AddPlaylistInitial extends AddPlaylistState {
  AddPlaylistInitial()
      : super(
          playlist: Playlist(
            uuid: const Uuid().v8(),
            name: '',
            songsIds: const [],
          ),
        );
}
