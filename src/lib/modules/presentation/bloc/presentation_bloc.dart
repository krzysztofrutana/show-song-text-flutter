import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

part 'presentation_event.dart';
part 'presentation_state.dart';

class PresentationBloc extends Bloc<PresentationEvent, PresentationState> {
  PresentationBloc({
    SongsRepository? songsRepository,
    PlaylistsRepository? playlistsRepository,
  })  : _songsRepository = songsRepository ?? sl<SongsRepository>(),
        _playlistsRepository = playlistsRepository ?? sl<PlaylistsRepository>(),
        super(PresentationInitial()) {
    on<PresentationEvent>((event, emit) {
      if (event is ClearPresentationStore) {
        emit(PresentationInitial());
      }

      if (event is PlaylistPresentation) {
        final playlist = _playlistsRepository.getPlaylist(event.playlist.uuid);

        if (playlist == null) return;

        final allSongs = _songsRepository.getAllSongs();
        final songsFromPlaylist = allSongs
            .where((song) => playlist.songsIds.contains(song.uuid))
            .toList();

        final songs = List<Song>.empty(growable: true);

        for (var songUuid in playlist.songsIds) {
          final song =
              songsFromPlaylist.firstWhereOrNull((x) => x.uuid == songUuid);
          if (song != null) {
            songs.add(song);
          }
        }

        emit(PresentationActive(songs: songs));
      }

      if (event is SongPresentation) {
        emit(PresentationActive(songs: [event.song]));
      }

      if (event is SongsPresentation) {
        emit(PresentationActive(songs: event.songs));
      }
    });
  }
  final SongsRepository _songsRepository;
  final PlaylistsRepository _playlistsRepository;
}
