import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/chat_conversation_model.dart';
import '../../services/chat_service.dart';
import 'ChatDetailScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late String _currentUserId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          
          // Conversations list
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _chatService.getUserConversations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var conversations = snapshot.data ?? [];

                // Filter based on search query
                if (_searchQuery.isNotEmpty) {
                  conversations = conversations.where((conv) {
                    final otherName = conv.getOtherParticipantName(_currentUserId);
                    return otherName
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ??
                        false;
                  }).toList();
                }

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No conversations found'
                              : 'No conversations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildConversationTile(context, conversation);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
      BuildContext context, ChatConversation conversation) {
    final otherUserId = conversation.getOtherParticipantId(_currentUserId);
    final otherName = conversation.getOtherParticipantName(_currentUserId);
    final otherImage = conversation.getOtherParticipantImage(_currentUserId);
    final unreadCount = conversation.unreadCounts[_currentUserId] ?? 0;

    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('users')
          .where('firebaseUid', isEqualTo: otherUserId)
          .limit(1)
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || userSnap.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final userData =
            userSnap.data!.docs.first.data() as Map<String, dynamic>;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: otherImage != null
                    ? NetworkImage(otherImage)
                    : null,
                child: otherImage == null
                    ? Text(
                        otherName?.isNotEmpty == true
                            ? otherName!.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              // Online indicator
              if (userData['isOnline'] == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            otherName ?? 'Unknown',
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(conversation.lastMessageAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7CD3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  conversationId: conversation.id,
                  otherUserId: otherUserId,
                  otherUserName: otherName ?? 'Unknown',
                  otherUserImage: otherImage,
                ),
              ),
            );
          },
          onLongPress: () => _showConversationOptions(context, conversation),
        );
      },
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Conversations'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(
      BuildContext context, ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Pin Conversation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversation pinned')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications muted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Conversation', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _blockUser(ChatConversation conversation) {
    final otherUserId = conversation.getOtherParticipantId(_currentUserId);
    _chatService.blockUser(
      conversationId: conversation.id,
      blockUserId: otherUserId,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User blocked')),
    );
  }

  void _deleteConversation(ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _firestore
                  .collection('conversations')
                  .doc(conversation.id)
                  .delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
