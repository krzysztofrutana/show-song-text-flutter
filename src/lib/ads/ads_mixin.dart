import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/helpers/ad_helper.dart';
import 'package:pomocnik_wokalisty/helpers/initialization_helper.dart';

mixin Ads {
  final _consentManager = AdMobInitializationHelper();
  bool _isMobileAdsInitializeCalled = false;
  BannerAd? bannerAd;

  void initAds(
      int Function() getWidth, void Function(BannerAd?) setStateBaner) {
    try {
      _initializeMobileAdsSDK(getWidth, setStateBaner);
    } catch (e) {
      debugPrint(
        "Error when loading ads: $e",
      );
    }
  }

  Widget getBanerWidget() {
    if (bannerAd != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: SizedBox(
            width: bannerAd!.size.width.toDouble(),
            height: bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: bannerAd!),
          ),
        ),
      );
    }
    return Stack();
  }

  void _loadAd(int Function() getWidth, Function setStateBaner) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      getWidth(),
    );

    if (size == null) {
      return;
    }

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Ad was loaded.");
          setStateBaner(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("Ad failed to load with error: $err");
          ad.dispose();
        },
      ),
    ).load();
  }

  void _initializeMobileAdsSDK(
      int Function() getWidth, Function setStateBaner) async {
    if (!Platform.isAndroid) return;

    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await _consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      _loadAd(getWidth, setStateBaner);
    }
  }
}
