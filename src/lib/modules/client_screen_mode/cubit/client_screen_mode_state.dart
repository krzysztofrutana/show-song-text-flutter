part of 'client_screen_mode_cubit.dart';

class ClientScreenModeState {
  ClientScreenModeState({required this.text});

  String text;

  ClientScreenModeState copyWith({String? text}) {
    return ClientScreenModeState(text: text ?? this.text);
  }
}

final class ClientScreenInitialState extends ClientScreenModeState {
  ClientScreenInitialState() : super(text: '');
}

final class ClientScreenTextRecived extends ClientScreenModeState {
  ClientScreenTextRecived({required super.text});
}
