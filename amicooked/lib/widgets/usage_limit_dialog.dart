import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/usage_limit_service.dart';
import '../screens/shop_screen.dart';

/// Dialog to show when user is about to use or has used their daily limit
class UsageLimitDialog extends StatelessWidget {
  final bool isRizzMode;
  final UsageLimitService usageLimitService;
  final bool isFirstUse; // true = warning before use, false = already used

  const UsageLimitDialog({
    super.key,
    required this.isRizzMode,
    required this.usageLimitService,
    required this.isFirstUse,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isRizzMode ? AppTheme.rizzPurpleMid : AppTheme.flameOrange;
    final accentColor = isRizzMode ? AppTheme.rizzPurpleDeep : AppTheme.flameRed;
    final lightColor = isRizzMode ? AppTheme.rizzPurpleLight : AppTheme.flameYellow;
    
    final timeRemaining = usageLimitService.getTimeRemainingString(isRizzMode);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBlack,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [primaryColor, lightColor],
                        ),
                      ),
                      child: Icon(
                        isFirstUse ? Icons.info_outline : Icons.timer,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                
                const SizedBox(height: 16),
                
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [lightColor, primaryColor],
                  ).createShader(bounds),
                  child: Text(
                    isFirstUse ? 'Free Daily Use' : 'Daily Limit Reached',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Message
                Text(
                  isFirstUse
                      ? (isRizzMode
                          ? 'You get 1 free Level Up per day.\nWould you like to use it now?'
                          : 'You get 1 free Save Me per day.\nWould you like to use it now?')
                      : (isRizzMode
                          ? 'You\'ve used your free Level Up for today!'
                          : 'You\'ve used your free Save Me for today!'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Time remaining (only show if already used)
                if (!isFirstUse)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Next free use in $timeRemaining',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Premium offer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        accentColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars, color: lightColor, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Go Premium',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: lightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Unlimited Uses + No Ads',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Buttons - Same layout for both states
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, isFirstUse ? true : false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isFirstUse ? 'Use It Now' : 'Maybe Later',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShopScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Premium',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ),
            // Close button in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                ),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the usage limit dialog
  /// Returns true if user wants to continue with their free use, false otherwise
  static Future<bool?> show(
    BuildContext context, {
    required bool isRizzMode,
    required UsageLimitService usageLimitService,
    required bool isFirstUse,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UsageLimitDialog(
        isRizzMode: isRizzMode,
        usageLimitService: usageLimitService,
        isFirstUse: isFirstUse,
      ),
    );
  }
}

