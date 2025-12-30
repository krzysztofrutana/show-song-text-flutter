part of 'navigation_drawer_bloc.dart';

class NavigationDrawerState {
  final NavigationPage navigationPage;

  const NavigationDrawerState(this.navigationPage);
}

enum NavigationPage {
  header,
  songsList,
  songsAdd,
  songsEdit,
  playlistList,
  playlistAdd,
  playlistEdit,
  serverSettings,
  clientMode,
  footer,
  quickSearch
}
