part of 'navigation_drawer_bloc.dart';

class NavigationDrawerState {
  const NavigationDrawerState(this.navigationPage);

  final NavigationPage navigationPage;
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
