import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/helpers/ad_helper.dart';
import 'package:pomocnik_wokalisty/helpers/initialization_helper.dart';

mixin InterstitialAds {
  final _consentManager = AdMobInitializationHelper();
  bool _isMobileAdsInitializeCalled = false;
  InterstitialAd? interstitialAd;

  void showInterstitialAds() {
    try {
      interstitialAd?.show();
    } catch (e) {
      debugPrint(
        "Error when loading ads: $e",
      );
    }
  }

  void _loadAd() async {
    InterstitialAd.load(
        adUnitId: AdHelper.interstatialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          interstitialAd = ad;
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            interstitialAd?.dispose();
            _loadAd();
          });
        }, onAdFailedToLoad: (err) {
          debugPrint("Ad failed to load with error: $err");
        }));
  }

  void initializeInterstitialMobileAdsSDK() async {
    if (!Platform.isAndroid) return;

    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await _consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      _loadAd();
    }
  }
}
