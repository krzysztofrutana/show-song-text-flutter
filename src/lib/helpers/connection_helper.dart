import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionHelper {
  static List<ConnectivityResult> validResult = [
    ConnectivityResult.wifi,
    ConnectivityResult.mobile,
    ConnectivityResult.ethernet,
  ];

  static Future<bool> checkIfDeviceIsConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    for (var item in connectivityResult) {
      if (validResult.contains(item)) {
        return true;
      }
    }
    return false;
  }
}
