import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubit/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';

class PlaylistSongsListComponent extends StatefulWidget {
  const PlaylistSongsListComponent(
      {super.key, required this.playlistEditCubit});

  final PlaylistEditCubit playlistEditCubit;

  @override
  State<PlaylistSongsListComponent> createState() =>
      _PlaylistSongsListComponentState();
}

class _PlaylistSongsListComponentState
    extends State<PlaylistSongsListComponent> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();

    initSongsList();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.songsAddedToPlaylist,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(0))),
      child: songs.isEmpty
          ? Center(
              heightFactor: 2,
              child: SizedBox(
                width: double.infinity,
                child: Text(AppLocalizations.of(context)!.noSongsAssigned,
                    textAlign: TextAlign.center),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(4),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                children: <Widget>[
                  for (int index = 0; index < songs.length; index += 1)
                    ListTile(
                      key: Key('$index'),
                      title: Text("${index + 1}. ${songs[index].title}"),
                      subtitle: Text(songs[index].author),
                      titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                      trailing: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        children: [
                          IconButton(
                              onPressed: () {
                                _removeSongFromPlaylis(
                                    songs[index], index, context);
                              },
                              icon: const Icon(Icons.remove_circle_outline)),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                    )
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
    );
  }

  void initSongsList() {
    setState(() {
      songs = [];
      final allSongs = sl<SongsRepository>().getAllSongs();
      final songsFromPlaylist = allSongs
          .where((song) =>
              widget.playlistEditCubit.state.songsIds.contains(song.uuid))
          .toList();

      for (var songId in widget.playlistEditCubit.state.songsIds) {
        final song =
            songsFromPlaylist.firstWhereOrNull((x) => x.uuid == songId);

        if (song != null) {
          songs.add(song);
        }
      }
    });
  }

  _removeSongFromPlaylis(Song song, int index, BuildContext parentContext) {
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.removingSongFromPlaylist),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!
                    .areYouSureYouWantRemoveSongFromPlaylistAtPosition(
                        song.author, song.title, index + 1)),
                Text(AppLocalizations.of(context)!
                    .changesWillBeImplementedAfterSavingTheForm)
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
}
