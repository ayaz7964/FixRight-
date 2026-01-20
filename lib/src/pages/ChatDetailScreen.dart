import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/enhanced_message_model.dart';
import '../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../services/translation_service.dart';
import 'AudioCallScreen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late String _currentUserId;
  late UserModel _currentUser;
  final _messageController = TextEditingController();
  bool _isTyping = false;
  String _selectedLanguage = 'en';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid ?? '';
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    try {
      // Resolve profile by Firebase UID (stored as `firebaseUid`)
      final snap = await _firestore
          .collection('users')
          .where('firebaseUid', isEqualTo: _currentUserId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      final doc = snap.docs.first;
      setState(() {
        _currentUser = UserModel.fromDoc(doc);
        _selectedLanguage = _currentUser.preferredLanguage ?? 'en';
      });
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.sendTypingIndicator(
      conversationId: widget.conversationId,
      userId: _currentUserId,
      isTyping: false,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
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
                          'No messages yet. Start the conversation!',
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
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(context, message);
                  },
                );
              },
            ),
          ),

          // Typing indicator
          StreamBuilder<List<String>>(
            stream: _chatService.getTypingIndicators(widget.conversationId),
            builder: (context, snapshot) {
              final typingUsers = snapshot.data ?? [];
              final isOtherTyping = typingUsers.contains(widget.otherUserId);

              if (!isOtherTyping) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${widget.otherUserName} is typing',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTypingDot(0),
                          _buildTypingDot(1),
                          _buildTypingDot(2),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Language selector and input
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.otherUserName),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('firebaseUid', isEqualTo: widget.otherUserId)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final isOnline = userData['isOnline'] ?? false;
              final status = isOnline ? 'Online' : 'Offline';

              return Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: isOnline ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AudioCallScreen(
                  receiverId: widget.otherUserId,
                  receiverName: widget.otherUserName,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showUserInfo(),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageModel message) {
    final isSentByMe = message.senderId == _currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderProfileImage != null
                  ? NetworkImage(message.senderProfileImage!)
                  : null,
              child: message.senderProfileImage == null
                  ? Text(message.senderName[0])
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context, message),
              child: Container(
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? const Color(0xFF2B7CD3)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original message
                    Text(
                      message.originalText,
                      style: TextStyle(
                        color: isSentByMe ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),

                    // Translated message if available
                    if (message.translationsByLanguage != null &&
                        message.translationsByLanguage!.containsKey(
                            _selectedLanguage) &&
                        _selectedLanguage != message.originalLanguage)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          message.translationsByLanguage![_selectedLanguage]!,
                          style: TextStyle(
                            color: isSentByMe
                                ? Colors.white70
                                : Colors.black54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Message info
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(
                              message.timestamp.toDate(),
                            ),
                            style: TextStyle(
                              color: isSentByMe
                                  ? Colors.white70
                                  : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          if (isSentByMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.status == 'seen'
                                  ? Icons.done_all
                                  : message.status == 'delivered'
                                      ? Icons.done_all
                                      : Icons.done,
                              size: 14,
                              color: message.status == 'seen'
                                  ? Colors.blue
                                  : Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (message.isEdited)
                      Text(
                        'edited',
                        style: TextStyle(
                          color: isSentByMe
                              ? Colors.white70
                              : Colors.grey[600],
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isSentByMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Message Language:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TranslationService.supportedLanguages.entries
                          .map((entry) {
                        final isSelected = _selectedLanguage == entry.key;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedLanguage = entry.key);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    // TODO: Implement emoji picker
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      if (value.isEmpty && _isTyping) {
                        _chatService.sendTypingIndicator(
                          conversationId: widget.conversationId,
                          userId: _currentUserId,
                          isTyping: false,
                        );
                        setState(() => _isTyping = false);
                      } else if (value.isNotEmpty && !_isTyping) {
                        _chatService.sendTypingIndicator(
                          conversationId: widget.conversationId,
                          userId: _currentUserId,
                          isTyping: true,
                        );
                        setState(() => _isTyping = true);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF2B7CD3),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    _chatService.sendTypingIndicator(
      conversationId: widget.conversationId,
      userId: _currentUserId,
      isTyping: false,
    );
    setState(() => _isTyping = false);

    _chatService.sendMessage(
      conversationId: widget.conversationId,
      text: text,
      userId: _currentUserId,
      senderName: _currentUser.fullName,
      senderProfileImage: _currentUser.profileImageUrl,
      sourceLanguage: _selectedLanguage,
    );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showMessageOptions(BuildContext context, MessageModel message) {
    final isSentByMe = message.senderId == _currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy to clipboard
              },
            ),
            if (_selectedLanguage != message.originalLanguage)
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text('Translate'),
                onTap: () {
                  Navigator.pop(context);
                  _translateMessage(message);
                },
              ),
            if (isSentByMe)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
            if (isSentByMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _translateMessage(MessageModel message) {
    _chatService.translateMessage(
      messageId: message.id,
      conversationId: widget.conversationId,
      text: message.originalText,
      targetLanguage: _selectedLanguage,
      sourceLanguage: message.originalLanguage,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Translating message...')),
    );
  }

  void _editMessage(MessageModel message) {
    final editController = TextEditingController(text: message.originalText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatService.editMessage(
                conversationId: widget.conversationId,
                messageId: message.id,
                newText: editController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message edited')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatService.deleteMessage(
                conversationId: widget.conversationId,
                messageId: message.id,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Info'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('users')
                .where('firebaseUid', isEqualTo: widget.otherUserId)
                .limit(1)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Text('User not found');
              }

              final user = UserModel.fromDoc(snapshot.data!.docs.first);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.profileImageUrl != null)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.profileImageUrl!),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Name: ${user.fullName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Phone: ${user.phoneNumber}'),
                  Text('Role: ${user.role.toUpperCase()}'),
                  if (user.rating != null)
                    Text(
                        'Rating: ${user.rating} ★ (${user.totalReviews} reviews)'),
                  if (user.bio != null) Text('Bio: ${user.bio}'),
                  Text(
                      'Preferred Language: ${TranslationService.getLanguageName(user.preferredLanguage ?? 'en')}'),
                ],
              );
            },
          ),
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

  Widget _buildTypingDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
