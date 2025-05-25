import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/models/playlist_include_song_model.dart';

class SongPlaylistsListComponent extends StatefulWidget {
  final String songId;
  const SongPlaylistsListComponent({super.key, required this.songId});

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
          labelText: "Listy odtwarzania do których dodano utwór",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(0))),
      child: playlists.isEmpty
          ? Center(
              heightFactor: 2,
              child: const SizedBox(
                width: double.infinity,
                child:
                    Text("Brak list odtwarzania", textAlign: TextAlign.center),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(4),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: playlists.length,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  final playlistModel = playlists[index];
                  return ListTile(
                    title: Text(playlistModel.playlist.name),
                    subtitle: Text("Pozycja: ${playlistModel.position + 1}"),
                    titleTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                    trailing: IconButton(
                        onPressed: () {
                          _removeSongFromPlaylis(playlistModel, context);
                        },
                        icon: Icon(Icons.remove_circle_outline)),
                  );
                },
              ),
            ),
    );
  }

  void initPlaylistsList() {
    setState(() {
      playlists = [];
      var playlistsIncludeSong = DataCollections.playlists()
          .values
          .where((playlist) =>
              playlist.songsIds.any((songId) => songId == widget.songId))
          .toList();

      for (var playlist in playlistsIncludeSong) {
        for (var i = 0; i < playlist.songsIds.length; i++) {
          if (playlist.songsIds[i] == widget.songId) {
            playlists
                .add(PlaylistIncludeSongModel(playlist: playlist, position: i));
          }
        }
      }
    });
  }

  _removeSongFromPlaylis(
      PlaylistIncludeSongModel playlistModel, BuildContext parentContext) {
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
                    'Czy na pewno chcesz usunąć utwór z listy odtwarzania ${playlistModel.playlist.name} z pozycji ${playlistModel.position + 1}?'),
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
                playlistModel.playlist.songsIds
                    .removeAt(playlistModel.position);
                var playlistsBox = DataCollections.playlists();
                playlistsBox.put(
                    playlistModel.playlist.uuid, playlistModel.playlist);

                initPlaylistsList();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
