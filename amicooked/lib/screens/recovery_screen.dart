import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cooked_result.dart';
import '../theme/app_theme.dart';

class RecoveryScreen extends StatefulWidget {
  final CookedResult result;
  final bool rizzMode;

  const RecoveryScreen({
    super.key,
    required this.result,
    this.rizzMode = false,
  });

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _copiedToClipboard = false;

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

  void _copyToClipboard() {
    if (widget.result.suggestedResponse != null) {
      Clipboard.setData(ClipboardData(text: widget.result.suggestedResponse!));
      setState(() {
        _copiedToClipboard = true;
      });
      
      // Reset the copied state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _copiedToClipboard = false;
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Copied to clipboard!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRizzMode = widget.rizzMode;
    final primaryColor = isRizzMode ? AppTheme.rizzPurpleMid : AppTheme.flameOrange;
    final accentColor = isRizzMode ? AppTheme.rizzPurpleDeep : AppTheme.flameRed;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRizzMode ? '💜 Level Up' : '🔥 Save Me',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlack,
              AppTheme.secondaryBlack,
              primaryColor.withOpacity(0.1),
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
                    
                    // Title
                    Text(
                      isRizzMode ? 'Level Up Your Game' : 'Recovery Plan',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      isRizzMode 
                        ? 'Here\'s how to boost your rizz' 
                        : 'Here\'s how to fix this situation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Suggested Response Section
                    if (widget.result.suggestedResponse != null) ...[
                      Text(
                        isRizzMode ? 'Smooth Response' : 'Suggested Response',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Text Bubble
                      GestureDetector(
                        onTap: _copyToClipboard,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.result.suggestedResponse!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.primaryBlack,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    _copiedToClipboard ? Icons.check : Icons.content_copy,
                                    size: 16,
                                    color: AppTheme.primaryBlack.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _copiedToClipboard ? 'Copied!' : 'Tap to copy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryBlack.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                    
                    // Recovery Plan Section
                    if (widget.result.recoveryPlan != null) ...[
                      Text(
                        isRizzMode ? 'Rizz Strategy' : 'Recovery Strategy',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBlack,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isRizzMode ? Icons.favorite_outline : Icons.lightbulb_outline,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isRizzMode ? 'Game Plan' : 'Action Plan',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.result.recoveryPlan!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                    
                    // Motivational message
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.2),
                            accentColor.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(isRizzMode ? '✨' : '💪', style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isRizzMode 
                                ? 'You got this! Follow the plan and watch your rizz levels soar.'
                                : 'You got this! Follow the plan and you\'ll be back on track.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Back button
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text('Back to Results'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
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
}

