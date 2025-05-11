import 'package:events_emitter/emitters/event_emitter.dart';

class EventsHub {
  static late final EventEmitter instance;

  static bool _init = false;
  static Future init() async {
    if (_init) return;
    instance = EventEmitter();
    _init = true;
    return instance;
  }
}
