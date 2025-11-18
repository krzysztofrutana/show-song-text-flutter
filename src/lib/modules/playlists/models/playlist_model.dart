import 'package:hive_flutter/hive_flutter.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 2)
class Playlist {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> songsIds;

  bool selected = false;

  Playlist({required this.uuid, required this.name, required this.songsIds});
}
