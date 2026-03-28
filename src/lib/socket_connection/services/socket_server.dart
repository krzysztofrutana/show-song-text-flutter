import 'dart:async';
import 'dart:io';
import 'package:encoder/encoder.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_constants.dart';

class Server {
  ServerSocket? _server;
  final info = NetworkInfo();
  String? ip;
  final List<Socket> _activeClients = [];
  List<Socket> get activeClients => List.unmodifiable(_activeClients);
  bool serverStarted = false;

  final _connectionController = StreamController<String>.broadcast();
  Stream<String> get connectionStream => _connectionController.stream;

  Future<void> init() async {
    ip = await info.getWifiIP();
  }

  Future<void> start() async {
    ip ??= await info.getWifiIP();

    if (ip == null) return;

    try {
      _server = await ServerSocket.bind(ip, SocketConstants.defaultPort);

      _server?.listen((client) {
        handleConnection(client);
      });

      serverStarted = true;
    } catch (e) {
      serverStarted = false;
      _connectionController.add('error:Could not start server on $ip:${SocketConstants.defaultPort} - $e');
    }
  }

  void handleConnection(Socket client) {
    _activeClients.add(client);
    _connectionController.add('connected:${client.remoteAddress.address}');

    client.listen((event) {}, onDone: () {
      _activeClients.remove(client);
      if (!_connectionController.isClosed) {
        _connectionController.add('disconnected:${client.remoteAddress.address}');
      }
    }, onError: (error) {
      _activeClients.remove(client);
      if (!_connectionController.isClosed) {
        _connectionController.add('disconnected:${client.remoteAddress.address}');
      }
    });
  }

  void send(String message) {
    for (var client in _activeClients) {
      client.writeln(Encoder.encodeString(message));
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    for (var client in _activeClients) {
      await client.close();
    }
    _activeClients.clear();
    serverStarted = false;
  }

  Future<void> dispose() async {
    await stop();
    await _connectionController.close();
  }
}
