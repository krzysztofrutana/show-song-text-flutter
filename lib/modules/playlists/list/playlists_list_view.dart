import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';

class PlaylistsList extends StatefulWidget {
  const PlaylistsList({super.key});

  @override
  State<PlaylistsList> createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> with InterstitialAds {
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
        body: PlaylistsListComponent(),
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
            final size = MediaQuery.of(context).size;
            var iconSize = size.width * 0.07; // icon scale
            var fontSize = size.width * 0.03; // text scale

            if (iconSize > 20) iconSize = 20;
            if (fontSize > 14) fontSize = 14;
            return Visibility(
              visible: state.choosePlaylists == true,
              child: SizedBox(
                height: size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: MaterialButton(
                          minWidth: 0,
                          padding: EdgeInsets.all(0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Icon(Icons.cancel_outlined, size: iconSize),
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.cancel,
                                  style: TextStyle(fontSize: fontSize))
                            ],
                          ),
                          onPressed: () {
                            internalContext
                                .read<PlaylistsListComponentBloc>()
                                .add(ClearSelectedPlaylists());

                            internalContext
                                .read<PlaylistsListComponentBloc>()
                                .add(ChoosePlaylistChangeEvent(value: false));
                          }),
                    ),
                    Expanded(
                      child: MaterialButton(
                          minWidth: 0,
                          padding: EdgeInsets.all(0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              ImageIcon(
                                AssetImage('assets/images/icons/delete.png'),
                                size: iconSize,
                              ),
                              Text(
                                  LocalizationManager
                                      .instance.appLocalization.delete,
                                  style: TextStyle(fontSize: fontSize))
                            ],
                          ),
                          onPressed: () =>
                              _showDeleteConfirmModal(internalContext)),
                    ),
                    Expanded(
                      child: MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            ImageIcon(
                                AssetImage(
                                    'assets/images/icons/presentation.png'),
                                size: iconSize),
                            Text(
                                LocalizationManager
                                    .instance.appLocalization.presentiaton,
                                style: TextStyle(fontSize: fontSize))
                          ],
                        ),
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
            title: Text(
              LocalizationManager.instance.appLocalization.noPlaylistsSelected,
              style: TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    LocalizationManager.instance.appLocalization
                        .youShouldMarkThePlaylistsToBeDeleted,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(LocalizationManager.instance.appLocalization.ok),
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
            title: Text(
                LocalizationManager.instance.appLocalization.deletingPlaylists),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(LocalizationManager.instance.appLocalization
                      .areYouSureYouWantDeletSelectedLists),
                  Text(LocalizationManager.instance.appLocalization
                      .numberOfPlaylists(selectedPlaylistsLength)),
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
          title:
              Text(LocalizationManager.instance.appLocalization.addingPlaylist),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: LocalizationManager
                              .instance.appLocalization.enterName,
                          labelText:
                              LocalizationManager.instance.appLocalization.name,
                        ),
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
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.yes),
              onPressed: () {
                parentContext.read<AddPlaylistBloc>().add(AddPlaylistSave());
                parentContext.read<AddPlaylistBloc>().add(AddPlaylistReset());

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
            title: Text(
              LocalizationManager.instance.appLocalization.noPlaylistsSelected,
              style: TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(LocalizationManager.instance.appLocalization
                      .pleaseSelectPlaylistForPresentation),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(LocalizationManager.instance.appLocalization.ok),
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
            title: Text(
              LocalizationManager.instance.appLocalization
                  .presentationIsOnlyPossibleForOneList,
              style: TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(LocalizationManager.instance.appLocalization
                      .pleaseSelectOnlyOneListForPresentation),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(LocalizationManager.instance.appLocalization.ok),
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
              title: Text(
                LocalizationManager.instance.appLocalization.error,
                style: TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(LocalizationManager.instance.appLocalization
                        .anErrorOccurredWhileRetrievingListInformation),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(LocalizationManager.instance.appLocalization.ok),
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

      showInterstitialAds();

      Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (parentContext) => PresentationView(),
        ),
      );
    }
  }
}
