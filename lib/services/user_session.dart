import 'package:flutter/material.dart';

/// Service to manage user session (phone number as UID)
/// This is a singleton that stores the authenticated user's UID globally
class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();

  String? _phoneUID;

  // Private constructor for singleton pattern
  UserSession._internal();

  // Factory constructor to return singleton instance
  factory UserSession() {
    return _instance;
  }

  /// Get the current user's phone UID
  String? get phoneUID => _phoneUID;

  /// Check if user is authenticated
  bool get isAuthenticated => _phoneUID != null;

  /// Store the phone UID after successful OTP verification
  void setPhoneUID(String phoneNumber) {
    _phoneUID = phoneNumber;
    notifyListeners();
  }

  /// Clear the session (logout)
  void clearSession() {
    _phoneUID = null;
    notifyListeners();
  }

  /// Reset singleton for testing purposes
  @visibleForTesting
  static void resetForTesting() {
    _instance._phoneUID = null;
  }
}
