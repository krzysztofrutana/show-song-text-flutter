import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';

main() {
  blocTest<NavigationDrawerBloc, NavigationDrawerState>(
      'Emits [NavDrawerState] when NavigateTo(NavItem.page_five) is added',
      build: () => NavigationDrawerBloc(),
      act: (bloc) async => bloc.add(NavigateToEvent(NavigationPage.songs_add)),
      expect: () => [isA<NavigationDrawerState>()],
      verify: (bloc) async {
        expect(bloc.state.navigationPage, NavigationPage.songs_add);
      });
}