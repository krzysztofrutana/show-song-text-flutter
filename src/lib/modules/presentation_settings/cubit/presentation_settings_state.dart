part of 'presentation_settings_cubit.dart';

class PresentationSettingsStateBase {
  PresentationSettingsStateBase(
      {required this.autovalidateMode, required this.fontSize});

  String fontSize;
  AutovalidateMode autovalidateMode;

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
