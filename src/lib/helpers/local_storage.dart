import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late final SharedPreferences instance;

  static bool _init = false;
  static Future<SharedPreferences> init() async {
    if (_init) return instance;
    instance = await SharedPreferences.getInstance();
    _init = true;
    return instance;
  }
}
