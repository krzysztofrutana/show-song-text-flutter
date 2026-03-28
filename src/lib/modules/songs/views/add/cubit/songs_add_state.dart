part of 'songs_add_cubit.dart';

class SongsAddState extends Equatable {
  const SongsAddState({
    required this.autovalidateMode,
    required this.uuid,
    required this.author,
    required this.title,
    required this.text,
    required this.key,
  });

  final AutovalidateMode autovalidateMode;
  final String uuid;
  final String author;
  final String title;
  final String text;
  final String key;

  SongsAddState copyWith({
    AutovalidateMode? autovalidateMode,
    String? uuid,
    String? author,
    String? title,
    String? text,
    String? key,
  }) {
    return SongsAddState(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        uuid: uuid ?? this.uuid,
        author: author ?? this.author,
        title: title ?? this.title,
        text: text ?? this.text,
        key: key ?? this.key);
  }

  @override
  List<Object?> get props => [autovalidateMode, uuid, author, title, text, key];
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
