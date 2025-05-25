part of 'playlist_edit_cubit.dart';

class PlaylistEditState {
  AutovalidateMode autovalidateMode;
  String uuid;
  String name;
  List<String> songsIds;

  PlaylistEditState(
      {required this.autovalidateMode,
      required this.uuid,
      required this.name,
      required this.songsIds});

  PlaylistEditState copyWiht(
      {AutovalidateMode? autovalidateMode,
      String? uuid,
      String? name,
      List<String>? songsIds}) {
    return PlaylistEditState(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        songsIds: songsIds ?? this.songsIds);
  }
}

final class PlaylistEditInitial extends PlaylistEditState {
  PlaylistEditInitial()
      : super(
            autovalidateMode: AutovalidateMode.disabled,
            uuid: '',
            name: '',
            songsIds: []);
}
