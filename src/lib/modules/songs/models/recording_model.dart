import 'package:equatable/equatable.dart';
import 'package:hive_ce_flutter/adapters.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 3)
class Recording extends Equatable {
  const Recording({
    required this.uuid,
    required this.songUuid,
    required this.filePath,
    required this.durationMs,
    required this.createdAt,
  });

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String songUuid;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final int durationMs;

  @HiveField(4)
  final DateTime createdAt;

  Recording copyWith({
    String? uuid,
    String? songUuid,
    String? filePath,
    int? durationMs,
    DateTime? createdAt,
  }) {
    return Recording(
      uuid: uuid ?? this.uuid,
      songUuid: songUuid ?? this.songUuid,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [uuid, songUuid, filePath, durationMs, createdAt];
}
