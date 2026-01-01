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

class _ShopScreenState extends State<ShopScreen> {
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    
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
    return Consumer2<RizzModeService, IAPService>(
      builder: (context, rizzModeService, iapService, child) {
        final isRizzMode = rizzModeService.isRizzMode;
        final primaryColor = isRizzMode ? AppTheme.rizzPurpleMid : AppTheme.flameOrange;
        
        return Scaffold(
          backgroundColor: AppTheme.primaryBlack,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '✨ Premium Shop',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                    ),
                  
                  if (iapService.isPremium)
                    const SizedBox(height: 32),
                  
                  // Premium offer card
                  if (!iapService.isPremium)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withOpacity(0.2),
                            AppTheme.secondaryBlack,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.stars,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Title
                          Text(
                            'Premium Unlimited',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Price
                          Text(
                            iapService.products.isNotEmpty
                                ? iapService.products.first.price
                                : '\$3.99',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.textPrimary,
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
                          
                          const SizedBox(height: 24),
                          
                          // Purchase button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isPurchasing ? null : () => _handlePurchase(iapService),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isPurchasing
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
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
                  
                  const SizedBox(height: 32),
                  
                  // Features
                  Text(
                    'What You Get:',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFeature(
                    Icons.all_inclusive,
                    'Unlimited Save Me & Level Up',
                    'Use recovery advice and game tips unlimited times',
                    primaryColor,
                  ),
                  
                  _buildFeature(
                    Icons.block,
                    'No Ads',
                    'Enjoy a completely ad-free experience',
                    primaryColor,
                  ),
                  
                  _buildFeature(
                    Icons.support,
                    'Support Development',
                    'Help us improve the app',
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
        );
      },
    );
  }

  Widget _buildFeature(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
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
  }
}

