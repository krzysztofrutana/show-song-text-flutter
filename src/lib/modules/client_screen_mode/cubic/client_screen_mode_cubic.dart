import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

part 'client_screen_mode_state.dart';

class ClientScreenModeCubic extends Cubit<ClientScreenModeState> {
  ClientScreenModeCubic() : super(ClientScreenInitialState());

  void setText(String text) async {
    emit(ClientScreenTextRecived(text: text));
  }

  void clear() async {
    emit(ClientScreenInitialState());
  }
}
