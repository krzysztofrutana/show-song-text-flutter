import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';

part 'playlist_edit_state.dart';

class PlaylistEditCubit extends Cubit<PlaylistEditState> {
  PlaylistEditCubit({PlaylistsRepository? playlistsRepository})
      : _playlistsRepository = playlistsRepository ?? PlaylistsRepository(),
        super(const PlaylistEditInitial());

  final PlaylistsRepository _playlistsRepository;

  void initForm(String playlistId) {
    final playlist = _playlistsRepository.getPlaylist(playlistId);

    if (playlist == null) return;

    emit(state.copyWith(
        uuid: playlist.uuid, name: playlist.name, songsIds: playlist.songsIds));
  }

  void updateName(String? name) {
    emit(state.copyWith(name: name));
  }

  void updateSongs(List<String> songsIds) {
    emit(state.copyWith(songsIds: songsIds));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(const PlaylistEditInitial());
  }

  Future<void> save() async {
    await _playlistsRepository.updatePlaylist(
      Playlist(
        uuid: state.uuid,
        name: state.name,
        songsIds: state.songsIds,
      ),
    );
  }
}
