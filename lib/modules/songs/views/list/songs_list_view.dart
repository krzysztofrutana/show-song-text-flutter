import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
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
            final size = MediaQuery.of(context).size;
            var iconSize = size.width * 0.07; // skalowanie ikony
            var fontSize = size.width * 0.03; // skalowanie tekstu

            if (iconSize > 20) iconSize = 20;
            if (fontSize > 14) fontSize = 14;

            return Visibility(
              visible: state.chooseSongs == true,
              child: SizedBox(
                height: size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      minWidth: 0,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: iconSize),
                          SizedBox(height: 4),
                          Text(
                              LocalizationManager
                                  .instance.appLocalization.cancel,
                              style: TextStyle(fontSize: fontSize))
                        ],
                      ),
                      onPressed: () {
                        internalContext
                            .read<SongsListComponentBloc>()
                            .add(ClearSelectedSongs());

                        internalContext
                            .read<SongsListComponentBloc>()
                            .add(ChooseSongChangeEvent(value: false));
                      },
                    ),
                    MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                                AssetImage('assets/images/icons/delete.png'),
                                size: iconSize),
                            SizedBox(height: 4),
                            Text(
                                LocalizationManager
                                    .instance.appLocalization.delete,
                                style: TextStyle(fontSize: fontSize))
                          ],
                        ),
                        onPressed: () =>
                            _showDeleteConfirmModal(internalContext)),
                    MaterialButton(
                      minWidth: 0,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                              AssetImage('assets/images/icons/playlist.png'),
                              size: iconSize),
                          SizedBox(width: 4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.create,
                                  style: TextStyle(fontSize: fontSize)),
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.playlist,
                                  style: TextStyle(fontSize: fontSize))
                            ],
                          )
                        ],
                      ),
                      onPressed: () =>
                          _showCreatePlaylistModal(internalContext),
                    ),
                    MaterialButton(
                      minWidth: 0,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage('assets/images/icons/playlist.png'),
                            size: iconSize,
                          ),
                          SizedBox(height: 4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.addTo,
                                  style: TextStyle(fontSize: fontSize)),
                              Text(
                                  LocalizationManager.instance.appLocalization
                                      .addToPlaylistSentence,
                                  style: TextStyle(fontSize: fontSize))
                            ],
                          )
                        ],
                      ),
                      onPressed: () =>
                          _showAddSelectedToExistPlaylistModal(internalContext),
                    ),
                    MaterialButton(
                      minWidth: 0,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(
                                  'assets/images/icons/presentation.png'),
                              size: iconSize,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                                LocalizationManager
                                    .instance.appLocalization.presentiaton,
                                style: TextStyle(fontSize: fontSize))
                          ]),
                      onPressed: () =>
                          _runPresentationForSelected(internalContext),
                    )
                  ],
                ),
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
      return showNoSongsSelectedDialog(LocalizationManager
          .instance.appLocalization.youMustMarkSongsToBeDeleted);
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                LocalizationManager.instance.appLocalization.deletingSongs),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(LocalizationManager.instance.appLocalization
                      .areYouSureYouWantDeleteSelectedSongs),
                  Text(LocalizationManager.instance.appLocalization
                      .numberOfSongs(selectedSongsLength)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text(LocalizationManager.instance.appLocalization.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(LocalizationManager.instance.appLocalization.yes),
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
      return showNoSongsSelectedDialog(LocalizationManager
          .instance.appLocalization.toCreatePlaylistYouNeedToSelectSongs);
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                LocalizationManager.instance.appLocalization.addingPlaylist),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ListBody(
                    children: <Widget>[
                      Text(LocalizationManager.instance.appLocalization
                          .numberOfSongs(selectedSongs.length)),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: LocalizationManager
                                  .instance.appLocalization.enterName,
                              labelText: LocalizationManager
                                  .instance.appLocalization.name),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocalizationManager
                                  .instance.appLocalization.nameIsRequired;
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
                child:
                    Text(LocalizationManager.instance.appLocalization.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(LocalizationManager.instance.appLocalization.yes),
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
      return showNoSongsSelectedDialog(LocalizationManager
          .instance.appLocalization.toAddToPlaylistSelectSongs);
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
                LocalizationManager.instance.appLocalization.addingToPlaylist),
            children: _getPlaylistsOptions(
                playlists.values, selectedSongs, parentContext, context),
          );
        },
      );
    }
  }

  Future<void> showNoSongsSelectedDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationManager.instance.appLocalization.noSongsSelected,
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
              _addSongsToPlaylist(playlist.uuid, selectedSongs);

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

  void _addSongsToPlaylist(String playlistId, List<String> selectedSongs) {
    var playlists = DataCollections.playlists();
    var playlist = playlists.get(playlistId);

    playlist!.songsIds.addAll(selectedSongs);

    playlists.put(playlist.uuid, playlist);
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
