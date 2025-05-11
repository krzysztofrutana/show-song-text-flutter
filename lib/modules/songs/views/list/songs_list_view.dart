import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/bloc/edit_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/songs_add.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/songs_list_component.dart';

class SongsList extends StatefulWidget {
  const SongsList({super.key});

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const SongsListComponent(),
        floatingActionButton:
            BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
                builder: (context, state) => Visibility(
                      visible: state.chooseSongs == false,
                      child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          child: const Icon(
                            Icons.add,
                            size: 30,
                          ),
                          onPressed: () => _redirectToSongsAdd(context)),
                    )),
        bottomNavigationBar:
            BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
          builder: (internalContext, state) {
            return Visibility(
              visible: state.chooseSongs == true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MaterialButton(
                      height: 70,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined),
                          SizedBox(width: 8),
                          Text('Anuluj')
                        ],
                      ),
                      onPressed: () => internalContext
                          .read<SongsListComponentBloc>()
                          .add(ChooseSongChangeEvent(value: false)),
                    ),
                  ),
                  Expanded(
                      child: MaterialButton(
                          height: 70,
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                  AssetImage('assets/images/icons/delete.png')),
                              SizedBox(width: 8),
                              Text('Usuń')
                            ],
                          ),
                          onPressed: () =>
                              _showDeleteConfirmModal(internalContext))),
                  Expanded(
                    child: MaterialButton(
                      height: 70,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                              AssetImage('assets/images/icons/playlist.png')),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('Utwórz'), Text('playlistę')],
                          )
                        ],
                      ),
                      onPressed: () =>
                          _showCreatePlaylistModal(internalContext),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      height: 70,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                              AssetImage('assets/images/icons/playlist.png')),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('Dodaj do'), Text('playlisty')],
                          )
                        ],
                      ),
                      onPressed: () =>
                          _showAddSelectedToExistPlaylistModal(internalContext),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      height: 70,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(AssetImage(
                              'assets/images/icons/presentation.png')),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                'Prezentacja',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          )
                        ],
                      ),
                      onPressed: () =>
                          _runPresentationForSelected(internalContext),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  void _redirectToSongsAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongsAdd(),
      ),
    );
  }

  Future<void> _showDeleteConfirmModal(BuildContext parentContext) async {
    var selectedSongsLength =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs.length;

    if (selectedSongsLength == 0) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Brak zaznaczonych utworów',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Należy zaznaczyć utwory do usunięcia'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usuwanie utworów'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Czy na pewno chcesz usunąć zaznaczone utwory?'),
                  Text('Liczba utworów: $selectedSongsLength'),
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
                  parentContext
                      .read<SongsListComponentBloc>()
                      .add(RemoveSelectedSongsEvent());

                  parentContext
                      .read<SongsListComponentBloc>()
                      .add(ReloadListEvent());

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showCreatePlaylistModal(BuildContext parentContext) async {
    var selectedSongs =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs;

    parentContext
        .read<AddPlaylistBloc>()
        .add(PlaylistSetSelectedSongs(selectedSongs));

    if (selectedSongs.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Brak zaznaczonych utworów',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('By utworzyć playlistę należy wybrać utwory'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Dodawanie playlisty'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ListBody(
                    children: <Widget>[
                      Text('Liczba utworów: ${selectedSongs.length}'),
                      TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Wprowadź nazwę',
                            labelText: 'Nazwa',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nazwa jest wymagana';
                            }
                            return null;
                          },
                          onChanged: (value) => parentContext
                              .read<AddPlaylistBloc>()
                              .add(PlaylistAddNameChange(value)))
                    ],
                  ),
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
                  parentContext.read<AddPlaylistBloc>().add(AddPlaylistSave());
                  parentContext.read<AddPlaylistBloc>().add(AddPlaylistReset());

                  parentContext
                      .read<SongsListComponentBloc>()
                      .add(ClearSelectedSongs());

                  parentContext
                      .read<SongsListComponentBloc>()
                      .add(ChooseSongChangeEvent(value: false));

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showAddSelectedToExistPlaylistModal(
      BuildContext parentContext) async {
    var selectedSongs =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs;

    var playlists = DataCollections.playlists();

    parentContext
        .read<AddPlaylistBloc>()
        .add(PlaylistSetSelectedSongs(selectedSongs));

    if (selectedSongs.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Brak zaznaczonych utworów',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('By dodać do playlisty należy wybrać utwory'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Dodawanie do playlisty'),
            children: _getPlaylistsOptions(
                playlists.values, selectedSongs, parentContext, context),
          );
        },
      );
    }
  }

  List<SimpleDialogOption> _getPlaylistsOptions(
      Iterable<Playlist> playlists,
      List<String> selectedSongs,
      BuildContext parentContext,
      BuildContext context) {
    return playlists
        .map((playlist) => SimpleDialogOption(
            child: Text(playlist.name),
            onPressed: () {
              parentContext.read<EditPlaylistBloc>().add(
                  AddSelectedSongsToPlaylist(playlist.uuid, selectedSongs));
              parentContext
                  .read<SongsListComponentBloc>()
                  .add(ClearSelectedSongs());
              parentContext
                  .read<SongsListComponentBloc>()
                  .add(ChooseSongChangeEvent(value: false));

              Navigator.of(context).pop();
            }))
        .toList();
  }

  void _runPresentationForSelected(BuildContext parentContext) async {
    var selectedSongs =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs;

    var box = DataCollections.songs();
    var songs =
        box.values.where((song) => selectedSongs.contains(song.uuid)).toList();

    parentContext
        .read<PresentatationBloc>()
        .add(SongsPresentation(songs: songs));

    Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (parentContext) => PresentationView(),
      ),
    );
  }
}
