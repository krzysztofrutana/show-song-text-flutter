import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/LocalStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'presentation_settings_state.dart';

class PresentationSettingsCubic extends Cubit<PresentationSettingsStateBase> {
  PresentationSettingsCubic() : super(PresentationSettingsInitial());

  void initSettings() async {
    var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

    emit(state.copyWith(fontSize: fontSize.toString()));
  }

  Future<void> setFontSize(String fontSize) async {
    var persistSettings = await SharedPreferences.getInstance();

    await persistSettings.setInt('fontSize', int.parse(fontSize));

    emit(state.copyWith(fontSize: fontSize));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }
}
