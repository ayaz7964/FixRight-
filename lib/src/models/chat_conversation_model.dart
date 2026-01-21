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
    'blockedUsers': blockedUsers,
  };

  factory ChatConversation.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      participantProfileImages: Map<String, String?>.from(
        data['participantProfileImages'] ?? {},
      ),
      participantRoles: Map<String, String>.from(
        data['participantRoles'] ?? {},
      ),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageAt: data['lastMessageAt'] ?? Timestamp.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
    );
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
}
