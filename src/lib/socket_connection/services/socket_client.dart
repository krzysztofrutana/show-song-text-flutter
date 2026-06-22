import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:encoder/encoder.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_constants.dart';

class Client {
  Client({Duration? watchdogTimeout})
      : _watchdogTimeout =
            watchdogTimeout ?? SocketConstants.clientWatchdogTimeout;

  Socket? _socket;
  Timer? _watchdogTimer;
  final Duration _watchdogTimeout;
  bool isConnected = false;
  bool connectionError = false;

  final _dataController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  Future<void> connect(String ip) async {
    connectionError = false;
    try {
      _socket = await Socket.connect(ip, SocketConstants.defaultPort,
          timeout: SocketConstants.connectTimeout);

      _socket?.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter()).listen(
        (line) {
          _resetWatchdog();
          try {
            final decoded = Encoder.decodeString(line);
            if (decoded == SocketConstants.heartbeatMessage) return;
          } catch (_) {}
          if (!_dataController.isClosed) {
            _dataController.add(line);
          }
        },
        onError: (e) {
          connectionError = true;
          if (!_dataController.isClosed) {
            _dataController.addError(e);
          }
        },
        onDone: () {
          _cancelWatchdog();
          _socket?.destroy();
          _socket = null;
          isConnected = false;
          if (!_dataController.isClosed) {
            _dataController.addError('Connection closed');
          }
        },
        cancelOnError: false,
      );
      isConnected = true;
      connectionError = false;
      _resetWatchdog();
    } catch (exception) {
      isConnected = false;
      connectionError = true;
      rethrow;
    }
  }

  void _resetWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_watchdogTimeout, () {
      _watchdogTimer = null;
      isConnected = false;
      connectionError = true;
      _socket?.destroy();
      _socket = null;
      if (!_dataController.isClosed) {
        _dataController.addError('Connection lost - no data received');
      }
    });
  }

  void _cancelWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
  }

  void send(Uint8List data) {
    if (isConnected && _socket != null) {
      _socket?.add(data);
    }
  }

  Future<void> stop() async {
    _cancelWatchdog();
    await _socket?.close();
    _socket = null;
    isConnected = false;
    connectionError = false;
  }

  void dispose() {
    _cancelWatchdog();
    if (isConnected) {
      _socket?.destroy();
      _socket = null;
    }
    _dataController.close();
  }
}
