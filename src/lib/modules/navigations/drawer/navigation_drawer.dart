import 'dart:io';

import 'package:async_preferences/async_preferences.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/initialization_helper.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/main.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/views/client_screen_mode.dart';
import 'package:pomocnik_wokalisty/modules/dialogs/policy_dialog.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  final _initializationHelper = AdMobInitializationHelper();
  late final Future<bool> _future;

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

  String _selectedLanguage = '';

  @override
  void initState() {
    super.initState();

    _future = _isUnderGdpr();
  }

  @override
  Widget build(BuildContext context) {
    var items = _getNavigationItems();
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

  Future<bool> _isUnderGdpr() async {
    if (!Platform.isAndroid) return false;

    final preferences = AsyncPreferences();
    return await preferences.getInt('IABTCF_gdprApplies') == 1;
  }

  List<_NavigationItem> _getNavigationItems() {
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

  Widget _getSelectedLanguageIcon() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: CountryFlag.fromLanguageCode(_selectedLanguage,
          theme: ImageTheme(shape: Circle(), height: 8, width: 8)),
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
        return Column(
          children: [
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(children: <Widget>[
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: DropdownMenu<String>(
                        inputDecorationTheme: InputDecorationTheme(
                          enabledBorder: InputBorder.none,
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        width: 160,
                        textStyle: TextStyle(fontSize: 14),
                        initialSelection: _getDefaultLanguage().value,
                        dropdownMenuEntries: _supportedLanguageList,
                        leadingIcon: _getSelectedLanguageIcon(),
                        label: Text(LocalizationManager
                            .instance.appLocalization.language),
                        onSelected: (value) {
                          setState(() {
                            MyApp.of(context).setLocale(Locale.fromSubtags(
                                languageCode: value.toString()));

                            LocalStorage.instance
                                .setString('lang', value.toString());
                            _selectedLanguage = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        text: LocalizationManager
                            .instance.appLocalization.privacyPolicy,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  var language = _getDefaultLanguage().value;
                                  return PolicyDialog(
                                      mdFileName:
                                          'privacy_policy_$language.md');
                                });
                          }),
                    TextSpan(
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        text:
                            ' ${LocalizationManager.instance.appLocalization.and} '),
                    TextSpan(
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        text: LocalizationManager
                            .instance.appLocalization.termsAndConditions,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  var language = _getDefaultLanguage().value;
                                  return PolicyDialog(
                                      mdFileName:
                                          'terms_and_conditions_$language.md');
                                });
                          })
                  ])),
            ),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Visibility(
                  visible: snapshot.hasData && snapshot.data == true,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            text: LocalizationManager
                                .instance.appLocalization.changePrivacyPolicy,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Navigator.of(context).pop();

                                final scafooldMessenger =
                                    ScaffoldMessenger.of(context);
                                final didChangePreferences =
                                    await _initializationHelper
                                        .changePrivacyPreferences();

                                scafooldMessenger.showSnackBar(SnackBar(
                                    content: didChangePreferences
                                        ? Text(LocalizationManager
                                            .instance
                                            .appLocalization
                                            .yourPrivacyChoisesHasBeenUpdated)
                                        : Text(LocalizationManager
                                            .instance
                                            .appLocalization
                                            .anErrorOccurredWhileTryingToChangeYourPrivacyPreferences)));
                              }),
                      ])),
                ),
              ),
            ),
          ],
        );
      });

  void _handleItemClick(BuildContext context, NavigationPage item) {
    if (item == NavigationPage.clientMode) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (parentContext) => ClientScreenMode(),
        ),
      );
    } else if (item == NavigationPage.quickSearch) {
    } else {
      BlocProvider.of<NavigationDrawerBloc>(context).add(NavigateToEvent(item));
      Navigator.pop(context);
    }
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
