part of 'navigation_drawer_bloc.dart';

abstract class NavigationDrawerEvent {}

class NavigateToEvent extends NavigationDrawerEvent{
  final NavigationPage navigateTo;

  NavigateToEvent(this.navigateTo);
}

