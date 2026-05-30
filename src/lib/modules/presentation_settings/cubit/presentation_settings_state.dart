part of 'presentation_settings_cubit.dart';

class PresentationSettingsStateBase {
  PresentationSettingsStateBase({
    required this.autovalidateMode,
    required this.fontSize,
    required this.textScrollMode,
  });

  String fontSize;
  AutovalidateMode autovalidateMode;
  String textScrollMode;

  PresentationSettingsStateBase copyWith({
    AutovalidateMode? autovalidateMode,
    String? fontSize,
    String? textScrollMode,
  }) {
    return PresentationSettingsStateBase(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      fontSize: fontSize ?? this.fontSize,
      textScrollMode: textScrollMode ?? this.textScrollMode,
    );
  }
}

final class PresentationSettingsInitial extends PresentationSettingsStateBase {
  PresentationSettingsInitial()
      : super(
          autovalidateMode: AutovalidateMode.disabled,
          fontSize: '15',
          textScrollMode: 'horizontal',
        );
}
