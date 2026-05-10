import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({SharedPreferences? prefs})
      : _prefs = prefs ?? sl<SharedPreferences>(),
        super(ThemeInitial(_getThemeMode(prefs ?? sl<SharedPreferences>())));

  final SharedPreferences _prefs;

  static ThemeMode _getThemeMode(SharedPreferences prefs) {
    final themeName = prefs.getString('themeMode');
    if (themeName == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode themeMode) {
    _prefs.setString('themeMode', themeMode.name);
    emit(ThemeChanged(themeMode));
  }
}
