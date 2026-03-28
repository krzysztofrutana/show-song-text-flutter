part of 'navigation_drawer_bloc.dart';

abstract class NavigationDrawerEvent {}

class NavigateToEvent extends NavigationDrawerEvent {
  NavigateToEvent(this.navigateTo);

  final NavigationPage navigateTo;
}
