part of 'playlist_edit_cubit.dart';

class PlaylistEditState extends Equatable {
  const PlaylistEditState({
    required this.autovalidateMode,
    required this.uuid,
    required this.name,
    required this.songsIds,
  });

  final AutovalidateMode autovalidateMode;
  final String uuid;
  final String name;
  final List<String> songsIds;

  PlaylistEditState copyWith({
    AutovalidateMode? autovalidateMode,
    String? uuid,
    String? name,
    List<String>? songsIds,
  }) {
    return PlaylistEditState(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        songsIds: songsIds ?? this.songsIds);
  }

  @override
  List<Object?> get props => [autovalidateMode, uuid, name, songsIds];
}

final class PlaylistEditInitial extends PlaylistEditState {
  const PlaylistEditInitial()
      : super(
            autovalidateMode: AutovalidateMode.disabled,
            uuid: '',
            name: '',
            songsIds: const []);
}
