import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'presentation_settings_state.dart';

class PresentationSettingsCubit extends Cubit<PresentationSettingsStateBase> {
  PresentationSettingsCubit() : super(PresentationSettingsInitial());

  void initSettings() async {
    final fontSize = sl<SharedPreferences>().getInt('fontSize') ?? 15;
    final textScrollMode =
        sl<SharedPreferences>().getString('textScrollMode') ?? 'horizontal';

    emit(state.copyWith(
      fontSize: fontSize.toString(),
      textScrollMode: textScrollMode,
    ));
  }

  Future<void> setFontSize(String fontSize) async {
    final persistSettings = sl<SharedPreferences>();

    await persistSettings.setInt('fontSize', int.parse(fontSize));

    emit(state.copyWith(fontSize: fontSize));
  }

  Future<void> setTextScrollMode(String textScrollMode) async {
    final persistSettings = sl<SharedPreferences>();

    await persistSettings.setString('textScrollMode', textScrollMode);

    emit(state.copyWith(textScrollMode: textScrollMode));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }
}
