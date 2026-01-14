import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user profile by phone document ID
  Future<DocumentSnapshot?> getUserProfile(String phoneDocId) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneDocId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    required String phoneDocId,
    required String firstName,
    required String lastName,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update user role (buyer/seller)
  Future<void> updateUserRole({
    required String phoneDocId,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'role': role,
      });
    } catch (e) {
      print('Error updating role: $e');
      rethrow;
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
  Stream<DocumentSnapshot> getUserProfileStream(String phoneDocId) {
    return _firestore.collection('users').doc(phoneDocId).snapshots();
  }

  /// Generate unique client ID (e.g. user_123456)
  Future<String> generateUniqueClientId(String first, String phone) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final id =
        'user_${first.substring(0, 2)}_${timestamp.substring(timestamp.length - 4)}';
    return id;
  }

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String uniqueId,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String county,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uniqueId': uniqueId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'city': city,
      'country': county,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
