import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/helpers/events_hub.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubic/client_screen_mode_cubic.dart';
import 'package:pomocnik_wokalisty/modules/home.dart';
import 'package:pomocnik_wokalisty/modules/initialize_screen.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubic/playlist_edit_cubit.dart';
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

  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();
  if (Platform.isAndroid) MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale(Platform.localeName);

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? language = LocalStorage.instance.getString('lang');
    if (language != null && language.isNotEmpty) {
      _locale = Locale(language);
    }
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: InitializeScreen(targetWidget: MyHomePage()),
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
    LocalizationManager.instance.setLocalization(context);
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
          create: (context) => PlaylistEditCubit(),
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: LocalizationManager.instance.appLocalization.singersAssistant,
        home: Home(),
      ),
    );
  }
}
