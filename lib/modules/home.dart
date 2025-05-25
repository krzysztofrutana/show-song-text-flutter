import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              Scaffold(
                  drawer: MyNavigationDrawer(),
                  appBar: AppBar(
                    title: Text(_getTextForItem(state.navigationPage)),
                  ),
                  body: _bodyForState(state)));
}

String _getTextForItem(NavigationPage navigationPage) {
  switch (navigationPage) {
    case NavigationPage.songsList:
      return "Lista utworów";
    case NavigationPage.songsAdd:
      return "Dodaj utwór";
    case NavigationPage.songsEdit:
      return "Edytuj utwór";
    case NavigationPage.playlistList:
      return "Listy odtwarzania";
    case NavigationPage.playlistAdd:
      return "Dodaj listę";
    case NavigationPage.playlistEdit:
      return "Edytuj listę";
    case NavigationPage.serverSettings:
      return "Ustawienia prezentacji";
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
