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
        var presentation = DataCollections.playlists().get(event.playlist.uuid);

        if (presentation == null) return;

        var songsBox = DataCollections.songs();
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
