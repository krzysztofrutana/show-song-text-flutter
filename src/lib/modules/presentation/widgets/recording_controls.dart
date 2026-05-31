import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/dialogs/recordings_dialog.dart';

class RecordingControls extends StatelessWidget {
  const RecordingControls({
    super.key,
    required this.songUuid,
    this.isRecording,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.compact,
    this.onToggleRecordingPanel,
  });

  final String songUuid;
  final bool? isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool compact;
  final VoidCallback? onToggleRecordingPanel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return const SizedBox.shrink();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isRecording == true
                  ? Icons.stop_circle_outlined
                  : Icons.mic,
              color: isRecording == true ? Colors.red : null,
            ),
            onPressed:
                isRecording == true
                    ? onStopRecording
                    : onStartRecording,
            tooltip: isRecording == true
                ? loc.stopRecording
                : loc.record,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showList(context),
            tooltip: loc.recordingsList,
          ),
        ],
      );
    }

    return Row(
      children: [
        if (isRecording == true)
          TextButton.icon(
            onPressed: onStopRecording,
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
            label: Text(loc.stopRecording, style: const TextStyle(color: Colors.red)),
          )
        else
          TextButton.icon(
            onPressed: onStartRecording,
            icon: const Icon(Icons.mic),
            label: Text(loc.record),
          ),
        TextButton.icon(
          onPressed: () => _showList(context),
          icon: const Icon(Icons.list),
          label: Text(loc.recordingsList),
        ),
      ],
    );
  }

  void _showList(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RecordingsDialog(songUuid: songUuid),
    );
  }
}
