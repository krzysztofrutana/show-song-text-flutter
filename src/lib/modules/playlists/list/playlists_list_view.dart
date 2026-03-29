import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/views/add_playlist_dialog.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
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
    final localizations = AppLocalizations.of(context)!;
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
                      child: TextButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                size: iconSize,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 5),
                              Text(localizations.cancel,
                                  style: TextStyle(
                                      fontSize: fontSize, color: Colors.black))
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
                      child: TextButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                color: Colors.black,
                                const AssetImage(
                                    'assets/images/icons/delete.png'),
                                size: iconSize,
                              ),
                              const SizedBox(height: 5),
                              Text(localizations.delete,
                                  style: TextStyle(
                                      fontSize: fontSize, color: Colors.black))
                            ],
                          ),
                          onPressed: () =>
                              _showDeleteConfirmModal(internalContext)),
                    ),
                    Expanded(
                      child: TextButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                                color: Colors.black,
                                const AssetImage(
                                    'assets/images/icons/presentation.png'),
                                size: iconSize),
                            const SizedBox(height: 5),
                            Text(localizations.showText,
                                style: TextStyle(
                                    fontSize: fontSize, color: Colors.black))
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
    final localizations = AppLocalizations.of(context)!;
    final selectedPlaylistsLength = parentContext
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
              localizations.noPlaylistsSelected,
              style: const TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    localizations.youShouldMarkThePlaylistsToBeDeleted,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(localizations.ok),
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
            title: Text(localizations.deletingPlaylists),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localizations.areYouSureYouWantDeletSelectedLists),
                  Text(
                      localizations.numberOfPlaylists(selectedPlaylistsLength)),
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
                onPressed: () {
                  parentContext
                      .read<PlaylistsListComponentBloc>()
                      .add(RemoveSelectedPlaylistsEvent());

                  parentContext
                      .read<PlaylistsListComponentBloc>()
                      .add(ReloadListEvent());

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(localizations.deletedSuccessfully),
                  ));
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: parentContext.read<AddPlaylistBloc>(),
          child: AddPlaylistDialog(),
        );
      },
    );
  }

  void _runPresentationForSelected(BuildContext parentContext) async {
    final localizations = AppLocalizations.of(parentContext)!;
    final selectedPlaylistsLength = parentContext
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
              localizations.noPlaylistsSelected,
              style: const TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localizations.pleaseSelectPlaylistForPresentation),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(localizations.ok),
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
              localizations.presentationIsOnlyPossibleForOneList,
              style: const TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localizations.pleaseSelectOnlyOneListForPresentation),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(localizations.ok),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      final selectedPlaylists = parentContext
          .read<PlaylistsListComponentBloc>()
          .state
          .selectedPlaylists;

      final playlist =
          sl<PlaylistsRepository>().getPlaylist(selectedPlaylists[0]);

      if (playlist == null) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                localizations.error,
                style: const TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(localizations
                        .anErrorOccurredWhileRetrievingListInformation),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.ok),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }

      parentContext
          .read<PresentationBloc>()
          .add(PlaylistPresentation(playlist: playlist));

      showInterstitialAds();

      Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (parentContext) => const PresentationView(),
        ),
      );
    }
  }
}
