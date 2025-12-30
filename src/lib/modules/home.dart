import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
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
  Widget build(BuildContext context) =>
      BlocBuilder<NavigationDrawerBloc, NavigationDrawerState>(
          builder: (BuildContext context, NavigationDrawerState state) =>
              SafeArea(
                top: false,
                bottom: true,
                child: Scaffold(
                    drawer: MyNavigationDrawer(),
                    appBar: AppBar(
                      title: Text(_getTextForItem(state.navigationPage)),
                    ),
                    body: _bodyForState(state)),
              ));
}

String _getTextForItem(NavigationPage navigationPage) {
  switch (navigationPage) {
    case NavigationPage.songsList:
      return LocalizationManager.instance.appLocalization.songsList;
    case NavigationPage.songsAdd:
      return LocalizationManager.instance.appLocalization.addSong;
    case NavigationPage.songsEdit:
      return LocalizationManager.instance.appLocalization.editSong;
    case NavigationPage.playlistList:
      return LocalizationManager.instance.appLocalization.playlists;
    case NavigationPage.playlistEdit:
      return LocalizationManager.instance.appLocalization.editPlaylist;
    case NavigationPage.serverSettings:
      return LocalizationManager.instance.appLocalization.presentationSettings;
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
