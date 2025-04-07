part of 'presentation_settings_cubic.dart';

class PresentationSettingsStateBase {
  String fontSize;
  AutovalidateMode autovalidateMode;

  PresentationSettingsStateBase(
      {required this.autovalidateMode, required this.fontSize});

  PresentationSettingsStateBase copyWith(
      {AutovalidateMode? autovalidateMode, String? fontSize}) {
    return PresentationSettingsStateBase(
        autovalidateMode: autovalidateMode ?? this.autovalidateMode,
        fontSize: fontSize ?? this.fontSize);
  }
}

final class PresentationSettingsInitial extends PresentationSettingsStateBase {
  PresentationSettingsInitial()
      : super(autovalidateMode: AutovalidateMode.disabled, fontSize: '15');
}
