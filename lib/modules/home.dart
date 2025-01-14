import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/navigation_drawer.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/playlists_list.dart';
import 'package:pomocnik_wokalisty/modules/settings/views/settings_edit.dart';
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
    case NavigationPage.songs_list:
      return "Lista utworów";
    case NavigationPage.songs_add:
      return "Dodaj utwór";
    case NavigationPage.songs_edit:
      return "Edytuj utwór";
    case NavigationPage.playlist_list:
      return "Listy odtwarzania";
    case NavigationPage.playlist_add:
      return "Dodaj listę";
    case NavigationPage.playlist_edit:
      return "Edytuj listę";
    case NavigationPage.settings:
      return "Ustawienia";
    default:
      return '-';
  }
}

Widget? _bodyForState(NavigationDrawerState state) {
  switch (state.navigationPage) {
    case NavigationPage.songs_list:
      return const SongsList();
    case NavigationPage.songs_add:
      return SongsAdd();
    case NavigationPage.playlist_list:
      return const PlaylistsList();
    case NavigationPage.settings:
      return const SettingsEdit();
    default:
      return null;
  }
}
