class SocketConstants {
  static const int defaultPort = 55555;
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration clientWatchdogTimeout = Duration(seconds: 90);
  static const String heartbeatMessage = '__ping__';
}
