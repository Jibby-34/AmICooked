import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Rizz Mode state
class RizzModeService extends ChangeNotifier {
  static final RizzModeService _instance = RizzModeService._internal();
  factory RizzModeService() => _instance;
  RizzModeService._internal();

  bool _isRizzMode = false;
  static const String _rizzModeKey = 'rizz_mode';

  bool get isRizzMode => _isRizzMode;

  /// Load the saved rizz mode state from SharedPreferences
  Future<void> loadRizzMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isRizzMode = prefs.getBool(_rizzModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Failed to load rizz mode: $e');
    }
  }

  /// Toggle the rizz mode state and save it
  Future<void> toggleRizzMode() async {
    _isRizzMode = !_isRizzMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rizzModeKey, _isRizzMode);
    } catch (e) {
      print('Failed to save rizz mode: $e');
    }
  }

  /// Set the rizz mode state and save it
  Future<void> setRizzMode(bool value) async {
    if (_isRizzMode == value) return;
    
    _isRizzMode = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rizzModeKey, _isRizzMode);
    } catch (e) {
      print('Failed to save rizz mode: $e');
    }
  }
}

