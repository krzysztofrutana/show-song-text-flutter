import 'package:equatable/equatable.dart';
import 'package:hive_ce_flutter/adapters.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 2)
class Playlist extends Equatable {
  const Playlist({
    required this.uuid,
    required this.name,
    required this.songsIds,
  });

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> songsIds;

  Playlist copyWith({String? uuid, String? name, List<String>? songsIds}) {
    return Playlist(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      songsIds: songsIds ?? this.songsIds,
    );
  }

  @override
  List<Object?> get props => [uuid, name, songsIds];
}
