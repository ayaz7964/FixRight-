import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

/// ChatService: handles sending/receiving messages and simple signaling for calls.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentUid() => _auth.currentUser?.uid ?? '';

  String chatIdFor(String a, String b) {
    final parts = [a, b]..sort();
    return parts.join('_');
  }

  /// Send a message to peer (writes to chats/{chatId}/messages)
  Future<void> sendMessage({
    required String toUid,
    required String text,
    required String senderRole,
    String? originalLanguage,
  }) async {
    final from = _currentUid();
    if (from.isEmpty) throw Exception('Not authenticated');

    final chatId = chatIdFor(from, toUid);
    final ref = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final msg = MessageModel(
      id: ref.id,
      senderId: from,
      receiverId: toUid,
      senderRole: senderRole,
      originalText: text,
      originalLanguage: originalLanguage,
      timestamp: Timestamp.now(),
      status: 'sent',
    );

    await ref.set(msg.toMap());

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [from, toUid],
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Stream messages for a chat
  Stream<List<MessageModel>> messagesStream(String chatId, {int limit = 100}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromDoc(d)).toList());
  }

  /// Typing indicator write (small doc)
  Future<void> setTyping(String chatId, bool typing) async {
    final uid = _currentUid();
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('meta')
        .doc('typing')
        .set({
          uid: typing ? FieldValue.serverTimestamp() : null,
        }, SetOptions(merge: true));
  }

  /// Simple signaling: create call doc (caller writes offer), receiver listens
  Future<String> createCall(String toUid, Map<String, dynamic> payload) async {
    final from = _currentUid();
    final doc = await _firestore.collection('calls').add({
      'callerId': from,
      'receiverId': toUid,
      'status': 'ringing',
      'createdAt': Timestamp.now(),
      'payload': payload,
    });
    return doc.id;
  }

  Stream<DocumentSnapshot> callStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  Future<void> answerCall(String callId, Map<String, dynamic> payload) async {
    await _firestore.collection('calls').doc(callId).set({
      'status': 'accepted',
      'answer': payload,
    }, SetOptions(merge: true));
  }

  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
      'endedAt': Timestamp.now(),
    });
  }
}
