import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/views/client_screen_mode.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';

class MyNavigationDrawer extends StatelessWidget {
  final List<_NavigationItem> _listItems = [
    _NavigationItem(
        true, NavigationPage.header, 'Header', const AssetImage('')),
    _NavigationItem(false, NavigationPage.songs_list, "Lista utworów",
        const AssetImage('assets/images/icons/note.png')),
    _NavigationItem(false, NavigationPage.playlist_list, "Listy odtwarzania",
        const AssetImage('assets/images/icons/playlist.png')),
    _NavigationItem(
        false,
        NavigationPage.server_settings,
        "Ustawienia prezentacji",
        const AssetImage('assets/images/icons/settings.png')),
    _NavigationItem(false, NavigationPage.client_mode, "Tryb wyświetlacza",
        const AssetImage('assets/images/icons/presentation.png')),
  ];

  MyNavigationDrawer({super.key});

  Widget _buildItem(_NavigationItem data, NavigationDrawerState state) =>
      data.header ? _makeHeaderItem() : _makeListItem(data, state);
  Widget _makeHeaderItem() => const DrawerHeader(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo/logo.png'),
                radius: 35,
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text('Pomocnik wokalisty',
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text("by Krzysztof Rutana",
                  style:
                      TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );

  Widget _makeListItem(_NavigationItem data, NavigationDrawerState state) =>
      Card(
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
        borderOnForeground: true,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Builder(
          builder: (BuildContext context) => ListTile(
            title: Text(data.title),
            leading: ImageIcon(
              data.icon,
              size: 20,
            ),
            onTap: () => _handleItemClick(context, data.item),
          ),
        ),
      );

  void _handleItemClick(BuildContext context, NavigationPage item) {
    if (item == NavigationPage.client_mode) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (parentContext) => ClientScreenMode(),
        ),
      );
    } else {
      BlocProvider.of<NavigationDrawerBloc>(context).add(NavigateToEvent(item));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _listItems.length,
        itemBuilder: (context, index) {
          return BlocBuilder<NavigationDrawerBloc, NavigationDrawerState>(
              builder: (context, state) {
            return _buildItem(_listItems[index], state);
          });
        },
      ),
    );
  }
}

class _NavigationItem {
  final bool header;
  final NavigationPage item;
  final String title;
  final AssetImage icon;
  _NavigationItem(this.header, this.item, this.title, this.icon);
}
