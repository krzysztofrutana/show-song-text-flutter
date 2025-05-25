import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

part 'playlist_edit_state.dart';

class PlaylistEditCubit extends Cubit<PlaylistEditState> {
  PlaylistEditCubit() : super(PlaylistEditInitial());

  void initForm(String playlistId) {
    var box = DataCollections.playlists();

    var playlist = box.get(playlistId);

    if (playlist == null) return;

    emit(state.copyWiht(
        uuid: playlist.uuid, name: playlist.name, songsIds: playlist.songsIds));
  }

  void updateName(String? title) {
    emit(state.copyWiht(name: title));
  }

  void updateSongs(List<String> songsIds) {
    emit(state.copyWiht(songsIds: songsIds));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWiht(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(PlaylistEditInitial());
  }

  void save() {
    var box = DataCollections.playlists();
    box.put(state.uuid,
        Playlist(uuid: state.uuid, name: state.name, songsIds: state.songsIds));
  }
}
