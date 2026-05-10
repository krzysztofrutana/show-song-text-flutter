import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nested/nested.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/events_hub.dart';
import 'package:pomocnik_wokalisty/helpers/full_screen_helper.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/injection_container.dart' as di;
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubit/client_screen_mode_cubit.dart';
import 'package:pomocnik_wokalisty/modules/home.dart';
import 'package:pomocnik_wokalisty/modules/initialize_screen.dart';
import 'package:pomocnik_wokalisty/modules/localization/bloc/localization_cubit.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubit/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/client_cubit/client_cubit.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/server_cubit/server_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DataCollections.initCollections();
  await LocalStorage.init();
  EventsHub.init();
  await di.init();

  await FullScreenHelper.init();
  if (Platform.isAndroid) MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getBlockProviders,
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, state) {
          return MaterialApp(
            locale: state.locale,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (ctx) {
              return AppLocalizations.of(ctx)!.singersAssistant;
            },
            theme: ThemeData(
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineSmall: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
                titleLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                labelLarge: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelMedium: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                labelSmall: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            home: const InitializeScreen(targetWidget: MyHomePage()),
          );
        },
      ),
    );
  }

  List<SingleChildWidget> get getBlockProviders {
    return [
      BlocProvider(create: (context) => LocalizationCubit()),
      BlocProvider(create: (context) => NavigationDrawerBloc()),
      BlocProvider(create: (context) => SongsListComponentBloc()),
      BlocProvider(create: (context) => AddPlaylistBloc()),
      BlocProvider(create: (context) => PlaylistsListComponentBloc()),
      BlocProvider(create: (context) => PlaylistEditCubit()),
      BlocProvider(create: (context) => ServerCubit()),
      BlocProvider(create: (context) => ClientCubit()),
      BlocProvider(create: (context) => PresentationBloc()),
      BlocProvider(create: (context) => ClientScreenModeCubit()),
      BlocProvider(create: (context) => SongSearchCubit()),
    ];
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool canPop = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: const Home(),
    );
  }

  Future<bool?> _showBackDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.exitApplication),
          content: Text(localizations.areYouSureYouWantToLeaveTheApplication),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(localizations.cancel),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(localizations.leave),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
