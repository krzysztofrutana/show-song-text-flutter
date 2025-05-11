import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

part 'playlists_list_component_event.dart';
part 'playlists_list_component_state.dart';

class PlaylistsListComponentBloc
    extends Bloc<PlaylistsListComponentEvent, PlaylistsListComponentState> {
  PlaylistsListComponentBloc() : super(PlaylistsListComponentInitialState()) {
    on<PlaylistsListComponentEvent>((event, emit) {
      if (event is ReloadListEvent) {
        var allPlaylists = DataCollections.playlists().values.toList();

        if (state.selectedPlaylists.isNotEmpty) {
          for (var playlist in allPlaylists) {
            if (state.selectedPlaylists.any((id) => id == playlist.uuid)) {
              playlist.selected = true;
            }
          }
        }

        emit(state.copyWith(data: allPlaylists));
      }

      if (event is FilterPlaylistsListComponentEvent) {
        emit(state.copyWith(data: event.filteredList));
      }

      if (event is ChoosePlaylistChangeEvent) {
        emit(state.copyWith(choosePlaylists: event.value));
      }

      if (event is SelectPlaylistEvent) {
        var currentSelectedPlaylists = state.selectedPlaylists;

        var checkIfExist = currentSelectedPlaylists
            .firstWhereOrNull((x) => x == event.playlist.uuid);

        if (checkIfExist == null) {
          currentSelectedPlaylists.add(event.playlist.uuid);
        }

        emit(state.copyWith(selectedPlaylists: currentSelectedPlaylists));
      }

      if (event is UnelectPlaylistEvent) {
        var currentSelectedSongs = state.selectedPlaylists;
        var checkIfExist = currentSelectedSongs
            .firstWhereOrNull((x) => x == event.playlist.uuid);
        if (checkIfExist != null) {
          currentSelectedSongs.remove(event.playlist.uuid);
        }
        emit(state.copyWith(selectedPlaylists: currentSelectedSongs));
      }

      if (event is RemoveSelectedPlaylistsEvent) {
        var box = DataCollections.playlists();
        for (var i = 0; i < state.selectedPlaylists.length; i++) {
          var element = state.selectedPlaylists[i];
          box.delete(element);
        }
      }
    });
  }
}
