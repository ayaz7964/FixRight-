import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // Use phone number from Firebase Auth or passed otherUserId (both are phone numbers)
    _currentUserId = _auth.currentUser?.phoneNumber ?? '';
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    try {
      // Look up user profile using phone number as document ID
      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (!userDoc.exists) {
        print('User profile not found for phone: $_currentUserId');
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final firstName = data['firstName'] ?? '';
      final lastName = data['lastName'] ?? '';

      setState(() {
        _currentUser = UserModel(
          uid: _currentUserId,
          phoneNumber: _currentUserId,
          firstName: firstName,
          lastName: lastName,
          profileImageUrl: data['profileImageUrl'],
          role: data['role'] ?? 'buyer',
          preferredLanguage: data['preferredLanguage'] ?? 'en',
          bio: data['bio'],
          rating: (data['rating'] as num?)?.toDouble(),
          totalReviews: data['totalReviews'] ?? 0,
          isOnline: data['isOnline'] ?? false,
          status: data['status'],
        );
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

  /// Format timestamp to 12-hour format with AM/PM (WhatsApp style)
  String _formatMessageTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  /// Save language preference to Firestore
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      await _firestore.collection('users').doc(_currentUserId).update({
        'preferredLanguage': languageCode,
      });
      print('Language preference saved: $languageCode');
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  /// Show translation language selector modal
  void _showTranslationLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Auto-Translation Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: TranslationService.supportedLanguages.entries.map((
                    entry,
                  ) {
                    final isSelected = _selectedLanguage == entry.key;
                    return ListTile(
                      title: Text(entry.value),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                          : null,
                      onTap: () {
                        setState(() => _selectedLanguage = entry.key);
                        _saveLanguagePreference(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(widget.otherUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const SizedBox.shrink();
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
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
        mainAxisAlignment: isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                          _selectedLanguage,
                        ) &&
                        _selectedLanguage != message.originalLanguage)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          message.translationsByLanguage![_selectedLanguage]!,
                          style: TextStyle(
                            color: isSentByMe ? Colors.white70 : Colors.black54,
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
                            _formatMessageTime(message.timestamp),
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
                          color: isSentByMe ? Colors.white70 : Colors.grey[600],
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
          // Auto-Translation Language Selector - moved to settings menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Auto-Translate to: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: _showTranslationLanguageSelector,
                  child: Chip(
                    label: Text(
                      TranslationService
                              .supportedLanguages[_selectedLanguage] ??
                          'English',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    avatar: const Icon(Icons.translate, size: 16),
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
      sourceLanguage: null, // Auto-detect message language
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
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Translating message...')));
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Message edited')));
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Message deleted')));
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
          child: FutureBuilder<DocumentSnapshot>(
            future: _firestore
                .collection('users')
                .doc(widget.otherUserId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.data!.exists) {
                return const Text('User not found');
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final firstName = data['firstName'] ?? '';
              final lastName = data['lastName'] ?? '';

              final user = UserModel(
                uid: widget.otherUserId,
                phoneNumber: widget.otherUserId,
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: data['profileImageUrl'],
                role: data['role'] ?? 'buyer',
                preferredLanguage: data['preferredLanguage'] ?? 'en',
                bio: data['bio'],
                rating: (data['rating'] as num?)?.toDouble(),
                totalReviews: data['totalReviews'] ?? 0,
              );

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
                  if (user.rating != null && user.rating! > 0)
                    Text(
                      'Rating: ${user.rating} ★ (${user.totalReviews} reviews)',
                    ),
                  if (user.bio != null && (user.bio as String).isNotEmpty)
                    Text('Bio: ${user.bio}'),
                  Text(
                    'Preferred Language: ${TranslationService.getLanguageName(user.preferredLanguage ?? 'en')}',
                  ),
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
      decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    );
  }
}
