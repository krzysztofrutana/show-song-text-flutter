part of 'songs_edit_cubit.dart';

class SongsEditState {
  AutovalidateMode autovalidateMode;
  String uuid;
  String author;
  String title;
  String text;
  String key;

  SongsEditState(
      {required this.autovalidateMode,
      required this.uuid,
      required this.author,
      required this.title,
      required this.text,
      required this.key});

  SongsEditState copyWiht(
      {AutovalidateMode? autovalidateMode,
      String? uuid,
      String? author,
      String? title,
      String? text,
      String? key}) {
    return SongsEditState(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        uuid: uuid ?? this.uuid,
        author: author ?? this.author,
        title: title ?? this.title,
        text: text ?? this.text,
        key: key ?? this.key);
  }
}

final class SongsEditInitial extends SongsEditState {
  SongsEditInitial()
      : super(
            autovalidateMode: AutovalidateMode.disabled,
            uuid: '',
            author: '',
            title: '',
            text: '',
            key: '');
}
