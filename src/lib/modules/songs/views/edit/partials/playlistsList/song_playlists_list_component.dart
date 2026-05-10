import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/models/playlist_include_song_model.dart';

class SongPlaylistsListComponent extends StatefulWidget {
  const SongPlaylistsListComponent({super.key, required this.songId});
  final String songId;

  @override
  State<SongPlaylistsListComponent> createState() =>
      _SongPlaylistsListComponentState();
}

class _SongPlaylistsListComponentState
    extends State<SongPlaylistsListComponent> {
  List<PlaylistIncludeSongModel> playlists = [];

  @override
  void initState() {
    super.initState();

    initPlaylistsList();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)!.playlistsToWhichSongHasBeenAdded,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
      child:
          playlists.isEmpty
              ? Center(
                heightFactor: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.noPlaylists,
                    textAlign: TextAlign.center,
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

  void initPlaylistsList() {
    setState(() {
      playlists = [];
      final repository = sl<PlaylistsRepository>();
      final playlistsIncludeSong =
          repository
              .getAllPlaylists()
              .where(
                (playlist) =>
                    playlist.songsIds.any((songId) => songId == widget.songId),
              )
              .toList();

      for (final playlist in playlistsIncludeSong) {
        for (var i = 0; i < playlist.songsIds.length; i++) {
          if (playlist.songsIds[i] == widget.songId) {
            playlists.add(
              PlaylistIncludeSongModel(playlist: playlist, position: i),
            );
          }
        }
      }
    });
  }

  _removeSongFromPlaylis(
    PlaylistIncludeSongModel playlistModel,
    BuildContext parentContext,
  ) {
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

                initPlaylistsList();

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
