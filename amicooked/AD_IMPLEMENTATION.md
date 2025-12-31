# AdMob Rewarded Ad Implementation

## Overview
This app implements rewarded ads using Google AdMob that appear 4 seconds after the user views their results, every other time.

## Features
- ✅ Rewarded ads show 4 seconds after results are displayed
- ✅ Ads appear every other time (alternating pattern)
- ✅ Platform-specific ad IDs (iOS and Android)
- ✅ Currently using **test ad IDs** for development

## How It Works

### Ad Display Logic
1. When a user reaches the results screen, the view count is incremented
2. If the count is even (2, 4, 6, etc.), an ad will be shown
3. A 4-second timer starts before displaying the ad
4. The ad is shown as a rewarded ad (user can skip or watch)
5. When the user completes watching, they see a success message

### Files Modified

#### 1. `pubspec.yaml`
Added dependencies:
- `google_mobile_ads: ^5.2.0` - For AdMob integration
- `shared_preferences: ^2.2.2` - For tracking ad view counts

#### 2. `lib/main.dart`
- Initializes AdMob SDK on app startup
- Loads result view count from preferences
- Preloads the first ad

#### 3. `lib/services/ad_service.dart`
Core ad management service that handles:
- Platform-specific ad unit IDs (iOS/Android)
- Ad loading and showing
- View count tracking
- Determining when to show ads (every other time)

#### 4. `lib/screens/results_screen.dart`
- Triggers ad display 4 seconds after results are shown
- Handles ad callbacks and user rewards
- Shows success message when user watches ad

#### 5. Android Configuration (`android/app/src/main/AndroidManifest.xml`)
Added AdMob App ID metadata

#### 6. iOS Configuration (`ios/Runner/Info.plist`)
Added:
- AdMob App ID
- SKAdNetwork identifiers for iOS 14+ tracking

## Automatic Test/Production Ad Switching

The app automatically uses the correct ad IDs based on build mode:

### Debug Mode (Development)
Automatically uses Google's test ad IDs:
- **Android Rewarded Ad**: `ca-app-pub-3940256099942544/5224354917`
- **iOS Rewarded Ad**: `ca-app-pub-3940256099942544/1712485313`

### Release Mode (Production)
Automatically uses your production ad IDs:
- **Android Rewarded Ad**: `ca-app-pub-6637557002473159/1392428474`
- **iOS Rewarded Ad**: `ca-app-pub-6637557002473159/5852410058`

✅ **No manual switching needed!** The app detects debug vs release mode automatically using Flutter's `kDebugMode`.

## Replacing with Production Ad IDs

### Step 1: Create AdMob Account
1. Go to [AdMob Console](https://apps.admob.com/)
2. Sign in with your Google account
3. Create a new app or add existing app

### Step 2: Get Your App IDs
1. In AdMob console, go to "Apps"
2. Select your app
3. Copy the App ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

### Step 3: Create Rewarded Ad Units
1. In your app, go to "Ad units"
2. Click "Add ad unit"
3. Select "Rewarded"
4. Configure and create
5. Copy the Ad unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)
6. Repeat for both Android and iOS

### Step 4: Update the Code

#### Update `lib/services/ad_service.dart`:
```dart
// Replace the production IDs with your real IDs:
static const String _prodAndroidRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your Android ID
static const String _prodIosRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your iOS ID

// Keep the test IDs as they are - they're used automatically in debug mode
```

#### Update `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Replace the test App ID with your real Android App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

#### Update `ios/Runner/Info.plist`:
```xml
<!-- Replace the test App ID with your real iOS App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### Step 5: Test with Real Ads

#### Debug Testing (Test Ads)
1. Run the app in debug mode: `flutter run`
2. Test ads will automatically be used
3. View results twice to trigger an ad on the second view
4. Wait 4 seconds for the test ad to appear
5. Check console for log: "Loading TEST ad: ..."

#### Production Testing (Real Ads)
1. Build in release mode: `flutter build apk --release` or `flutter build ios --release`
2. Install on a real device (not emulator)
3. Your production ads will automatically be used
4. View results twice to trigger an ad on the second view
5. Wait 4 seconds for the ad to appear
6. Check console for log: "Loading PRODUCTION ad: ..."

⚠️ **Testing Note**: During testing with real ad IDs, add your test device ID in AdMob console to avoid invalid traffic that could get your account flagged.

## Customization Options

### Change Ad Frequency
In `lib/services/ad_service.dart`, modify the `shouldShowAd()` method:

```dart
// Current: Show every other time (every 2 views)
bool shouldShowAd() {
  return _resultViewCount % 2 == 0;
}

// Show every 3rd time:
bool shouldShowAd() {
  return _resultViewCount % 3 == 0;
}

// Always show:
bool shouldShowAd() {
  return true;
}
```

### Change Delay Time
In `lib/screens/results_screen.dart`, modify the timer duration:

```dart
// Current: 4 seconds
_adTimer = Timer(const Duration(seconds: 4), () {
  if (mounted) {
    _showRewardedAd();
  }
});

// Change to 6 seconds:
_adTimer = Timer(const Duration(seconds: 6), () {
  if (mounted) {
    _showRewardedAd();
  }
});
```

### Give Rewards
You can give users in-app rewards when they watch ads. Update the `onUserEarnedReward` callback in `results_screen.dart`:

```dart
onUserEarnedReward: () {
  // Example: Give user coins, unlock features, etc.
  // Add your reward logic here
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ You earned 10 coins!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Ad Not Showing
1. Check internet connection
2. Verify ad IDs are correct
3. Ensure you're on the correct view count (check logs)
4. Wait for ad to load (check `isAdReady`)
5. Check AdMob account status

### Testing Issues
- Use test IDs during development
- Test on real devices, not emulators
- Clear app data to reset view count
- Check console logs for error messages

### Production Issues
- Verify AdMob account is approved
- Check payment information is set up
- Ensure app is published and verified
- Review AdMob policies compliance

## How Automatic Ad ID Switching Works

The app uses Flutter's `kDebugMode` constant to automatically detect the build mode:

```dart
String get _rewardedAdUnitId {
  if (Platform.isAndroid) {
    return kDebugMode ? _testAndroidRewardedAdUnitId : _prodAndroidRewardedAdUnitId;
  } else if (Platform.isIOS) {
    return kDebugMode ? _testIosRewardedAdUnitId : _prodIosRewardedAdUnitId;
  }
  return '';
}
```

**Benefits:**
- ✅ No need to manually switch IDs between testing and production
- ✅ Prevents accidentally using production IDs during development
- ✅ Avoids invalid traffic on your production ads
- ✅ Console logs show which mode is active
- ✅ Safe for production releases - automatically uses real IDs

## Best Practices
1. ✅ Test in debug mode first (uses test IDs automatically)
2. ✅ Add test devices to AdMob before release builds
3. ✅ Don't click your own ads in production
4. ✅ Monitor ad performance in AdMob console
5. ✅ Follow AdMob policies and guidelines
6. ✅ Provide value to users (consider rewards)
7. ✅ Check console logs to verify correct ad mode

## Resources
- [AdMob Documentation](https://developers.google.com/admob)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)

