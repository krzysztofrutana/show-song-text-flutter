part of 'client_cubit.dart';

class ClientState {
  Client client;
  String ip;
  bool connectionStarted;

  ClientState(
      {required this.client,
      required this.ip,
      required this.connectionStarted});

  ClientState copyWith({Client? client, String? ip, bool? connectionStarted}) {
    return ClientState(
        client: client ?? this.client,
        ip: ip ?? this.ip,
        connectionStarted: connectionStarted ?? this.connectionStarted);
  }
}

final class ClientConnectionState extends ClientState {
  ClientConnectionState()
      : super(client: Client(), ip: '', connectionStarted: false);
}
