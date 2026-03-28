import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_server.dart';

part 'server_state.dart';

class ServerCubit extends Cubit<ServerState> {
  ServerCubit({Server? server})
      : _server = server ?? sl<Server>(),
        super(const ServerState()) {
    _server.init().then((_) => _updateState());
    _subscription = _server.connectionStream.listen((event) {
      _updateState();
    });
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      refreshIp();
    });
  }

  final Server _server;
  StreamSubscription? _subscription;
  StreamSubscription? _connectivitySubscription;

  Future<void> start() async {
    if (_server.serverStarted) return;
    await _server.start();
    _updateState();
  }

  Future<void> stop() async {
    await _server.stop();
    _updateState();
  }

  void send(String message) {
    _server.send(message);
  }

  void refreshIp() {
    _server.init().then((_) => _updateState());
  }

  void _updateState() {
    emit(ServerState(
      serverStarted: _server.serverStarted,
      activeClientsCount: _server.activeClients.length,
      ip: _server.ip,
    ));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
