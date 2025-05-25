import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubic/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class PlaylistSongsListComponent extends StatefulWidget {
  final PlaylistEditCubit playlistEditCubit;
  const PlaylistSongsListComponent(
      {super.key, required this.playlistEditCubit});

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
          labelText: "Utwory dodane do listy odtwarzania",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(0))),
      child: songs.isEmpty
          ? Center(
              heightFactor: 2,
              child: const SizedBox(
                width: double.infinity,
                child: Text("Brak przypisanych utworów",
                    textAlign: TextAlign.center),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(4),
              child: ReorderableListView(
                scrollDirection: Axis.vertical,
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
                              icon: Icon(Icons.remove_circle_outline)),
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
                    final Song item = songs.removeAt(oldIndex);
                    songs.insert(newIndex, item);

                    var songsIds = songs.map((x) => x.uuid).toList();

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
      var songsFromPlaylist = DataCollections.songs()
          .values
          .where((song) =>
              widget.playlistEditCubit.state.songsIds.contains(song.uuid))
          .toList();

      for (var songId in widget.playlistEditCubit.state.songsIds) {
        var song = songsFromPlaylist.firstWhereOrNull((x) => x.uuid == songId);

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
          title: const Text('Usuwanie utworu z listy odtwarzania'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Czy na pewno chcesz usunąć utwór ${song.author} - ${song.title} z listy odtwarzania z pozycji ${index + 1}?'),
                Text('Zmiany zostaną wprowadzone po zapisaniu formularza')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Tak'),
              onPressed: () {
                setState(() {
                  songs.removeAt(index);

                  var songsIds = songs.map((x) => x.uuid).toList();

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
