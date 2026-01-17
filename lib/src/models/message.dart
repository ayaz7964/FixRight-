import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderRole;
  final String originalText;
  final String? originalLanguage;
  final String? translatedText;
  final String? translatedLanguage;
  final Timestamp timestamp;
  final String status; // sent/delivered/seen

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderRole,
    required this.originalText,
    this.originalLanguage,
    this.translatedText,
    this.translatedLanguage,
    required this.timestamp,
    this.status = 'sent',
  });

  Map<String, dynamic> toMap() => {
        'messageId': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'senderRole': senderRole,
        'originalText': originalText,
        'originalLanguage': originalLanguage,
        'translatedText': translatedText,
        'translatedLanguage': translatedLanguage,
        'timestamp': timestamp,
        'status': status,
      };

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderRole: data['senderRole'] ?? 'Buyer',
      originalText: data['originalText'] ?? '',
      originalLanguage: data['originalLanguage'],
      translatedText: data['translatedText'],
      translatedLanguage: data['translatedLanguage'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: data['status'] ?? 'sent',
    );
  }
}
