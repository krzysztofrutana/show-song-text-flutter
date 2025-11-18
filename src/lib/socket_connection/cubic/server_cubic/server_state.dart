part of 'server_cubit.dart';

class ServerStateBase {
  Server server;

  ServerStateBase({required this.server});

  ServerStateBase copyWith({Server? server}) =>
      ServerStateBase(server: server ?? this.server);
}

final class ServerState extends ServerStateBase {
  ServerState() : super(server: Server());
}
