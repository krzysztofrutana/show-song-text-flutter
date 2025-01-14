import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/modules/home.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubic/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  await Hive.openBox<Song>('songs');
  await Hive.openBox<Playlist>('playlists');

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
          create: (context) => SongsListComponentBloc(),
        ),
        BlocProvider(
          create: (context) => AddPlaylistBloc(),
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
