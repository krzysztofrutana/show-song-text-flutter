import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubit/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/views/dialogs/song_selection_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

class PlaylistSongsListComponent extends StatefulWidget {
  const PlaylistSongsListComponent({
    super.key,
    required this.playlistEditCubit,
  });

  final PlaylistEditCubit playlistEditCubit;

  @override
  State<PlaylistSongsListComponent> createState() =>
      _PlaylistSongsListComponentState();
}

class _PlaylistSongsListComponentState
    extends State<PlaylistSongsListComponent> {
  List<Song> songs = [];
  List<Song> availableSongs = [];

  @override
  void initState() {
    super.initState();

    initSongsList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocListener<PlaylistEditCubit, PlaylistEditState>(
      listenWhen: (previous, current) => previous.songsIds != current.songsIds,
      listener: (context, state) {
        initSongsList();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: localizations.songsAddedToPlaylist,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child:
                songs.isEmpty
                    ? Center(
                      heightFactor: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showSongSelectionDialog(context),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add),
                              const SizedBox(height: 4),
                              Text(
                                localizations.noSongs,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : ReorderableListView(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      children: <Widget>[
                        for (int index = 0; index < songs.length; index += 1)
                          ReorderableDelayedDragStartListener(
                            key: Key('$index'),
                            index: index,
                            child: ListTile(
                              leading: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_indicator),
                              ),
                              title: Text(
                                "${index + 1}. ${songs[index].title}",
                              ),
                              subtitle: Text(songs[index].author),
                              titleTextStyle: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              contentPadding: const EdgeInsets.only(),
                              trailing: IconButton(
                                onPressed: () {
                                  _removeSongFromPlaylist(
                                    songs[index],
                                    index,
                                    context,
                                  );
                                },
                                color: Colors.red,
                                icon: const Icon(
                                  Icons.highlight_remove_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = songs.removeAt(oldIndex);
                          songs.insert(newIndex, item);

                          final songsIds = songs.map((x) => x.uuid).toList();

                          widget.playlistEditCubit.updateSongs(songsIds);
                        });
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void initSongsList() {
    setState(() {
      final allSongs = sl<SongsRepository>().getAllSongs();

      songs = [];
      for (var songId in widget.playlistEditCubit.state.songsIds) {
        final song = allSongs.firstWhereOrNull((x) => x.uuid == songId);

        if (song != null) {
          songs.add(song);
        }
      }

      availableSongs =
          allSongs
              .where(
                (song) =>
                    !widget.playlistEditCubit.state.songsIds.contains(
                      song.uuid,
                    ),
              )
              .toList();
    });
  }

  _removeSongFromPlaylist(Song song, int index, BuildContext parentContext) {
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.removingSongFromPlaylist),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(
                    context,
                  )!.areYouSureYouWantRemoveSongFromPlaylistAtPosition(
                    song.author,
                    song.title,
                    index + 1,
                  ),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.changesWillBeImplementedAfterSavingTheForm,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                setState(() {
                  songs.removeAt(index);

                  final songsIds = songs.map((x) => x.uuid).toList();

                  widget.playlistEditCubit.updateSongs(songsIds);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSongSelectionDialog(BuildContext context) async {
    final selectedSongsIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => const SongSelectionDialog(),
    );

    if (selectedSongsIds != null && selectedSongsIds.isNotEmpty) {
      widget.playlistEditCubit.addSongs(selectedSongsIds);
    }
  }
}
