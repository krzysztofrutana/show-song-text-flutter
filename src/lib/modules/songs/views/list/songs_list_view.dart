import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/songs_add.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubic/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/songs_list_component.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:uuid/uuid.dart';

class SongsList extends StatefulWidget {
  const SongsList({super.key});

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> with InterstitialAds {
  @override
  void initState() {
    super.initState();
    initializeInterstitialMobileAdsSDK();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const SongsListComponent(),
        floatingActionButton:
            BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
                builder: (context, state) => Visibility(
                      visible: state.chooseSongs == false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          FloatingActionButton(
                              heroTag: "quickSearch",
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              child: const Icon(
                                Icons.manage_search,
                                size: 30,
                              ),
                              onPressed: () => _showQuickAddModal(context)),
                          FloatingActionButton(
                              heroTag: "add",
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              child: const Icon(
                                Icons.add,
                                size: 30,
                              ),
                              onPressed: () => _redirectToSongsAdd(context)),
                        ],
                      ),
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
                    Expanded(
                      child: MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Icon(Icons.cancel_outlined, size: iconSize),
                            Text(
                                LocalizationManager
                                    .instance.appLocalization.cancel,
                                style: TextStyle(fontSize: fontSize),
                                textAlign: TextAlign.center)
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
                    ),
                    Expanded(
                      child: MaterialButton(
                          minWidth: 0,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              ImageIcon(
                                  AssetImage('assets/images/icons/delete.png'),
                                  size: iconSize),
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.delete,
                                  style: TextStyle(fontSize: fontSize),
                                  textAlign: TextAlign.center)
                            ],
                          ),
                          onPressed: () =>
                              _showDeleteConfirmModal(internalContext)),
                    ),
                    Expanded(
                      child: MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                                AssetImage('assets/images/icons/playlist.png'),
                                size: iconSize),
                            Text(
                                LocalizationManager
                                    .instance.appLocalization.createPlaylist,
                                style: TextStyle(fontSize: fontSize),
                                textAlign: TextAlign.center)
                          ],
                        ),
                        onPressed: () =>
                            _showCreatePlaylistModal(internalContext),
                      ),
                    ),
                    Expanded(
                      child: MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage('assets/images/icons/playlist.png'),
                              size: iconSize,
                            ),
                            Text(
                              LocalizationManager.instance.appLocalization
                                  .addToPlaylistSentence,
                              style: TextStyle(fontSize: fontSize),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        onPressed: () => _showAddSelectedToExistPlaylistModal(
                            internalContext),
                      ),
                    ),
                    Expanded(
                      child: MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              ImageIcon(
                                AssetImage(
                                    'assets/images/icons/presentation.png'),
                                size: iconSize,
                              ),
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.presentiaton,
                                  style: TextStyle(fontSize: fontSize),
                                  textAlign: TextAlign.center)
                            ]),
                        onPressed: () =>
                            _runPresentationForSelected(internalContext),
                      ),
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

    if (selectedSongs.isEmpty) {
      return showNoSongsSelectedDialog(LocalizationManager
          .instance.appLocalization.toRunPresentationSelectSongs);
    }
    var box = DataCollections.songs();
    var songs =
        box.values.where((song) => selectedSongs.contains(song.uuid)).toList();

    List<Song> toPresentation = List.empty(growable: true);

    for (var selectedSongId in selectedSongs) {
      var song = songs.firstWhereOrNull((x) => x.uuid == selectedSongId);
      if (song != null) {
        toPresentation.add(song);
      }
    }

    parentContext
        .read<PresentatationBloc>()
        .add(SongsPresentation(songs: toPresentation));

    showInterstitialAds();

    Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (parentContext) => PresentationView(),
      ),
    );
  }

  Future<void> _showQuickAddModal(BuildContext parentContext) async {
    Song newSong =
        Song(uuid: const Uuid().v8(), author: "", title: "", text: "");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationManager.instance.appLocalization.quickSearch),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(
                            hintText: LocalizationManager
                                .instance.appLocalization.enterAuthor,
                            labelText: LocalizationManager
                                .instance.appLocalization.author),
                        validator: (value) {
                          if (newSong.title.isEmpty &&
                              (value == null || value.isEmpty)) {
                            return LocalizationManager
                                .instance.appLocalization.authorIsRequired;
                          }
                          return null;
                        },
                        onChanged: (value) => newSong.author = value),
                    TextFormField(
                        decoration: InputDecoration(
                            hintText: LocalizationManager
                                .instance.appLocalization.enterTitle,
                            labelText: LocalizationManager
                                .instance.appLocalization.title),
                        validator: (value) {
                          if (newSong.author.isEmpty &&
                              (value == null || value.isEmpty)) {
                            return LocalizationManager
                                .instance.appLocalization.titleIsRequired;
                          }
                          return null;
                        },
                        onChanged: (value) => newSong.author = value)
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.search),
              onPressed: () {
                _onSearchClick(parentContext, newSong);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSearchClick(BuildContext builderContext, Song newSong) async {
    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      _showNotConnectedInfo();
      return;
    }

    if (newSong.author.isEmpty && newSong.title.isEmpty) {
      return _showInvalidSearchData();
    }

    var songToFind = SongToFindModel(newSong.author, newSong.title);

    if (builderContext.mounted) {
      var searchResult = await showDialog<SearchDialogResultModel>(
        context: builderContext,
        builder: (_) {
          return BlocProvider.value(
            value: builderContext.read<SongSearchCubit>(),
            child: SearchDialog(
                songToFind: songToFind,
                sourceView: SearchSourceViewEnum.songAddForm),
          );
        },
      );

      if (searchResult != null) {
        showInterstitialAds();

        if (newSong.author.isEmpty &&
            (searchResult.author != null && searchResult.author!.isNotEmpty)) {
          newSong.author = searchResult.author!;
        }

        if (newSong.title.isEmpty &&
            (searchResult.title != null && searchResult.title!.isNotEmpty)) {
          newSong.title = searchResult.title!;
        }

        newSong.text = searchResult.text!;

        if (builderContext.mounted) {
          _quickSearchResultPreviewModal(builderContext, newSong);
        }
      }
    }
  }

  void _showNotConnectedInfo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(LocalizationManager
          .instance.appLocalization.noActiveInternetConnection),
    ));
  }

  void _showInvalidSearchData() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(LocalizationManager
          .instance.appLocalization.toSearchForTextYouNeedAtLeastTitleOrAuthor),
    ));
  }

  Future<void> _quickSearchResultPreviewModal(
      BuildContext parentContext, Song newSong) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationManager.instance.appLocalization.quickSearch),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                        initialValue: newSong.author,
                        decoration: InputDecoration(
                            labelText: LocalizationManager
                                .instance.appLocalization.author),
                        validator: (value) {
                          if (newSong.title.isEmpty &&
                              (value == null || value.isEmpty)) {
                            return LocalizationManager
                                .instance.appLocalization.authorIsRequired;
                          }
                          return null;
                        },
                        onChanged: (value) => newSong.author = value),
                    TextFormField(
                        initialValue: newSong.title,
                        decoration: InputDecoration(
                            labelText: LocalizationManager
                                .instance.appLocalization.title),
                        validator: (value) {
                          if (newSong.author.isEmpty &&
                              (value == null || value.isEmpty)) {
                            return LocalizationManager
                                .instance.appLocalization.titleIsRequired;
                          }
                          return null;
                        },
                        onChanged: (value) => newSong.author = value),
                    SizedBox(height: 10),
                    TextFormField(
                        initialValue: newSong.text,
                        minLines: 12,
                        maxLines: null,
                        decoration: InputDecoration(
                            labelText: LocalizationManager
                                .instance.appLocalization.text,
                            alignLabelWithHint: true,
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocalizationManager
                                .instance.appLocalization.textIsRequired;
                          }
                          return null;
                        },
                        onChanged: (value) => newSong.text = value),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.save),
              onPressed: () {
                _saveSong(newSong);
                parentContext
                    .read<SongsListComponentBloc>()
                    .add(ReloadListEvent());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(LocalizationManager
                  .instance.appLocalization.saveAndLunchPresentation),
              onPressed: () {
                _saveSong(newSong);
                parentContext
                    .read<SongsListComponentBloc>()
                    .add(ReloadListEvent());
                parentContext
                    .read<PresentatationBloc>()
                    .add(SongsPresentation(songs: [newSong]));

                Navigator.of(context).pop();

                Navigator.of(parentContext).push(
                  MaterialPageRoute(
                    builder: (parentContext) => PresentationView(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _saveSong(Song newSong) {
    var box = DataCollections.songs();
    box.put(newSong.uuid, newSong);
  }
}
