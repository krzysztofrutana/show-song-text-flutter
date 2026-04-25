import 'dart:io';

import 'package:async_preferences/async_preferences.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pomocnik_wokalisty/helpers/initialization_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/views/client_screen_mode.dart';
import 'package:pomocnik_wokalisty/modules/dialogs/policy_dialog.dart';
import 'package:pomocnik_wokalisty/modules/localization/bloc/localization_cubit.dart';
import 'package:pomocnik_wokalisty/modules/navigations/drawer/bloc/navigation_drawer_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  final _initializationHelper = AdMobInitializationHelper();
  late final Future<bool> _future;
  late final Future<String> _versionFuture;

  final List<DropdownMenuEntry<String>> _supportedLanguageList = [
    DropdownMenuEntry<String>(
      value: 'pl',
      label: "PL",
      leadingIcon: CountryFlag.fromLanguageCode(
        'pl',
        theme: const ImageTheme(shape: Circle(), height: 25, width: 25),
      ),
    ),
    DropdownMenuEntry<String>(
      value: 'en',
      label: "EN",
      leadingIcon: CountryFlag.fromLanguageCode(
        'en',
        theme: const ImageTheme(shape: Circle(), height: 25, width: 25),
      ),
    ),
  ];

  String _selectedLanguage = '';

  @override
  void initState() {
    super.initState();

    _future = _isUnderGdpr();
    _versionFuture = _getActualVersion();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final items = _getNavigationItems(context);
    return BlocBuilder<NavigationDrawerBloc, NavigationDrawerState>(
      builder: (context, state) {
        return Drawer(
          child: Column(
            children: [
              _makeHeaderItem(context),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder:
                      (context, index) => _makeListItem(items[index], state),
                ),
              ),
              _makeFooterItem(context, localizations),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _isUnderGdpr() async {
    if (!Platform.isAndroid) return false;

    final preferences = AsyncPreferences();
    return await preferences.getInt('IABTCF_gdprApplies') == 1;
  }

  List<_NavigationItem> _getNavigationItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      _NavigationItem(
        false,
        false,
        NavigationPage.songsList,
        localizations.songsList,
        const AssetImage('assets/images/icons/note.png'),
      ),
      _NavigationItem(
        false,
        false,
        NavigationPage.playlistList,
        localizations.playlists,
        const AssetImage('assets/images/icons/playlist.png'),
      ),
      _NavigationItem(
        false,
        false,
        NavigationPage.serverSettings,
        localizations.presentationSettings,
        const AssetImage('assets/images/icons/settings.png'),
      ),
      _NavigationItem(
        false,
        false,
        NavigationPage.clientMode,
        localizations.clientMode,
        Icons.cast,
        isMaterialIcon: true,
      ),
      _NavigationItem(
        false,
        false,
        NavigationPage.help,
        localizations.help,
        Icons.help_outline,
        isMaterialIcon: true,
      ),
    ];
  }

  DropdownMenuEntry<String> _getDefaultLanguage() {
    if (_selectedLanguage.isNotEmpty) {
      return _supportedLanguageList.firstWhere(
        (x) => x.value == _selectedLanguage,
      );
    }

    final language = sl<SharedPreferences>().getString('lang');
    if (language == null || language.isEmpty) {
      final platformLanguage = Locale(Platform.localeName);
      if (AppLocalizations.supportedLocales.any(
        (l) => platformLanguage.languageCode.startsWith(l.languageCode),
      )) {
        if (Platform.localeName.split('_')[0] == 'pl') {
          sl<SharedPreferences>().setString(
            'lang',
            _supportedLanguageList.first.value,
          );
          _selectedLanguage = _supportedLanguageList.first.value;
          return _supportedLanguageList.first;
        }
      }

      sl<SharedPreferences>().setString(
        'lang',
        _supportedLanguageList.last.value,
      );

      _selectedLanguage = _supportedLanguageList.last.value;
      return _supportedLanguageList.last;
    } else {
      final option = _supportedLanguageList.firstWhere(
        (x) => x.value == language,
      );
      _selectedLanguage = option.value;

      return option;
    }
  }

  Widget _getSelectedLanguageIcon() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CountryFlag.fromLanguageCode(
        _selectedLanguage,
        theme: const ImageTheme(shape: Circle(), height: 8, width: 8),
      ),
    );
  }

  Widget _makeHeaderItem(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return DrawerHeader(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo/logo.png'),
              radius: 35,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              localizations.singersAssistant,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "by Krzysztof Rutana",
              style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FutureBuilder<String>(
              future: _versionFuture,
              builder: (context, snapshot) {
                return Text(
                  snapshot.hasData ? "${snapshot.data}" : "",
                  style: const TextStyle(fontSize: 10.0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeListItem(_NavigationItem data, NavigationDrawerState state) =>
      Card(
        shape: const ContinuousRectangleBorder(),
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Builder(
          builder:
              (BuildContext context) => ListTile(
                title: Text(data.title),
                leading:
                    data.isMaterialIcon
                        ? Icon(data.icon as IconData, size: 20)
                        : ImageIcon(data.icon as AssetImage, size: 20),
                onTap: () => _handleItemClick(context, data.item),
              ),
        ),
      );

  Widget _makeFooterItem(
    BuildContext context,
    AppLocalizations localizations,
  ) => Builder(
    builder: (context) {
      return Column(
        children: [
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              children: <Widget>[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: DropdownMenu<String>(
                        inputDecorationTheme: const InputDecorationTheme(
                          enabledBorder: InputBorder.none,
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        width: 160,
                        textStyle: const TextStyle(fontSize: 14),
                        initialSelection: _getDefaultLanguage().value,
                        dropdownMenuEntries: _supportedLanguageList,
                        leadingIcon: _getSelectedLanguageIcon(),
                        label: Text(localizations.language),
                        onSelected: (value) {
                          if (value != null) {
                            context.read<LocalizationCubit>().setLocale(
                              Locale.fromSubtags(languageCode: value),
                            );
                            setState(() {
                              _selectedLanguage = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    text: localizations.privacyPolicy,
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final language = _getDefaultLanguage().value;
                                return PolicyDialog(
                                  mdFileName: 'privacy_policy_$language.md',
                                );
                              },
                            );
                          },
                  ),
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    text: ' ${localizations.and} ',
                  ),
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    text: localizations.termsAndConditions,
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final language = _getDefaultLanguage().value;
                                return PolicyDialog(
                                  mdFileName:
                                      'terms_and_conditions_$language.md',
                                );
                              },
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: _future,
            builder:
                (context, snapshot) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Visibility(
                    visible: snapshot.hasData && snapshot.data == true,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            text: localizations.changePrivacyPolicy,
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.of(context).pop();

                                    final scafooldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final didChangePreferences =
                                        await _initializationHelper
                                            .changePrivacyPreferences();

                                    scafooldMessenger.showSnackBar(
                                      SnackBar(
                                        content:
                                            didChangePreferences
                                                ? Text(
                                                  localizations
                                                      .yourPrivacyChoisesHasBeenUpdated,
                                                )
                                                : Text(
                                                  localizations
                                                      .anErrorOccurredWhileTryingToChangeYourPrivacyPreferences,
                                                ),
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ],
      );
    },
  );

  void _handleItemClick(BuildContext context, NavigationPage item) {
    if (item == NavigationPage.clientMode) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (parentContext) => const ClientScreenMode()),
      );
    } else if (item == NavigationPage.quickSearch) {
    } else {
      BlocProvider.of<NavigationDrawerBloc>(context).add(NavigateToEvent(item));
      Navigator.pop(context);
    }
  }
}

Future<String> _getActualVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final version = packageInfo.version;
  final code = packageInfo.buildNumber;
  return '$version.$code';
}

class _NavigationItem {
  _NavigationItem(
    this.header,
    this.footer,
    this.item,
    this.title,
    this.icon, {
    this.isMaterialIcon = false,
  });

  final bool header;
  final NavigationPage item;
  final String title;
  final dynamic icon;
  final bool footer;
  final bool isMaterialIcon;
}
