part of 'playlists_list_component_bloc.dart';

class PlaylistsListComponentState {
  List<String> selectedPlaylists = [];
  bool choosePlaylists = false;
  List<Playlist> data = [];

  PlaylistsListComponentState(
      {required this.data,
      required this.choosePlaylists,
      required this.selectedPlaylists});

  PlaylistsListComponentState copyWith(
      {List<String>? selectedPlaylists,
      bool? choosePlaylists,
      List<Playlist>? data}) {
    return PlaylistsListComponentState(
        data: data ?? this.data,
        choosePlaylists: choosePlaylists ?? this.choosePlaylists,
        selectedPlaylists: selectedPlaylists ?? this.selectedPlaylists);
  }
}

final class PlaylistsListComponentInitialState
    extends PlaylistsListComponentState {
  PlaylistsListComponentInitialState()
      : super(
            data: DataCollections.playlists().values.toList(),
            choosePlaylists: false,
            selectedPlaylists: []);
}
