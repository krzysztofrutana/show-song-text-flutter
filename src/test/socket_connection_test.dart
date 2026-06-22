import 'dart:async';

import 'package:encoder/encoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_client.dart';
import 'package:pomocnik_wokalisty/socket_connection/services/socket_constants.dart';
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

    test('Heartbeat is filtered and not passed to data stream', () async {
      await server.start();
      await client.connect(localhost);

      final receivedMessages = <String>[];
      client.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });

      server.send(SocketConstants.heartbeatMessage);
      server.send('real_data');

      await Future.delayed(const Duration(milliseconds: 200));
      expect(receivedMessages.length, 1);
      expect(receivedMessages[0], contains('real_data'));
    });

    test('New client receives last sent message on connect', () async {
      await server.start();

      final client1 = Client();
      await client1.connect(localhost);

      const testMessage = '{"page": "test"}';
      server.send(testMessage);

      final client2 = Client();
      final receivedMessages = <String>[];
      client2.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });
      await client2.connect(localhost);

      await Future.delayed(const Duration(milliseconds: 200));
      expect(receivedMessages.length, 1);
      expect(receivedMessages[0], contains(testMessage));

      await client1.stop();
      await client2.stop();
      client1.dispose();
      client2.dispose();
    });

    test('New client receives the most recent message only', () async {
      await server.start();

      final client1 = Client();
      await client1.connect(localhost);

      server.send('first_message');
      server.send('second_message');

      final client2 = Client();
      final receivedMessages = <String>[];
      client2.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });
      await client2.connect(localhost);

      await Future.delayed(const Duration(milliseconds: 200));
      expect(receivedMessages.length, 1);
      expect(receivedMessages[0], contains('second_message'));
      expect(receivedMessages[0], isNot(contains('first_message')));

      await client1.stop();
      await client2.stop();
      client1.dispose();
      client2.dispose();
    });

    test('Heartbeat does not overwrite last sent message', () async {
      await server.start();

      final client1 = Client();
      await client1.connect(localhost);

      server.send('important_data');
      server.send(SocketConstants.heartbeatMessage);

      final client2 = Client();
      final receivedMessages = <String>[];
      client2.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });
      await client2.connect(localhost);

      await Future.delayed(const Duration(milliseconds: 200));
      expect(receivedMessages.length, 1);
      expect(receivedMessages[0], contains('important_data'));

      await client1.stop();
      await client2.stop();
      client1.dispose();
      client2.dispose();
    });

    test('Last message is cleared when server stops', () async {
      await server.start();
      await client.connect(localhost);

      server.send('data_before_stop');
      await Future.delayed(const Duration(milliseconds: 50));

      await server.stop();

      final newServer = Server();
      newServer.ip = localhost;
      await newServer.start();

      final newClient = Client();
      final receivedMessages = <String>[];
      newClient.dataStream.listen((data) {
        receivedMessages.add(Encoder.decodeString(data));
      });
      await newClient.connect(localhost);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(receivedMessages, isEmpty);

      newServer.send('data_after_restart');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(receivedMessages.length, 1);
      expect(receivedMessages[0], contains('data_after_restart'));

      await newClient.stop();
      newClient.dispose();
      await newServer.stop();
      newServer.dispose();

      server = Server();
      server.ip = localhost;
    });

    test('Watchdog detects no data within timeout', () async {
      final watchdogServer = Server(heartbeatInterval: const Duration(days: 1));
      watchdogServer.ip = localhost;
      await watchdogServer.start();

      final watchdogClient = Client(
        watchdogTimeout: const Duration(milliseconds: 100),
      );
      await watchdogClient.connect(localhost);
      expect(watchdogClient.isConnected, isTrue);

      await Future.delayed(const Duration(milliseconds: 300));

      expect(watchdogClient.isConnected, isFalse);
      expect(watchdogClient.connectionError, isTrue);

      await watchdogClient.stop();
      watchdogClient.dispose();
      await watchdogServer.stop();
      watchdogServer.dispose();
    });

    test('Watchdog is reset by incoming data', () async {
      final watchdogServer = Server(heartbeatInterval: const Duration(days: 1));
      watchdogServer.ip = localhost;
      await watchdogServer.start();

      final watchdogClient = Client(
        watchdogTimeout: const Duration(milliseconds: 300),
      );
      await watchdogClient.connect(localhost);
      expect(watchdogClient.isConnected, isTrue);

      for (var i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        watchdogServer.send('keep_alive_$i');
      }

      expect(watchdogClient.isConnected, isTrue);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(watchdogClient.isConnected, isTrue);

      await watchdogClient.stop();
      watchdogClient.dispose();
      await watchdogServer.stop();
      watchdogServer.dispose();
    });

    test('Watchdog is reset by heartbeat', () async {
      final heartbeatServer = Server(
        heartbeatInterval: const Duration(milliseconds: 30),
      );
      heartbeatServer.ip = localhost;
      await heartbeatServer.start();

      final watchdogClient = Client(
        watchdogTimeout: const Duration(milliseconds: 100),
      );
      await watchdogClient.connect(localhost);
      expect(watchdogClient.isConnected, isTrue);

      await Future.delayed(const Duration(milliseconds: 400));

      expect(watchdogClient.isConnected, isTrue);

      await watchdogClient.stop();
      watchdogClient.dispose();
      await heartbeatServer.stop();
      heartbeatServer.dispose();
    });
  });
}
