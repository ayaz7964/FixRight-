import 'package:flutter/material.dart';

/// Model to hold user data
class UserModel {
  final String uid;
  final String phone;
  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String address;
  final String role;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.address,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Create UserModel from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      phone: data['phone'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] ?? 'buyer',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Get full name
  String get fullName => '$firstName $lastName';
}

/// Service to manage user session (singleton)
/// Stores authenticated user's data globally throughout the app
class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();

  String? _phone;
  String? _uid;
  UserModel? _userData;
  bool _isAuthenticated = false;

  // Private constructor for singleton pattern
  UserSession._internal();

  // Factory constructor to return singleton instance
  factory UserSession() {
    return _instance;
  }

  // ════════════════════════════════════════════════════════════
  // GETTERS
  // ════════════════════════════════════════════════════════════

  /// Get current user's phone number
  String? get phone => _phone;

  /// Get current user's Firebase UID
  String? get uid => _uid;

  /// Get current user's full data model
  UserModel? get userData => _userData;

  /// Get current user's full name
  String get userName => _userData?.fullName ?? 'User';

  /// Get current user's role
  String get userRole => _userData?.role ?? 'buyer';

  /// Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Get user's full name (deprecated: use userName getter)
  String? get phoneUID => _phone;

  // ════════════════════════════════════════════════════════════
  // SETTERS
  // ════════════════════════════════════════════════════════════

  /// Set user session after successful login
  void setUserSession({
    required String phone,
    required String uid,
    required UserModel userData,
  }) {
    _phone = phone;
    _uid = uid;
    _userData = userData;
    _isAuthenticated = true;
    notifyListeners();
    print('✅ User session set: $phone (${userData.role})');
  }

  /// Update user data (called after profile updates)
  void updateUserData(UserModel newData) {
    _userData = newData;
    notifyListeners();
    print('✅ User data updated');
  }

  /// Set phone UID (backward compatibility with old code)
  void setPhoneUID(String phoneNumber) {
    _phone = phoneNumber;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Clear the session (logout)
  void clearSession() {
    _phone = null;
    _uid = null;
    _userData = null;
    _isAuthenticated = false;
    notifyListeners();
    print('✅ User session cleared (logged out)');
  }

  /// Reset singleton for testing purposes
  @visibleForTesting
  static void resetForTesting() {
    _instance._phone = null;
    _instance._uid = null;
    _instance._userData = null;
    _instance._isAuthenticated = false;
  }
}
