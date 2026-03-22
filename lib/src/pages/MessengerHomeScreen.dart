// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/chat_conversation_model.dart';
// import '../../services/chat_service.dart';
// import '../../services/translation_service.dart';
// import '../../services/auth_session_service.dart';
// import '../../services/user_session.dart';
// import 'ChatDetailScreen.dart';
// import 'CallsListScreen.dart';

// class MessengerHomeScreen extends StatefulWidget {
//   const MessengerHomeScreen({super.key});

//   @override
//   State<MessengerHomeScreen> createState() => _MessengerHomeScreenState();
// }

// class _MessengerHomeScreenState extends State<MessengerHomeScreen> {
//   final ChatService _chatService = ChatService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   late String _currentUserId;
//   String _searchQuery = '';
//   String _userTypeFilter = 'all'; // all, buyer, seller
//   String _locationFilter = 'all'; // all, nearest, sameCity
//   String _skillFilter = 'all';
//   String _autoTranslateLanguage = 'ur';
//   final bool _isDarkMode = false;

//   final _searchController = TextEditingController();

//   // Normalize phone input/email local-part to Firestore doc ID format: +<digits>
//   String _normalizePhoneForDoc(String raw) {
//     if (raw.isEmpty) return '';
//     // Extract digits only, then prefix with +
//     final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
//     if (digits.isEmpty) return '';
//     return '+$digits';
//   }

  
//   /// Try fetching a user document by trying several phone-id variants.
//   /// Returns the first existing document or null.
//   Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchUserDoc(
//     String phone,
//   ) async {
//     if (phone.isEmpty) return null;
//     final candidates = <String>{};

//     // normalized (should be '+digits')
//     final normalized = _normalizePhoneForDoc(phone);
//     if (normalized.isNotEmpty) candidates.add(normalized);

//     // digits only (no plus)
//     final digitsOnly = normalized.replaceAll('+', '');
//     if (digitsOnly.isNotEmpty) candidates.add(digitsOnly);

//     // leading zero variant (common in some datasets)
//     if (digitsOnly.startsWith('92')) {
//       candidates.add('0${digitsOnly.substring(2)}');
//     }

//     for (final id in candidates) {
//       try {
//         final doc = await _firestore.collection('users').doc(id).get();
//         if (doc.exists) return doc;
//       } catch (e) {
//         // ignore and try next
//       }
//     }
//     return null;
//   }
  
  
//   @override
//   void initState() {
//     super.initState();
//     // Use phone number as user ID (FixRight architecture)
//     // Resolve current user id (phone) using same strategy as contact actions
//     final cu = _auth.currentUser;
//     if (cu != null) {
//       if ((cu.phoneNumber ?? '').isNotEmpty) {
//         _currentUserId = cu.phoneNumber!;
//       } else if ((cu.email ?? '').contains(AuthSessionService.emailDomain)) {
//         _currentUserId = cu.email!.replaceAll(
//           AuthSessionService.emailDomain,
//           '',
//         );
//       } else if ((UserSession().phone ?? '').isNotEmpty) {
//         _currentUserId = UserSession().phone!;
//       } else {
//         _currentUserId = UserSession().uid ?? '';
//       }
//     } else {
//       _currentUserId = '';
//     }
//     // Normalize to Firestore doc ID format (+digits)
//     _currentUserId = _normalizePhoneForDoc(_currentUserId);
//     _loadUserPreferences();
//     _migrateConversationData();
//   }

//   void _migrateConversationData() async {
//     try {
//       // Run migration to fix any corrupted conversation data
//       await _chatService.migrateCorruptedConversations();
//     } catch (e) {
//       print('Error migrating conversations: $e');
//     }
//   }

//   void _loadUserPreferences() async {
//     try {
//       final doc = await _firestore
//           .collection('users')
//           .doc(_currentUserId)
//           .get();
//       if (doc.exists) {
//         setState(() {
//           _autoTranslateLanguage = doc['preferredLanguage'] ?? 'ur';
//         });
//       }
//     } catch (e) {
//       print('Error loading preferences: $e');
//     }
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
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Messenger',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2B7CD3),
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: _buildChatsTab(),
//     );
//   }

