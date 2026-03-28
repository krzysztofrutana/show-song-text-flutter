part of 'server_cubit.dart';

class ServerState extends Equatable {
  const ServerState({
    this.serverStarted = false,
    this.activeClientsCount = 0,
    this.ip,
  });

  final bool serverStarted;
  final int activeClientsCount;
  final String? ip;

  ServerState copyWith({
    bool? serverStarted,
    int? activeClientsCount,
    String? ip,
  }) {
    return ServerState(
      serverStarted: serverStarted ?? this.serverStarted,
      activeClientsCount: activeClientsCount ?? this.activeClientsCount,
      ip: ip ?? this.ip,
    );
  }

  @override
  List<Object?> get props => [serverStarted, activeClientsCount, ip];
}
