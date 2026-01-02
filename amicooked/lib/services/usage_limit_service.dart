import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage usage limits for Save Me / Level Up features
/// Each mode (Cooked/Rizz) has its own separate usage limit
class UsageLimitService extends ChangeNotifier {
  static final UsageLimitService _instance = UsageLimitService._internal();
  factory UsageLimitService() => _instance;
  UsageLimitService._internal();

  // Separate tracking for Save Me (cooked mode) and Level Up (rizz mode)
  static const String _lastCookedUseDateKey = 'last_save_me_use_date';
  static const String _hasUsedCookedTodayKey = 'has_used_save_me_today';
  static const String _lastRizzUseDateKey = 'last_level_up_use_date';
  static const String _hasUsedRizzTodayKey = 'has_used_level_up_today';
  
  DateTime? _lastCookedUseDate;
  bool _hasUsedCookedToday = false;
  DateTime? _lastRizzUseDate;
  bool _hasUsedRizzToday = false;

  // Getters for specific modes
  bool hasUsedCookedToday() => _hasUsedCookedToday;
  bool hasUsedRizzToday() => _hasUsedRizzToday;
  bool canUseCookedToday() => !_hasUsedCookedToday;
  bool canUseRizzToday() => !_hasUsedRizzToday;
  DateTime? get lastCookedUseDate => _lastCookedUseDate;
  DateTime? get lastRizzUseDate => _lastRizzUseDate;

  /// Initialize the service and load saved data
  Future<void> initialize() async {
    print('⏰ Initializing Usage Limit Service...');
    await _loadUsageData();
    _checkAndResetDaily();
  }

  /// Load usage data from SharedPreferences
  Future<void> _loadUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cooked mode data
      final lastCookedDateString = prefs.getString(_lastCookedUseDateKey);
      if (lastCookedDateString != null) {
        _lastCookedUseDate = DateTime.parse(lastCookedDateString);
      }
      _hasUsedCookedToday = prefs.getBool(_hasUsedCookedTodayKey) ?? false;
      
      // Load rizz mode data
      final lastRizzDateString = prefs.getString(_lastRizzUseDateKey);
      if (lastRizzDateString != null) {
        _lastRizzUseDate = DateTime.parse(lastRizzDateString);
      }
      _hasUsedRizzToday = prefs.getBool(_hasUsedRizzTodayKey) ?? false;
      
      print('📱 Loaded usage data:');
      print('   Save Me - Last use: $_lastCookedUseDate, Used: $_hasUsedCookedToday');
      print('   Level Up - Last use: $_lastRizzUseDate, Used: $_hasUsedRizzToday');
      
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load usage data: $e');
    }
  }

  /// Check if 24 hours have passed and reset the daily limit
  void _checkAndResetDaily() {
    // Cooked mode check
    if (_lastCookedUseDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastCookedUseDate!);
      
      // Check if 24 hours (86400 seconds) have passed
      if (difference.inSeconds >= 86400) {
        print('✅ 24 hours passed for Save Me - resetting');
        _resetCookedLimit();
      }
    }
    
    // Rizz mode check
    if (_lastRizzUseDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastRizzUseDate!);
      
      // Check if 24 hours (86400 seconds) have passed
      if (difference.inSeconds >= 86400) {
        print('✅ 24 hours passed for Level Up - resetting');
        _resetRizzLimit();
      }
    }
  }

  /// Reset the cooked mode usage limit
  Future<void> _resetCookedLimit() async {
    _hasUsedCookedToday = false;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasUsedCookedTodayKey, false);
      print('💾 Reset Save Me limit');
    } catch (e) {
      print('❌ Failed to reset Save Me limit: $e');
    }
  }

  /// Reset the rizz mode usage limit
  Future<void> _resetRizzLimit() async {
    _hasUsedRizzToday = false;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasUsedRizzTodayKey, false);
      print('💾 Reset Level Up limit');
    } catch (e) {
      print('❌ Failed to reset Level Up limit: $e');
    }
  }

  /// Record that the user has used their free daily use
  Future<void> recordUsage(bool isRizzMode) async {
    final now = DateTime.now();
    
    if (isRizzMode) {
      _lastRizzUseDate = now;
      _hasUsedRizzToday = true;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastRizzUseDateKey, now.toIso8601String());
        await prefs.setBool(_hasUsedRizzTodayKey, true);
        print('💾 Recorded Level Up usage at $now');
      } catch (e) {
        print('❌ Failed to record Level Up usage: $e');
      }
    } else {
      _lastCookedUseDate = now;
      _hasUsedCookedToday = true;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastCookedUseDateKey, now.toIso8601String());
        await prefs.setBool(_hasUsedCookedTodayKey, true);
        print('💾 Recorded Save Me usage at $now');
      } catch (e) {
        print('❌ Failed to record Save Me usage: $e');
      }
    }
    
    notifyListeners();
  }

  /// Get the time remaining until the next free use (in seconds)
  int getSecondsUntilNextUse(bool isRizzMode) {
    final lastUseDate = isRizzMode ? _lastRizzUseDate : _lastCookedUseDate;
    final hasUsed = isRizzMode ? _hasUsedRizzToday : _hasUsedCookedToday;
    
    if (lastUseDate == null || !hasUsed) {
      return 0;
    }

    final now = DateTime.now();
    final difference = now.difference(lastUseDate);
    final secondsRemaining = 86400 - difference.inSeconds; // 24 hours = 86400 seconds
    
    return secondsRemaining > 0 ? secondsRemaining : 0;
  }

  /// Get the time remaining until the next free use (in hours)
  int getHoursUntilNextUse(bool isRizzMode) {
    final seconds = getSecondsUntilNextUse(isRizzMode);
    return (seconds / 3600).ceil();
  }

  /// Get a formatted string for time remaining
  String getTimeRemainingString(bool isRizzMode) {
    final seconds = getSecondsUntilNextUse(isRizzMode);
    
    if (seconds == 0) {
      return 'Available now!';
    }
    
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'less than 1m';
    }
  }

  /// Check if the user can use the feature (for non-premium users)
  bool canUseFeature(bool isPremium, bool isRizzMode) {
    if (isPremium) {
      return true; // Premium users have unlimited access
    }
    
    // Check if 24 hours have passed since last use
    _checkAndResetDaily();
    
    return isRizzMode ? canUseRizzToday() : canUseCookedToday();
  }

  /// For testing purposes - manually reset the usage
  Future<void> resetForTesting() async {
    await _resetCookedLimit();
    await _resetRizzLimit();
    _lastCookedUseDate = null;
    _lastRizzUseDate = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastCookedUseDateKey);
      await prefs.remove(_lastRizzUseDateKey);
      print('🧪 Reset all usage for testing');
    } catch (e) {
      print('❌ Failed to reset for testing: $e');
    }
  }
}

