# AdMob Troubleshooting Guide

## Common Issue: "Ad not ready yet" on Emulator

### The Problem
When testing the app on an **emulator**, you may see this error in the console:
```
❌ Rewarded ad is not ready yet
   _rewardedAd is null: true
   _isAdLoaded: false
   ⚠️  This is common on emulators - try a real device
```

### Why This Happens
**AdMob ads often fail to load on emulators**, even with test ad IDs. This is a known limitation with Google's AdMob SDK. The ads require Google Play Services and specific device configurations that emulators don't always provide reliably.

### Solutions

#### ✅ Solution 1: Test on a Real Device (Recommended)
This is the most reliable way to test ads:

1. Connect a physical Android or iOS device
2. Enable developer mode on the device
3. Run the app: `flutter run`
4. Test ads will load and display properly

#### ✅ Solution 2: Use Android Emulator with Google Play
If you must use an emulator, make sure it has Google Play Services:

1. In Android Studio, open **AVD Manager**
2. Create or edit an emulator
3. Choose a system image with **"Google Play"** (not "Google APIs")
4. Common working images:
   - Pixel 6 API 33 (with Google Play)
   - Pixel 5 API 31 (with Google Play)
5. Start the emulator and ensure you're signed into a Google account

#### ✅ Solution 3: Check iOS Simulator Settings
For iOS simulator:

1. Make sure you're using Xcode 14+
2. Use iOS 15.0+ simulators
3. Note: iOS simulators may still have issues - real device testing is best

### What the New Logs Tell You

With the improved logging, you'll now see detailed information:

#### Successful Ad Loading
```
🎯 Loading TEST ad...
   Ad Unit ID: ca-app-pub-3940256099942544/5224354917
   Platform: Android
✅ Ad loaded successfully!
```

#### Failed Ad Loading
```
🎯 Loading TEST ad...
   Ad Unit ID: ca-app-pub-3940256099942544/5224354917
   Platform: Android
❌ RewardedAd failed to load:
   Error code: 3
   Error domain: com.google.android.gms.ads
   Error message: No fill
   ⚠️  Note: Ads often fail to load on emulators. Test on a real device for best results.
```

#### When Ad Should Show
```
📊 Result view count: 2
🎯 Ad should be shown (view count is even)
⏱️  Waiting 4 seconds before showing ad...
⏰ 4 seconds elapsed, attempting to show ad...
```

### Common Error Codes

| Error Code | Meaning | Solution |
|------------|---------|----------|
| 0 | Internal Error | Restart app, check network |
| 1 | Invalid Request | Check ad unit IDs are correct |
| 2 | Network Error | Check internet connection |
| 3 | No Fill | No ad available (common on emulator) |
| 8 | App ID Mismatch | Check AndroidManifest.xml and Info.plist |

### Verifying Your Setup

Run through this checklist:

- [ ] Dependencies installed: Run `flutter pub get`
- [ ] Using debug mode (test ads should load)
- [ ] Internet connection is active
- [ ] Testing on real device (not emulator)
- [ ] Google Play Services installed (Android)
- [ ] Signed into Google account on device
- [ ] Ad unit IDs are correct in `ad_service.dart`
- [ ] App IDs set in `AndroidManifest.xml` and `Info.plist`

### Testing the Ad Flow

1. **First result view**: Ad should NOT show (count = 1, odd)
   - Check console: `⏭️  Skipping ad this time (view count is odd)`

2. **Second result view**: Ad SHOULD show (count = 2, even)
   - Check console: `🎯 Ad should be shown (view count is even)`
   - Wait 4 seconds
   - Ad displays if ready

3. **Third result view**: Ad should NOT show (count = 3, odd)

4. **Fourth result view**: Ad SHOULD show (count = 4, even)

### Resetting View Count for Testing

If you want to reset the view count to test from the beginning:

**Android:**
```bash
adb shell pm clear com.blinklabs.amicooked
```

**iOS:**
```bash
# Uninstall and reinstall the app
```

Or manually in code (temporary debugging):
```dart
// In ad_service.dart, add to resetViewCount()
Future<void> resetViewCount() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('result_view_count', 0);
  _resultViewCount = 0;
  print('🔄 View count reset to 0');
}
```

### Still Having Issues?

1. **Check AdMob Account**
   - Verify your account is active
   - Check if app is registered
   - Ensure ad units are created

2. **Check Console Logs**
   - Look for initialization messages
   - Check for error codes
   - Note the exact error message

3. **Test with Test IDs First**
   - Debug mode automatically uses test IDs
   - These should work on real devices
   - If test IDs don't work, there's a configuration issue

4. **Common Configuration Issues**
   - Android: Missing AdMob App ID in `AndroidManifest.xml`
   - iOS: Missing GADApplicationIdentifier in `Info.plist`
   - Wrong package name in AdMob console
   - Ad unit IDs don't match platform (Android ID used for iOS or vice versa)

### Getting Help

If you're still stuck, gather this information:

1. Platform (Android/iOS)
2. Device or emulator model
3. Debug or release mode
4. Complete console output (especially ad loading section)
5. Error code and message
6. Whether you're using test or production IDs

## Expected Behavior

### On Real Device with Working Setup:

**First Run:**
```
Initializing AdMob SDK...
AdMob SDK initialized successfully
Result view count loaded: 0
🎯 Loading TEST ad...
   Ad Unit ID: ca-app-pub-3940256099942544/5224354917
   Platform: Android
✅ Ad loaded successfully!
```

**First Result View:**
```
📊 Result view count: 1
⏭️  Skipping ad this time (view count is odd)
```

**Second Result View:**
```
📊 Result view count: 2
🎯 Ad should be shown (view count is even)
⏱️  Waiting 4 seconds before showing ad...
⏰ 4 seconds elapsed, attempting to show ad...
🎬 Showing rewarded ad...
✅ Rewarded ad shown successfully
```

This is what you should see when everything is working correctly!

