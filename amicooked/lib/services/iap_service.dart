import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simplified IAP Service - rebuilt from scratch
class IAPService extends ChangeNotifier {
  // Singleton pattern
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  // IAP instance
  final InAppPurchase _iap = InAppPurchase.instance;
  
  // Product ID - keep the same as before
  static const String premiumProductId = 'premium_unlimited';
  
  // State
  bool _isPremium = false;
  bool _isAvailable = false;
  bool _isInitialized = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  // Getters
  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  List<ProductDetails> get products => _products;
  
  // SharedPreferences key
  static const String _premiumKey = 'premium_status';

  /// Initialize the IAP service
  Future<void> initialize() async {
    print('🛒 [IAP] Initializing...');
    
    try {
      // Check if IAP is available
      _isAvailable = await _iap.isAvailable();
      print('🛒 [IAP] Available: $_isAvailable');
      
      // Load saved premium status
      await _loadPremiumStatus();
      
      if (_isAvailable) {
        // Set up purchase listener
        _purchaseSubscription = _iap.purchaseStream.listen(
          _handlePurchaseUpdate,
          onDone: () => print('🛒 [IAP] Purchase stream closed'),
          onError: (error) => print('❌ [IAP] Purchase stream error: $error'),
        );
        
        // Load products
        await loadProducts();
        
        // Restore previous purchases
        await restorePurchases();
      }
      
      _isInitialized = true;
      print('✅ [IAP] Initialization complete. Premium: $_isPremium');
    } catch (e) {
      print('❌ [IAP] Initialization error: $e');
      _isInitialized = true; // Mark as initialized even on error
    }
  }

  /// Load products from store
  Future<void> loadProducts() async {
    if (!_isAvailable) {
      print('⚠️ [IAP] Cannot load products - store not available');
      return;
    }

    try {
      print('🛒 [IAP] Loading products...');
      final response = await _iap.queryProductDetails({premiumProductId});
      
      if (response.error != null) {
        print('❌ [IAP] Error loading products: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      print('✅ [IAP] Loaded ${_products.length} product(s)');
      
      for (var product in _products) {
        print('   📦 ${product.id}: ${product.title} - ${product.price}');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ [IAP] Exception loading products: $e');
    }
  }

  /// Purchase premium
  Future<bool> purchasePremium() async {
    print('🛒 [IAP] purchasePremium() called');
    
    if (!_isAvailable) {
      print('❌ [IAP] Store not available');
      throw Exception('Store is not available');
    }
    
    if (_isPremium) {
      print('ℹ️ [IAP] Already premium');
      return true;
    }
    
    if (_products.isEmpty) {
      print('⚠️ [IAP] No products loaded, reloading...');
      await loadProducts();
      
      if (_products.isEmpty) {
        print('❌ [IAP] No products available');
        throw Exception('Product not available');
      }
    }
    
    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => throw Exception('Product not found'),
    );
    
    print('🛒 [IAP] Initiating purchase for: ${product.id}');
    
    final purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      print('🛒 [IAP] Purchase initiated: $result');
      return result;
    } catch (e) {
      print('❌ [IAP] Purchase error: $e');
      rethrow;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      print('⚠️ [IAP] Cannot restore - store not available');
      return;
    }
    
    print('🔄 [IAP] Restoring purchases...');
    
    try {
      await _iap.restorePurchases();
      print('✅ [IAP] Restore complete');
    } catch (e) {
      print('❌ [IAP] Restore error: $e');
    }
  }

  /// Handle purchase updates from the stream
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    print('📦 [IAP] Purchase update: ${purchaseDetailsList.length} item(s)');
    
    for (final purchase in purchaseDetailsList) {
      print('   - ${purchase.productID}: ${purchase.status}');
      
      if (purchase.status == PurchaseStatus.pending) {
        print('⏳ [IAP] Purchase pending...');
      } else if (purchase.status == PurchaseStatus.error) {
        print('❌ [IAP] Purchase error: ${purchase.error}');
      } else if (purchase.status == PurchaseStatus.purchased ||
                 purchase.status == PurchaseStatus.restored) {
        print('✅ [IAP] Purchase success!');
        
        // Verify and deliver
        if (await _verifyPurchase(purchase)) {
          await _deliverProduct(purchase);
        }
      }
      
      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        print('✓ [IAP] Completing purchase...');
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase (simplified - in production use server verification)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // In production, verify with your backend
    print('✓ [IAP] Verifying purchase (simplified)...');
    return true;
  }

  /// Deliver the product to user
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    if (purchase.productID == premiumProductId) {
      await _setPremiumStatus(true);
      print('🎉 [IAP] Premium unlocked!');
    }
  }

  /// Load premium status from local storage
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      print('📱 [IAP] Loaded premium status: $_isPremium');
      notifyListeners();
    } catch (e) {
      print('❌ [IAP] Failed to load premium status: $e');
    }
  }

  /// Save premium status to local storage
  Future<void> _setPremiumStatus(bool value) async {
    _isPremium = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, value);
      print('💾 [IAP] Saved premium status: $value');
    } catch (e) {
      print('❌ [IAP] Failed to save premium status: $e');
    }
  }

  /// Test method to manually set premium (for debugging only)
  Future<void> enableTestPremium() async {
    print('🧪 [IAP] Test premium enabled');
    await _setPremiumStatus(true);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

