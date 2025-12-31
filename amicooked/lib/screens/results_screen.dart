import 'package:flutter/material.dart';
import '../models/cooked_result.dart';
import '../theme/app_theme.dart';
import '../widgets/cooked_meter.dart';
import '../services/share_service.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';
import 'recovery_screen.dart';
import 'dart:async';

class ResultsScreen extends StatefulWidget {
  final CookedResult result;

  const ResultsScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final ShareService _shareService = ShareService();
  final AdService _adService = AdService();
  bool _isSharing = false;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    
    // Slide-in animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    
    // Handle ad display logic
    _handleAdDisplay();
  }

  void _handleAdDisplay() async {
    // Increment view count
    await _adService.incrementResultViewCount();
    
    print('📊 Result view count: ${_adService.resultViewCount}');
    
    // Check if we should show an ad (every other time)
    if (_adService.shouldShowAd()) {
      print('🎯 Ad should be shown (view count is even)');
      print('⏱️  Waiting 4 seconds before showing ad...');
      
      // Wait 4 seconds before showing ad
      _adTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          print('⏰ 4 seconds elapsed, attempting to show ad...');
          _showRewardedAd();
        }
      });
    } else {
      print('⏭️  Skipping ad this time (view count is odd)');
    }
  }

  void _showRewardedAd() {
    print('🎬 _showRewardedAd() called');
    print('   Ad ready status: ${_adService.isAdReady}');
    
    if (!_adService.isAdReady) {
      print('❌ Ad not ready - cannot show');
      return;
    }

    _adService.showRewardedAd(
      onAdShown: () {
        print('✅ Rewarded ad shown successfully');
      },
      onUserEarnedReward: () {
        // User watched the ad and earned a reward
        // You can optionally give them something here
        print('🎉 User earned reward');
      },
      onAdFailed: () {
        print('❌ Failed to show rewarded ad');
      },
    );
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  String _getEmoji(int percentage) {
    if (percentage >= 90) return '💀';
    if (percentage >= 70) return '🔥';
    if (percentage >= 50) return '😰';
    if (percentage >= 30) return '😅';
    return '✅';
  }

  void _tryAnother() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _saveMe() {
    // Check if recovery plan is available
    if (widget.result.recoveryPlan != null || widget.result.suggestedResponse != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecoveryScreen(result: widget.result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ No recovery plan available for this result'),
          backgroundColor: AppTheme.flameRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _shareVerdict() async {
    if (_isSharing) return;
    
    setState(() {
      _isSharing = true;
    });

    try {
      await _shareService.shareResult(context, widget.result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Shared successfully!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to share: $e'),
            backgroundColor: AppTheme.flameRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlack,
              AppTheme.secondaryBlack,
              _getBackgroundColor(),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _slideController,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Cooked Meter
                    Center(
                      child: CookedMeter(
                        percentage: widget.result.cookedPercent,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Verdict with emoji
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getEmoji(widget.result.cookedPercent),
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.result.verdict,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Explanation
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlack,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getBorderColor(),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        widget.result.explanation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Action buttons
                    ElevatedButton.icon(
                      onPressed: _tryAnother,
                      icon: const Icon(Icons.refresh, size: 24),
                      label: const Text('Try Another'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saveMe,
                            icon: const Text('🔥'),
                            label: const Text('Save Me'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSharing ? null : _shareVerdict,
                            icon: _isSharing 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.share, size: 20),
                            label: Text(_isSharing ? 'Sharing...' : 'Share'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.result.cookedPercent >= 70) {
      return AppTheme.flameRed.withOpacity(0.15);
    } else if (widget.result.cookedPercent >= 50) {
      return AppTheme.flameOrange.withOpacity(0.1);
    } else {
      return const Color(0xFF4CAF50).withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    if (widget.result.cookedPercent >= 70) {
      return AppTheme.flameRed;
    } else if (widget.result.cookedPercent >= 50) {
      return AppTheme.flameOrange;
    } else {
      return const Color(0xFF4CAF50);
    }
  }
}

