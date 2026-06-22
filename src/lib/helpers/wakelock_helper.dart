import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockHelper {
  static late final WakelockHelper instance;

  static bool _init = false;
  static void init() {
    if (_init) return;
    instance = WakelockHelper();
    _init = true;
  }

  void enable() {
    WakelockPlus.enable();
  }

  void disable() {
    WakelockPlus.disable();
  }
}
