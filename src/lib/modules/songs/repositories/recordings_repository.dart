import 'package:hive_ce_flutter/adapters.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/recording_model.dart';

class RecordingsRepository {
  RecordingsRepository({Box<Recording>? box})
    : _box = box ?? DataCollections.recordings();

  final Box<Recording> _box;

  List<Recording> getAllRecordings() {
    return _box.values.toList();
  }

  List<Recording> getBySongUuid(String songUuid) {
    final result = _box.values.where((r) => r.songUuid == songUuid).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> addRecording(Recording recording) async {
    await _box.put(recording.uuid, recording);
  }

  Future<void> deleteRecording(String uuid) async {
    await _box.delete(uuid);
  }

  Future<void> deleteBySongUuid(String songUuid) async {
    final keys = _box.values
        .where((r) => r.songUuid == songUuid)
        .map((r) => r.uuid)
        .toList();
    for (final key in keys) {
      await _box.delete(key);
    }
  }
}
