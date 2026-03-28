import 'package:get_it/get_it.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_server.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton(() => SongsRepository());
  sl.registerLazySingleton(() => PlaylistsRepository());

  // Services
  sl.registerLazySingleton(() => Server());
  sl.registerLazySingleton(() => Client());
  sl.registerLazySingleton(() => TekstowoService());

  // External
  sl.registerLazySingleton(() => LocalStorage.instance);
}
