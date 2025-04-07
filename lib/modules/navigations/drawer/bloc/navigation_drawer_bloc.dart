import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_drawer_event.dart';
part 'navigation_drawer_state.dart';

class NavigationDrawerBloc
    extends Bloc<NavigationDrawerEvent, NavigationDrawerState> {
  NavigationDrawerBloc()
      : super(const NavigationDrawerState(NavigationPage.songs_list)) {
    on<NavigationDrawerEvent>((event, emit) {
      if (event is NavigateToEvent) {
        if (state.navigationPage != event.navigateTo) {
          emit(NavigationDrawerState(event.navigateTo));
        }
      }
    });
  }
}
