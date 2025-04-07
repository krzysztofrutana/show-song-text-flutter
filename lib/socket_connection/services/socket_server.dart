import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pomocnik_wokalisty/helpers/EventsHub.dart';

class Server {
  late ServerSocket server;
  final info = NetworkInfo();
  String? ip;
  List<Socket> activeClienst = [];
  bool serverStarted = false;

  Future<void> init() async {
    ip = await info.getWifiIP();
  }

  Future<void> start() async {
    ip ??= await info.getWifiIP();

    if (ip == null) return;

    server = await ServerSocket.bind(ip, 55555);

    server.listen((client) {
      handleConnection(client);
    });

    serverStarted = true;
  }

  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    activeClienst.add(client);
    EventsHub.instance.emit('client_connected', client.remoteAddress.address);

    client.listen((event) {}, onDone: () {
      activeClienst.remove(client);
      EventsHub.instance
          .emit('client_disconnected', client.remoteAddress.address);
    }, onError: (error) {
      activeClienst.remove(client);
      EventsHub.instance
          .emit('client_disconnected', client.remoteAddress.address);
    });
  }

  void send(String message) {
    for (var client in activeClienst) {
      client.write(message);
    }
  }

  Future<void> stop() async {
    await server.close();
    activeClienst.clear();
    serverStarted = false;
  }
}
