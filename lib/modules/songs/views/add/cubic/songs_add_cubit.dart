import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:uuid/uuid.dart';

part 'songs_add_state.dart';

class SongsAddCubit extends Cubit<SongsAddState> {
  SongsAddCubit() : super(SongsAddInitial());

  void initForm(
      {String uuid = '',
      String title = '',
      String author = '',
      String key = '',
      String text = ''}) {
    emit(state.copyWiht(
        uuid: uuid, title: title, author: author, key: key, text: text));
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
    emit(SongsAddInitial());
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

    emit(SongsAddInitial());
  }
}
