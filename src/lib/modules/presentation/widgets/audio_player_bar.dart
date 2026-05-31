import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({
    super.key,
    required this.player,
    this.showPlayButton = true,
  });

  final AudioPlayer player;
  final bool showPlayButton;

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _posSub = widget.player.positionStream.listen(
      (pos) => setState(() => _position = pos),
    );
    _durSub = widget.player.durationStream.listen(
      (dur) => setState(() => _duration = dur ?? Duration.zero),
    );
    _stateSub = widget.player.playerStateStream.listen(
      (state) => setState(() => _playing = state.playing),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.showPlayButton)
          IconButton(
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_playing) {
                widget.player.pause();
              } else {
                widget.player.play();
              }
            },
          ),
        Text(
          '${_fmt(_position)} / ${_fmt(_duration)}',
          style: const TextStyle(fontSize: 12),
        ),
        Expanded(
          child: Slider(
            value: _duration.inMilliseconds > 0
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              widget.player.seek(
                Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$mm:$ss' : '$mm:$ss';
  }
}
