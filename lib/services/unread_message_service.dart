import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to get total unread message count for current user
class UnreadMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time stream of total unread message count
  Stream<int> getTotalUnreadCount() {
    final currentUserId = _auth.currentUser?.phoneNumber;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
        if (unreadCounts != null && unreadCounts.containsKey(currentUserId)) {
          totalUnread += (unreadCounts[currentUserId] as num?)?.toInt() ?? 0;
        }
      }
      return totalUnread;
    });
  }

  /// Get unread count for a specific conversation
  Future<int> getConversationUnreadCount(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.phoneNumber;
      if (currentUserId == null) return 0;

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return 0;

      final data = doc.data() as Map<String, dynamic>;
      final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
      
      return (unreadCounts?[currentUserId] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.phoneNumber;
      if (currentUserId == null) return;

      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }
}
