import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iap_service.dart';
import '../services/rizz_mode_service.dart';
import 'dart:math' as math;

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shimmerController;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Shimmer animation for premium card
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _purchasePremium(IAPService iapService) async {
    if (_isPurchasing) return;
    
    setState(() {
      _isPurchasing = true;
    });

    try {
      await iapService.purchasePremium();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: AppTheme.flameRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases(IAPService iapService) async {
    try {
      await iapService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppTheme.flameRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RizzModeService, IAPService>(
      builder: (context, rizzModeService, iapService, child) {
        // Use a unified color scheme (mix of both modes)
        final primaryColor = const Color(0xFFB366FF); // Purple-ish
        final accentColor = const Color(0xFFFF6B35); // Orange-ish
        final lightColor = const Color(0xFFFFD93D); // Yellow-ish
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  primaryColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                  AppTheme.primaryBlack,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: AppTheme.textPrimary,
                        ),
                        const Spacer(),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [lightColor, primaryColor, accentColor],
                          ).createShader(bounds),
                          child: Text(
                            '✨ Premium Shop',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Premium status indicator
                          if (iapService.isPremiumUser)
                            _buildPremiumBadge(primaryColor, lightColor),
                          
                          if (iapService.isPremiumUser)
                            const SizedBox(height: 32),
                          
                          // Premium card
                          if (!iapService.isPremiumUser)
                            _buildPremiumCard(
                              primaryColor,
                              accentColor,
                              lightColor,
                              iapService,
                            ),
                          
                          if (!iapService.isPremiumUser)
                            const SizedBox(height: 32),
                          
                          // Features list
                          _buildFeaturesList(primaryColor),
                          
                          const SizedBox(height: 32),
                          
                          // Restore purchases button
                          if (!iapService.isPremiumUser)
                            TextButton(
                              onPressed: () => _restorePurchases(iapService),
                              child: Text(
                                'Restore Purchases',
                                style: TextStyle(
                                  color: primaryColor.withOpacity(0.7),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Info text
                          Text(
                            'One-time purchase. No subscriptions.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumBadge(Color primaryColor, Color lightColor) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, lightColor],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'Premium Unlocked!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumCard(
    Color primaryColor,
    Color accentColor,
    Color lightColor,
    IAPService iapService,
  ) {
    // Get product details
    final product = iapService.products.isNotEmpty 
        ? iapService.products.first 
        : null;
    
    final price = product?.price ?? '\$3.99'; // Fallback price
    
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _shimmerController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: accentColor.withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background gradient
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.2),
                        accentColor.withOpacity(0.1),
                        AppTheme.secondaryBlack,
                      ],
                    ),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryColor, lightColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.stars,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [lightColor, primaryColor, accentColor],
                        ).createShader(bounds),
                        child: Text(
                          'Premium Unlimited',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price
                      Text(
                        price,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: lightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'One-time payment',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Purchase button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPurchasing || iapService.isLoading
                              ? null
                              : () => _purchasePremium(iapService),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isPurchasing || iapService.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_cart, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Unlock Premium',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Shimmer effect
                Positioned.fill(
                  child: CustomPaint(
                    painter: ShimmerPainter(
                      animation: _shimmerController.value,
                      color: lightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList(Color primaryColor) {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Unlimited Save Me & Level Up',
        'description': 'Get unlimited recovery advice and game-leveling tips whenever you need them',
      },
      {
        'icon': Icons.block,
        'title': 'No Ads',
        'description': 'Enjoy a completely ad-free experience',
      },
      {
        'icon': Icons.support,
        'title': 'Support Development',
        'description': 'Help us keep improving the app',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'What You Get:',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...features.map((feature) => _buildFeatureItem(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          primaryColor,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for shimmer effect
class ShimmerPainter extends CustomPainter {
  final double animation;
  final Color color;

  ShimmerPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          color.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: [
          animation - 0.3,
          animation,
          animation + 0.3,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) => true;
}

