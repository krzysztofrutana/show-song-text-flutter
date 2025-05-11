import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';

class PlaylistsList extends StatefulWidget {
  const PlaylistsList({super.key});

  @override
  State<PlaylistsList> createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const PlaylistsListComponent(),
        floatingActionButton: BlocBuilder<PlaylistsListComponentBloc,
                PlaylistsListComponentState>(
            builder: (context, state) => Visibility(
                  visible: state.choosePlaylists == false,
                  child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                      onPressed: () => _showCreatePlaylistModal(context)),
                )),
        bottomNavigationBar: BlocBuilder<PlaylistsListComponentBloc,
            PlaylistsListComponentState>(
          builder: (internalContext, state) {
            return Visibility(
              visible: state.choosePlaylists == true,
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
                          .read<PlaylistsListComponentBloc>()
                          .add(ChoosePlaylistChangeEvent(value: false)),
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
                          ImageIcon(AssetImage(
                              'assets/images/icons/presentation.png')),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('Prezentacja')],
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

  Future<void> _showDeleteConfirmModal(BuildContext parentContext) async {
    var selectedPlaylistsLength = parentContext
        .read<PlaylistsListComponentBloc>()
        .state
        .selectedPlaylists
        .length;

    if (selectedPlaylistsLength == 0) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Brak zaznaczonych list odtwarzania',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Należy zaznaczyć listy do usunięcia'),
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
            title: const Text('Usuwanie list odtwarzania'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Czy na pewno chcesz usunąć zaznaczone listy?'),
                  Text('Liczba list: $selectedPlaylistsLength'),
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
                      .read<PlaylistsListComponentBloc>()
                      .add(RemoveSelectedPlaylistsEvent());

                  parentContext
                      .read<PlaylistsListComponentBloc>()
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

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _runPresentationForSelected(BuildContext parentContext) async {
    var selectedPlaylistsLength = parentContext
        .read<PlaylistsListComponentBloc>()
        .state
        .selectedPlaylists
        .length;

    if (selectedPlaylistsLength == 0) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Brak zaznaczonych list odtwarzania',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Należy zaznaczyć listę do prezentacji '),
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
    } else if (selectedPlaylistsLength > 1) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Prezentacja możliwa tylko dla jednej listy',
              style: TextStyle(fontSize: 20),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Należy zaznaczyć tylko jedną listę do prezentacji'),
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
      var selectedPlaylists = parentContext
          .read<PlaylistsListComponentBloc>()
          .state
          .selectedPlaylists;

      var playlist = DataCollections.playlists().get(selectedPlaylists[0]);

      if (playlist == null) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Błąd',
                style: TextStyle(fontSize: 20),
              ),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Wystąpił błąd przy pobieraniu informacji o liście'),
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
      }

      parentContext
          .read<PresentatationBloc>()
          .add(PlaylistPresentation(playlist: playlist));

      Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (parentContext) => PresentationView(),
        ),
      );
    }
  }
}
