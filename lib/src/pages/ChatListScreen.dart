// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../models/chat_conversation_model.dart';
// import '../../services/chat_service.dart';
// import 'ChatDetailScreen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   final ChatService _chatService = ChatService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   late String _currentUserId;
//   String _searchQuery = '';
//   final _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _currentUserId = _auth.currentUser?.uid ?? '';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Messages'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () => _showSearchDialog(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           if (_searchQuery.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search conversations...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       _searchController.clear();
//                       setState(() => _searchQuery = '');
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 onChanged: (value) => setState(() => _searchQuery = value),
//               ),
//             ),
          
//           // Conversations list
//           Expanded(
//             child: StreamBuilder<List<ChatConversation>>(
//               stream: _chatService.getUserConversations(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var conversations = snapshot.data ?? [];

//                 // Filter based on search query
//                 if (_searchQuery.isNotEmpty) {
//                   conversations = conversations.where((conv) {
//                     final otherName = conv.getOtherParticipantName(_currentUserId);
//                     return otherName
//                             ?.toLowerCase()
//                             .contains(_searchQuery.toLowerCase()) ??
//                         false;
//                   }).toList();
//                 }

//                 if (conversations.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.mail_outline,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _searchQuery.isNotEmpty
//                               ? 'No conversations found'
//                               : 'No conversations yet',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: conversations.length,
//                   itemBuilder: (context, index) {
//                     final conversation = conversations[index];
//                     return _buildConversationTile(context, conversation);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildConversationTile(
//       BuildContext context, ChatConversation conversation) {
//     final otherUserId = conversation.getOtherParticipantId(_currentUserId);
//     final otherName = conversation.getOtherParticipantName(_currentUserId);
//     final otherImage = conversation.getOtherParticipantImage(_currentUserId);
//     final unreadCount = conversation.unreadCounts[_currentUserId] ?? 0;

//     return FutureBuilder<QuerySnapshot>(
//       future: _firestore
//           .collection('users')
//           .where('firebaseUid', isEqualTo: otherUserId)
//           .limit(1)
//           .get(),
//       builder: (context, userSnap) {
//         if (!userSnap.hasData || userSnap.data!.docs.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         final userData =
//             userSnap.data!.docs.first.data() as Map<String, dynamic>;

//         return ListTile(
//           leading: Stack(
//             children: [
//               CircleAvatar(
//                 radius: 28,
//                 backgroundImage: otherImage != null
//                     ? NetworkImage(otherImage)
//                     : null,
//                 child: otherImage == null
//                     ? Text(
//                         otherName?.isNotEmpty == true
//                             ? otherName!.substring(0, 1).toUpperCase()
//                             : '?',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     : null,
//               ),
//               // Online indicator
//               if (userData['isOnline'] == true)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     width: 14,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           title: Text(
//             otherName ?? 'Unknown',
//             style: TextStyle(
//               fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           subtitle: Text(
//             conversation.lastMessage,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
//               fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
//             ),
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 _formatTime(conversation.lastMessageAt),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               if (unreadCount > 0)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2B7CD3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     unreadCount.toString(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ChatDetailScreen(
//                   conversationId: conversation.id,
//                   otherUserId: otherUserId,
//                   otherUserName: otherName ?? 'Unknown',
//                   otherUserImage: otherImage,
//                 ),
//               ),
//             );
//           },
//           onLongPress: () => _showConversationOptions(context, conversation),
//         );
//       },
//     );
//   }

//   String _formatTime(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     final now = DateTime.now();

//     if (date.day == now.day &&
//         date.month == now.month &&
//         date.year == now.year) {
//       return DateFormat('HH:mm').format(date);
//     } else if (date.day == now.day - 1 &&
//         date.month == now.month &&
//         date.year == now.year) {
//       return 'Yesterday';
//     } else if (date.year == now.year) {
//       return DateFormat('MMM d').format(date);
//     } else {
//       return DateFormat('MMM d, y').format(date);
//     }
//   }

//   void _showSearchDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Search Conversations'),
//         content: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Enter name...',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           onChanged: (value) {
//             setState(() => _searchQuery = value);
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showConversationOptions(
//       BuildContext context, ChatConversation conversation) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.pin),
//               title: const Text('Pin Conversation'),
//               onTap: () {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Conversation pinned')),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.volume_off),
//               title: const Text('Mute Notifications'),
//               onTap: () {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Notifications muted')),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.block),
//               title: const Text('Block User'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _blockUser(conversation);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete Conversation', style: TextStyle(color: Colors.red)),
//               onTap: () {
//                 Navigator.pop(context);
//                 _deleteConversation(conversation);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _blockUser(ChatConversation conversation) {
//     final otherUserId = conversation.getOtherParticipantId(_currentUserId);
//     _chatService.blockUser(
//       conversationId: conversation.id,
//       blockUserId: otherUserId,
//     );
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('User blocked')),
//     );
//   }

//   void _deleteConversation(ChatConversation conversation) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Conversation?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _firestore
//                   .collection('conversations')
//                   .doc(conversation.id)
//                   .delete();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Conversation deleted')),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';
import 'notification_service.dart';
import 'tts_translation_service.dart';
import 'ChatDetailScreen.dart';

// ═══════════════════════════════════════════════════════════════
//  CONVERSATIONS LIST — Professional Messenger UI
//  ✅ No search bar, no filters
//  ✅ Real-time unread badge
//  ✅ Clean WhatsApp-style layout
// ═══════════════════════════════════════════════════════════════
class ConversationsListScreen extends StatefulWidget {
  final String? phoneUID;
  const ConversationsListScreen({super.key, this.phoneUID});
  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  late String _uid;

  @override
  void initState() {
    super.initState();
    _uid = _resolveUid();
    TtsTranslationService().init();
  }

  String _resolveUid() {
    final raw = widget.phoneUID ??
        UserSession().phoneUID ??
        UserSession().phone ??
        UserSession().uid ??
        '';
    return _normalizePhone(raw);
  }

  String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    final t = raw.trim();
    if (t.startsWith('+')) return t;
    if (RegExp(r'^\d+$').hasMatch(t)) return '+$t';
    return t;
  }

  Stream<QuerySnapshot> get _convStream => FirebaseFirestore.instance
      .collection('conversations')
      .where('participantIds', arrayContains: _uid)
      .orderBy('lastMessageAt', descending: true)
      .snapshots();

  int _totalUnread(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final unread = data['unreadCounts'] as Map<String, dynamic>? ?? {};
      total += (unread[_uid] ?? 0) as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: const Center(child: Text('Please log in to view messages')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _convStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2));
          }
          if (snap.hasError) {
            return _ErrorState(error: snap.error.toString());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _ConversationTile(convId: docs[i].id, data: data, myUid: _uid);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: const Text(
        'Messages',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.4),
      ),
      actions: [
        StreamBuilder<QuerySnapshot>(
          stream: _convStream,
          builder: (ctx, snap) {
            final unread = _totalUnread(snap.data?.docs ?? []);
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(alignment: Alignment.topRight, children: [
                const GlobalLanguageButton(color: Color(0xFF00695C)),
                if (unread > 0) Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFF00695C), shape: BoxShape.circle),
                  child: Center(child: Text('$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                ),
              ]),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade100),
      ),
    );
  }
}

