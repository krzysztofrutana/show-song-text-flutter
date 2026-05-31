part of 'songs_edit_cubit.dart';

class SongsEditState extends Equatable {
  const SongsEditState({
    required this.autovalidateMode,
    required this.uuid,
    required this.author,
    required this.title,
    required this.text,
    required this.key,
    this.audioUrl,
    this.audioFilePath,
  });

  final AutovalidateMode autovalidateMode;
  final String uuid;
  final String author;
  final String title;
  final String text;
  final String key;
  final String? audioUrl;
  final String? audioFilePath;

  SongsEditState copyWith({
    AutovalidateMode? autovalidateMode,
    String? uuid,
    String? author,
    String? title,
    String? text,
    String? key,
    String? audioUrl,
    String? audioFilePath,
  }) {
    return SongsEditState(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      uuid: uuid ?? this.uuid,
      author: author ?? this.author,
      title: title ?? this.title,
      text: text ?? this.text,
      key: key ?? this.key,
      audioUrl: audioUrl ?? this.audioUrl,
      audioFilePath: audioFilePath ?? this.audioFilePath,
    );
  }

  @override
  List<Object?> get props => [
    autovalidateMode,
    uuid,
    author,
    title,
    text,
    key,
    audioUrl,
    audioFilePath,
  ];
}

final class SongsEditInitial extends SongsEditState {
  const SongsEditInitial()
      : super(
            autovalidateMode: AutovalidateMode.disabled,
            uuid: '',
            author: '',
            title: '',
            text: '',
            key: '',
            audioUrl: null,
            audioFilePath: null);
}
