import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (replace with your actual IDs)
  static const String _prodBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static bool _isTestMode = true; // Set to false for production

  // Interstitial Ad instance for preloading
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;

  // Get Ad Unit IDs based on platform and mode
  static String get bannerAdUnitId {
    if (_isTestMode) return _testBannerAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodBannerAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (_isTestMode) return _testInterstitialAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodInterstitialAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (_isTestMode) return _testRewardedAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodRewardedAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  // Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // Preload interstitial ad on app start
    await loadInterstitialAd();
  }

  // Create Banner Ad with unique ID for each screen
  static BannerAd createBannerAd({
    required String screenName,
    required AdSize adSize,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: listener,
    );
  }

  // Load Interstitial Ad (preload for exit)
  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              // Reload for next time
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('InterstitialAd failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Reload for next time
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show Interstitial Ad (for exit)
  static Future<bool> showInterstitialAd() async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    } else {
      print('Interstitial ad not ready');
      return false;
    }
  }

  // Check if interstitial ad is ready
  static bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Load Rewarded Ad
  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;
    
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
    
    return rewardedAd;
  }

  // Show Rewarded Ad
  static Future<bool> showRewardedAd(RewardedAd ad, {required Function() onRewarded}) async {
    bool rewarded = false;
    
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('RewardedAd failed to show: $error');
        ad.dispose();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onRewarded();
      },
    );

    return rewarded;
  }

  // Dispose interstitial ad
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}

