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
  Playlist? _initialPlaylist;

  void initForm(String playlistId) {
    final playlist = _playlistsRepository.getPlaylist(playlistId);

    if (playlist == null) return;

    _initialPlaylist = playlist;

    emit(
      state.copyWith(
        uuid: playlist.uuid,
        name: playlist.name,
        songsIds: playlist.songsIds,
      ),
    );
  }

  void updateName(String? name) {
    emit(state.copyWith(name: name));
  }

  void updateSongs(List<String> songsIds) {
    emit(state.copyWith(songsIds: songsIds));
  }

  void addSongs(List<String> songsIds) {
    final updatedSongsIds = List<String>.from(state.songsIds)..addAll(songsIds);
    emit(state.copyWith(songsIds: updatedSongsIds));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(const PlaylistEditInitial());
  }

  Future<void> save() async {
    final playlist = Playlist(
      uuid: state.uuid,
      name: state.name,
      songsIds: state.songsIds,
    );
    await _playlistsRepository.updatePlaylist(playlist);
    _initialPlaylist = playlist;
  }

  Future<void> delete() async {
    await _playlistsRepository.deletePlaylist(state.uuid);
  }

  bool get isModified {
    if (_initialPlaylist == null) return true;
    if (state.name != _initialPlaylist!.name) return true;
    if (state.songsIds.length != _initialPlaylist!.songsIds.length) return true;
    for (int i = 0; i < state.songsIds.length; i++) {
      if (state.songsIds[i] != _initialPlaylist!.songsIds[i]) return true;
    }
    return false;
  }
}
