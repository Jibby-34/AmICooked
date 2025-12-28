import 'package:flutter/material.dart';
import '../models/cooked_result.dart';
import '../theme/app_theme.dart';
import '../widgets/cooked_meter.dart';
import 'home_screen.dart';

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
  }

  @override
  void dispose() {
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
    // Stub for future rewrite feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔜 Save Me feature coming soon!'),
        backgroundColor: AppTheme.flameOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _shareVerdict() {
    // Stub for future share feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📱 Share feature coming soon!'),
        backgroundColor: AppTheme.flameOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
                            onPressed: _shareVerdict,
                            icon: const Icon(Icons.share, size: 20),
                            label: const Text('Share'),
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

