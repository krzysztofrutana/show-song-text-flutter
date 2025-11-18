import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

part 'presentation_event.dart';
part 'presentation_state.dart';

class PresentatationBloc extends Bloc<PresetationEvent, PresentationState> {
  PresentatationBloc() : super(PresentationInitial()) {
    on<PresetationEvent>((event, emit) {
      if (event is ClearPresentationStore) {
        emit(PresentationInitial());
      }

      if (event is PlaylistPresentation) {
        var playlist = DataCollections.playlists().get(event.playlist.uuid);

        if (playlist == null) return;

        var songsBox = DataCollections.songs();
        var songsFromPlaylist = songsBox.values
            .where((song) => playlist.songsIds.contains(song.uuid))
            .toList();

        List<Song> songs = List.empty(growable: true);

        for (var songUuid in playlist.songsIds) {
          var song =
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
}
