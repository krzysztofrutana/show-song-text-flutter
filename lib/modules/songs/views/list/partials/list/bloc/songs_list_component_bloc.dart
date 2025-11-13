import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

part 'songs_list_component_event.dart';
part 'songs_list_component_state.dart';

class SongsListComponentBloc
    extends Bloc<SongsListComponentEvent, SongsListComponentState> {
  SongsListComponentBloc() : super(SongsListComponentInitialState()) {
    on<SongsListComponentEvent>((event, emit) {
      if (event is ReloadListEvent) {
        var allsongs = DataCollections.songs().values.toList();

        if (state.selectedSongs.isNotEmpty) {
          for (var song in allsongs) {
            if (state.selectedSongs.any((id) => id == song.uuid)) {
              song.selected = true;
            }
          }
        }

        emit(state.copyWith(data: allsongs));
      }

      if (event is FilterSongListComponentEvent) {
        emit(state.copyWith(data: event.filteredList));
      }

      if (event is ChooseSongChangeEvent) {
        emit(state.copyWith(chooseSongs: event.value));
      }

      if (event is SelectSongEvent) {
        var currentSelectedSongs = state.selectedSongs;
        var checkIfExist =
            currentSelectedSongs.firstWhereOrNull((x) => x == event.song.uuid);
        if (checkIfExist == null) {
          currentSelectedSongs.add(event.song.uuid);
        }
        emit(state.copyWith(selectedSongs: currentSelectedSongs));
      }

      if (event is UnelectSongEvent) {
        var currentSelectedSongs = state.selectedSongs;
        var checkIfExist =
            currentSelectedSongs.firstWhereOrNull((x) => x == event.song.uuid);
        if (checkIfExist != null) {
          currentSelectedSongs.remove(event.song.uuid);
        }
        emit(state.copyWith(selectedSongs: currentSelectedSongs));
      }

      if (event is RemoveSelectedSongsEvent) {
        var songBox = DataCollections.songs();
        var playlistBox = DataCollections.playlists();
        for (var i = 0; i < state.selectedSongs.length; i++) {
          var songUuid = state.selectedSongs[i];

          var playlistsWithSong = playlistBox.values
              .where((playlist) => playlist.songsIds.contains(songUuid));
          for (var playlist in playlistsWithSong) {
            playlist.songsIds.removeWhere((uuid) => uuid == songUuid);
            playlistBox.put(playlist.uuid, playlist);
          }
          songBox.delete(songUuid);
        }
      }

      if (event is ClearSelectedSongs) {
        var allsongs = DataCollections.songs().values.toList();

        for (var song in allsongs) {
          if (state.selectedSongs.any((id) => id == song.uuid)) {
            song.selected = false;
          }
        }
        emit(state.copyWith(selectedSongs: []));
      }
    });
  }
}
