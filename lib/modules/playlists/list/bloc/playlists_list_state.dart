// part of 'playlists_list_bloc.dart';

// abstract class PlaylistsListState {
//   List<String> selectedPlaylists = [];
//   bool choosePlaylist = false;
//   List<Playlist> data = [];
//   List<Playlist> allPlaylists = [];
//   String query = '';

//   PlaylistsListState(PlaylistsListState? oldState) {
//     if (oldState != null) {
//       selectedPlaylists = oldState.selectedPlaylists;
//       choosePlaylist = oldState.choosePlaylist;
//       data = oldState.data;
//       allPlaylists = oldState.allPlaylists;
//     }
//   }
// }

// final class PlaylistsListComponentInitial extends PlaylistsListState {
//   PlaylistsListComponentInitial() : super(null) {
//     Box<Playlist> boxAllPlaylists = Hive.box<Playlist>('playlists');
//     allPlaylists = boxAllPlaylists.values.toList();
//     data = allPlaylists.toList();
//     choosePlaylist = false;
//     selectedPlaylists = [];
//   }
// }

// final class UpdatedPlaylistsListState extends PlaylistsListState {
//   UpdatedPlaylistsListState({required PlaylistsListState oldState})
//       : super(oldState);
// }

// final class FilteredPlaylistsListComponent extends PlaylistsListState {
//   @override
//   final String query;

//   FilteredPlaylistsListComponent(
//       {required this.query, required PlaylistsListState oldState})
//       : super(oldState) {
//     if (query == '') {
//       data = allPlaylists.toList();
//     } else {
//       data = allPlaylists
//           .where((playlist) => playlist.name.contains(query))
//           .toList();
//     }
//   }
// }

// final class ChoosePlaylistsChange extends PlaylistsListState {
//   ChoosePlaylistsChange(
//       {required bool choosePlaylist, required PlaylistsListState oldState})
//       : super(oldState) {
//     this.choosePlaylist = choosePlaylist;

//     if (!choosePlaylist) {
//       for (var x in allPlaylists) {
//         x.selected = false;
//       }

//       for (var x in data) {
//         x.selected = false;
//       }
//     }
//   }
// }

// final class UpdateSelectedPlaylistsState extends PlaylistsListState {
//   UpdateSelectedPlaylistsState(
//       {required List<String> selectedPlaylists,
//       required PlaylistsListState oldState})
//       : super(oldState) {
//     this.selectedPlaylists = selectedPlaylists;
//   }
// }
