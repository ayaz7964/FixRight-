import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantProfileImages;
  final Map<String, String> participantRoles;
  final String lastMessage;
  final String? lastMessageSenderId;
  final Timestamp lastMessageAt;
  final Map<String, int> unreadCounts; // userId -> unreadCount
  final Map<String, Timestamp>?
  lastReadAt; // userId -> timestamp when they read the chat
  final List<String> blockedUsers;

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantProfileImages,
    required this.participantRoles,
    required this.lastMessage,
    this.lastMessageSenderId,
    required this.lastMessageAt,
    required this.unreadCounts,
    this.lastReadAt,
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() => {
    'participantIds': participantIds,
    'participantNames': participantNames,
    'participantProfileImages': participantProfileImages,
    'participantRoles': participantRoles,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageAt': lastMessageAt,
    'unreadCounts': unreadCounts,
    'lastReadAt': lastReadAt,
    'blockedUsers': blockedUsers,
  };

  factory ChatConversation.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper to safely convert arrays to maps
    Map<String, String> _arrayToMap(dynamic value) {
      if (value is Map) {
        return Map<String, String>.from(value);
      } else if (value is List) {
        // Convert array to empty map (fallback)
        return {};
      }
      return {};
    }

    Map<String, String?> _arrayToMapNullable(dynamic value) {
      if (value is Map) {
        return Map<String, String?>.from(value);
      } else if (value is List) {
        // Convert array to empty map (fallback)
        return {};
      }
      return {};
    }

    Map<String, int> _arrayToMapInt(dynamic value) {
      if (value is Map) {
        return Map<String, int>.from(value);
      } else if (value is List) {
        // Convert array to empty map (fallback)
        return {};
      }
      return {};
    }

    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: _arrayToMap(data['participantNames']),
      participantProfileImages: _arrayToMapNullable(
        data['participantProfileImages'],
      ),
      participantRoles: _arrayToMap(data['participantRoles']),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageAt: data['lastMessageAt'] ?? Timestamp.now(),
      unreadCounts: _arrayToMapInt(data['unreadCounts']),
      lastReadAt: _parseLastReadAt(data['lastReadAt']),
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
    );
  }

  /// Helper to parse lastReadAt field (userId -> Timestamp)
  static Map<String, Timestamp>? _parseLastReadAt(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final result = <String, Timestamp>{};
      for (var entry in (value as Map).entries) {
        if (entry.value is Timestamp) {
          result[entry.key.toString()] = entry.value as Timestamp;
        }
      }
      return result.isNotEmpty ? result : null;
    }
    return null;
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String? getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId];
  }

  String? getOtherParticipantImage(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantProfileImages[otherId];
  }

  String? getOtherParticipantRole(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantRoles[otherId];
  }
}
