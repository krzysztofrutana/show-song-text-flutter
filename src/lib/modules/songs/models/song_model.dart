import 'package:equatable/equatable.dart';
import 'package:hive_ce_flutter/adapters.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class Song extends Equatable {
  const Song({
    required this.uuid,
    required this.title,
    required this.author,
    required this.text,
    this.audioUrl,
    this.audioFilePath,
    this.audioCachePath,
    this.audioCachedUrl,
  });

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String? audioUrl;

  @HiveField(5)
  final String? audioFilePath;

  @HiveField(6)
  final String? audioCachePath;

  @HiveField(7)
  final String? audioCachedUrl;

  Song copyWith({
    String? uuid,
    String? title,
    String? author,
    String? text,
    String? audioUrl,
    String? audioFilePath,
    String? audioCachePath,
    String? audioCachedUrl,
  }) {
    return Song(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      author: author ?? this.author,
      text: text ?? this.text,
      audioUrl: audioUrl ?? this.audioUrl,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      audioCachePath: audioCachePath ?? this.audioCachePath,
      audioCachedUrl: audioCachedUrl ?? this.audioCachedUrl,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    title,
    author,
    text,
    audioUrl,
    audioFilePath,
    audioCachePath,
    audioCachedUrl,
  ];
}
