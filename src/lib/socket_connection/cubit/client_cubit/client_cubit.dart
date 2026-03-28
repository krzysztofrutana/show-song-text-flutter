import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';

part 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  ClientCubit({Client? client})
      : _client = client ?? sl<Client>(),
        super(const ClientConnectionState());

  final Client _client;

  Stream<dynamic> get dataStream => _client.dataStream;

  void setIp(String ip) {
    emit(state.copyWith(ip: ip, connectionError: false));
  }

  Future<void> startConnection() async {
    if (_client.isConnected) return;

    try {
      emit(state.copyWith(connectionStarted: true, connectionError: false));
      await _client.connect(state.ip);
      emit(state.copyWith(
        connectionStarted: false,
        isConnected: _client.isConnected,
        connectionError: _client.connectionError,
      ));
    } catch (ex) {
      emit(state.copyWith(
        connectionStarted: false,
        isConnected: _client.isConnected,
        connectionError: _client.connectionError,
      ));
    }
  }

  Future<void> stop() async {
    if (_client.isConnected) {
      await _client.stop();
    }
    emit(const ClientConnectionState().copyWith(ip: state.ip));
  }
}
