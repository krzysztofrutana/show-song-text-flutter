import 'package:flutter_fullscreen/flutter_fullscreen.dart';

class FullScreenHelper {
  static late final FullScreenHelper instance;

  static bool _init = false;
  static Future init() async {
    if (_init) return;
    await FullScreen.ensureInitialized();
    instance = FullScreenHelper();
    _init = true;
  }

  void setFullScreen(bool enabled) {
    FullScreen.setFullScreen(enabled);
  }

  void addListener(FullScreenListener listener) {
    FullScreen.addListener(listener);
  }

  void removeListener(FullScreenListener listener) {
    FullScreen.removeListener(listener);
  }
}
