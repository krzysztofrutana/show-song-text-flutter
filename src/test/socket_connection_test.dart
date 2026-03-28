import 'dart:async';

import 'package:encoder/encoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_server.dart';

void main() {
  group('SocketConnection Integration', () {
    late Server server;
    late Client client;
    const localhost = '127.0.0.1';

    setUp(() {
      server = Server();
      client = Client();
      server.ip = localhost;
    });

    tearDown(() async {
      await server.stop();
      await client.stop();
      server.dispose();
      client.dispose();
    });

    test('Server starts and stops correctly', () async {
      await server.start();
      expect(server.serverStarted, isTrue);

      await server.stop();
      expect(server.serverStarted, isFalse);
    });

    test('Client connects to server and receives data', () async {
      await server.start();
      expect(server.serverStarted, isTrue);

      final completer = Completer<String>();
      client.dataStream.listen((data) {
        if (!completer.isCompleted) {
          completer.complete(Encoder.decodeString(data));
        }
      });

      await client.connect(localhost);
      expect(client.isConnected, isTrue);

      const testMessage = '{"test": "message"}';
      server.send(testMessage);

      final receivedMessage =
          await completer.future.timeout(const Duration(seconds: 2));
      expect(receivedMessage, contains(testMessage));
    });

    test('Server handles multiple clients', () async {
      await server.start();

      final client1 = Client();
      final client2 = Client();

      await client1.connect(localhost);
      await client2.connect(localhost);

      expect(server.activeClients.length, 2);

      await client1.stop();
      // Small delay to allow server to detect disconnection
      await Future.delayed(const Duration(milliseconds: 100));
      expect(server.activeClients.length, 1);

      await client2.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(server.activeClients.length, 0);

      client1.dispose();
      client2.dispose();
    });

    test('LineSplitter handles multiple messages correctly', () async {
      await server.start();
      await client.connect(localhost);

      final receivedMessages = <String>[];
      client.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });

      server.send('message1');
      server.send('message2');

      await Future.delayed(const Duration(milliseconds: 200));
      expect(receivedMessages.length, 2);
      expect(receivedMessages[0], contains('message1'));
      expect(receivedMessages[1], contains('message2'));
    });
  });
}
