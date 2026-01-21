import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../src/models/chat_conversation_model.dart';
import '../src/models/enhanced_message_model.dart';
import '../src/models/user_model.dart';
import 'translation_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TranslationService _translationService = TranslationService();

  /// Create or get a conversation between two users
  Future<ChatConversation> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required UserModel user1,
    required UserModel user2,
  }) async {
    try {
      // Create a deterministic conversation ID
      final conversationId = _getConversationId(userId1, userId2);

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (doc.exists) {
        return ChatConversation.fromDoc(doc);
      }

      // Create new conversation
      final conversation = ChatConversation(
        id: conversationId,
        participantIds: [userId1, userId2],
        participantNames: {userId1: user1.fullName, userId2: user2.fullName},
        participantProfileImages: {
          userId1: user1.profileImageUrl,
          userId2: user2.profileImageUrl,
        },
        participantRoles: {userId1: user1.role, userId2: user2.role},
        lastMessage: '',
        lastMessageAt: Timestamp.now(),
        unreadCounts: {userId1: 0, userId2: 0},
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toMap());

      return conversation;
    } catch (e) {
      print('Error getting/creating conversation: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<String> sendMessage({
    required String conversationId,
    required String text,
    required String userId,
    required String senderName,
    String? senderProfileImage,
    String? mediaUrl,
    String mediaType = 'text',
    String? sourceLanguage,
  }) async {
    try {
      final messageId = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc()
          .id;

      // Detect language if not provided
      final detectedLanguage =
          sourceLanguage ?? await _translationService.detectLanguage(text);

      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: userId,
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        originalText: text,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        originalLanguage: detectedLanguage,
        timestamp: Timestamp.now(),
        status: 'sent',
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update conversation's last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageSenderId': userId,
        'lastMessageAt': Timestamp.now(),
      });

      return messageId;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages for a conversation
  /// Automatically translates messages to all supported languages
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) async {
          final messages = snapshot.docs.map((doc) => MessageModel.fromDoc(doc)).toList();
          
          // Translate messages that don't have translations yet
          for (final message in messages) {
            if (message.translationsByLanguage == null || 
                message.translationsByLanguage!.isEmpty) {
              _translateMessageAsync(conversationId, message);
            }
          }
          
          return messages;
        })
        .asyncMap((future) async => await future);
  }

  /// Translate a message to all supported languages and save to Firestore
  Future<void> _translateMessageAsync(String conversationId, MessageModel message) async {
    try {
      if (message.mediaType != 'text') return; // Only translate text messages

      final targetLanguages = TranslationService.supportedLanguages.keys
          .where((lang) => lang != message.originalLanguage)
          .toList();

      if (targetLanguages.isEmpty) return;

      final translations = await _translationService.translateToMultiple(
        text: message.originalText,
        targetLanguages: targetLanguages,
        sourceLanguage: message.originalLanguage,
      );

      // Save translations to Firestore
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .update({'translationsByLanguage': translations});

      _log('Translated message ${message.id} to ${targetLanguages.length} languages');
    } catch (e) {
      _log('Error translating message: $e');
    }
  }

  /// Get conversations for current user
  /// Fetches conversations without composite index and sorts client-side
  Stream<List<ChatConversation>> getUserConversations() {
    // Use phone number as user ID (FixRight architecture)
    final currentUserId = _auth.currentUser?.phoneNumber;
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          try {
            final conversations = snapshot.docs
                .map((doc) {
                  try {
                    return ChatConversation.fromDoc(doc);
                  } catch (e) {
                    _log('Error parsing conversation ${doc.id}: $e');
                    // Return null for invalid conversations
                    return null;
                  }
                })
                .whereType<ChatConversation>() // Filter out nulls
                .toList();

            // Sort by lastMessageAt descending (most recent first)
            conversations.sort(
              (a, b) => b.lastMessageAt.compareTo(a.lastMessageAt),
            );

            return conversations;
          } catch (e) {
            _log('Error getting conversations: $e');
            rethrow;
          }
        });
  }

  /// Search conversations
  Future<List<ChatConversation>> searchConversations(String query) async {
    try {
      final currentUserId = _auth.currentUser?.phoneNumber;
      if (currentUserId == null) return [];

      // Get all conversations and filter locally (Firestore doesn't support complex text search easily)
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: currentUserId)
          .get();

      return snapshot.docs.map((doc) => ChatConversation.fromDoc(doc)).where((
        conv,
      ) {
        final otherName = conv.getOtherParticipantName(currentUserId);
        return otherName?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    } catch (e) {
      print('Error searching conversations: $e');
      return [];
    }
  }

  /// Mark message as seen
  Future<void> markMessageAsSeen(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'status': 'seen'});
    } catch (e) {
      print('Error marking message as seen: $e');
    }
  }

  /// Mark all messages as seen
  Future<void> markConversationAsSeen(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {
      print('Error marking conversation as seen: $e');
    }
  }

  /// Translate a message to target language
  Future<String> translateMessage({
    required String messageId,
    required String conversationId,
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final translated = await _translationService.translate(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );

      // Store translation in message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'translationsByLanguage.$targetLanguage': translated});

      return translated;
    } catch (e) {
      print('Error translating message: $e');
      return text;
    }
  }

  /// Edit message
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
            'originalText': newText,
            'isEdited': true,
            'editedAt': Timestamp.now(),
            'translationsByLanguage': {}, // Clear translations on edit
          });
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  /// Delete message
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'typingUsers': isTyping
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  /// Get typing indicator stream
  Stream<List<String>> getTypingIndicators(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((doc) => List<String>.from(doc['typingUsers'] ?? []));
  }

  /// Block user
  Future<void> blockUser({
    required String conversationId,
    required String blockUserId,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'blockedUsers': FieldValue.arrayUnion([blockUserId]),
      });
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  /// Unblock user
  Future<void> unblockUser({
    required String conversationId,
    required String unblockUserId,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'blockedUsers': FieldValue.arrayRemove([unblockUserId]),
      });
    } catch (e) {
      print('Error unblocking user: $e');
    }
  }

  /// Helper method to generate consistent conversation ID
  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get unread message count
  Future<int> getUnreadCount(String conversationId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return 0;

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final unreadCounts = doc['unreadCounts'] as Map<String, dynamic>?;
      return unreadCounts?[currentUserId] ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Increment unread count for other participants
  Future<void> incrementUnreadCount(
    String conversationId,
    String senderId,
  ) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final participants = List<String>.from(doc['participantIds'] ?? []);

      for (final participantId in participants) {
        if (participantId != senderId) {
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .update({'unreadCounts.$participantId': FieldValue.increment(1)});
        }
      }
    } catch (e) {
      print('Error incrementing unread count: $e');
    }
  }

  /// Fetch all unique skills from database
  Future<List<String>> fetchAllSkills() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final skillsSet = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['skills'] != null && data['skills'] is List) {
          skillsSet.addAll(List<String>.from(data['skills']));
        }
      }

      return skillsSet.toList()..sort();
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }

  /// Search users by name with details
  String _normalizePhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned;
  }

  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    if (query.isEmpty) return [];

    try {
      final currentUserId = _auth.currentUser?.uid;
      final queryTrim = query.trim();
      final queryLower = queryTrim.toLowerCase();

      final results = <Map<String, dynamic>>[];

      // 1) If query looks like a phone number or a document id, try direct doc lookup
      final phoneLike = RegExp(r'[0-9+]');
      if (phoneLike.hasMatch(queryTrim)) {
        try {
          final doc = await _firestore.collection('users').doc(queryTrim).get();
          if (doc.exists && doc.id != currentUserId) {
            results.add(_userMapFromDoc(doc));
            return results;
          }
        } catch (_) {
          // ignore and continue to other search methods
        }

        // Also try phoneNumber equality with normalization
        final normalized = _normalizePhone(queryTrim);
        final variants = <String>{queryTrim, normalized};
        if (normalized.startsWith('+')) {
          variants.add(normalized.replaceFirst('+', ''));
        } else {
          variants.add('+' + normalized);
        }

        for (final variant in variants) {
          final phoneSnap = await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: variant)
              .limit(5)
              .get();

          for (final doc in phoneSnap.docs) {
            if (doc.id != currentUserId) results.add(_userMapFromDoc(doc));
          }
          if (results.isNotEmpty) return results;
        }
      }

      // 2) Search by firstName or lastName using range queries (requires indexed fields)
      final firstNameSnap = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: queryLower)
          .where('firstName', isLessThan: '${queryLower}z')
          .limit(20)
          .get();

      for (final doc in firstNameSnap.docs) {
        if (doc.id != currentUserId) results.add(_userMapFromDoc(doc));
      }

      final lastNameSnap = await _firestore
          .collection('users')
          .where('lastName', isGreaterThanOrEqualTo: queryLower)
          .where('lastName', isLessThan: '${queryLower}z')
          .limit(20)
          .get();

      for (final doc in lastNameSnap.docs) {
        if (doc.id != currentUserId) results.add(_userMapFromDoc(doc));
      }

      // 3) If there are still no results, try a broader name contains search client-side
      if (results.isEmpty) {
        final snap = await _firestore.collection('users').limit(100).get();
        for (final doc in snap.docs) {
          if (doc.id == currentUserId) continue;
          final data = doc.data();
          final fullName =
              '${(data['firstName'] ?? '').toString()} ${(data['lastName'] ?? '').toString()}'
                  .toLowerCase();
          if (fullName.contains(queryLower)) {
            results.add(_userMapFromDoc(doc));
          }
        }
      }

      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Helper to create a standard user map from a DocumentSnapshot
  Map<String, dynamic> _userMapFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'userId': doc.id,
      'firstName': data['firstName'] ?? '',
      'lastName': data['lastName'] ?? '',
      'fullName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      'role': data['role'] ?? 'Unknown',
      'profileImageUrl': data['profileImageUrl'],
      'skills': List<String>.from(data['skills'] ?? []),
      'bio': data['bio'] ?? '',
      'rating': data['rating'] ?? 0.0,
      'totalReviews': data['totalReviews'] ?? 0,
      'city': data['city'] ?? 'Unknown City',
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'isOnline': data['isOnline'] ?? false,
    };
  }

  /// Create or retrieve a conversation id between current user and target user
  Future<String?> startConversationWithUser(String targetUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      final currentDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final targetDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .get();

      if (!currentDoc.exists || !targetDoc.exists) return null;

      final user1 = UserModel.fromDoc(currentDoc);
      final user2 = UserModel.fromDoc(targetDoc);

      final conv = await getOrCreateConversation(
        userId1: currentUserId,
        userId2: targetUserId,
        user1: user1,
        user2: user2,
      );

      return conv.id;
    } catch (e) {
      print('Error starting conversation: $e');
      return null;
    }
  }

  /// Get sellers near buyer based on location (radius in km)
  Future<List<Map<String, dynamic>>> getSellersNearby({
    required double buyerLatitude,
    required double buyerLongitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      // Fetch all sellers
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Seller')
          .get();

      final sellers = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          final data = doc.data();

          // Check if seller has location
          if (data['latitude'] != null && data['longitude'] != null) {
            final sellerLat = (data['latitude'] as num).toDouble();
            final sellerLng = (data['longitude'] as num).toDouble();

            // Calculate distance using Haversine formula
            final distance = _calculateDistance(
              buyerLatitude,
              buyerLongitude,
              sellerLat,
              sellerLng,
            );

            // Include only if within radius
            if (distance <= radiusKm) {
              sellers.add({
                'userId': doc.id,
                'firstName': data['firstName'] ?? '',
                'lastName': data['lastName'] ?? '',
                'fullName':
                    '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                        .trim(),
                'role': 'Seller',
                'profileImageUrl': data['profileImageUrl'],
                'skills': List<String>.from(data['skills'] ?? []),
                'bio': data['bio'] ?? '',
                'rating': data['rating'] ?? 0.0,
                'totalReviews': data['totalReviews'] ?? 0,
                'city': data['city'] ?? 'Unknown City',
                'distance': distance,
                'isOnline': data['isOnline'] ?? false,
              });
            }
          }
        }
      }

      // Sort by distance
      sellers.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );

      return sellers;
    } catch (e) {
      print('Error fetching nearby sellers: $e');
      return [];
    }
  }

  /// Get sellers by skill
  Future<List<Map<String, dynamic>>> getSellersBySkill(String skill) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Seller')
          .where('skills', arrayContains: skill)
          .get();

      final sellers = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          final data = doc.data();
          sellers.add({
            'userId': doc.id,
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'fullName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                .trim(),
            'role': 'Seller',
            'profileImageUrl': data['profileImageUrl'],
            'skills': List<String>.from(data['skills'] ?? []),
            'bio': data['bio'] ?? '',
            'rating': data['rating'] ?? 0.0,
            'totalReviews': data['totalReviews'] ?? 0,
            'city': data['city'] ?? 'Unknown City',
            'isOnline': data['isOnline'] ?? false,
          });
        }
      }

      return sellers;
    } catch (e) {
      print('Error fetching sellers by skill: $e');
      return [];
    }
  }

  /// Get sellers in same city
  Future<List<Map<String, dynamic>>> getSellersSameCity(String city) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Seller')
          .where('city', isEqualTo: city)
          .get();

      final sellers = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          final data = doc.data();
          sellers.add({
            'userId': doc.id,
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'fullName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                .trim(),
            'role': 'Seller',
            'profileImageUrl': data['profileImageUrl'],
            'skills': List<String>.from(data['skills'] ?? []),
            'bio': data['bio'] ?? '',
            'rating': data['rating'] ?? 0.0,
            'totalReviews': data['totalReviews'] ?? 0,
            'city': city,
            'isOnline': data['isOnline'] ?? false,
          });
        }
      }

      return sellers;
    } catch (e) {
      print('Error fetching sellers in same city: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0; // Earth's radius in km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  /// Migrate corrupted conversation data from arrays to maps
  /// This fixes conversations that were created with array format instead of maps
  Future<void> migrateCorruptedConversations() async {
    try {
      _log('Starting conversation data migration...');

      final snapshot = await _firestore.collection('conversations').get();
      int fixedCount = 0;

      for (final doc in snapshot.docs) {
        // Skip if doc ID is empty
        if (doc.id.isEmpty) {
          _log('Skipping conversation with empty ID');
          continue;
        }

        final data = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // Check and fix participantNames
        if (data['participantNames'] is List) {
          _log('Fixing participantNames in ${doc.id}');
          updates['participantNames'] = {};
          needsUpdate = true;
        }

        // Check and fix participantRoles
        if (data['participantRoles'] is List) {
          _log('Fixing participantRoles in ${doc.id}');
          updates['participantRoles'] = {};
          needsUpdate = true;
        }

        // Check and fix participantProfileImages
        if (data['participantProfileImages'] is List) {
          _log('Fixing participantProfileImages in ${doc.id}');
          updates['participantProfileImages'] = {};
          needsUpdate = true;
        }

        // Check and fix unreadCounts
        if (data['unreadCounts'] is List) {
          _log('Fixing unreadCounts in ${doc.id}');
          updates['unreadCounts'] = {};
          needsUpdate = true;
        }

        if (needsUpdate && doc.id.isNotEmpty) {
          await _firestore
              .collection('conversations')
              .doc(doc.id)
              .update(updates);
          fixedCount++;
        }
      }

      _log('Migration complete! Fixed $fixedCount conversations');
    } catch (e) {
      _log('Error during migration: $e');
    }
  }

  void _log(String message) {
    print('[ChatService] $message');
  }
}
