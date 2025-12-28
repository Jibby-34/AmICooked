import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  // Set system UI overlay style for status bar
  WidgetsFlutterBinding.ensureInitialized();
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