//   Widget _buildChatsTab() {
//     return Column(
//       children: [
//         // Search Bar
//         Text("Here is searh bar"),
//         _buildSearchBar(),

//         // Filter Chips
//         Text('Here are search results'),
//         _buildFilterSection(),

//         // Chats List or Search Results
//         Expanded(
//           child: _searchQuery.isNotEmpty
//               ? _buildSearchResults()
//               : _buildChatsList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//       color: _isDarkMode ? const Color(0xFF1a1a1a) : Colors.grey[100],
//       child: TextField(
//         controller: _searchController,
//         onChanged: (value) => setState(() => _searchQuery = value),
//         style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
//         decoration: InputDecoration(
//           hintText: 'Search contacts or messages...',
//           hintStyle: TextStyle(
//             color: _isDarkMode ? Colors.grey[600] : Colors.grey[600],
//           ),
//           prefixIcon: Icon(
//             Icons.search,
//             color: _isDarkMode ? Colors.grey[600] : Colors.grey[600],
//           ),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     _searchController.clear();
//                     setState(() => _searchQuery = '');
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(24),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 10,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Row(
//         children: [
//           // User Type Filter
//           _buildFilterChip(
//             label: _userTypeFilter == 'all'
//                 ? 'All'
//                 : _userTypeFilter == 'buyer'
//                 ? 'Buyers'
//                 : 'Sellers',
//             selected: true,
//             onTap: () => _showUserTypeFilter(),
//           ),

//           const SizedBox(width: 8),

//           // Location Filter
//           _buildFilterChip(
//             label: _locationFilter == 'all'
//                 ? 'Location'
//                 : _locationFilter == 'nearest'
//                 ? 'Nearest'
//                 : 'Same City',
//             onTap: () => _showLocationFilter(),
//           ),

//           const SizedBox(width: 8),

//           // Skills/Categories Filter
//           _buildFilterChip(
//             label: _skillFilter == 'all' ? 'Skills' : _skillFilter,
//             onTap: () => _showSkillsFilter(),
//           ),

//           const SizedBox(width: 8),

//           // Clear Filters Button
//           if (_userTypeFilter != 'all' ||
//               _locationFilter != 'all' ||
//               _skillFilter != 'all')
//             _buildFilterChip(
//               label: 'Clear',
//               backgroundColor: Colors.red[700],
//               onTap: _clearAllFilters,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip({
//     required String label,
//     bool selected = false,
//     Color? backgroundColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               backgroundColor ??
//               (selected
//                   ? const Color(0xFF2B7CD3)
//                   : (_isDarkMode ? Colors.grey[800] : Colors.grey[200])),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected
//                 ? const Color(0xFF2B7CD3)
//                 : (_isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: selected
//                     ? Colors.white
//                     : (_isDarkMode ? Colors.white : Colors.black87),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (selected || label == 'Clear') const SizedBox(width: 4),
//             if (selected || label == 'Clear')
//               Icon(
//                 selected ? Icons.expand_more : Icons.close,
//                 size: 16,
//                 color: selected ? Colors.white : Colors.red,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChatsList() {
//     return StreamBuilder<List<ChatConversation>>(
//       stream: _chatService.getUserConversations(),
//       builder: (context, snapshot) {
//         // Show error state
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Error loading conversations',
//                   style: TextStyle(fontSize: 16, color: Colors.red[400]),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   snapshot.error.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Show loading state
//         if (!snapshot.hasData) {
//           return Center(
//             child: CircularProgressIndicator(color: const Color(0xFF2B7CD3)),
//           );
//         }

//         var conversations = snapshot.data ?? [];

//         // Show empty state
//         if (conversations.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.mail_outline, size: 64, color: Colors.grey[600]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No messages yet',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start a conversation with a contact',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Show conversations list
//         return ListView.separated(
//           itemCount: conversations.length,
//           separatorBuilder: (context, index) => Divider(
//             color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
//             height: 1,
//           ),
//           itemBuilder: (context, index) {
//             return _buildConversationTile(conversations[index]);
//           },
//         );
//       },
//     );
//   }

//   /// Build search results with seller details
//   Widget _buildSearchResults() {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _chatService.searchUsersByName(_searchQuery),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(color: const Color(0xFF2B7CD3)),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No users found for "$_searchQuery"',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         final users = snapshot.data!;

//         return ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             return _buildSearchResultTile(users[index]);
//           },
//         );
//       },
//     );
//   }


//  // setuping the profile picture and ui of message 
//   /// Build individual search result tile with seller info
//   Widget _buildSearchResultTile(Map<String, dynamic> user) {
//     final fullName = user['fullName'] ?? 'Unknown';
//     final role = user['role'] ?? 'Unknown';
//     final profileImage = user['profileImage'];
//     final skills = (user['skills'] as List<dynamic>?)?.cast<String>() ?? [];
//     final rating = user['rating'] ?? 0.0;
//     final reviews = user['totalReviews'] ?? 0;
//     final city = user['city'] ?? 'Unknown City';
//     final bio = user['bio'] ?? '';
//     final userId = user['userId'] ?? '';

//     // Skip rendering if userId is empty (invalid user)
//     if (userId.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//           onTap: () async {
//         // Create or navigate to conversation
//         try {
//           final currentUser = _auth.currentUser;
//           if (currentUser == null) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Please login first')));
//             return;
//           }

//           // Resolve current user phone from multiple sources and normalize
//           String currentUserPhone = '';
//           if ((currentUser.phoneNumber ?? '').isNotEmpty) {
//             currentUserPhone = currentUser.phoneNumber!;
//           } else if ((currentUser.email ?? '').contains(
//             AuthSessionService.emailDomain,
//           )) {
//             currentUserPhone = currentUser.email!.replaceAll(
//               AuthSessionService.emailDomain,
//               '',
//             );
//           } else if ((UserSession().phone ?? '').isNotEmpty) {
//             currentUserPhone = UserSession().phone!;
//           } else if ((UserSession().uid ?? '').isNotEmpty) {
//             currentUserPhone = UserSession().uid!;
//           }
//           currentUserPhone = _normalizePhoneForDoc(currentUserPhone);
//           // Get phone from userId (which is doc.id - the phone number in Firestore schema)
//           final otherUserPhone = _normalizePhoneForDoc(user['userId'] ?? '');

//           if (currentUserPhone.isEmpty || otherUserPhone.isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Phone number not found  line 403 MessageHome'),
//               ),
//             );
//             return;
//           }

//           // Generate deterministic conversation ID
//           final phones = [currentUserPhone, otherUserPhone]..sort();
//           final conversationId = '${phones[0]}_${phones[1]}';

//           // Check if conversation exists, create if not
//           final convDoc = await _firestore
//               .collection('conversations')
//               .doc(conversationId)
//               .get();

//           if (!convDoc.exists) {
//             // Get current user's full profile (try multiple id variants)
//             final currentUserDoc = await _fetchUserDoc(currentUserPhone);

//             if (currentUserDoc == null || !currentUserDoc.exists) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Your profile not found')),
//               );
//               return;
//             }

//             final currentUserData =
//                 currentUserDoc.data() as Map<String, dynamic>;

//             // Create conversation in Firestore with complete data
//             await _firestore.collection('conversations').doc(conversationId).set({
//               'participantIds': [currentUserPhone, otherUserPhone],
//               'participantNames': {
//                 currentUserPhone:
//                     '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
//                         .trim(),
//                 otherUserPhone: fullName,
//               },
//               'participantRoles': {
//                 currentUserPhone: currentUserData['role'] ?? 'buyer',
//                 otherUserPhone: role,
//               },
//               'participantProfileImages': {
//                 currentUserPhone: currentUserData['profileImage'] ?? '',
//                 otherUserPhone: profileImage ?? '',
//               },
//               'lastMessage': '',
//               'lastMessageAt': Timestamp.now(),
//               'createdAt': Timestamp.now(),
//               'unreadCounts': {currentUserPhone: 0, otherUserPhone: 0},
//             });
//           }

//           // Navigate to chat screen with all necessary data
//           if (mounted) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(

//   //               const ChatDetailScreen({
//   //   super.key,
//   //   required this.convId,
//   //   required this.myUid,
//   //   required this.otherUid,
//   //   required this.otherName,
//   //   required this.otherImage,
//   //   required this.otherRole,
//   //   this.jobTitle = '',
//   // });
//                 builder: (_) => ChatDetailScreen(
//                   convId: conversationId,
//                   myUid: currentUserPhone,
//                   otherUid: otherUserPhone,
//                   otherName: fullName,
//                   otherImage: profileImage ?? '',
//                   otherRole: role,
//                 ),
//               ),
//             );
//           }
//         } catch (e) {
//           if (mounted) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//           }
//           print('Error starting conversation: $e');
//         }
//       },
//       child: Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // Avatar
//                 CircleAvatar(
//                   radius: 32,
//                   backgroundColor: const Color(0xFF2B7CD3),
//                   backgroundImage: profileImage != null
//                       ? NetworkImage(profileImage)
//                       : null,
//                   child: profileImage == null
//                       ? Text(
//                           fullName.isNotEmpty
//                               ? fullName.substring(0, 1).toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 // User Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Name and role
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               fullName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: _isDarkMode
//                                     ? Colors.white
//                                     : Colors.black87,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: role == 'Seller'
//                                   ? Colors.green[700]
//                                   : Colors.blue[700],
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               role,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       // Location
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             size: 12,
//                             color: Colors.grey[500],
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               city,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       // Rating and reviews (for sellers)
//                       if (role == 'Seller' && rating > 0)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.star,
//                                 size: 12,
//                                 color: Colors.amber[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '$rating ★ ($reviews reviews)',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       // Bio
//                       if (bio.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             bio,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.grey[500],
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             // Skills (if seller)
//             if (role == 'Seller' && skills.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Wrap(
//                   spacing: 6,
//                   children: skills
//                       .take(3)
//                       .map(
//                         (skill) => Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2B7CD3).withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: const Color(0xFF2B7CD3),
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Text(
//                             skill,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Color(0xFF2B7CD3),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             // Contact Button (visible action)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2B7CD3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                   onPressed: () async {
//                     // Contact button action - same as tap logic
//                     try {
//                       final currentUser = _auth.currentUser;
//                       if (currentUser == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please login first')),
//                         );
//                         return;
//                       }

//                       // Resolve phone number from multiple possible sources:
//                       // 1) FirebaseAuth.phoneNumber
//                       // 2) Email alias (local-part) created by AuthSessionService
//                       // 3) Fallback to cached UserSession values
//                       String currentUserPhone = '';

//                       if ((currentUser.phoneNumber ?? '').isNotEmpty) {
//                         currentUserPhone = currentUser.phoneNumber!;
//                       } else if ((currentUser.email ?? '').contains(
//                         AuthSessionService.emailDomain,
//                       )) {
//                         currentUserPhone = currentUser.email!.replaceAll(
//                           AuthSessionService.emailDomain,
//                           '',
//                         );
//                       } else if ((UserSession().phone ?? '').isNotEmpty) {
//                         currentUserPhone = UserSession().phone!;
//                       } else if ((UserSession().uid ?? '').isNotEmpty) {
//                         currentUserPhone = UserSession().uid!;
//                       }
//                       currentUserPhone = _normalizePhoneForDoc(
//                         currentUserPhone,
//                       );

//                       final otherUserPhone = _normalizePhoneForDoc(
//                         user['userId'] ?? '',
//                       );

//                       if (currentUserPhone.isEmpty || otherUserPhone.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Phone number not found. Please login or complete your profile.',
//                             ),
//                           ),
//                         );
//                         return;
//                       }

//                       final phones = [currentUserPhone, otherUserPhone]..sort();
//                       final conversationId = '${phones[0]}_${phones[1]}';

//                       final convDoc = await _firestore
//                           .collection('conversations')
//                           .doc(conversationId)
//                           .get();

//                       if (!convDoc.exists) {
//                         final currentUserDoc = await _fetchUserDoc(
//                           currentUserPhone,
//                         );

//                         if (currentUserDoc == null || !currentUserDoc.exists) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Your profile not found'),
//                             ),
//                           );
//                           return;
//                         }

//                         final currentUserData =
//                             currentUserDoc.data() as Map<String, dynamic>;

//                         await _firestore
//                             .collection('conversations')
//                             .doc(conversationId)
//                             .set({
//                               'participantIds': [
//                                 currentUserPhone,
//                                 otherUserPhone,
//                               ],
//                               'participantNames': {
//                                 currentUserPhone:
//                                     '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
//                                         .trim(),
//                                 otherUserPhone: fullName,
//                               },
//                               'participantRoles': {
//                                 currentUserPhone:
//                                     currentUserData['role'] ?? 'buyer',
//                                 otherUserPhone: role,
//                               },
//                               'participantProfileImages': {
//                                 currentUserPhone:
//                                     currentUserData['profileImage'] ?? '',
//                                 otherUserPhone: profileImage ?? '',
//                               },
//                               'lastMessage': '',
//                               'lastMessageAt': Timestamp.now(),
//                               'createdAt': Timestamp.now(),
//                               'unreadCounts': {
//                                 currentUserPhone: 0,
//                                 otherUserPhone: 0,
//                               },
//                             });
//                       }

//                       if (mounted) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ChatDetailScreen(
//                               convId: conversationId,
//                               myUid: currentUserPhone,
//                               otherUid: otherUserPhone,
//                               otherName: fullName,
//                               otherImage: profileImage ?? '',
//                               otherRole: role,
//                             ),
//                           ),
//                         );
//                       }
//                     } catch (e) {
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error: ${e.toString()}')),
//                         );
//                       }
//                       print('Error contacting user: $e');
//                     }
//                   },
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.mail_outline, size: 18),
//                       SizedBox(width: 8),
//                       Text(
//                         'Send Message is this ',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const Divider(),
//           ],
//         ),
//       ),
//     );
//   }

  
   
//   Widget _buildConversationTile(ChatConversation conversation) {
//     final otherId = conversation.getOtherParticipantId(_currentUserId);
//     final otherName = conversation.getOtherParticipantName(_currentUserId);
//     final otherImage = conversation.getOtherParticipantImage(_currentUserId);
//     final unreadCount = conversation.unreadCounts[_currentUserId] ?? 0;

//     // Skip rendering if otherId is empty (invalid conversation)
//     if (otherId.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//       onLongPress: () => _showConversationOptions(conversation),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ChatDetailScreen(
//               convId: conversation.id,
//               myUid: _currentUserId,
//               otherUid: otherId,
//               otherName: otherName ?? 'Unknown',
//               otherImage: otherImage ?? '',
//               otherRole: '',
//             ),
//           ),
//         );
//       },
//       child: Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: Row(
//           children: [
//             // Avatar with online indicator
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: const Color(0xFF2B7CD3),
//                   backgroundImage: otherImage != null
//                       ? NetworkImage(otherImage)
//                       : null,
//                   child: otherImage == null
//                       ? Text(
//                           otherName?.isNotEmpty == true
//                               ? otherName!.substring(0, 1).toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : null,
//                 ),
//                 // Online indicator - Removed FutureBuilder to avoid field errors
//                 // Note: Can be re-enabled once isOnline field is consistently added to all user docs
//                 const SizedBox.shrink(),
//               ],
//             ),
            
//             const SizedBox(width: 12),

//             // Message info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name and time
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           otherName ?? 'Ayaz Unknown',
//                           style: TextStyle(
//                             fontWeight: unreadCount > 0
//                                 ? FontWeight.bold
//                                 : FontWeight.w500,
//                             fontSize: 14,
//                             color: _isDarkMode ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         _formatChatTime(conversation.lastMessageAt),
//                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   // Last message preview
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           conversation.lastMessage,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: unreadCount > 0
//                                 ? (_isDarkMode ? Colors.white : Colors.black87)
//                                 : Colors.grey[500],
//                           ),
//                         ),
//                       ),
//                       if (unreadCount > 0)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2B7CD3),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             unreadCount > 99 ? '99+' : unreadCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatChatTime(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     final now = DateTime.now();
//     final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
//     final minute = date.minute.toString().padLeft(2, '0');
//     final ampm = date.hour < 12 ? 'AM' : 'PM';

//     if (date.day == now.day &&
//         date.month == now.month &&
//         date.year == now.year) {
//       // Today - 12-hour format with AM/PM (WhatsApp style)
//       return '$hour:$minute $ampm';
//     } else if (date.day == now.day - 1 &&
//         date.month == now.month &&
//         date.year == now.year) {
//       return 'Yesterday';
//     } else if (now.difference(date).inDays < 7) {
//       final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//       return days[date.weekday % 7];
//     } else {
//       return '${date.day}/${date.month}';
//     }
//   }

//   void _showUserTypeFilter() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Contact Type',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: _isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('All Contacts'),
//               trailing: _userTypeFilter == 'all'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _userTypeFilter = 'all');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Buyers Only'),
//               trailing: _userTypeFilter == 'buyer'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _userTypeFilter = 'buyer');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Sellers Only'),
//               trailing: _userTypeFilter == 'seller'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _userTypeFilter = 'seller');
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLocationFilter() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Location',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: _isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('All Locations'),
//               trailing: _locationFilter == 'all'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _locationFilter = 'all');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Same City'),
//               trailing: _locationFilter == 'sameCity'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _locationFilter = 'sameCity');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Nearest (10km)'),
//               subtitle: const Text('Based on your location'),
//               trailing: _locationFilter == 'nearest'
//                   ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                   : null,
//               onTap: () {
//                 setState(() => _locationFilter = 'nearest');
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSkillsFilter() {
//     // Fetch skills from Firebase
//     _chatService.fetchAllSkills().then((skills) {
//       if (!mounted) return;

//       showModalBottomSheet(
//         context: context,
//         builder: (context) => Container(
//           color: _isDarkMode ? Colors.black : Colors.white,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   'Skills / Services',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: _isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ),
//               ListTile(
//                 title: const Text('All Skills'),
//                 trailing: _skillFilter == 'all'
//                     ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                     : null,
//                 onTap: () {
//                   setState(() => _skillFilter = 'all');
//                   Navigator.pop(context);
//                 },
//               ),
//               if (skills.isNotEmpty) const Divider(),
//               if (skills.isNotEmpty)
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: skills.length,
//                     itemBuilder: (context, index) {
//                       final skill = skills[index];
//                       return ListTile(
//                         title: Text(skill),
//                         trailing: _skillFilter == skill
//                             ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                             : null,
//                         onTap: () {
//                           setState(() => _skillFilter = skill);
//                           Navigator.pop(context);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               if (skills.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     'No skills available',
//                     style: TextStyle(color: Colors.grey[500]),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   void _clearAllFilters() {
//     setState(() {
//       _userTypeFilter = 'all';
//       _locationFilter = 'all';
//       _skillFilter = 'all';
//     });
//   }

//   void _showSettingsMenu() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Settings',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: _isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             // Auto-Translation Language
//             ListTile(
//               leading: const Icon(Icons.translate),
//               title: const Text('Auto-Translation Language'),
//               subtitle: Text(
//                 'Currently: ${TranslationService.getLanguageName(_autoTranslateLanguage)}',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//               ),
//               onTap: _showLanguageSelector,
//             ),
//             // Notifications
//             ListTile(
//               leading: const Icon(Icons.notifications),
//               title: const Text('Notifications'),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: () {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Notification settings')),
//                 );
//               },
//             ),
//             // About
//             ListTile(
//               leading: const Icon(Icons.info),
//               title: const Text('About'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showAboutDialog(
//                   context: context,
//                   applicationName: 'FixRight Messenger',
//                   applicationVersion: '1.0.0',
//                   children: [
//                     const Text(
//                       'Professional marketplace messenger for domestic workers.',
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLanguageSelector() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Select Auto-Translation Language',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: _isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             ...TranslationService.supportedLanguages.entries.map(
//               (entry) => ListTile(
//                 title: Text(entry.value),
//                 trailing: _autoTranslateLanguage == entry.key
//                     ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                     : null,
//                 onTap: () {
//                   setState(() => _autoTranslateLanguage = entry.key);
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showConversationOptions(ChatConversation conversation) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: _isDarkMode ? Colors.black : Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.pin),
//               title: const Text('Pin'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.volume_off),
//               title: const Text('Mute'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.block),
//               title: const Text('Block'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete', style: TextStyle(color: Colors.red)),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_conversation_model.dart';
import '../../services/chat_service.dart';
import '../../services/auth_session_service.dart';
import '../../services/user_session.dart';
import 'ChatDetailScreen.dart';
import 'tts_translation_service.dart';
import 'notification_service.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════════
//  MESSENGER HOME SCREEN — Professional, no search/filter
//  ✅ Uses existing ChatService.getUserConversations()
//  ✅ Read/unread badge fully preserved
//  ✅ Long-press options (delete, block, mute)
//  ✅ Language button in app bar
// ═══════════════════════════════════════════════════════════════
class MessengerHomeScreen extends StatefulWidget {
  final String? phoneUID;
  const MessengerHomeScreen({super.key, this.phoneUID});

  @override
  State<MessengerHomeScreen> createState() => _MessengerHomeScreenState();
}

class _MessengerHomeScreenState extends State<MessengerHomeScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _currentUserId;

  String _normalizePhoneForDoc(String raw) {
    if (raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return '+$digits';
  }

  @override
  void initState() {
    super.initState();
    TtsTranslationService().init();

    // Resolve uid — same multi-source logic as original MessengerHomeScreen
    final cu = _auth.currentUser;
    String raw = '';
    if (cu != null) {
      if ((cu.phoneNumber ?? '').isNotEmpty) {
        raw = cu.phoneNumber!;
      } else if ((cu.email ?? '').contains(AuthSessionService.emailDomain)) {
        raw = cu.email!.replaceAll(AuthSessionService.emailDomain, '');
      } else if ((UserSession().phone ?? '').isNotEmpty) {
        raw = UserSession().phone!;
      } else {
        raw = UserSession().uid ?? '';
      }
    }
    if (raw.isEmpty) raw = widget.phoneUID ?? '';
    _currentUserId = _normalizePhoneForDoc(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: _currentUserId.isEmpty
          ? const _EmptyLoginState()
          : _buildConversationsList(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: const Text(
        'Messages',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        StreamBuilder<List<ChatConversation>>(
          stream: _chatService.getUserConversations(),
          builder: (ctx, snap) {
            // Total unread count badge on language button
            final totalUnread = (snap.data ?? []).fold<int>(
              0,
              (sum, c) => sum + ((c.unreadCounts[_currentUserId] ?? 0)),
            );
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(alignment: Alignment.topRight, children: [
                const GlobalLanguageButton(color: Color(0xFF00695C)),
                if (totalUnread > 0)
                  Positioned(
                    right: 2, top: 2,
                    child: Container(
                      width: 15, height: 15,
                      decoration: const BoxDecoration(
                          color: Color(0xFF00695C), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          totalUnread > 9 ? '9+' : '$totalUnread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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

  // ── Conversations List (uses ChatService — same as original) ─
  Widget _buildConversationsList() {
    return StreamBuilder<List<ChatConversation>>(
      stream: _chatService.getUserConversations(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00695C), strokeWidth: 2));
        }
        if (snap.hasError) {
          return _ErrorState(error: snap.error.toString());
        }
        final convs = snap.data ?? [];
        if (convs.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: convs.length,
          itemBuilder: (ctx, i) => _ConversationTile(
            conversation: convs[i],
            myUid: _currentUserId,
            onLongPress: () => _showConversationOptions(convs[i]),
            onTap: () => _openChat(convs[i]),
          ),
        );
      },
    );
  }

  // ── Navigation to ChatDetailScreen ───────────────────────────
  void _openChat(ChatConversation conversation) {
    final otherId   = conversation.getOtherParticipantId(_currentUserId);
    final otherName = conversation.getOtherParticipantName(_currentUserId) ?? 'Unknown';
    final otherImg  = conversation.getOtherParticipantImage(_currentUserId) ?? '';
    final roles     = conversation.participantRoles ?? {};
    final otherRole = roles[otherId] ?? '';
    final jobTitle  = '';

    if (otherId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          convId: conversation.id,
          myUid: _currentUserId,
          otherUid: otherId,
          otherName: otherName,
          otherImage: otherImg,
          otherRole: otherRole,
          jobTitle: jobTitle,
        ),
      ),
    );
  }

  // ── Long-press options ───────────────────────────────────────
  void _showConversationOptions(ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          ListTile(leading: const Icon(Icons.volume_off_outlined), title: const Text('Mute'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.block_outlined, color: Colors.orange), title: const Text('Block'), onTap: () { Navigator.pop(context); _chatService.blockUser(conversationId: conversation.id, blockUserId: conversation.getOtherParticipantId(_currentUserId)); }),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Conversation', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Delete Conversation?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () { Navigator.pop(context); _firestore.collection('conversations').doc(conversation.id).delete(); },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Conversation Tile ─────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String myUid;
  final VoidCallback onTap, onLongPress;
  const _ConversationTile({
    required this.conversation,
    required this.myUid,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherId   = conversation.getOtherParticipantId(myUid);
    final otherName = conversation.getOtherParticipantName(myUid) ?? 'Unknown';
    final otherImg  = conversation.getOtherParticipantImage(myUid) ?? '';
    final roles     = conversation.participantRoles ?? {};
    final otherRole = roles[otherId] ?? '';
    // ✅ Unread from ChatConversation model — same as original
    final unread    = (conversation.unreadCounts[myUid] ?? 0);
    final hasUnread = unread > 0;
    final lastMsg   = conversation.lastMessage;
    final lastAt    = conversation.lastMessageAt;
    final jobTitle  = '';

    if (otherId.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Avatar + role badge
            Stack(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
                backgroundImage: otherImg.isNotEmpty ? NetworkImage(otherImg) : null,
                child: otherImg.isEmpty
                    ? Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    : null,
              ),
              if (otherRole.isNotEmpty)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: otherRole == 'seller' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      otherRole == 'seller' ? Icons.build_rounded : Icons.person_rounded,
                      size: 9, color: Colors.white,
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 12),
            // Text content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(otherName,
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 15.5, color: Colors.black87,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(
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
                  lastMsg.isNotEmpty
                      ? lastMsg
                      : (jobTitle.isNotEmpty ? '📋 $jobTitle' : 'Start a conversation…'),
                  style: TextStyle(
                    fontSize: 13,
                    color: hasUnread ? Colors.black87 : Colors.grey[500],
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
                // ✅ Unread count badge — same logic as original
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 20, height: 20,
                    decoration: const BoxDecoration(
                        color: Color(0xFF00695C), shape: BoxShape.circle),
                    child: Center(child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    )),
                  ),
              ]),
              if (jobTitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.work_outline_rounded, size: 11, color: Colors.grey[400]),
                  const SizedBox(width: 4),
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
    );
  }

  String _formatTime(Timestamp ts) {
    final dt  = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM/yy').format(dt);
  }
}

// ── States ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
            color: const Color(0xFF00695C).withOpacity(0.07), shape: BoxShape.circle),
        child: const Icon(Icons.chat_bubble_outline_rounded, size: 38, color: Color(0xFF00695C)),
      ),
      const SizedBox(height: 20),
      const Text('No conversations yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
      const SizedBox(height: 8),
      Text('When you place an order or bid on a job,\nyour conversations will appear here.',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]), textAlign: TextAlign.center),
    ]),
  );
}

class _EmptyLoginState extends StatelessWidget {
  const _EmptyLoginState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Please log in to view messages',
        style: TextStyle(fontSize: 15, color: Colors.grey)),
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
      const Text('Could not load messages',
          style: TextStyle(fontSize: 15, color: Colors.black54)),
    ]),
  );
}
