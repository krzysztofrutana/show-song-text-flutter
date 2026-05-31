import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pomocnik_wokalisty/helpers/recording_mixin.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/widgets/audio_player_bar.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/recording_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/recordings_repository.dart';

class SongRecordingsListComponent extends StatefulWidget {
  const SongRecordingsListComponent({super.key, required this.songId});
  final String songId;

  @override
  State<SongRecordingsListComponent> createState() =>
      _SongRecordingsListComponentState();
}

class _SongRecordingsListComponentState
    extends State<SongRecordingsListComponent>
    with RecordingMixin {
  final _repo = sl<RecordingsRepository>();
  AudioPlayer? _player;
  Recording? _currentRecording;
  StreamSubscription? _completionSub;

  @override
  void dispose() {
    _completionSub?.cancel();
    _player?.dispose();
    cancelRecording();
    super.dispose();
  }

  void _play(Recording recording) {
    _completionSub?.cancel();
    setState(() => _currentRecording = recording);
    _player?.stop();
    _player?.dispose();

    final player = AudioPlayer();
    player.setAudioSource(AudioSource.file(recording.filePath));
    player.play();
    _player = player;

    _completionSub = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _stopPlayback();
      }
    });

    if (mounted) setState(() {});
  }

  void _stopPlayback() {
    _completionSub?.cancel();
    _completionSub = null;
    _player?.stop();
    _player?.dispose();
    _player = null;
    _currentRecording = null;
    if (mounted) setState(() {});
  }

  Future<void> _delete(Recording recording) async {
    File(recording.filePath).delete();
    await _repo.deleteRecording(recording.uuid);

    if (_currentRecording?.uuid == recording.uuid) {
      _stopPlayback();
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final recordings = _repo.getBySongUuid(widget.songId);
    final hasRecordings = recordings.isNotEmpty;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: loc.recordings,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_player != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AudioPlayerBar(player: _player!),
              ),
            ),
          if (isRecording)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  buildRecordingProgressIndicator(),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => stopRecording(widget.songId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.stop_circle_outlined,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.stopRecording,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (!hasRecordings)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => startRecording(widget.songId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mic),
                      const SizedBox(height: 4),
                      Text(loc.addFirstRecording),
                    ],
                  ),
                ),
              ),
            if (hasRecordings)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recordings.length,
                itemBuilder: (ctx, i) {
                  final rec = recordings[i];
                  final isCurrent = _currentRecording?.uuid == rec.uuid;
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(isCurrent ? Icons.stop : Icons.play_arrow),
                      onPressed: () => isCurrent ? _stopPlayback() : _play(rec),
                    ),
                    title: Text(
                      rec.createdAt.toIso8601String().substring(0, 16),
                    ),
                    subtitle: Text(
                      _fmt(Duration(milliseconds: rec.durationMs)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(rec),
                    ),
                    contentPadding: const EdgeInsets.only(),
                  );
                },
              ),
            if (hasRecordings)
              ElevatedButton(
                onPressed: () => startRecording(widget.songId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mic),
                    const SizedBox(height: 4),
                    Text(loc.record),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
