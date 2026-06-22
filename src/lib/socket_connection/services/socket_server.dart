import 'dart:async';
import 'dart:io';

import 'package:encoder/encoder.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_constants.dart';

class Server {
  Server({Duration? heartbeatInterval})
      : _heartbeatInterval =
            heartbeatInterval ?? SocketConstants.heartbeatInterval;

  ServerSocket? _server;
  Timer? _heartbeatTimer;
  final Duration _heartbeatInterval;
  final info = NetworkInfo();
  String? ip;
  String? _lastSentMessage;
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
      _startHeartbeat();
    } catch (e) {
      serverStarted = false;
      _connectionController.add(
        'error:Could not start server on $ip:${SocketConstants.defaultPort} - $e',
      );
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) {
        if (_activeClients.isNotEmpty) {
          send(SocketConstants.heartbeatMessage);
        }
      },
    );
  }

  void handleConnection(Socket client) {
    _activeClients.add(client);
    _connectionController.add('connected:${client.remoteAddress.address}');

    if (_lastSentMessage != null) {
      client.writeln(Encoder.encodeString(_lastSentMessage!));
    }

    client.listen(
      (event) {},
      onDone: () {
        _activeClients.remove(client);
        if (!_connectionController.isClosed) {
          final address = _clientAddress(client);
          _connectionController.add('disconnected:$address');
        }
      },
      onError: (error) {
        _activeClients.remove(client);
        if (!_connectionController.isClosed) {
          final address = _clientAddress(client);
          _connectionController.add('disconnected:$address');
        }
      },
    );
  }

  String _clientAddress(Socket client) {
    try {
      return client.remoteAddress.address;
    } catch (_) {
      return 'unknown';
    }
  }

  void send(String message) {
    if (message != SocketConstants.heartbeatMessage) {
      _lastSentMessage = message;
    }
    for (var client in _activeClients) {
      client.writeln(Encoder.encodeString(message));
    }
  }

  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _lastSentMessage = null;
    await _server?.close();
    _server = null;

    final closeFutures = <Future>[];
    for (var client in _activeClients) {
      closeFutures.add(client.close());
    }
    await Future.wait(closeFutures);

    _activeClients.clear();
    serverStarted = false;
  }

  Future<void> dispose() async {
    await stop();
    await _connectionController.close();
  }
}
