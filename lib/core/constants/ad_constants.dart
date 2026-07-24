import 'dart:io';

/// Centralized configuration file for all Google Mobile Ads (AdMob / ADX) Unit IDs & App IDs.
/// Change your production AdMob IDs here in one place.
class AdConstants {
  // ── AdMob Application IDs ───────────────────────────────────
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  // ── Banner Ad Unit IDs ──────────────────────────────────────
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // ── Interstitial Ad Unit IDs ────────────────────────────────
  static const String androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  // ── Rewarded Ad Unit IDs ────────────────────────────────────
  static const String androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  // ── Native Ad Unit IDs ──────────────────────────────────────
  static const String androidNativeId = 'ca-app-pub-3940256099942544/2247696110';
  static const String iosNativeId = 'ca-app-pub-3940256099942544/3986624511';

  // ── App Open Ad Unit IDs ────────────────────────────────────
  static const String androidAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String iosAppOpenId = 'ca-app-pub-3940256099942544/5608718116';

  // ── Getters for Active Platform ─────────────────────────────
  static String get appId => Platform.isAndroid ? androidAppId : iosAppId;
  static String get bannerAdUnitId => Platform.isAndroid ? androidBannerId : iosBannerId;
  static String get interstitialAdUnitId => Platform.isAndroid ? androidInterstitialId : iosInterstitialId;
  static String get rewardedAdUnitId => Platform.isAndroid ? androidRewardedId : iosRewardedId;
  static String get nativeAdUnitId => Platform.isAndroid ? androidNativeId : iosNativeId;
  static String get appOpenAdUnitId => Platform.isAndroid ? androidAppOpenId : iosAppOpenId;
}
