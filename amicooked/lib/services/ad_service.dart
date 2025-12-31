import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  int _resultViewCount = 0;

  // Test Ad Unit IDs (used in debug mode)
  static const String _testAndroidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  // Production Ad Unit IDs (used in release mode)
  static const String _prodAndroidRewardedAdUnitId = 'ca-app-pub-6637557002473159/1392428474';
  static const String _prodIosRewardedAdUnitId = 'ca-app-pub-6637557002473159/5852410058';

  // Get platform-specific ad unit ID (automatically uses test IDs in debug mode)
  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode ? _testAndroidRewardedAdUnitId : _prodAndroidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return kDebugMode ? _testIosRewardedAdUnitId : _prodIosRewardedAdUnitId;
    }
    return '';
  }

  /// Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    final initResult = await MobileAds.instance.initialize();
    print('AdMob initialization status: ${initResult.adapterStatuses}');
  }

  /// Load result view count from preferences
  Future<void> loadResultViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    _resultViewCount = prefs.getInt('result_view_count') ?? 0;
  }

  /// Increment and save result view count
  Future<void> incrementResultViewCount() async {
    _resultViewCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('result_view_count', _resultViewCount);
  }

  /// Check if ad should be shown (every other time)
  bool shouldShowAd() {
    return _resultViewCount % 2 == 0;
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (Platform.isAndroid || Platform.isIOS) {
      print('🎯 Loading ${kDebugMode ? 'TEST' : 'PRODUCTION'} ad...');
      print('   Ad Unit ID: $_rewardedAdUnitId');
      print('   Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
      
      try {
        await RewardedAd.load(
          adUnitId: _rewardedAdUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              _rewardedAd = ad;
              _isAdLoaded = true;
              _setupAdCallbacks();
              print('✅ Ad loaded successfully!');
            },
            onAdFailedToLoad: (error) {
              print('❌ RewardedAd failed to load:');
              print('   Error code: ${error.code}');
              print('   Error domain: ${error.domain}');
              print('   Error message: ${error.message}');
              print('   Response info: ${error.responseInfo}');
              print('   ⚠️  Note: Ads often fail to load on emulators. Test on a real device for best results.');
              _isAdLoaded = false;
            },
          ),
        );
      } catch (e) {
        print('❌ Exception while loading ad: $e');
        _isAdLoaded = false;
      }
    } else {
      print('⚠️  Ads not supported on this platform');
    }
  }

  /// Setup ad callbacks
  void _setupAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        // Preload next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
    );
  }

  /// Show the rewarded ad
  Future<void> showRewardedAd({
    required Function() onAdShown,
    required Function() onUserEarnedReward,
    required Function() onAdFailed,
  }) async {
    if (_rewardedAd != null && _isAdLoaded) {
      print('🎬 Showing rewarded ad...');
      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('🎉 User earned reward: ${reward.amount} ${reward.type}');
            onUserEarnedReward();
          },
        );
        onAdShown();
      } catch (e) {
        print('❌ Error showing ad: $e');
        onAdFailed();
      }
    } else {
      print('❌ Rewarded ad is not ready yet');
      print('   _rewardedAd is null: ${_rewardedAd == null}');
      print('   _isAdLoaded: $_isAdLoaded');
      print('   ⚠️  This is common on emulators - try a real device');
      onAdFailed();
    }
  }

  /// Dispose of the ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }

  /// Check if ad is loaded and ready
  bool get isAdReady => _isAdLoaded && _rewardedAd != null;

  /// Get current result view count
  int get resultViewCount => _resultViewCount;
}

