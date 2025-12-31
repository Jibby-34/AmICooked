import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';

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
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.primaryBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const AmICookedApp());
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
