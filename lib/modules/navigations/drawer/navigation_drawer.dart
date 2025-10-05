import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/main.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/views/client_screen_mode.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  final List<DropdownMenuEntry<String>> _supportedLanguageList = [
    DropdownMenuEntry<String>(
        value: 'pl',
        label: "PL",
        leadingIcon: CountryFlag.fromLanguageCode(
          'pl',
          theme: ImageTheme(shape: Circle(), height: 25, width: 25),
        )),
    DropdownMenuEntry<String>(
        value: 'en',
        label: "EN",
        leadingIcon: CountryFlag.fromLanguageCode('en',
            theme: ImageTheme(shape: Circle(), height: 25, width: 25))),
  ];

  List<_NavigationItem> getNavigationItems() {
    return [
      _NavigationItem(
          false,
          false,
          NavigationPage.songsList,
          LocalizationManager.instance.appLocalization.songsList,
          const AssetImage('assets/images/icons/note.png')),
      _NavigationItem(
          false,
          false,
          NavigationPage.playlistList,
          LocalizationManager.instance.appLocalization.playlists,
          const AssetImage('assets/images/icons/playlist.png')),
      _NavigationItem(
          false,
          false,
          NavigationPage.serverSettings,
          LocalizationManager.instance.appLocalization.presentationSettings,
          const AssetImage('assets/images/icons/settings.png')),
      _NavigationItem(
          false,
          false,
          NavigationPage.clientMode,
          LocalizationManager.instance.appLocalization.clientMode,
          const AssetImage('assets/images/icons/presentation.png')),
    ];
  }

  String _selectedLanguage = '';

  DropdownMenuEntry<String> _getDefaultLanguage() {
    if (_selectedLanguage.isNotEmpty) {
      return _supportedLanguageList
          .firstWhere((x) => x.value == _selectedLanguage);
    }

    final String? language = LocalStorage.instance.getString('lang');
    if (language == null || language.isEmpty) {
      Locale platformLanguage = Locale(Platform.localeName);
      if (AppLocalizations.supportedLocales.contains(platformLanguage)) {
        if (Platform.localeName == 'pl') {
          LocalStorage.instance
              .setString('lang', _supportedLanguageList.first.value);
          _selectedLanguage = _supportedLanguageList.first.value;
          return _supportedLanguageList.first;
        }
      }

      LocalStorage.instance
          .setString('lang', _supportedLanguageList.last.value);

      _selectedLanguage = _supportedLanguageList.last.value;
      return _supportedLanguageList.last;
    } else {
      var option =
          _supportedLanguageList.firstWhere((x) => x.value == language);
      _selectedLanguage = option.value;

      return option;
    }
  }

  Widget getSelectedLanguageIcon() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: CountryFlag.fromLanguageCode(_selectedLanguage,
          theme: ImageTheme(shape: Circle(), height: 10, width: 10)),
    );
  }

  Widget _makeHeaderItem() => DrawerHeader(
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
              child: Text(
                  LocalizationManager.instance.appLocalization.singersAssistant,
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

  Widget _makeFooterItem(BuildContext context) => Builder(builder: (context) {
        return Align(
          alignment: FractionalOffset.bottomCenter,
          child: Column(children: [
            Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationTheme(
                      enabledBorder: InputBorder.none,
                    ),
                    width: 150,
                    initialSelection: _getDefaultLanguage().value,
                    dropdownMenuEntries: _supportedLanguageList,
                    leadingIcon: getSelectedLanguageIcon(),
                    label: Text(
                        LocalizationManager.instance.appLocalization.language),
                    onSelected: (value) {
                      setState(() {
                        MyApp.of(context).setLocale(
                            Locale.fromSubtags(languageCode: value.toString()));

                        LocalStorage.instance
                            .setString('lang', value.toString());
                        _selectedLanguage = value.toString();
                      });
                    },
                  ),
                ),
              ],
            )
          ]),
        );
      });

  void _handleItemClick(BuildContext context, NavigationPage item) {
    if (item == NavigationPage.clientMode) {
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
    var items = getNavigationItems();
    return BlocBuilder<NavigationDrawerBloc, NavigationDrawerState>(
        builder: (context, state) {
      return Drawer(
        child: Column(
          children: [
            _makeHeaderItem(),
            Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _makeListItem(items[index], state))),
            _makeFooterItem(context)
          ],
        ),
      );
    });
  }
}

class _NavigationItem {
  final bool header;
  final NavigationPage item;
  final String title;
  final AssetImage icon;
  final bool footer;
  _NavigationItem(this.header, this.footer, this.item, this.title, this.icon);
}
