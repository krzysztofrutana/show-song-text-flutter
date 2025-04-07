part of 'client_screen_mode_cubic.dart';

class ClientScreenModeState {
  String text;

  ClientScreenModeState({required this.text});

  ClientScreenModeState copyWith({String? text}) {
    return ClientScreenModeState(text: text ?? this.text);
  }
}

final class ClientScreenInitialState extends ClientScreenModeState {
  ClientScreenInitialState() : super(text: "Brak tekstu do wyświetlenia");
}

final class ClientScreenTextRecived extends ClientScreenModeState {
  ClientScreenTextRecived({required super.text});
}
