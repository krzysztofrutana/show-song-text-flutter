import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:uuid/uuid.dart';

part 'add_playlist_event.dart';
part 'add_playlist_state.dart';

class AddPlaylistBloc extends Bloc<AddPlaylistEvent, AddPlaylistState> {
  AddPlaylistBloc({PlaylistsRepository? playlistsRepository})
      : _playlistsRepository = playlistsRepository ?? PlaylistsRepository(),
        super(AddPlaylistInitial()) {
    on<PlaylistAddNameChange>(_onNameChange);
    on<PlaylistSetSelectedSongs>(_onSetSelectedSongs);
    on<AddPlaylistSave>(_onSave);
    on<AddPlaylistReset>(_onReset);
    on<AddPlaylistUpdateAutovalidateMode>(_onUpdateAutovalidateMode);
  }

  final PlaylistsRepository _playlistsRepository;

  void _onUpdateAutovalidateMode(
    AddPlaylistUpdateAutovalidateMode event,
    Emitter<AddPlaylistState> emit,
  ) {
    emit(state.copyWith(autovalidateMode: event.autovalidateMode));
  }

  void _onNameChange(
    PlaylistAddNameChange event,
    Emitter<AddPlaylistState> emit,
  ) {
    emit(state.copyWith(
      playlist: state.playlist.copyWith(name: event.name),
    ));
  }

  void _onSetSelectedSongs(
    PlaylistSetSelectedSongs event,
    Emitter<AddPlaylistState> emit,
  ) {
    emit(state.copyWith(
      playlist: state.playlist.copyWith(songsIds: event.songsIds),
    ));
  }

  Future<void> _onSave(
    AddPlaylistSave event,
    Emitter<AddPlaylistState> emit,
  ) async {
    await _playlistsRepository.addPlaylist(state.playlist);
  }

  void _onReset(
    AddPlaylistReset event,
    Emitter<AddPlaylistState> emit,
  ) {
    emit(AddPlaylistInitial());
  }
}
