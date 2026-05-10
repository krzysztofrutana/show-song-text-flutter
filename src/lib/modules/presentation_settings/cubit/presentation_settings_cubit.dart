import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'presentation_settings_state.dart';

class PresentationSettingsCubit extends Cubit<PresentationSettingsStateBase> {
  PresentationSettingsCubit() : super(PresentationSettingsInitial());

  void initSettings() async {
    final fontSize = sl<SharedPreferences>().getInt('fontSize') ?? 15;

    emit(state.copyWith(fontSize: fontSize.toString()));
  }

  Future<void> setFontSize(String fontSize) async {
    final persistSettings = sl<SharedPreferences>();

    await persistSettings.setInt('fontSize', int.parse(fontSize));

    emit(state.copyWith(fontSize: fontSize));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }
}
