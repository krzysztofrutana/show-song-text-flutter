import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

part 'songs_edit_state.dart';

class SongsEditCubit extends Cubit<SongsEditState> {
  SongsEditCubit() : super(SongsEditInitial());

  void initForm(String songId) {
    var box = Hive.box<Song>('songs');

    var song = box.get(songId);

    if (song == null) return;

    emit(state.copyWiht(
        uuid: song.uuid,
        title: song.title,
        author: song.author,
        key: song.key,
        text: song.text));
  }

  void updateTitle(String? title) {
    emit(state.copyWiht(title: title));
  }

  void updateAuthor(String? author) {
    emit(state.copyWiht(author: author));
  }

  void updateKey(String? key) {
    emit(state.copyWiht(key: key));
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
    var box = Hive.box<Song>('songs');
    box.put(
        state.uuid,
        Song(
            uuid: state.uuid,
            title: state.title,
            author: state.author,
            text: state.text,
            key: state.key));
  }
}
