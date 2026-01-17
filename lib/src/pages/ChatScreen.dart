import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String peerUid;
  const ChatScreen({super.key, required this.chatId, required this.peerUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  late ChatService _chatService;
  StreamSubscription? _typingSub;

  String _currentUid() => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
  }

  @override
  void dispose() {
    _typingSub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final uid = _currentUid();
    await _chatService.sendMessage(
      toUid: widget.peerUid,
      text: text,
      senderRole: 'Buyer',
    );
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [CircleAvatar(child: Text(widget.peerUid.isNotEmpty ? widget.peerUid[0] : '?')), const SizedBox(width: 8), Text(widget.peerUid)]),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () async {
              final callId = await _chatService.createCall(widget.peerUid, {'note': 'audio-call'});
              Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(callId: callId)));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.messagesStream(widget.chatId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snap.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final mine = m.senderId == _currentUid();
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mine ? Colors.blue.shade600 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.originalText, style: TextStyle(color: mine ? Colors.white : Colors.black)),
                            if (m.translatedText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(m.translatedText!, style: TextStyle(color: mine ? Colors.white70 : Colors.black54, fontSize: 12)),
                              ),
                            const SizedBox(height: 6),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(_formatTimestamp(m.timestamp), style: TextStyle(color: mine ? Colors.white70 : Colors.black45, fontSize: 10)),
                              const SizedBox(width: 8),
                              if (mine) Icon(Icons.check, size: 12, color: Colors.white70),
                            ])
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                      onChanged: (v) {
                        _chatService.setTyping(widget.chatId, v.isNotEmpty);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// Minimal call screen for WebRTC flow
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  const CallScreen({super.key, required this.callId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _pc;
  StreamSubscription<DocumentSnapshot>? _callSub;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startCall();
  }

  @override
  void dispose() {
    _callSub?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _pc.close();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    final cfg = {'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]};
    _pc = await createPeerConnection(cfg);

    final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
    _localRenderer.srcObject = stream;
    _pc.addStream(stream);

    _pc.onAddStream = (s) {
      _remoteRenderer.srcObject = s;
    };

    // Note: For production use, signaling must exchange SDP and ICE via Firestore and secure rules.
    // Here we demonstrate local scaffolding only.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call')),
      body: Column(
        children: [
          Expanded(child: Center(child: Text('Audio call active - minimal UI'))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('End Call'),
            ),
          )
        ],
      ),
    );
  }
}
