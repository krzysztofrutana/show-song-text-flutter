part of 'songs_add_cubit.dart';

class SongsAddState {
  AutovalidateMode autovalidateMode;
  String uuid;
  String author;
  String title;
  String text;
  String key;

  SongsAddState(
      {required this.autovalidateMode,
      required this.uuid,
      required this.author,
      required this.title,
      required this.text,
      required this.key});

  SongsAddState copyWiht(
      {AutovalidateMode? autovalidateMode,
      String? uuid,
      String? author,
      String? title,
      String? text,
      String? key}) {
    return SongsAddState(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        uuid: uuid ?? this.uuid,
        author: author ?? this.author,
        title: title ?? this.title,
        text: text ?? this.text,
        key: key ?? this.key);
  }
}

final class SongsAddInitial extends SongsAddState {
  SongsAddInitial()
      : super(
            autovalidateMode: AutovalidateMode.disabled,
            uuid: const Uuid().v8(),
            author: '',
            title: '',
            text: '',
            key: '');
}
