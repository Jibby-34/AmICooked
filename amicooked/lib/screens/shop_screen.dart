import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iap_service.dart';
import '../services/rizz_mode_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  bool _isPurchasing = false;
  
  // Animation controllers
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _emberController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  final List<ShopEmber> _embers = [];

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Set up ember animation (floating particles)
    _emberController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Initialize embers with unified color palette
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _embers.add(ShopEmber(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 0.4 + 0.2,
        opacity: random.nextDouble() * 0.3 + 0.1,
        colorIndex: i % 4, // More color variations
      ));
    }
    
    // Shimmer animation for premium box
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    
    // Listen for IAP changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iapService = Provider.of<IAPService>(context, listen: false);
      iapService.addListener(_onIAPChanged);
    });
  }

  @override
  void dispose() {
    final iapService = Provider.of<IAPService>(context, listen: false);
    iapService.removeListener(_onIAPChanged);
    _glowController.dispose();
    _emberController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onIAPChanged() {
    if (!mounted) return;
    
    final iapService = Provider.of<IAPService>(context, listen: false);
    
    if (iapService.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Premium unlocked! Thank you!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handlePurchase(IAPService iapService) async {
    if (_isPurchasing) return;
    
    setState(() => _isPurchasing = true);
    
    try {
      print('🛒 [SHOP] Purchase button pressed');
      await iapService.purchasePremium();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛒 Processing purchase...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [SHOP] Purchase failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _handleRestore(IAPService iapService) async {
    try {
      await iapService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Restore complete'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unified color palette that blends orange and purple aesthetics
    const primaryColor = Color(0xFFFF6B9D); // Coral pink - between orange and purple
    const accentColor = Color(0xFFC06BFF); // Vibrant purple-pink
    const highlightColor = Color(0xFFFFA06B); // Warm orange-pink
    const deepColor = Color(0xFF8B5FBF); // Deep purple
    
    return Consumer2<RizzModeService, IAPService>(
      builder: (context, rizzModeService, iapService, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Animated gradient background
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          primaryColor.withOpacity(0.08 * _glowAnimation.value),
                          accentColor.withOpacity(0.06 * _glowAnimation.value),
                          deepColor.withOpacity(0.04 * _glowAnimation.value),
                          AppTheme.primaryBlack,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // Floating embers
              AnimatedBuilder(
                animation: _emberController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ShopEmberPainter(
                      embers: _embers,
                      animation: _emberController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      primaryColor,
                                      accentColor,
                                      highlightColor,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    '✨ Premium Shop',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),
                    
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            
                            // Store not available warning
                            if (!iapService.isAvailable)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange, width: 2),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Store unavailable. Please test on a real device.',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (!iapService.isAvailable)
                              const SizedBox(height: 24),
                            
                            // Premium badge if already purchased
                            if (iapService.isPremium)
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.8),
                                          accentColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(_glowAnimation.value * 0.4),
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
                                          'Premium Active!',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            
                            if (iapService.isPremium)
                              const SizedBox(height: 32),
                            
                            // Premium offer card with shimmer effect
                            if (!iapService.isPremium)
                              AnimatedBuilder(
                                animation: Listenable.merge([_glowAnimation, _shimmerAnimation]),
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(_glowAnimation.value * 0.3),
                                          blurRadius: 25,
                                          spreadRadius: 3,
                                        ),
                                        BoxShadow(
                                          color: accentColor.withOpacity(_glowAnimation.value * 0.2),
                                          blurRadius: 35,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Stack(
                                        children: [
                                          // Background gradient
                                          Container(
                                            padding: const EdgeInsets.all(28),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  primaryColor.withOpacity(0.15),
                                                  accentColor.withOpacity(0.12),
                                                  deepColor.withOpacity(0.1),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: primaryColor.withOpacity(0.3),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: Column(
                                              children: [
                                                // Animated icon with pulsing glow
                                                Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [primaryColor, accentColor],
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: primaryColor.withOpacity(_glowAnimation.value * 0.6),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.stars,
                                                    size: 48,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
                                                        blurRadius: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 24),
                                                
                                                // Title with gradient
                                                ShaderMask(
                                                  shaderCallback: (bounds) => LinearGradient(
                                                    colors: [
                                                      primaryColor,
                                                      accentColor,
                                                      highlightColor,
                                                    ],
                                                  ).createShader(bounds),
                                                  child: Text(
                                                    'Premium Unlimited',
                                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 20),
                                                
                                                // Price with glow
                                                Text(
                                                  iapService.products.isNotEmpty
                                                      ? iapService.products.first.price
                                                      : '\$3.99',
                                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        color: primaryColor.withOpacity(_glowAnimation.value * 0.5),
                                                        blurRadius: 15,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 8),
                                                
                                                Text(
                                                  'One-time payment',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 28),
                                                
                                                // Purchase button
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: _isPurchasing ? null : () => _handlePurchase(iapService),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor: Colors.transparent,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                    child: Ink(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            primaryColor,
                                                            accentColor,
                                                            highlightColor,
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                                        alignment: Alignment.center,
                                                        child: _isPurchasing
                                                            ? const SizedBox(
                                                                height: 24,
                                                                width: 24,
                                                                child: CircularProgressIndicator(
                                                                  color: Colors.white,
                                                                  strokeWidth: 3,
                                                                ),
                                                              )
                                                            : Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                                                                  const SizedBox(width: 12),
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
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Shimmer overlay effect
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: CustomPaint(
                                                painter: ShimmerPainter(
                                                  animation: _shimmerAnimation.value,
                                                  primaryColor: primaryColor,
                                                  secondaryColor: accentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            
                            const SizedBox(height: 40),
                            
                            // Features
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [primaryColor, accentColor],
                              ).createShader(bounds),
                              child: Text(
                                'What You Get:',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildFeature(
                              Icons.all_inclusive,
                              'Unlimited Save Me & Level Up',
                              'Use recovery advice and game tips unlimited times',
                              primaryColor,
                              accentColor,
                            ),
                            
                            _buildFeature(
                              Icons.block,
                              'No Ads',
                              'Enjoy a completely ad-free experience',
                              accentColor,
                              highlightColor,
                            ),
                            
                            _buildFeature(
                              Icons.support,
                              'Support Development',
                              'Help us improve the app',
                              highlightColor,
                              primaryColor,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Restore button
                            if (!iapService.isPremium)
                              TextButton(
                                onPressed: () => _handleRestore(iapService),
                                child: Text(
                                  'Restore Purchases',
                                  style: TextStyle(
                                    color: primaryColor.withOpacity(0.7),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            
                            // Test button (for debugging)
                            if (kDebugMode && !iapService.isPremium)
                              TextButton(
                                onPressed: () async {
                                  await iapService.enableTestPremium();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🧪 Test premium enabled'),
                                        backgroundColor: Colors.purple,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Enable Test Premium (Debug)',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 16),
                            
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeature(IconData icon, String title, String description, Color color1, Color color2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color1.withOpacity(0.08),
                  color2.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color1.withOpacity(0.2 + _glowAnimation.value * 0.1),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color1.withOpacity(_glowAnimation.value * 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Ember particle class for floating animation in shop
class ShopEmber {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final int colorIndex;

  ShopEmber({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.colorIndex,
  });
}

// Custom painter for floating embers with unified color scheme
class ShopEmberPainter extends CustomPainter {
  final List<ShopEmber> embers;
  final double animation;

  ShopEmberPainter({
    required this.embers,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Unified color palette
    const colors = [
      Color(0xFFFF6B9D), // Coral pink
      Color(0xFFC06BFF), // Vibrant purple-pink
      Color(0xFFFFA06B), // Warm orange-pink
      Color(0xFF8B5FBF), // Deep purple
    ];

    for (var ember in embers) {
      final emberColor = colors[ember.colorIndex % colors.length];
      
      final paint = Paint()
        ..color = emberColor.withOpacity(ember.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      // Calculate position with vertical movement and subtle horizontal sway
      final yPos = ((ember.y + animation * ember.speed) % 1.0) * size.height;
      final xPos = ember.x * size.width + 
                   math.sin(animation * 2 * math.pi + ember.x * 10) * 25;

      // Draw ember as a small circle with glow
      canvas.drawCircle(
        Offset(xPos, yPos),
        ember.size,
        paint,
      );
      
      // Add inner glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(ember.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(xPos, yPos),
        ember.size * 0.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ShopEmberPainter oldDelegate) => true;
}

// Custom painter for shimmer effect
class ShimmerPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  ShimmerPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          primaryColor.withOpacity(0.1),
          secondaryColor.withOpacity(0.15),
          Colors.white.withOpacity(0.3),
          secondaryColor.withOpacity(0.15),
          primaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.35, 0.5, 0.65, 0.8, 1.0],
        transform: GradientRotation(math.pi / 4),
      ).createShader(Rect.fromLTWH(
        size.width * animation - size.width,
        0,
        size.width * 2,
        size.height,
      ));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

