import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:uuid/uuid.dart';

part 'songs_add_state.dart';

class SongsAddCubit extends Cubit<SongsAddState> {
  SongsAddCubit({SongsRepository? songsRepository})
    : _songsRepository = songsRepository ?? SongsRepository(),
      super(SongsAddInitial());

  final SongsRepository _songsRepository;

  void initForm({
    String uuid = '',
    String title = '',
    String author = '',
    String text = '',
  }) {
    emit(state.copyWith(uuid: uuid, title: title, author: author, text: text));
  }

  void updateTitle(String? title) {
    emit(state.copyWith(title: title));
  }

  void updateAuthor(String? author) {
    emit(state.copyWith(author: author));
  }

  void updateText(String? text) {
    emit(state.copyWith(text: text));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(SongsAddInitial());
  }

  Future<void> save() async {
    await _songsRepository.addSong(
      Song(
        uuid: state.uuid,
        title: state.title,
        author: state.author,
        text: state.text,
      ),
    );
    emit(SongsAddInitial());
  }

  bool get isModified =>
      state.author.isNotEmpty ||
      state.title.isNotEmpty ||
      state.text.isNotEmpty;
}
