import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/ui_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/views/add_playlist_dialog.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';

class SongsUIHelper {
  static Future<void> showAddSongsToPlaylistModal({
    required BuildContext context,
    required List<String> selectedSongsIds,
    String? successMessage,
    VoidCallback? onSuccess,
  }) async {
    final localizations = AppLocalizations.of(context)!;
    final playlistsRepository = sl<PlaylistsRepository>();
    final playlists = playlistsRepository.getAllPlaylists();

    if (selectedSongsIds.isEmpty) {
      return showNoSongsSelectedDialog(context);
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text(localizations.addingToPlaylist),
          children: _getPlaylistsOptions(
            context: context,
            dialogContext: dialogContext,
            playlists: playlists,
            selectedSongsIds: selectedSongsIds,
            successMessage: successMessage,
            onSuccess: onSuccess,
          ),
        );
      },
    );
  }

  static Future<void> showNoSongsSelectedDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            localizations.noSongsSelected,
            style: const TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(localizations.toAddToPlaylistSelectSongs),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  static List<Widget> _getPlaylistsOptions({
    required BuildContext context,
    required BuildContext dialogContext,
    required Iterable<Playlist> playlists,
    required List<String> selectedSongsIds,
    String? successMessage,
    VoidCallback? onSuccess,
  }) {
    final localizations = AppLocalizations.of(context)!;

    final options = <Widget>[
      SimpleDialogOption(
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline),
            const SizedBox(width: 10),
            Text(localizations.toNewPlaylist),
          ],
        ),
        onPressed: () async {
          Navigator.of(dialogContext).pop();
          if (!context.mounted) return;
          await showCreatePlaylistModal(
            context: context,
            selectedSongsIds: selectedSongsIds,
            successMessage: successMessage,
            onSuccess: onSuccess,
          );
        },
      ),
    ];

    if (playlists.isNotEmpty) {
      options.add(const Divider());
      options.addAll(
        playlists.map(
          (playlist) => SimpleDialogOption(
            child: Text(playlist.name),
            onPressed: () {
              _addSongsToPlaylist(playlist.uuid, selectedSongsIds);

              Navigator.of(dialogContext).pop();

              if (context.mounted) {
                UIHelper.showSnackBar(
                  context,
                  successMessage ?? localizations.addedSelectedToPlaylist,
                );
              }

              if (onSuccess != null) {
                onSuccess();
              }
            },
          ),
        ),
      );
    }

    return options;
  }

  static void _addSongsToPlaylist(String playlistId, List<String> songIds) {
    final playlistsRepository = sl<PlaylistsRepository>();
    final playlist = playlistsRepository.getPlaylist(playlistId);

    if (playlist != null) {
      final updatedSongsIds = List<String>.from(playlist.songsIds)
        ..addAll(songIds);
      playlistsRepository.updatePlaylist(
        playlist.copyWith(songsIds: updatedSongsIds),
      );
    }
  }

  static Future<void> showCreatePlaylistModal({
    required BuildContext context,
    required List<String> selectedSongsIds,
    String? successMessage,
    VoidCallback? onSuccess,
  }) async {
    final localizations = AppLocalizations.of(context)!;
    context.read<AddPlaylistBloc>().add(
      PlaylistSetSelectedSongs(selectedSongsIds),
    );

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AddPlaylistDialog();
      },
    );

    if (result != null) {
      if (context.mounted) {
        UIHelper.showSnackBar(
          context,
          successMessage ?? localizations.addedSelectedToPlaylist,
        );
      }
      if (onSuccess != null) {
        onSuccess();
      }
    }
  }
}
