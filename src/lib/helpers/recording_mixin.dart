import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomocnik_wokalisty/helpers/ui_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/recording_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/recordings_repository.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

mixin RecordingMixin<T extends StatefulWidget> on State<T> {
  bool isRecording = false;
  int recordingElapsedSec = 0;
  AudioRecorder? _recorder;
  Timer? _recordingTimer;

  void cancelRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recorder?.cancel();
    _recorder = null;
    isRecording = false;
  }

  Future<void> startRecording(String songId) async {
    if (!await AudioRecorder().hasPermission()) return;

    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${dir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final uuid = const Uuid().v8();
    final path = '${recordingsDir.path}/$uuid.m4a';

    _recorder = AudioRecorder();
    await _recorder!.start(const RecordConfig(), path: path);

    recordingElapsedSec = 0;
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        recordingElapsedSec++;
        if (mounted) setState(() {});
      },
    );
    if (mounted) setState(() => isRecording = true);
  }

  Future<void> stopRecording(String songId) async {
    if (_recorder == null) return;

    try {
      final path = await _recorder!.stop();
      _recorder = null;

      if (path == null) {
        if (mounted) _showRecordingError();
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        if (mounted) _showRecordingError();
        return;
      }

      final durationMs = await _getFileDuration(path);

      final recording = Recording(
        uuid: const Uuid().v8(),
        songUuid: songId,
        filePath: path,
        durationMs: durationMs,
        createdAt: DateTime.now(),
      );

      await sl<RecordingsRepository>().addRecording(recording);
    } catch (e) {
      if (mounted) _showRecordingError();
    } finally {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      isRecording = false;
      if (mounted) setState(() {});
    }
  }

  void _showRecordingError() {
    UIHelper.showErrorSnackBar(
      context,
      AppLocalizations.of(context)!.recordingSaveError,
    );
  }

  Future<int> _getFileDuration(String path) async {
    final player = AudioPlayer();
    try {
      await player.setAudioSource(AudioSource.file(path));
      return player.duration?.inMilliseconds ?? 0;
    } catch (_) {
      return 0;
    } finally {
      player.dispose();
    }
  }

  Widget buildRecordingProgressIndicator() {
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 4),
        Text(
          '${(recordingElapsedSec ~/ 60).toString().padLeft(2, '0')}:${(recordingElapsedSec % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
