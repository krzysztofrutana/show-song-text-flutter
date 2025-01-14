// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

// part 'playlists_list_event.dart';
// part 'playlists_list_state.dart';

// class PlaylistsListBloc
//     extends Bloc<PlaylistsListComponentEvent, PlaylistsListState> {
//   PlaylistsListBloc() : super(PlaylistsListComponentInitial()) {
//     on<PlaylistsListComponentEvent>((event, emit) {
//       if (event is FilterPlaylistsListComponentEvent) {
//         emit(FilteredPlaylistsListComponent(
//             query: event.query, oldState: state));
//       }

//       if (event is ReloadListEvent) {
//         emit(SongsListComponentInitial());

//         if (songsSearchBarCubit.state != '') {
//           emit(FilteredSongListComponent(
//               query: songsSearchBarCubit.state, oldState: state));
//         }
//       }

//       if (event is ChooseSongChangeEvent) {
//         emit(ChooseSongChange(chooseSongs: event.value, oldState: state));
//       }

//       if (event is SelectSongEvent) {
//         var currentSelectedSongs = state.selectedSongs;
//         var checkIfExist =
//             currentSelectedSongs.firstWhereOrNull((x) => x == event.song.uuid);
//         if (checkIfExist == null) {
//           currentSelectedSongs.add(event.song.uuid);
//         }
//         emit(UpdateSelectedSongState(
//             selectedSongs: currentSelectedSongs, oldState: state));
//       }

//       if (event is UnelectSongEvent) {
//         var currentSelectedSongs = state.selectedSongs;
//         var checkIfExist =
//             currentSelectedSongs.firstWhereOrNull((x) => x == event.song.uuid);
//         if (checkIfExist != null) {
//           currentSelectedSongs.remove(event.song.uuid);
//         }
//         emit(UpdateSelectedSongState(
//             selectedSongs: currentSelectedSongs, oldState: state));
//       }

//       if (event is RemoveSelectedSongsEvent) {
//         var box = Hive.box<Song>('songs');
//         for (var i = 0; i < state.selectedSongs.length; i++) {
//           var element = state.selectedSongs[i];
//           box.delete(element);
//         }

//         emit(SongsListComponentInitial());

//         if (songsSearchBarCubit.state != '') {
//           emit(FilteredSongListComponent(
//               query: songsSearchBarCubit.state, oldState: state));
//         }
//       }
//     });
//   }
// }
