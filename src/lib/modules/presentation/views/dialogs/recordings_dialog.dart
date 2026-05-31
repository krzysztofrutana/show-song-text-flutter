import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/widgets/audio_player_bar.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/recording_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/recordings_repository.dart';

class RecordingsDialog extends StatefulWidget {
  const RecordingsDialog({super.key, required this.songUuid});

  final String songUuid;

  @override
  State<RecordingsDialog> createState() => _RecordingsDialogState();
}

class _RecordingsDialogState extends State<RecordingsDialog> {
  final _repo = sl<RecordingsRepository>();
  AudioPlayer? _player;
  Recording? _currentRecording;
  StreamSubscription? _completionSub;

  @override
  void dispose() {
    _completionSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  void _play(Recording recording) {
    _completionSub?.cancel();
    setState(() {
      _currentRecording = recording;
    });
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
    final recordings = _repo.getBySongUuid(widget.songUuid);

    return AlertDialog(
      title: Text(loc.recordings),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_player != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AudioPlayerBar(player: _player!),
              ),
            if (_player != null) const Divider(),
            if (recordings.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(loc.noRecordings),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recordings.length,
                  itemBuilder: (ctx, i) {
                    final rec = recordings[i];
                    final isCurrent = _currentRecording?.uuid == rec.uuid;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCurrent ? Icons.stop : Icons.play_arrow,
                        size: 20,
                      ),
                      onTap: () => isCurrent ? _stopPlayback() : _play(rec),
                      title: Text(
                        rec.createdAt.toIso8601String().substring(0, 16),
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        _fmt(Duration(milliseconds: rec.durationMs)),
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _delete(rec),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _player?.stop();
            _player?.dispose();
            Navigator.of(context).pop();
          },
          child: Text(loc.exit),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
