import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iap_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  bool _isPurchasing = false;
  
  // Animations
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final List<Particle> _particles = [];
  
  // Beautiful unified color scheme (coral-pink meets purple)
  static const Color shopPink = Color(0xFFFF6B9D);
  static const Color shopPurple = Color(0xFFC06BFF);
  static const Color shopOrange = Color(0xFFFFA06B);
  static const Color shopDeep = Color(0xFF8B5FBF);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
  }

  void _initAnimations() {
    // Background glow animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Particle floating animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Pulse animation for premium card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1.5,
        speed: random.nextDouble() * 0.3 + 0.15,
        opacity: random.nextDouble() * 0.4 + 0.1,
        colorIndex: i % 4,
      ));
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showPurchaseDialog() async {
    if (_isPurchasing) return;
    
    setState(() => _isPurchasing = true);
    
    try {
      final iapService = context.read<IAPService>();
      print('🛒 Starting purchase flow...');
      
      await iapService.purchasePremium();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Processing your premium purchase...'),
            backgroundColor: shopPurple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Purchase error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _restorePurchases() async {
    try {
      final iapService = context.read<IAPService>();
      print('🔄 Restoring purchases...');
      await iapService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Restore error: $e');
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
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Consumer<IAPService>(
        builder: (context, iapService, _) {
          return Stack(
            children: [
              // Animated background
              _buildAnimatedBackground(),
              
              // Floating particles
              _buildFloatingParticles(),
              
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    _buildAppBar(),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            
                            // Store warning if needed
                            if (!iapService.isAvailable) _buildStoreWarning(),
                            
                            // Main premium card
                            if (iapService.isPremium)
                              _buildActivePremiumCard()
                            else
                              _buildPremiumOfferCard(iapService),
                            
                            const SizedBox(height: 40),
                            
                            // Benefits section
                            _buildBenefitsSection(),
                            
                            const SizedBox(height: 32),
                            
                            // Restore button
                            if (!iapService.isPremium) _buildRestoreButton(),
                            
                            // Debug button
                            if (kDebugMode && !iapService.isPremium)
                              _buildDebugButton(iapService),
                            
                            const SizedBox(height: 24),
                            
                            // Footer
                            _buildFooter(),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.8,
              colors: [
                shopPink.withOpacity(0.1 * _backgroundController.value),
                shopPurple.withOpacity(0.08 * _backgroundController.value),
                shopDeep.withOpacity(0.05 * _backgroundController.value),
                AppTheme.primaryBlack,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [shopPink, shopPurple, shopOrange],
              ).createShader(bounds),
              child: const Text(
                '✨ Premium Shop',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStoreWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Store unavailable. Test on a real device.',
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePremiumCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [shopPink, shopPurple],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shopPink.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium Active!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have unlimited access',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumOfferCard(IAPService iapService) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: shopPink.withOpacity(0.4 * _pulseAnimation.value),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: shopPurple.withOpacity(0.3 * _pulseAnimation.value),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  shopPink.withOpacity(0.2),
                  shopPurple.withOpacity(0.15),
                  shopDeep.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: shopPink.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Premium icon with glow
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [shopPink, shopPurple],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: shopPink.withOpacity(0.8),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [shopPink, shopPurple, shopOrange],
                  ).createShader(bounds),
                  child: const Text(
                    'Premium Unlimited',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Text(
                  iapService.products.isNotEmpty
                      ? iapService.products.first.price
                      : '\$3.99',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'One-time payment • Lifetime access',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Purchase button
                _buildPurchaseButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isPurchasing ? null : () {
          print('🛒 [BUTTON] Tapped!');
          _showPurchaseDialog();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [shopPink, shopPurple, shopOrange],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shopPink.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: _isPurchasing
                ? const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Unlock Premium',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [shopPink, shopPurple],
          ).createShader(bounds),
          child: const Text(
            'Premium Benefits',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildBenefit(
          Icons.all_inclusive_rounded,
          'Unlimited Everything',
          'Use Save Me & Level Up features without limits',
          shopPink,
        ),
        
        _buildBenefit(
          Icons.block_rounded,
          'Zero Ads',
          'Enjoy completely ad-free experience',
          shopPurple,
        ),
        
        _buildBenefit(
          Icons.favorite_rounded,
          'Support Development',
          'Help us build amazing new features',
          shopOrange,
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description, Color color) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3 + _backgroundController.value * 0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
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

  Widget _buildRestoreButton() {
    return TextButton.icon(
      onPressed: _restorePurchases,
      icon: const Icon(Icons.restore_rounded, color: shopPurple),
      label: const Text(
        'Restore Purchases',
        style: TextStyle(
          color: shopPurple,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDebugButton(IAPService iapService) {
    return TextButton(
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
        'Enable Test Premium (Debug Only)',
        style: TextStyle(color: Colors.purple, fontSize: 12),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlack,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: AppTheme.textSecondary, size: 16),
              SizedBox(width: 8),
              Text(
                'Secure checkout • Cancel anytime',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'One-time purchase. No subscriptions.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Particle class for animations
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final int colorIndex;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.colorIndex,
  });
}

// Custom painter for floating particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  static const colors = [
    Color(0xFFFF6B9D), // shopPink
    Color(0xFFC06BFF), // shopPurple
    Color(0xFFFFA06B), // shopOrange
    Color(0xFF8B5FBF), // shopDeep
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final color = colors[particle.colorIndex];
      
      // Calculate position with floating animation
      final y = ((particle.y + progress * particle.speed) % 1.0) * size.height;
      final x = particle.x * size.width +
          math.sin(progress * 2 * math.pi + particle.x * 8) * 30;
      
      // Draw particle with glow
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(Offset(x, y), particle.size, paint);
      
      // Inner glow
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(Offset(x, y), particle.size * 0.4, innerPaint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

