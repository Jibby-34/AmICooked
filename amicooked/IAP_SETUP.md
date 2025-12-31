# In-App Purchase (IAP) Setup Guide

This document explains the IAP implementation and how to configure it for production.

## Features Implemented

### 1. **Premium Unlimited Purchase**
- One-time purchase that unlocks:
  - ✅ Unlimited "Save Me" / "Level Up" feature usage
  - ✅ Ad-free experience
  - ✅ Support for the app development

### 2. **Usage Limits for Free Users**
- Free users get **1 free use every 24 hours** of the "Save Me" / "Level Up" feature
- Timer-based system tracks last usage
- Automatic reset after 24 hours
- Warning dialog shown when limit is reached

### 3. **Shop Screen**
- Beautiful themed UI that adapts to Rizz Mode / Cooked Mode
- Shows premium features and pricing
- Purchase and restore purchase functionality
- Premium status badge for users who already purchased

### 4. **UI Updates**
- Mode selector moved to top-left corner
- Shopping bag icon added to top-right corner
- Shop icon opens the premium shop screen

## Product ID Configuration

### Current Product ID
The app uses the following product ID:
- **Product ID**: `premium_unlimited`

### ⚠️ IMPORTANT: Before Publishing

You **MUST** configure this product in both app stores:

#### Google Play Console (Android)
1. Go to Google Play Console
2. Navigate to your app → Monetization → Products → In-app products
3. Create a new product:
   - **Product ID**: `premium_unlimited`
   - **Name**: Premium Unlimited (or your preferred name)
   - **Description**: Unlock unlimited Save Me/Level Up + remove ads
   - **Price**: Set your desired price (suggested: $3.99)
   - **Status**: Active

#### App Store Connect (iOS)
1. Go to App Store Connect
2. Navigate to your app → Features → In-App Purchases
3. Create a new In-App Purchase:
   - **Type**: Non-Consumable
   - **Reference Name**: Premium Unlimited
   - **Product ID**: `premium_unlimited`
   - **Price**: Set your desired price (suggested: $3.99)
   - **Localization**: Add display name and description
   - **Review Screenshot**: Upload a screenshot showing the purchase
   - **Status**: Ready to Submit

### Changing the Product ID

If you want to use a different product ID, update it in:

```dart
// lib/services/iap_service.dart
static const String premiumProductId = 'your_new_product_id';
```

## Testing IAPs

### Android Testing
1. Add test accounts in Google Play Console
2. Use test accounts to make purchases (they won't be charged)
3. Test purchases will show "Test" in the purchase flow

### iOS Testing
1. Create a Sandbox tester account in App Store Connect
2. Sign out of your Apple ID on the test device
3. When prompted during purchase, sign in with sandbox account
4. Test purchases won't charge real money

### Manual Testing Mode
For development/testing without store setup, you can manually set premium status:

```dart
// In your code (for testing only!)
final iapService = context.read<IAPService>();
await iapService.setTestPremiumStatus(true); // Enable premium
```

## File Structure

### Services
- `lib/services/iap_service.dart` - Handles all IAP logic
- `lib/services/usage_limit_service.dart` - Manages 24-hour usage limits
- `lib/services/ad_service.dart` - Updated to respect premium status

### Screens
- `lib/screens/shop_screen.dart` - Premium shop UI
- `lib/screens/home_screen.dart` - Updated with shop icon
- `lib/screens/results_screen.dart` - Integrated IAP checks for Save Me

### Widgets
- `lib/widgets/usage_limit_dialog.dart` - Dialog shown when limit reached

## How It Works

### Purchase Flow
1. User taps shopping bag icon → Opens shop screen
2. User taps "Unlock Premium" → IAP purchase flow starts
3. User completes purchase → Premium status saved locally
4. App unlocks all premium features immediately

### Usage Limit Flow (Free Users)
1. User taps "Save Me" / "Level Up" button
2. App checks if user is premium → If yes, allow immediately
3. If not premium, check 24-hour timer:
   - If available → Allow and record usage
   - If not available → Show usage limit dialog with timer

### Ad Removal Flow
1. On app start, IAP service loads premium status
2. Premium status passed to Ad Service
3. Ad Service checks premium status before showing ads
4. Premium users never see ads

## Important Notes

### Platform-Specific Requirements

#### Android
- Billing library is included via `in_app_purchase_android`
- No additional configuration needed in AndroidManifest.xml
- Ensure your app is uploaded to Google Play Console (at least as internal testing)

#### iOS
- StoreKit is included via `in_app_purchase_storekit`
- No additional configuration needed in Info.plist
- Ensure your app is configured in App Store Connect

### Purchase Verification
Currently, the app uses client-side verification (simplified for MVP). For production, consider:
1. Implementing server-side receipt verification
2. Using a backend to validate purchases
3. Preventing purchase fraud

### Restore Purchases
The app includes a "Restore Purchases" button that:
- Queries the store for previous purchases
- Restores premium status if found
- Useful when user reinstalls app or switches devices

## Troubleshooting

### "Product not found" error
- Ensure product ID matches exactly in both code and store console
- Wait 2-4 hours after creating product in store console
- Ensure app is signed with production certificate (for iOS)

### "IAP not available" message
- Check device has internet connection
- Ensure device is signed in to App Store / Play Store
- Emulators may not support IAP - test on real device

### Purchase not restoring
- Ensure user is signed in with same account used for purchase
- Check that product is non-consumable type
- Try "Restore Purchases" button in shop

## Next Steps

1. ✅ Configure product in Google Play Console
2. ✅ Configure product in App Store Connect
3. ✅ Test purchases with sandbox/test accounts
4. ✅ Update product pricing if needed
5. ✅ Consider adding server-side verification for production
6. ✅ Monitor purchase analytics in store consoles

## Support

For IAP-related issues:
- Android: [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- iOS: [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- Flutter: [in_app_purchase package](https://pub.dev/packages/in_app_purchase)

