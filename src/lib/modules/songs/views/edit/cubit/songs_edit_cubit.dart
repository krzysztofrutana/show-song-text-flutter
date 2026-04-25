import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

part 'songs_edit_state.dart';

class SongsEditCubit extends Cubit<SongsEditState> {
  SongsEditCubit({SongsRepository? songsRepository})
    : _songsRepository = songsRepository ?? SongsRepository(),
      super(const SongsEditInitial());

  final SongsRepository _songsRepository;
  Song? _initialSong;

  void initForm(String songId) {
    final song = _songsRepository.getSong(songId);

    if (song == null) return;

    _initialSong = song;

    emit(
      state.copyWith(
        uuid: song.uuid,
        title: song.title,
        author: song.author,
        text: song.text,
      ),
    );
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
    emit(const SongsEditInitial());
  }

  Future<void> save() async {
    final song = Song(
      uuid: state.uuid,
      title: state.title,
      author: state.author,
      text: state.text,
    );
    await _songsRepository.updateSong(song);
    _initialSong = song;
  }

  Future<void> delete() async {
    await _songsRepository.deleteSong(state.uuid);
  }

  bool get isModified =>
      _initialSong == null ||
      state.author != _initialSong!.author ||
      state.title != _initialSong!.title ||
      state.text != _initialSong!.text;
}
