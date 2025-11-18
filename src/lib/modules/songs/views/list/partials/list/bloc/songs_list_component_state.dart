part of 'songs_list_component_bloc.dart';

class SongsListComponentState {
  List<String> selectedSongs = [];
  bool chooseSongs = false;
  List<Song> data = [];

  SongsListComponentState(
      {required this.data,
      required this.chooseSongs,
      required this.selectedSongs});

  SongsListComponentState copyWith(
      {List<String>? selectedSongs, bool? chooseSongs, List<Song>? data}) {
    return SongsListComponentState(
        data: data ?? this.data,
        chooseSongs: chooseSongs ?? this.chooseSongs,
        selectedSongs: selectedSongs ?? this.selectedSongs);
  }
}

final class SongsListComponentInitialState extends SongsListComponentState {
  SongsListComponentInitialState()
      : super(
            data: DataCollections.songs().values.toList(),
            chooseSongs: false,
            selectedSongs: []);
}
