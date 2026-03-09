import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();

  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _pinHashKey = 'app_pin_hash';

  bool _isAppLockEnabled = true;
  bool _isAuthenticated = false;
  bool _isChecking = true;
  bool _isAuthenticating = false;
  bool _hasPinSet = false;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;
  bool get isAuthenticating => _isAuthenticating;
  bool get hasPinSet => _hasPinSet;

  AuthProvider() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAppLockEnabled = prefs.getBool(_lockEnabledKey) ?? true;
    _hasPinSet = prefs.getString(_pinHashKey) != null;

    if (!_isAppLockEnabled) {
      _isAuthenticated = true;
    }
    _isChecking = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Biometric authentication
  // ---------------------------------------------------------------------------

  Future<void> authenticate() async {
    if (!_isAppLockEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return;
    }

    _isAuthenticating = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Biometrics aren't natively supported on web via this package easily
        if (!_hasPinSet) {
          _isAuthenticated = true;
        }
        _isAuthenticating = false;
        notifyListeners();
        return;
      }

      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device has NO security configured — let them in if no app PIN set either
        if (!_hasPinSet) {
          _isAuthenticated = true;
          _isAuthenticating = false;
          notifyListeners();
          return;
        }
        // Otherwise require PIN entry
        _isAuthenticating = false;
        notifyListeners();
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to access CashWand',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      _isAuthenticated = didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Auth error: $e');
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // In-app PIN management
  // ---------------------------------------------------------------------------

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hashPin(pin));
    _hasPinSet = true;
    notifyListeners();
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    _hasPinSet = false;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);
    if (storedHash == null) return false;
    final match = _hashPin(pin) == storedHash;
    if (match) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return match;
  }

  // ---------------------------------------------------------------------------
  // Toggle & lifecycle
  // ---------------------------------------------------------------------------

  Future<void> toggleAppLock(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enable);
    _isAppLockEnabled = enable;
    if (!enable) {
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isAuthenticating) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isAppLockEnabled && _isAuthenticated) {
        _isAuthenticated = false;
        notifyListeners();
      }
    }
  }
}
