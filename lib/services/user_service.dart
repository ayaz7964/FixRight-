import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user profile by phone number
  Future<DocumentSnapshot?> getUserProfile(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get user by phone number
  Future<DocumentSnapshot?> getUserByPhone(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// Create new user profile (called after OTP verification)
  Future<void> createUser({
    required String phoneNumber,
    required String uid,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).set({
        'uid': uid,
        'phone': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'country': country,
        'address': address,
        'role': 'buyer',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false));

      print('User profile created: $phoneNumber');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'city': city,
        'country': country,
      });

      print('User profile updated: $phoneNumber');
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      print('Last login updated: $phoneNumber');
    } catch (e) {
      print('Error updating last login: $e');
      rethrow;
    }
  }

  /// Update user role (buyer/seller)
  Future<void> updateUserRole({
    required String phoneNumber,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'role': role,
      });

      print('User role updated: $phoneNumber → $role');
    } catch (e) {
      print('Error updating role: $e');
      rethrow;
    }
  }

  /// Search users by first name
  Future<List<DocumentSnapshot>> searchUsers(String query) async {
    try {
      final results = await _firestore
          .collection('users')
          .where(
            'firstName',
            isGreaterThanOrEqualTo: query,
            isLessThan: '${query}z',
          )
          .limit(10)
          .get();
      return results.docs;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get all users with a specific role
  Future<List<DocumentSnapshot>> getUsersByRole(String role) async {
    try {
      final results = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .limit(50)
          .get();
      return results.docs;
    } catch (e) {
      print('Error fetching users by role: $e');
      return [];
    }
  }

  /// Stream of user profile updates
  Stream<DocumentSnapshot> getUserProfileStream(String phoneNumber) {
    return _firestore.collection('users').doc(phoneNumber).snapshots();
  }
}
