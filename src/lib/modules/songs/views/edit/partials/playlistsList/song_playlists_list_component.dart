import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/models/playlist_include_song_model.dart';

class SongPlaylistsListComponent extends StatefulWidget {
  const SongPlaylistsListComponent({
    super.key,
    required this.songId,
    this.onAddToPlaylist,
  });
  final String songId;
  final VoidCallback? onAddToPlaylist;

  @override
  State<SongPlaylistsListComponent> createState() =>
      _SongPlaylistsListComponentState();
}

class _SongPlaylistsListComponentState
    extends State<SongPlaylistsListComponent> {
  @override
  Widget build(BuildContext context) {
    final playlists = sl<PlaylistsRepository>().getBySongId(widget.songId);

    return InputDecorator(
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)!.playlistsToWhichSongHasBeenAdded,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
      child:
          playlists.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onAddToPlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.playlist_add),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context)!.addToFirstPlaylist),
                      ],
                    ),
                  ),
                ),
              )
              : Container(
                padding: const EdgeInsets.all(4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final playlistModel = playlists[index];
                    return ListTile(
                      title: Text(playlistModel.playlist.name),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        )!.position(playlistModel.position + 1),
                      ),
                      titleTextStyle: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      contentPadding: const EdgeInsets.only(),
                      trailing: IconButton(
                        onPressed: () {
                          _removeSongFromPlaylis(playlistModel, context);
                        },
                        color: Colors.red,
                        icon: const Icon(Icons.highlight_remove_outlined),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Future<void> _removeSongFromPlaylis(
    PlaylistIncludeSongModel playlistModel,
    BuildContext parentContext,
  ) async {
    final localizations = AppLocalizations.of(parentContext)!;
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.removingSongFromPlaylist),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  localizations
                      .areYouSureYouWantRemoveCurrentSongFromPlaylistAtPosition(
                        playlistModel.playlist.name,
                        playlistModel.position + 1,
                      ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.yes),
              onPressed: () async {
                final repository = sl<PlaylistsRepository>();
                final updated = playlistModel.playlist.copyWith(
                  songsIds: List<String>.from(playlistModel.playlist.songsIds)
                    ..removeAt(playlistModel.position),
                );
                await repository.updatePlaylist(updated);

                if (mounted) setState(() {});

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
