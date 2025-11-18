import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_server.dart';

part 'server_state.dart';

class ServerCubit extends Cubit<ServerStateBase> {
  ServerCubit() : super(ServerState());

  Future<void> start() async {
    if (state.server.serverStarted) return;

    await state.server.start();
    emit(state.copyWith(server: state.server));
  }

  Future<void> stop() async {
    await state.server.stop();
    emit(ServerState());
  }

  void send(String message) {
    state.server.send(message);
  }

  void clientConnected() {
    emit(state.copyWith(server: state.server));
  }

  void clientDisconnected() {
    emit(state.copyWith(server: state.server));
  }
}
