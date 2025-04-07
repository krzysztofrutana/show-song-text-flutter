import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
        var presentation =
            Hive.box<Playlist>('playlists').get(event.playlist.uuid);

        if (presentation == null) return;

        var songsBox = Hive.box<Song>('songs');
        var songs = songsBox.values
            .where((song) => presentation.songsIds.contains(song.uuid))
            .toList();

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
