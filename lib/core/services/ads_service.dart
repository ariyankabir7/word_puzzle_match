import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ad_constants.dart';
import '../../shared/widgets/banner_ad_widget.dart';

const int _loadCooldownMs = 5000;

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  bool isAdsEnabled = true;

  // Interstitial Ad state
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _lastInterstitialLoadMs = 0;

  // App Open Ad state
  AppOpenAd? _appOpenAd;
  bool _isAppOpenLoading = false;

  // Rewarded Ad state
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  int _lastRewardedLoadMs = 0;

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [
            '31F4E188CC675CACEFBDABD7BD2E2301',
          ],
        ),
      );
      loadAppOpenAd();
      loadInterstitial();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdsService initialization error: $e');
    }
  }

  // ── App Open Ad ─────────────────────────────────────────────

  void loadAppOpenAd({void Function(bool)? onLoaded}) {
    if (_appOpenAd != null) {
      onLoaded?.call(true);
      return;
    }
    if (_isAppOpenLoading) {
      onLoaded?.call(false);
      return;
    }
    _isAppOpenLoading = true;

    AppOpenAd.load(
      adUnitId: AdConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          onLoaded?.call(true);
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isAppOpenLoading = false;
          onLoaded?.call(false);
        },
      ),
    );
  }

  void showAppOpenAd({required VoidCallback onDismissed}) {
    final ad = _appOpenAd;
    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _appOpenAd = null;
          onDismissed();
          loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _appOpenAd = null;
          onDismissed();
          loadAppOpenAd();
        },
      );
      ad.show();
    } else {
      onDismissed();
      loadAppOpenAd();
    }
  }

  // ── Interstitial Ad ─────────────────────────────────────────

  void loadInterstitial({void Function(bool)? onLoaded}) {
    if (_interstitialAd != null) {
      onLoaded?.call(true);
      return;
    }
    if (_isInterstitialLoading) {
      onLoaded?.call(false);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastInterstitialLoadMs < _loadCooldownMs) {
      onLoaded?.call(false);
      return;
    }

    _isInterstitialLoading = true;
    _lastInterstitialLoadMs = now;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          onLoaded?.call(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          onLoaded?.call(false);
        },
      ),
    );
  }

  void showInterstitialIfReady({required VoidCallback onComplete}) {
    final ad = _interstitialAd;
    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _interstitialAd = null;
          onComplete();
          loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _interstitialAd = null;
          onComplete();
          loadInterstitial();
        },
      );
      ad.show();
    } else {
      onComplete();
      loadInterstitial();
    }
  }

  /// Show Interstitial with loading dialog overlay (SpaceRacer implementation)
  Future<void> showInterstitialWithLoading(
    BuildContext context, {
    required VoidCallback onDismissed,
  }) async {
    final dialogContextCompleter = Completer<BuildContext>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        if (!dialogContextCompleter.isCompleted) {
          dialogContextCompleter.complete(dialogContext);
        }
        return const _AdLoadingDialog(subtitle: 'Preparing next level...');
      },
    );

    final dialogCtx = await dialogContextCompleter.future;
    final maxWaitMs = 6000;
    final checkIntervalMs = 500;
    int timeElapsed = 0;

    Timer.periodic(Duration(milliseconds: checkIntervalMs), (timer) {
      final ad = _interstitialAd;
      if (ad != null) {
        timer.cancel();
        if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();

        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            _interstitialAd = null;
            onDismissed();
            loadInterstitial();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _interstitialAd = null;
            onDismissed();
            loadInterstitial();
          },
        );
        ad.show();
      } else {
        timeElapsed += checkIntervalMs;
        if (timeElapsed >= maxWaitMs) {
          timer.cancel();
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
          onDismissed();
          loadInterstitial();
        } else {
          if (!_isInterstitialLoading) loadInterstitial();
        }
      }
    });
  }

  // ── Rewarded Ad ─────────────────────────────────────────────

  void loadRewardedAd({void Function(bool)? onLoaded}) {
    if (_rewardedAd != null) {
      onLoaded?.call(true);
      return;
    }
    if (_isRewardedLoading) {
      onLoaded?.call(false);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRewardedLoadMs < _loadCooldownMs) {
      onLoaded?.call(false);
      return;
    }

    _isRewardedLoading = true;
    _lastRewardedLoadMs = now;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          onLoaded?.call(true);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          onLoaded?.call(false);
        },
      ),
    );
  }

  Future<int> getRewardedAdsCountToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final lastDate = prefs.getString('last_rewarded_date') ?? '';
    if (lastDate != todayStr) {
      await prefs.setString('last_rewarded_date', todayStr);
      await prefs.setInt('rewarded_count', 0);
      return 0;
    }
    return prefs.getInt('rewarded_count') ?? 0;
  }

  Future<void> _incrementRewardedAdsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final count = await getRewardedAdsCountToday();
    await prefs.setString('last_rewarded_date', todayStr);
    await prefs.setInt('rewarded_count', count + 1);
  }

  Future<void> showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onFailed,
    BuildContext? context,
  }) async {
    final todayCount = await getRewardedAdsCountToday();
    if (todayCount >= 10) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily limit of 10 rewarded ads reached! Try again tomorrow.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
      onFailed();
      return;
    }

    final ad = _rewardedAd;
    if (ad != null) {
      bool rewardGranted = false;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _rewardedAd = null;
          if (rewardGranted) {
            onRewardEarned();
          } else {
            onFailed();
          }
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _rewardedAd = null;
          onFailed();
          loadRewardedAd();
        },
      );
      ad.show(onUserEarnedReward: (ad, reward) {
        rewardGranted = true;
        _incrementRewardedAdsCount();
      });
    } else {
      loadRewardedAd();
      onFailed();
    }
  }

  /// Banner Ad Widget Hook
  Widget buildBannerAdWidget() {
    if (!isAdsEnabled) {
      return const SizedBox.shrink();
    }
    return const BannerAdWidget();
  }
}

class _AdLoadingDialog extends StatelessWidget {
  final String subtitle;

  const _AdLoadingDialog({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
