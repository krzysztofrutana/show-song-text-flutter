import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/navigation_drawer.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/playlists_list_view.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/views/presentation_settings_view.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/songs_add.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/songs_list_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<NavigationDrawerBloc, NavigationDrawerState>(
        builder: (BuildContext context, NavigationDrawerState state) =>
            SafeArea(
              top: false,
              child: Scaffold(
                  drawer: const MyNavigationDrawer(),
                  appBar: AppBar(
                    title: Text(
                        _getTextForItem(state.navigationPage, localizations)),
                  ),
                  body: _bodyForState(state)),
            ));
  }
}

String _getTextForItem(
    NavigationPage navigationPage, AppLocalizations localizations) {
  switch (navigationPage) {
    case NavigationPage.songsList:
      return localizations.songsList;
    case NavigationPage.songsAdd:
      return localizations.addSong;
    case NavigationPage.songsEdit:
      return localizations.editSong;
    case NavigationPage.playlistList:
      return localizations.playlists;
    case NavigationPage.playlistEdit:
      return localizations.editPlaylist;
    case NavigationPage.serverSettings:
      return localizations.presentationSettings;
    default:
      return '-';
  }
}

Widget? _bodyForState(NavigationDrawerState state) {
  switch (state.navigationPage) {
    case NavigationPage.songsList:
      return const SongsList();
    case NavigationPage.songsAdd:
      return SongsAdd();
    case NavigationPage.playlistList:
      return const PlaylistsList();
    case NavigationPage.serverSettings:
      return PresentationSettings();
    default:
      return null;
  }
}
