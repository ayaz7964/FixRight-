import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_conversation_model.dart';
import '../../services/chat_service.dart';
import '../../services/translation_service.dart';
import '../../services/user_data_helper.dart';
import 'ChatDetailScreen.dart';
import 'CallsListScreen.dart';

class MessengerHomeScreen extends StatefulWidget {
  const MessengerHomeScreen({super.key});

  @override
  State<MessengerHomeScreen> createState() => _MessengerHomeScreenState();
}

class _MessengerHomeScreenState extends State<MessengerHomeScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _currentUserId;
  String _searchQuery = '';
  String _userTypeFilter = 'all'; // all, buyer, seller
  String _locationFilter = 'all'; // all, nearest, sameCity
  String _skillFilter = 'all';
  String _autoTranslateLanguage = 'ur';
  bool _isDarkMode = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use phone number as user ID (FixRight architecture)
    _currentUserId = UserDataHelper.getCurrentPhoneUID() ?? '';
    _loadUserPreferences();
    _migrateConversationData();
  }

  void _migrateConversationData() async {
    try {
      // Run migration to fix any corrupted conversation data
      await _chatService.migrateCorruptedConversations();
    } catch (e) {
      print('Error migrating conversations: $e');
    }
  }

  void _loadUserPreferences() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      if (doc.exists) {
        setState(() {
          _autoTranslateLanguage = doc['preferredLanguage'] ?? 'ur';
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messenger',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B7CD3),
          ),
        ),
        centerTitle: true,
      ),
      body: _buildChatsTab(),
    );
  }

  Widget _buildChatsTab() {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),

        // Filter Chips
        _buildFilterSection(),

        // Chats List or Search Results
        Expanded(
          child: _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : _buildChatsList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: _isDarkMode ? const Color(0xFF1a1a1a) : Colors.grey[100],
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search contacts or messages...',
          hintStyle: TextStyle(
            color: _isDarkMode ? Colors.grey[600] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isDarkMode ? Colors.grey[600] : Colors.grey[600],
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // User Type Filter
          _buildFilterChip(
            label: _userTypeFilter == 'all'
                ? 'All'
                : _userTypeFilter == 'buyer'
                ? 'Buyers'
                : 'Sellers',
            selected: true,
            onTap: () => _showUserTypeFilter(),
          ),

          const SizedBox(width: 8),

          // Location Filter
          _buildFilterChip(
            label: _locationFilter == 'all'
                ? 'Location'
                : _locationFilter == 'nearest'
                ? 'Nearest'
                : 'Same City',
            onTap: () => _showLocationFilter(),
          ),

          const SizedBox(width: 8),

          // Skills/Categories Filter
          _buildFilterChip(
            label: _skillFilter == 'all' ? 'Skills' : _skillFilter,
            onTap: () => _showSkillsFilter(),
          ),

          const SizedBox(width: 8),

          // Clear Filters Button
          if (_userTypeFilter != 'all' ||
              _locationFilter != 'all' ||
              _skillFilter != 'all')
            _buildFilterChip(
              label: 'Clear',
              backgroundColor: Colors.red[700],
              onTap: _clearAllFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    bool selected = false,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (selected
                  ? const Color(0xFF2B7CD3)
                  : (_isDarkMode ? Colors.grey[800] : Colors.grey[200])),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2B7CD3)
                : (_isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (_isDarkMode ? Colors.white : Colors.black87),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selected || label == 'Clear') const SizedBox(width: 4),
            if (selected || label == 'Clear')
              Icon(
                selected ? Icons.expand_more : Icons.close,
                size: 16,
                color: selected ? Colors.white : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<ChatConversation>>(
      stream: _chatService.getUserConversations(),
      builder: (context, snapshot) {
        // Show error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading conversations',
                  style: TextStyle(fontSize: 16, color: Colors.red[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Show loading state
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: const Color(0xFF2B7CD3)),
          );
        }

        var conversations = snapshot.data ?? [];

        // Show empty state
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with a contact',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Show conversations list
        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) => Divider(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
            height: 1,
          ),
          itemBuilder: (context, index) {
            return _buildConversationTile(conversations[index]);
          },
        );
      },
    );
  }

  /// Build search results with seller details
  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _chatService.searchUsersByName(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: const Color(0xFF2B7CD3)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No users found for "$_searchQuery"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildSearchResultTile(users[index]);
          },
        );
      },
    );
  }

  /// Build individual search result tile with seller info
  Widget _buildSearchResultTile(Map<String, dynamic> user) {
    final fullName = user['fullName'] ?? 'Unknown';
    final role = user['role'] ?? 'Unknown';
    final profileImage = user['profileImageUrl'];
    final skills = (user['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final rating = user['rating'] ?? 0.0;
    final reviews = user['totalReviews'] ?? 0;
    final city = user['city'] ?? 'Unknown City';
    final bio = user['bio'] ?? '';
    final userId = user['userId'] ?? '';

    // Skip rendering if userId is empty (invalid user)
    if (userId.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
          onTap: () async {
        // Create or navigate to conversation
        try {
          final currentUser = _auth.currentUser;
          if (currentUser == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Please login first')));
            return;
          }
          // Resolve phone-based UID (handles email/login alias -> phone mapping)
          final currentUserPhone = await UserDataHelper.resolvePhoneUID() ?? '';
          // Get phone from userId (which is doc.id - the phone number in Firestore schema)
          final otherUserPhone = user['userId'] ?? '';

          if (currentUserPhone.isEmpty || otherUserPhone.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number not found  line 403 MessageHome'),
              ),
            );
            return;
          }

          // Generate deterministic conversation ID
          final phones = [currentUserPhone, otherUserPhone]..sort();
          final conversationId = '${phones[0]}_${phones[1]}';

          // Check if conversation exists, create if not
          final convDoc = await _firestore
              .collection('conversations')
              .doc(conversationId)
              .get();

          if (!convDoc.exists) {
            // Get current user's full profile
            final currentUserDoc = await _firestore
                .collection('users')
                .doc(currentUserPhone)
                .get();

            if (!currentUserDoc.exists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your profile not found')),
              );
              return;
            }

            final currentUserData =
                currentUserDoc.data() as Map<String, dynamic>;

            // Create conversation in Firestore with complete data
            await _firestore.collection('conversations').doc(conversationId).set({
              'participantIds': [currentUserPhone, otherUserPhone],
              'participantNames': {
                currentUserPhone:
                    '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
                        .trim(),
                otherUserPhone: fullName,
              },
              'participantRoles': {
                currentUserPhone: currentUserData['role'] ?? 'buyer',
                otherUserPhone: role,
              },
              'participantProfileImages': {
                currentUserPhone: currentUserData['profileImageUrl'] ?? '',
                otherUserPhone: profileImage ?? '',
              },
              'lastMessage': '',
              'lastMessageAt': Timestamp.now(),
              'createdAt': Timestamp.now(),
              'unreadCounts': {currentUserPhone: 0, otherUserPhone: 0},
            });
          }

          // Navigate to chat screen with all necessary data
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  conversationId: conversationId,
                  otherUserId: otherUserPhone, // Use phone as ID
                  otherUserName: fullName,
                  otherUserImage: profileImage,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
          }
          print('Error starting conversation: $e');
        }
      },
      child: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF2B7CD3),
                  backgroundImage: profileImage != null
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage == null
                      ? Text(
                          fullName.isNotEmpty
                              ? fullName.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and role
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: role == 'Seller'
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              city,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Rating and reviews (for sellers)
                      if (role == 'Seller' && rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ★ ($reviews reviews)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Bio
                      if (bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Skills (if seller)
            if (role == 'Seller' && skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  children: skills
                      .take(3)
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B7CD3).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2B7CD3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2B7CD3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            // Contact Button (visible action)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B7CD3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () async {
                    // Contact button action - same as tap logic
                    try {
                      final currentUser = _auth.currentUser;
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login first')),
                        );
                        return;
                      }
                      final currentUserPhone = await UserDataHelper.resolvePhoneUID() ?? '';
                      final otherUserPhone = user['userId'] ?? '';

                      if (currentUserPhone.isEmpty || otherUserPhone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Phone number not found line 680 MessageHome ' 
                              //Phone number not found line 680 MessageHome 
                            ),
                          ),
                        );
                        return;
                      }

                      final phones = [currentUserPhone, otherUserPhone]..sort();
                      final conversationId = '${phones[0]}_${phones[1]}';

                      final convDoc = await _firestore
                          .collection('conversations')
                          .doc(conversationId)
                          .get();

                      if (!convDoc.exists) {
                        final currentUserDoc = await _firestore
                            .collection('users')
                            .doc(currentUserPhone)
                            .get();

                        if (!currentUserDoc.exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your profile not found'),
                            ),
                          );
                          return;
                        }

                        final currentUserData =
                            currentUserDoc.data() as Map<String, dynamic>;

                        await _firestore
                            .collection('conversations')
                            .doc(conversationId)
                            .set({
                              'participantIds': [
                                currentUserPhone,
                                otherUserPhone,
                              ],
                              'participantNames': {
                                currentUserPhone:
                                    '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
                                        .trim(),
                                otherUserPhone: fullName,
                              },
                              'participantRoles': {
                                currentUserPhone:
                                    currentUserData['role'] ?? 'buyer',
                                otherUserPhone: role,
                              },
                              'participantProfileImages': {
                                currentUserPhone:
                                    currentUserData['profileImageUrl'] ?? '',
                                otherUserPhone: profileImage ?? '',
                              },
                              'lastMessage': '',
                              'lastMessageAt': Timestamp.now(),
                              'createdAt': Timestamp.now(),
                              'unreadCounts': {
                                currentUserPhone: 0,
                                otherUserPhone: 0,
                              },
                            });
                      }

                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversationId: conversationId,
                              otherUserId: otherUserPhone,
                              otherUserName: fullName,
                              otherUserImage: profileImage,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                      print('Error contacting user: $e');
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final otherId = conversation.getOtherParticipantId(_currentUserId);
    final otherName = conversation.getOtherParticipantName(_currentUserId);
    final otherImage = conversation.getOtherParticipantImage(_currentUserId);
    final unreadCount = conversation.unreadCounts[_currentUserId] ?? 0;

    // Skip rendering if otherId is empty (invalid conversation)
    if (otherId.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onLongPress: () => _showConversationOptions(conversation),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              conversationId: conversation.id,
              otherUserId: otherId,
              otherUserName: otherName ?? 'Unknown',
              otherUserImage: otherImage,
            ),
          ),
        );
      },
      child: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF2B7CD3),
                  backgroundImage: otherImage != null
                      ? NetworkImage(otherImage)
                      : null,
                  child: otherImage == null
                      ? Text(
                          otherName?.isNotEmpty == true
                              ? otherName!.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Online indicator - Removed FutureBuilder to avoid field errors
                // Note: Can be re-enabled once isOnline field is consistently added to all user docs
                const SizedBox.shrink(),
              ],
            ),

            const SizedBox(width: 12),

            // Message info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherName ?? 'Ayaz Unknown',
                          style: TextStyle(
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 14,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _formatChatTime(conversation.lastMessageAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Last message preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: unreadCount > 0
                                ? (_isDarkMode ? Colors.white : Colors.black87)
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B7CD3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      // Today - 12-hour format with AM/PM (WhatsApp style)
      return '$hour:$minute $ampm';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[date.weekday % 7];
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showUserTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Contact Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            ListTile(
              title: const Text('All Contacts'),
              trailing: _userTypeFilter == 'all'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _userTypeFilter = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Buyers Only'),
              trailing: _userTypeFilter == 'buyer'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _userTypeFilter = 'buyer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sellers Only'),
              trailing: _userTypeFilter == 'seller'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _userTypeFilter = 'seller');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            ListTile(
              title: const Text('All Locations'),
              trailing: _locationFilter == 'all'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _locationFilter = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Same City'),
              trailing: _locationFilter == 'sameCity'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _locationFilter = 'sameCity');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Nearest (10km)'),
              subtitle: const Text('Based on your location'),
              trailing: _locationFilter == 'nearest'
                  ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                  : null,
              onTap: () {
                setState(() => _locationFilter = 'nearest');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSkillsFilter() {
    // Fetch skills from Firebase
    _chatService.fetchAllSkills().then((skills) {
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          color: _isDarkMode ? Colors.black : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Skills / Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              ListTile(
                title: const Text('All Skills'),
                trailing: _skillFilter == 'all'
                    ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                    : null,
                onTap: () {
                  setState(() => _skillFilter = 'all');
                  Navigator.pop(context);
                },
              ),
              if (skills.isNotEmpty) const Divider(),
              if (skills.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: skills.length,
                    itemBuilder: (context, index) {
                      final skill = skills[index];
                      return ListTile(
                        title: Text(skill),
                        trailing: _skillFilter == skill
                            ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                            : null,
                        onTap: () {
                          setState(() => _skillFilter = skill);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              if (skills.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No skills available',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _clearAllFilters() {
    setState(() {
      _userTypeFilter = 'all';
      _locationFilter = 'all';
      _skillFilter = 'all';
    });
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // Auto-Translation Language
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Auto-Translation Language'),
              subtitle: Text(
                'Currently: ${TranslationService.getLanguageName(_autoTranslateLanguage)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              onTap: _showLanguageSelector,
            ),
            // Notifications
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings')),
                );
              },
            ),
            // About
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'FixRight Messenger',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text(
                      'Professional marketplace messenger for domestic workers.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Auto-Translation Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            ...TranslationService.supportedLanguages.entries.map(
              (entry) => ListTile(
                title: Text(entry.value),
                trailing: _autoTranslateLanguage == entry.key
                    ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
                    : null,
                onTap: () {
                  setState(() => _autoTranslateLanguage = entry.key);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Pin'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Mute'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
