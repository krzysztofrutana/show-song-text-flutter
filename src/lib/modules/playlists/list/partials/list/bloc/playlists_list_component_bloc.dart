import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';

part 'playlists_list_component_event.dart';
part 'playlists_list_component_state.dart';

class PlaylistsListComponentBloc
    extends Bloc<PlaylistsListComponentEvent, PlaylistsListComponentState> {
  PlaylistsListComponentBloc({PlaylistsRepository? playlistsRepository})
    : _playlistsRepository = playlistsRepository ?? sl<PlaylistsRepository>(),
      super(const PlaylistsListComponentInitialState()) {
    on<LoadPlaylistsEvent>(_onLoadPlaylists);
    on<ReloadListEvent>(_onLoadPlaylists);
    on<SearchPlaylistsEvent>(_onSearchPlaylists);
    on<ChoosePlaylistChangeEvent>(_onChoosePlaylistChange);
    on<SelectPlaylistEvent>(_onSelectPlaylist);
    on<UnelectPlaylistEvent>(_onUnelectPlaylist);
    on<RemoveSelectedPlaylistsEvent>(_onRemoveSelectedPlaylists);
    on<ClearSelectedPlaylists>(_onClearSelectedPlaylists);
  }

  final PlaylistsRepository _playlistsRepository;

  void _onLoadPlaylists(
    PlaylistsListComponentEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    emit(state.copyWith(status: PlaylistsListStatus.loading));
    try {
      final allPlaylists = _playlistsRepository.getAllPlaylists();
      final filteredPlaylists = _filterPlaylists(
        allPlaylists,
        state.searchQuery,
      );
      emit(
        state.copyWith(
          status: PlaylistsListStatus.success,
          data: filteredPlaylists,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaylistsListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchPlaylists(
    SearchPlaylistsEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    try {
      final allPlaylists = _playlistsRepository.getAllPlaylists();
      final filteredPlaylists = _filterPlaylists(allPlaylists, event.query);
      emit(state.copyWith(searchQuery: event.query, data: filteredPlaylists));
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaylistsListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  List<Playlist> _filterPlaylists(List<Playlist> playlists, String query) {
    if (query.isEmpty) return playlists;
    final lowerQuery = query.toLowerCase();
    return playlists
        .where((playlist) => playlist.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void _onChoosePlaylistChange(
    ChoosePlaylistChangeEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    emit(state.copyWith(choosePlaylists: event.value));
  }

  void _onSelectPlaylist(
    SelectPlaylistEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    final updatedSelected = List<String>.from(state.selectedPlaylists);
    if (!updatedSelected.contains(event.playlist.uuid)) {
      updatedSelected.add(event.playlist.uuid);
    }
    emit(state.copyWith(selectedPlaylists: updatedSelected));
  }

  void _onUnelectPlaylist(
    UnelectPlaylistEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    final updatedSelected = List<String>.from(state.selectedPlaylists)
      ..remove(event.playlist.uuid);
    emit(state.copyWith(selectedPlaylists: updatedSelected));
  }

  Future<void> _onRemoveSelectedPlaylists(
    RemoveSelectedPlaylistsEvent event,
    Emitter<PlaylistsListComponentState> emit,
  ) async {
    for (final uuid in state.selectedPlaylists) {
      await _playlistsRepository.deletePlaylist(uuid);
    }
    add(LoadPlaylistsEvent());
    add(ClearSelectedPlaylists());
  }

  void _onClearSelectedPlaylists(
    ClearSelectedPlaylists event,
    Emitter<PlaylistsListComponentState> emit,
  ) {
    emit(state.copyWith(selectedPlaylists: [], choosePlaylists: false));
  }
}
