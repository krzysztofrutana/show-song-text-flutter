import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit({SharedPreferences? prefs})
      : _prefs = prefs ?? sl<SharedPreferences>(),
        super(LocalizationState(Locale(prefs?.getString('lang') ??
            sl<SharedPreferences>().getString('lang') ??
            Platform.localeName.split('_')[0])));

  final SharedPreferences _prefs;

  void setLocale(Locale locale) {
    _prefs.setString('lang', locale.languageCode);
    emit(LocalizationState(locale));
  }
}
