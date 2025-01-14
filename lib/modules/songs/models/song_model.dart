import 'package:hive_flutter/hive_flutter.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class Song {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  String text;

  @HiveField(4)
  String key;

  bool selected = false;

  Song(
      {required this.uuid,
      required this.title,
      required this.author,
      required this.text,
      required this.key});
}
