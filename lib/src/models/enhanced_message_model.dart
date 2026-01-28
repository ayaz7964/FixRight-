import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId; // The intended receiver of this message
  final String senderName;
  final String? senderProfileImage;
  final String originalText;
  final String? mediaUrl;
  final String mediaType; // 'text', 'image', 'audio', 'video'
  final String? originalLanguage;
  final Map<String, String>?
  translationsByLanguage; // language -> translated text
  final Timestamp timestamp;
  final String status; // 'sending', 'sent', 'delivered', 'seen'
  final bool isEdited;
  final Timestamp? editedAt;
  final String? replyToMessageId;
  final String? replyToText;
  final bool isRead; // WhatsApp-like unread tracking: true if receiver has read

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.senderName,
    this.senderProfileImage,
    required this.originalText,
    this.mediaUrl,
    this.mediaType = 'text',
    this.originalLanguage,
    this.translationsByLanguage,
    required this.timestamp,
    this.status = 'sending',
    this.isEdited = false,
    this.editedAt,
    this.replyToMessageId,
    this.replyToText,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'conversationId': conversationId,
    'senderId': senderId,
    'receiverId': receiverId,
    'senderName': senderName,
    'senderProfileImage': senderProfileImage,
    'originalText': originalText,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'originalLanguage': originalLanguage,
    'translationsByLanguage': translationsByLanguage,
    'timestamp': timestamp,
    'status': status,
    'isEdited': isEdited,
    'editedAt': editedAt,
    'replyToMessageId': replyToMessageId,
    'replyToText': replyToText,
    'isRead': isRead,
  };

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'],
      senderName: data['senderName'] ?? '',
      senderProfileImage: data['senderProfileImage'],
      originalText: data['originalText'] ?? '',
      mediaUrl: data['mediaUrl'],
      mediaType: data['mediaType'] ?? 'text',
      originalLanguage: data['originalLanguage'],
      translationsByLanguage: data['translationsByLanguage'] != null
          ? Map<String, String>.from(data['translationsByLanguage'])
          : null,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: data['status'] ?? 'sent',
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'],
      replyToMessageId: data['replyToMessageId'],
      replyToText: data['replyToText'],
      isRead: data['isRead'] ?? false,
    );
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? senderProfileImage,
    String? originalText,
    String? mediaUrl,
    String? mediaType,
    String? originalLanguage,
    Map<String, String>? translationsByLanguage,
    Timestamp? timestamp,
    String? status,
    bool? isEdited,
    Timestamp? editedAt,
    String? replyToMessageId,
    String? replyToText,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      originalText: originalText ?? this.originalText,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      translationsByLanguage:
          translationsByLanguage ?? this.translationsByLanguage,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      isRead: isRead ?? this.isRead,
    );
  }
}
