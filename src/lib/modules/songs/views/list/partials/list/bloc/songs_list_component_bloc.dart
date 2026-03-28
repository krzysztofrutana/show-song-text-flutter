import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'songs_list_component_event.dart';
part 'songs_list_component_state.dart';

class SongsListComponentBloc
    extends Bloc<SongsListComponentEvent, SongsListComponentState> {
  SongsListComponentBloc({
    SongsRepository? songsRepository,
    PlaylistsRepository? playlistsRepository,
  })  : _songsRepository = songsRepository ?? sl<SongsRepository>(),
        _playlistsRepository = playlistsRepository ?? sl<PlaylistsRepository>(),
        super(const SongsListComponentInitialState()) {
    on<LoadSongsEvent>(_onLoadSongs);
    on<ReloadListEvent>(_onLoadSongs);
    on<SearchSongsEvent>(
      _onSearchSongs,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 300)).switchMap(mapper),
    );
    on<ChooseSongChangeEvent>(_onChooseSongChange);
    on<SelectSongEvent>(_onSelectSong);
    on<UnselectSongEvent>(_onUnselectSong);
    on<RemoveSelectedSongsEvent>(_onRemoveSelectedSongs);
    on<ClearSelectedSongs>(_onClearSelectedSongs);
  }

  final SongsRepository _songsRepository;
  final PlaylistsRepository _playlistsRepository;

  void _onLoadSongs(
    SongsListComponentEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    emit(state.copyWith(status: SongsListStatus.loading));
    try {
      final allSongs = _songsRepository.getAllSongs();
      final filteredSongs = _filterSongs(allSongs, state.searchQuery);
      emit(state.copyWith(
        status: SongsListStatus.success,
        data: filteredSongs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SongsListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchSongs(
    SearchSongsEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    final allSongs = _songsRepository.getAllSongs();
    final filteredSongs = _filterSongs(allSongs, event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      data: filteredSongs,
    ));
  }

  List<Song> _filterSongs(List<Song> songs, String query) {
    if (query.isEmpty) return songs;
    final lowerQuery = query.toLowerCase();
    return songs
        .where((song) =>
            song.title.toLowerCase().contains(lowerQuery) ||
            song.author.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void _onChooseSongChange(
    ChooseSongChangeEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    emit(state.copyWith(chooseSongs: event.value));
  }

  void _onSelectSong(
    SelectSongEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    final updatedSelected = List<String>.from(state.selectedSongs);
    if (!updatedSelected.contains(event.song.uuid)) {
      updatedSelected.add(event.song.uuid);
    }
    emit(state.copyWith(selectedSongs: updatedSelected));
  }

  void _onUnselectSong(
    UnselectSongEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    final updatedSelected = List<String>.from(state.selectedSongs)
      ..remove(event.song.uuid);
    emit(state.copyWith(selectedSongs: updatedSelected));
  }

  Future<void> _onRemoveSelectedSongs(
    RemoveSelectedSongsEvent event,
    Emitter<SongsListComponentState> emit,
  ) async {
    for (final songUuid in state.selectedSongs) {
      final playlistsWithSong = _playlistsRepository
          .getAllPlaylists()
          .where((playlist) => playlist.songsIds.contains(songUuid));

      for (final playlist in playlistsWithSong) {
        final updatedSongsIds = List<String>.from(playlist.songsIds)
          ..remove(songUuid);
        await _playlistsRepository
            .updatePlaylist(playlist.copyWith(songsIds: updatedSongsIds));
      }
      await _songsRepository.deleteSong(songUuid);
    }
    add(LoadSongsEvent());
    add(ClearSelectedSongs());
  }

  void _onClearSelectedSongs(
    ClearSelectedSongs event,
    Emitter<SongsListComponentState> emit,
  ) {
    emit(state.copyWith(selectedSongs: [], chooseSongs: false));
  }
}
