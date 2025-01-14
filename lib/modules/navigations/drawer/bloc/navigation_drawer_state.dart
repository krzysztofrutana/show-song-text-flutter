part of 'navigation_drawer_bloc.dart';

class NavigationDrawerState {
  final NavigationPage navigationPage;

  const NavigationDrawerState(this.navigationPage);
}


enum NavigationPage {
  header,
  songs_list,
  songs_add,
  songs_edit,
  playlist_list,
  playlist_add,
  playlist_edit,
  settings
}