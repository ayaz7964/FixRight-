import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage user online/offline presence using a dedicated Firestore collection
/// This provides reliable presence tracking across app lifecycle
class UserPresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _presenceCollection = 'userPresence';

  /// Update user presence status
  /// Called when app resumes (online) or pauses (offline)
  Future<void> updatePresence(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final phoneUID = currentUser.phoneNumber;
      if (phoneUID == null || phoneUID.isEmpty) return;

      // Create or update presence document
      await _firestore.collection(_presenceCollection).doc(phoneUID).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      print(
        'Presence updated: ${isOnline ? "Online" : "Offline"} for $phoneUID',
      );
    } catch (e) {
      print('Error updating presence: $e');
      // Silently fail - don't crash app if presence update fails
    }
  }

  /// Get real-time stream of user presence
  /// Returns stream of presence data for a specific user
  Stream<Map<String, dynamic>?> getUserPresenceStream(String userId) {
    return _firestore
        .collection(_presenceCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return snapshot.data();
        });
  }

  /// Check if a user is currently online
  /// Returns true if isOnline field is true
  Stream<bool> isUserOnlineStream(String userId) {
    return getUserPresenceStream(userId).map((data) {
      return data?['isOnline'] as bool? ?? false;
    });
  }

  /// Get last seen timestamp for a user
  /// Useful for showing "Last seen at HH:MM"
  Stream<Timestamp?> getLastSeenStream(String userId) {
    return getUserPresenceStream(userId).map((data) {
      return data?['lastSeen'] as Timestamp?;
    });
  }

  /// Get formatted online/offline status for UI display
  /// Returns: "Online" or "Last seen at HH:MM"
  Stream<String> getUserStatusStream(String userId) {
    return _firestore
        .collection(_presenceCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return 'Offline';

          final data = snapshot.data() as Map<String, dynamic>;
          final isOnline = data['isOnline'] as bool? ?? false;

          if (isOnline) {
            return 'Online';
          }

          final lastSeen = data['lastSeen'] as Timestamp?;
          if (lastSeen == null) return 'Offline';

          // Format last seen time
          final now = DateTime.now();
          final lastSeenTime = lastSeen.toDate();
          final difference = now.difference(lastSeenTime);

          if (difference.inMinutes < 1) {
            return 'Just now';
          } else if (difference.inMinutes < 60) {
            return 'Last seen ${difference.inMinutes}m ago';
          } else if (difference.inHours < 24) {
            return 'Last seen ${difference.inHours}h ago';
          } else {
            // Format as date and time
            final formatter = _formatDateTime(lastSeenTime);
            return 'Last seen $formatter';
          }
        });
  }

  /// Helper to format datetime for display
  String _formatDateTime(DateTime dateTime) {
    final today = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'at ${_formatTime(dateTime)}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'yesterday at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format time as HH:MM (24-hour format)
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get presence data as a one-time fetch (not a stream)
  Future<Map<String, dynamic>?> getUserPresence(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .get();
      return snapshot.data();
    } catch (e) {
      print('Error fetching user presence: $e');
      return null;
    }
  }
}
