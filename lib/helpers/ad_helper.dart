import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4147589820070442/4505043527';
    }

    throw UnsupportedError('Unsuported platform');
  }

  static String get interstatialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4147589820070442/5606688110';
    }

    throw UnsupportedError('Unsuported platform');
  }
}
