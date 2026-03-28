import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:pomocnik_wokalisty/socket_connection/services/socket_constants.dart';

class Client {
  Socket? _socket;
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
    } catch (exception) {
      isConnected = false;
      connectionError = true;
      rethrow;
    }
  }

  void send(Uint8List data) {
    if (isConnected && _socket != null) {
      _socket?.add(data);
    }
  }

  Future<void> stop() async {
    await _socket?.close();
    _socket = null;
    isConnected = false;
    connectionError = false;
  }

  void dispose() {
    if (isConnected) {
      _socket?.destroy();
      _socket = null;
    }
    _dataController.close();
  }
}
