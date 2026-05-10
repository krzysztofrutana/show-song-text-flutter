import 'package:get_it/get_it.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubit/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/cubit/presentation_settings_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubit/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_server.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton(() => SongsRepository());
  sl.registerLazySingleton(() => PlaylistsRepository());

  // Cubits
  sl.registerFactory(() => PresentationSettingsCubit());
  sl.registerFactory(() => SongsEditCubit(songsRepository: sl()));
  sl.registerFactory(() => PlaylistEditCubit(playlistsRepository: sl()));

  // Services
  sl.registerLazySingleton(() => Server());
  sl.registerLazySingleton(() => Client());
  sl.registerLazySingleton(() => TekstowoService());

  // External
  sl.registerLazySingleton<SharedPreferences>(() => LocalStorage.instance);
}
