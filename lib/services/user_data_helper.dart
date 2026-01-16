import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_session.dart';

/// Utility helper class for accessing user data using phone UID
class UserDataHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  /// Get the current user's phone UID
  static String? getCurrentPhoneUID() {
    return UserSession().phoneUID;
  }

  /// Check if user is authenticated
  static bool isUserAuthenticated() {
    return UserSession().isAuthenticated;
  }

  /// Get user profile by phone UID
  static Future<Map<String, dynamic>?> getUserProfile(String phoneUID) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneUID).get();

      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get current logged-in user's profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final phoneUID = getCurrentPhoneUID();
    if (phoneUID == null) return null;
    return getUserProfile(phoneUID);
  }

  /// Stream current user profile changes (real-time)
  static Stream<Map<String, dynamic>?> streamCurrentUserProfile() {
    final phoneUID = getCurrentPhoneUID();
    if (phoneUID == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(phoneUID)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as Map<String, dynamic> : null);
  }

  /// Get specific user data field
  static Future<dynamic> getUserField(String phoneUID, String fieldName) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneUID).get();

      return doc.get(fieldName);
    } catch (e) {
      print('Error fetching user field: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(
    String phoneUID,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(phoneUID).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update current user profile
  static Future<void> updateCurrentUserProfile(
    Map<String, dynamic> updates,
  ) async {
    final phoneUID = getCurrentPhoneUID();
    if (phoneUID == null) {
      throw Exception('User not authenticated');
    }
    return updateUserProfile(phoneUID, updates);
  }

  /// Get user's first name
  static Future<String> getUserFirstName(String phoneUID) async {
    final profile = await getUserProfile(phoneUID);
    return profile?['firstName'] ?? 'User';
  }

  /// Get user's full name
  static Future<String> getUserFullName(String phoneUID) async {
    final profile = await getUserProfile(phoneUID);
    if (profile == null) return 'User';

    final firstName = profile['firstName'] ?? '';
    final lastName = profile['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Get user's location
  static Future<String> getUserLocation(String phoneUID) async {
    final profile = await getUserProfile(phoneUID);
    if (profile == null) return 'Unknown';

    final address = profile['address'];
    if (address != null && (address as String).isNotEmpty) {
      return address;
    }

    final city = profile['city'] ?? '';
    final country = profile['country'] ?? '';
    return '$city, $country'.replaceAll(RegExp(r',\s*$'), '').trim();
  }

  /// Get user's role
  static Future<String> getUserRole(String phoneUID) async {
    final profile = await getUserProfile(phoneUID);
    return profile?['Role'] ?? 'buyer';
  }

  /// Check if user is a seller
  static Future<bool> isUserSeller(String phoneUID) async {
    final role = await getUserRole(phoneUID);
    return role.toLowerCase() == 'seller';
  }

  /// Update user role
  static Future<void> updateUserRole(String phoneUID, String role) async {
    await updateUserProfile(phoneUID, {'Role': role});
  }

  /// Get user's live location
  static Future<Map<String, dynamic>?> getUserLiveLocation(
    String phoneUID,
  ) async {
    final profile = await getUserProfile(phoneUID);
    if (profile == null) return null;

    final liveLocation = profile['liveLocation'] as Map<String, dynamic>?;
    return liveLocation;
  }

  /// Update user's live location
  static Future<void> updateUserLiveLocation(
    String phoneUID,
    double latitude,
    double longitude,
  ) async {
    await updateUserProfile(phoneUID, {
      'liveLocation': {
        'lat': latitude,
        'lng': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  /// Get user's contact number
  static Future<String> getUserContactNumber(String phoneUID) async {
    final profile = await getUserProfile(phoneUID);
    return profile?['mobile'] ?? phoneUID;
  }

  /// Search users by name
  static Future<List<Map<String, dynamic>>> searchUsersByName(
    String query,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: query + 'z')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Logout current user (clears session)
  static void logout() {
    UserSession().clearSession();
  }
}
