import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';

part 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  ClientCubit() : super(ClientConnectionState());

  void setIp(String ip) {
    var client = state.client;
    if (client.connectionError == true) client.connectionError = false;

    emit(state.copyWith(ip: ip, client: client));
  }

  Future<void> startConnection(Function(Uint8List) onData) async {
    if (state.client.isConnected == true) return;

    try {
      emit(state.copyWith(connectionStarted: true));
      await state.client.connect(onData, state.ip);
      emit(state.copyWith(client: state.client, connectionStarted: false));
    } catch (ex) {
      emit(state.copyWith(client: state.client, connectionStarted: false));
    }
  }

  Future<void> stop() async {
    if (state.client.isConnected) await state.client.stop();
    emit(state.copyWith(client: Client(), connectionStarted: false));
  }
}
