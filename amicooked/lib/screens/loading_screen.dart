import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/analysis_service.dart';
import '../services/rizz_mode_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String? text;
  final File? image;
  final bool? rizzMode;

  const LoadingScreen({
    super.key,
    this.text,
    this.image,
    this.rizzMode,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  final AnalysisService _analysisService = AnalysisService();
  final List<String> _loadingMessages = [
    '🔍 Consulting the kitchen...',
    '🔥 Preheating the oven...',
    '🌡️ Checking internal temperature...',
    '👨‍🍳 Asking the chef...',
  ];
  
  final List<String> _rizzLoadingMessages = [
    '💜 Calculating charm levels...',
    '✨ Analyzing your game...',
    '💕 Measuring the vibes...',
    '😍 Checking attraction potential...',
  ];
  
  int _currentMessageIndex = 0;
  late bool _isRizzMode;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    
    // Get rizz mode from provider or widget parameter
    _isRizzMode = widget.rizzMode ?? context.read<RizzModeService>().isRizzMode;
    
    // Fade animation for text cycling
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    // Flame animation
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _flameAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
    );
    
    _startLoading();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    // Cycle through loading messages
    _fadeController.forward();
    
    final messages = _isRizzMode ? _rizzLoadingMessages : _loadingMessages;
    
    for (int i = 0; i < messages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _currentMessageIndex = i;
        });
        _fadeController.reset();
        _fadeController.forward();
      }
    }
    
    // Perform the actual analysis
    try {
      final result = await _analysisService.analyzeInput(
        text: widget.text,
        image: widget.image,
        rizzMode: _isRizzMode,
      );
      
      if (mounted) {
        // Navigate to results screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              result: result,
              rizzMode: _isRizzMode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing: $e'),
            backgroundColor: _isRizzMode ? AppTheme.rizzPurpleDeep : AppTheme.flameRed,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _isRizzMode ? _rizzLoadingMessages : _loadingMessages;
    final primaryColor = _isRizzMode ? AppTheme.rizzPurpleMid : AppTheme.flameOrange;
    final accentColor = _isRizzMode ? AppTheme.rizzPurpleDeep : AppTheme.flameRed;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlack,
              AppTheme.secondaryBlack,
              accentColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _flameAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _flameAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isRizzMode 
                            ? const Text(
                                '💜',
                                style: TextStyle(fontSize: 80),
                              )
                            : Image.asset(
                                'lib/icons/amicooked_logo.png',
                                width: 80,
                                height: 80,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Cycling loading text with fade animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        messages[_currentMessageIndex],
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Linear progress indicator with gradient effect
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        backgroundColor: AppTheme.secondaryBlack,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

