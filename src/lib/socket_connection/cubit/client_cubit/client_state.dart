part of 'client_cubit.dart';

class ClientState {
  const ClientState({
    required this.ip,
    required this.connectionStarted,
    required this.isConnected,
    required this.connectionError,
  });

  final String ip;
  final bool connectionStarted;
  final bool isConnected;
  final bool connectionError;

  ClientState copyWith({
    String? ip,
    bool? connectionStarted,
    bool? isConnected,
    bool? connectionError,
  }) {
    return ClientState(
      ip: ip ?? this.ip,
      connectionStarted: connectionStarted ?? this.connectionStarted,
      isConnected: isConnected ?? this.isConnected,
      connectionError: connectionError ?? this.connectionError,
    );
  }
}

final class ClientConnectionState extends ClientState {
  const ClientConnectionState()
      : super(
          ip: '',
          connectionStarted: false,
          isConnected: false,
          connectionError: false,
        );
}
