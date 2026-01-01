import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/rizz_mode_service.dart';
import 'services/iap_service.dart';
import 'services/usage_limit_service.dart';

void main() async {
  // Set system UI overlay style for status bar
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  try {
    print('Initializing AdMob SDK...');
    await AdService.initialize();
    print('AdMob SDK initialized successfully');
  } catch (e) {
    print('Failed to initialize AdMob: $e');
  }
  
  // Initialize ad service and load result view count
  final adService = AdService();
  try {
    await adService.loadResultViewCount();
    print('Result view count loaded: ${adService.resultViewCount}');
  } catch (e) {
    print('Failed to load result view count: $e');
  }
  
  // Preload first ad
  try {
    await adService.loadRewardedAd();
  } catch (e) {
    print('Failed to preload ad: $e');
  }
  
  // Initialize RizzModeService and load saved state
  final rizzModeService = RizzModeService();
  try {
    await rizzModeService.loadRizzMode();
    print('Rizz mode loaded: ${rizzModeService.isRizzMode}');
  } catch (e) {
    print('Failed to load rizz mode: $e');
  }
  
  // Initialize IAP Service
  final iapService = IAPService();
  try {
    await iapService.initialize();
    print('IAP service initialized. Premium: ${iapService.isPremium}');
    
    // Update ad service with premium status
    adService.setPremiumStatus(iapService.isPremium);
  } catch (e) {
    print('Failed to initialize IAP service: $e');
  }
  
  // Listen to IAP changes and update ad service
  iapService.addListener(() {
    adService.setPremiumStatus(iapService.isPremium);
  });
  
  // Initialize Usage Limit Service
  final usageLimitService = UsageLimitService();
  try {
    await usageLimitService.initialize();
    print('Usage limit service initialized');
  } catch (e) {
    print('Failed to initialize usage limit service: $e');
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.primaryBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: rizzModeService),
        ChangeNotifierProvider.value(value: iapService),
        ChangeNotifierProvider.value(value: usageLimitService),
      ],
      child: const AmICookedApp(),
    ),
  );
}

class AmICookedApp extends StatelessWidget {
  const AmICookedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Am I Cooked?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
