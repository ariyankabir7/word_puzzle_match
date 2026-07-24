import 'package:flutter/material.dart';

/// Modular AdsService abstraction pre-wired for Google Ads Manager (ADX) / AdMob.
/// Active ad rendering is disabled for v1.0 release, but clean UI hooks & listeners
/// are provided so ADX integration can be activated with a single config flag.
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  bool isAdsEnabled = false;

  Future<void> init() async {
    // Ready for MobileAds.instance.initialize()
  }

  /// Banner Ad container widget hook for bottom of screens.
  Widget buildBannerAdWidget() {
    if (!isAdsEnabled) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.black12,
      child: const Center(
        child: Text(
          'ADX Banner Placeholder',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ),
    );
  }

  /// Triggers an Interstitial ad placement during level transitions.
  void showInterstitialIfReady({required VoidCallback onComplete}) {
    // If ads are disabled, execute callback immediately
    onComplete();
  }

  /// Triggers a Rewarded Ad placement (e.g., Double Coins, Time Refill).
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onFailed,
  }) {
    if (!isAdsEnabled) {
      // In offline/disabled mode, directly award reward for instant feedback
      onRewardEarned();
    } else {
      onFailed();
    }
  }
}