// ── Conversation Tile ─────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final String convId, myUid;
  final Map<String, dynamic> data;
  const _ConversationTile({required this.convId, required this.data, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final names  = data['participantNames'] as Map<String, dynamic>? ?? {};
    final images = data['participantProfileImages'] as Map<String, dynamic>? ?? {};
    final roles  = data['participantRoles'] as Map<String, dynamic>? ?? {};
    final unread = (data['unreadCounts'] as Map<String, dynamic>?)?[myUid] ?? 0;
    final lastMsg = data['lastMessage'] as String? ?? '';
    final lastAt  = data['lastMessageAt'] as Timestamp?;
    final jobTitle = data['relatedJobTitle'] as String? ?? '';

    // Find the other participant
    final ids = List<String>.from(data['participantIds'] ?? []);
    final otherId = ids.firstWhere((id) => id != myUid, orElse: () => '');
    final otherName = names[otherId] as String? ?? 'Unknown';
    final otherImage = images[otherId] as String? ?? '';
    final otherRole  = roles[otherId] as String? ?? '';

    final hasUnread = (unread as int) > 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          convId: convId,
          myUid: myUid,
          otherUid: otherId,
          otherName: otherName,
          otherImage: otherImage,
          otherRole: otherRole,
          jobTitle: jobTitle,
        ),
      )),
      child: Container(
        color: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Avatar
              Stack(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00695C).withOpacity(0.12),
                  backgroundImage: otherImage.isNotEmpty ? NetworkImage(otherImage) : null,
                  child: otherImage.isEmpty ? Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 20),
                  ) : null,
                ),
                if (otherRole.isNotEmpty) Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: otherRole == 'seller' ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      otherRole == 'seller' ? 'W' : 'B',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              const SizedBox(width: 12),
              // Content
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(
                    otherName,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15.5, color: Colors.black87,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                  if (lastAt != null) Text(
                    _formatTime(lastAt),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: hasUnread ? const Color(0xFF00695C) : Colors.grey[400],
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Expanded(child: Text(
                    lastMsg.isNotEmpty ? lastMsg : (jobTitle.isNotEmpty ? '📋 $jobTitle' : 'No messages yet'),
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread ? Colors.black87 : Colors.grey[500],
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                  if (hasUnread) Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFF00695C), shape: BoxShape.circle),
                    child: Center(child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    )),
                  ),
                ]),
                if (jobTitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.work_outline, size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Expanded(child: Text(jobTitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ])),
            ]),
          ),
          Divider(height: 1, color: Colors.grey.shade100, indent: 72),
        ]),
      ),
    );
  }

  String _formatTime(Timestamp ts) {
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('hh:mm a').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM/yy').format(dt);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.08), shape: BoxShape.circle),
        child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Color(0xFF00695C)),
      ),
      const SizedBox(height: 20),
      const Text('No conversations yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
      const SizedBox(height: 8),
      Text('Start a conversation by placing an order\nor sending a bid on a job.', style: TextStyle(fontSize: 13, color: Colors.grey[500]), textAlign: TextAlign.center),
    ]),
  );
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red[300]),
      const SizedBox(height: 12),
      Text('Could not load messages', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
    ]),
  );
}