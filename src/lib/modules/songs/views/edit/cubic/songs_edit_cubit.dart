import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

part 'songs_edit_state.dart';

class SongsEditCubit extends Cubit<SongsEditState> {
  SongsEditCubit() : super(SongsEditInitial());

  void initForm(String songId) {
    var box = DataCollections.songs();

    var song = box.get(songId);

    if (song == null) return;

    emit(state.copyWiht(
        uuid: song.uuid,
        title: song.title,
        author: song.author,
        text: song.text));
  }

  void updateTitle(String? title) {
    emit(state.copyWiht(title: title));
  }

  void updateAuthor(String? author) {
    emit(state.copyWiht(author: author));
  }

  void updateText(String? text) {
    emit(state.copyWiht(text: text));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWiht(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(SongsEditInitial());
  }

  void save() {
    var box = DataCollections.songs();
    box.put(
        state.uuid,
        Song(
            uuid: state.uuid,
            title: state.title,
            author: state.author,
            text: state.text));
  }
}
