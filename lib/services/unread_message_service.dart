import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage unread message counts and read receipts
/// Provides real-time streams for both total and per-conversation unread status
class UnreadMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time stream of total unread message count across all conversations
  /// Updates immediately when messages are marked as read
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
            if (unreadCounts != null &&
                unreadCounts.containsKey(currentUserId)) {
              totalUnread +=
                  (unreadCounts[currentUserId] as num?)?.toInt() ?? 0;
            }
          }
          return totalUnread;
        });
  }

  /// Get real-time stream of unread count for a specific conversation
  /// Useful for showing unread badge in chat list that updates in real-time
  Stream<int> getConversationUnreadCountStream(String conversationId) {
    final currentUserId = _auth.currentUser?.phoneNumber;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final data = doc.data() as Map<String, dynamic>;
          final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
          return (unreadCounts?[currentUserId] as num?)?.toInt() ?? 0;
        });
  }

  /// Get unread count for a specific conversation (one-time fetch)
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

  /// Check if current user has unread messages in a conversation
  /// True if unreadCount > 0
  Stream<bool> hasUnreadMessages(String conversationId) {
    return getConversationUnreadCountStream(
      conversationId,
    ).map((count) => count > 0);
  }

  /// Get the last read timestamp for a specific conversation
  /// Returns null if never read
  Future<Timestamp?> getLastReadTimestamp(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.phoneNumber;
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final lastReadAt = data['lastReadAt'] as Map<String, dynamic>?;

      if (lastReadAt != null && lastReadAt.containsKey(currentUserId)) {
        return lastReadAt[currentUserId] as Timestamp?;
      }
      return null;
    } catch (e) {
      print('Error getting last read timestamp: $e');
      return null;
    }
  }

  /// Mark all messages in a conversation as read (legacy method)
  /// Note: Use ChatService.markMessagesAsRead() instead for full functionality
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.phoneNumber;
      if (currentUserId == null) return;

      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$currentUserId': 0,
        'lastReadAt.$currentUserId': Timestamp.now(),
      });
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }
}
