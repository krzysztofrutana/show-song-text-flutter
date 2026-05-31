import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/recordings_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

part 'songs_list_component_event.dart';
part 'songs_list_component_state.dart';

class SongsListComponentBloc
    extends Bloc<SongsListComponentEvent, SongsListComponentState> {
  SongsListComponentBloc({
    SongsRepository? songsRepository,
    PlaylistsRepository? playlistsRepository,
  }) : _songsRepository = songsRepository ?? sl<SongsRepository>(),
       _playlistsRepository = playlistsRepository ?? sl<PlaylistsRepository>(),
       super(
         SongsListComponentState(
           data: const [],
           chooseSongs: false,
           selectedSongs: const [],
           sortOption: _getSavedSortOption(),
         ),
       ) {
    on<LoadSongsEvent>(_onLoadSongs);
    on<ReloadListEvent>(_onLoadSongs);
    on<SearchSongsEvent>(
      _onSearchSongs,
      transformer:
          (events, mapper) => events
              .debounce(const Duration(milliseconds: 300))
              .switchMap(mapper),
    );
    on<ChooseSongChangeEvent>(_onChooseSongChange);
    on<SelectSongEvent>(_onSelectSong);
    on<UnselectSongEvent>(_onUnselectSong);
    on<RemoveSelectedSongsEvent>(_onRemoveSelectedSongs);
    on<ClearSelectedSongs>(_onClearSelectedSongs);
    on<ChangeSortEvent>(_onChangeSort);
  }

  final SongsRepository _songsRepository;
  final PlaylistsRepository _playlistsRepository;

  static SongsSortOption _getSavedSortOption() {
    final sortOptionIndex =
        sl<SharedPreferences>().getInt('songsSortOption') ?? 0;
    if (sortOptionIndex >= 0 &&
        sortOptionIndex < SongsSortOption.values.length) {
      return SongsSortOption.values[sortOptionIndex];
    }
    return SongsSortOption.latest;
  }

  void _onLoadSongs(
    SongsListComponentEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    emit(state.copyWith(status: SongsListStatus.loading));
    try {
      final allSongs = _songsRepository.getAllSongs();
      final filteredSongs = _filterSongs(allSongs, state.searchQuery);
      final sortedSongs = _sortSongs(filteredSongs, state.sortOption);
      emit(state.copyWith(status: SongsListStatus.success, data: sortedSongs));
    } catch (e) {
      emit(
        state.copyWith(
          status: SongsListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchSongs(
    SearchSongsEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    try {
      final allSongs = _songsRepository.getAllSongs();
      final filteredSongs = _filterSongs(allSongs, event.query);
      final sortedSongs = _sortSongs(filteredSongs, state.sortOption);
      emit(state.copyWith(searchQuery: event.query, data: sortedSongs));
    } catch (e) {
      emit(
        state.copyWith(
          status: SongsListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  List<Song> _filterSongs(List<Song> songs, String query) {
    if (query.isEmpty) return songs;
    final lowerQuery = query.toLowerCase();
    return songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(lowerQuery) ||
              song.author.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<Song> _sortSongs(List<Song> songs, SongsSortOption sortOption) {
    final sortedSongs = List<Song>.from(songs);
    switch (sortOption) {
      case SongsSortOption.latest:
        sortedSongs.sort((a, b) => b.uuid.compareTo(a.uuid));
        break;
      case SongsSortOption.oldest:
        sortedSongs.sort((a, b) => a.uuid.compareTo(b.uuid));
        break;
      case SongsSortOption.artistAndTitle:
        sortedSongs.sort((a, b) {
          final authorCompare = a.author.toLowerCase().compareTo(
            b.author.toLowerCase(),
          );
          if (authorCompare != 0) return authorCompare;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case SongsSortOption.title:
        sortedSongs.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return sortedSongs;
  }

  void _onChangeSort(
    ChangeSortEvent event,
    Emitter<SongsListComponentState> emit,
  ) {
    sl<SharedPreferences>().setInt('songsSortOption', event.sortOption.index);
    final sortedSongs = _sortSongs(state.data, event.sortOption);
    emit(state.copyWith(sortOption: event.sortOption, data: sortedSongs));
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
    final recordingsRepo = sl<RecordingsRepository>();
    for (final songUuid in state.selectedSongs) {
      final playlistsWithSong = _playlistsRepository.getAllPlaylists().where(
        (playlist) => playlist.songsIds.contains(songUuid),
      );

      for (final playlist in playlistsWithSong) {
        final updatedSongsIds = List<String>.from(playlist.songsIds)
          ..remove(songUuid);
        await _playlistsRepository.updatePlaylist(
          playlist.copyWith(songsIds: updatedSongsIds),
        );
      }

      final recordings = recordingsRepo.getBySongUuid(songUuid);
      for (final r in recordings) {
        File(r.filePath).delete();
      }
      await recordingsRepo.deleteBySongUuid(songUuid);

      final song = _songsRepository.getSong(songUuid);
      if (song?.audioCachePath != null) {
        File(song!.audioCachePath!).delete();
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
