import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/events_hub.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubic/client_screen_mode_cubic.dart';
import 'package:pomocnik_wokalisty/modules/home.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/bloc/edit_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubic/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubic/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubic/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/client_cubic/client_cubit.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/server_cubic/server_cubit.dart';

void main() async {
  await DataCollections.initCollections();

  await LocalStorage.init();
  EventsHub.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Pomocnik wokalisty';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavigationDrawerBloc(),
        ),
        BlocProvider(
          create: (context) => SongsAddCubit(),
        ),
        BlocProvider(
          create: (context) => SongsEditCubit(),
        ),
        BlocProvider(
          create: (context) => SongsListComponentBloc(),
        ),
        BlocProvider(
          create: (context) => AddPlaylistBloc(),
        ),
        BlocProvider(
          create: (context) => PlaylistsListComponentBloc(),
        ),
        BlocProvider(
          create: (context) => EditPlaylistBloc(),
        ),
        BlocProvider(
          create: (context) => ServerCubit(),
        ),
        BlocProvider(
          create: (context) => ClientCubit(),
        ),
        BlocProvider(
          create: (context) => PresentatationBloc(),
        ),
        BlocProvider(
          create: (context) => ClientScreenModeCubic(),
        ),
        BlocProvider(
          create: (context) => SongSearchCubit(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pomocnik wokalisty',
        home: Home(),
      ),
    );
  }
}
