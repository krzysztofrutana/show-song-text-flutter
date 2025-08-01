import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

class Client {
  late Socket socket;
  bool isConnected = false;
  bool connectionError = false;

  Future<void> connect(
      Function(Uint8List) onData, Function(dynamic) onError, String ip) async {
    connectionError = false;
    try {
      socket = await Socket.connect(ip, 55555, timeout: Duration(seconds: 5));
      socket.listen(
        onData,
        onError: onError,
        onDone: () {
          socket.destroy();
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

  Future<void> stop() async {
    await socket.close();
    isConnected = false;
    connectionError = false;
  }
}
