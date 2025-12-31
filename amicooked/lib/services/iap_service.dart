import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage In-App Purchases
class IAPService extends ChangeNotifier {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs - IMPORTANT: Replace these with your actual product IDs from App Store Connect and Google Play Console
  static const String premiumProductId = 'premium_unlimited';
  
  bool _isPremiumUser = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  bool get isPremiumUser => _isPremiumUser;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;
  
  static const String _premiumKey = 'is_premium_user';

  /// Initialize the IAP service
  Future<void> initialize() async {
    print('🛒 Initializing IAP Service...');
    
    // Check if IAP is available on this device
    _isAvailable = await _iap.isAvailable();
    print('🛒 IAP Available: $_isAvailable');
    
    if (!_isAvailable) {
      print('⚠️  IAP not available on this device');
      // Still load saved premium status for testing
      await _loadPremiumStatus();
      return;
    }

    // Load saved premium status
    await _loadPremiumStatus();

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('❌ Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
    
    // Restore purchases on startup
    await restorePurchases();
  }

  /// Load products from the store
  Future<void> loadProducts() async {
    if (!_isAvailable) {
      print('⚠️  Cannot load products - IAP not available');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🛒 Loading products...');
      const Set<String> productIds = {premiumProductId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        print('❌ Error loading products: ${response.error}');
        _products = [];
      } else {
        _products = response.productDetails;
        print('✅ Loaded ${_products.length} products');
        for (var product in _products) {
          print('   - ${product.id}: ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      print('❌ Exception loading products: $e');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase the premium product
  Future<void> purchasePremium() async {
    if (!_isAvailable) {
      print('⚠️  Cannot purchase - IAP not available');
      return;
    }

    if (_isPremiumUser) {
      print('ℹ️  User already has premium');
      return;
    }

    final ProductDetails? product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => throw Exception('Premium product not found'),
    );

    if (product == null) {
      print('❌ Premium product not available');
      return;
    }

    print('🛒 Initiating purchase for ${product.id}...');
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('❌ Purchase error: $e');
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      print('⚠️  Cannot restore - IAP not available');
      return;
    }

    print('🔄 Restoring purchases...');
    
    try {
      await _iap.restorePurchases();
      print('✅ Restore purchases completed');
    } catch (e) {
      print('❌ Restore purchases error: $e');
    }
  }

  /// Handle purchase updates from the stream
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    print('📦 Purchase update received: ${purchaseDetailsList.length} items');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('   - ${purchaseDetails.productID}: ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('⏳ Purchase pending...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('❌ Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        print('✅ Purchase successful/restored!');
        
        // Verify purchase (in production, you should verify with your backend)
        final bool valid = await _verifyPurchase(purchaseDetails);
        
        if (valid) {
          print('✅ Purchase verified');
          await _deliverProduct(purchaseDetails);
        } else {
          print('❌ Purchase verification failed');
        }
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        print('✓ Completing purchase...');
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Verify the purchase (simplified - in production, verify with your backend)
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a real app, you should verify the purchase with your backend server
    // For now, we'll just return true
    return true;
  }

  /// Deliver the product to the user
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == premiumProductId) {
      await _setPremiumStatus(true);
      print('🎉 Premium unlocked!');
    }
  }

  /// Load premium status from SharedPreferences
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumUser = prefs.getBool(_premiumKey) ?? false;
      print('📱 Loaded premium status: $_isPremiumUser');
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load premium status: $e');
    }
  }

  /// Save premium status to SharedPreferences
  Future<void> _setPremiumStatus(bool value) async {
    _isPremiumUser = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, value);
      print('💾 Saved premium status: $value');
    } catch (e) {
      print('❌ Failed to save premium status: $e');
    }
  }

  /// For testing purposes - manually set premium status
  Future<void> setTestPremiumStatus(bool value) async {
    await _setPremiumStatus(value);
  }

  /// Dispose of the service
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

