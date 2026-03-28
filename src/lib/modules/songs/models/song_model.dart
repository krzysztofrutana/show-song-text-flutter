import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class Song extends Equatable {
  const Song({
    required this.uuid,
    required this.title,
    required this.author,
    required this.text,
  });

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String text;

  Song copyWith({
    String? uuid,
    String? title,
    String? author,
    String? text,
  }) {
    return Song(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      author: author ?? this.author,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [uuid, title, author, text];
}
