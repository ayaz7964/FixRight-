// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../models/enhanced_message_model.dart';
// import '../models/user_model.dart';
// import '../../services/chat_service.dart';
// import '../../services/translation_service.dart';
// import '../../services/user_presence_service.dart';
// import '../../services/auth_session_service.dart';
// import '../../services/user_session.dart' as user_session;

// class ChatDetailScreen extends StatefulWidget {
//   final String conversationId;
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserImage;

//   const ChatDetailScreen({
//     super.key,
//     required this.conversationId,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserImage,
//   });

//   @override
//   State<ChatDetailScreen> createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<ChatDetailScreen> {
//   final ChatService _chatService = ChatService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final UserPresenceService _presenceService = UserPresenceService();

//   late String _currentUserId;
//   late UserModel _currentUser;
//   final _messageController = TextEditingController();
//   bool _isTyping = false;
//   String _selectedLanguage = 'en';
//   final ScrollController _scrollController = ScrollController();

//   String _normalizePhoneForDoc(String raw) {
//     if (raw.isEmpty) return '';
//     final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
//     if (digits.isEmpty) return '';
//     return '+$digits';
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Resolve current user phone from FirebaseAuth / email-alias / UserSession
//     final cu = _auth.currentUser;
//     String phone = '';
//     if (cu != null) {
//       if ((cu.phoneNumber ?? '').isNotEmpty) {
//         phone = cu.phoneNumber!;
//       } else if ((cu.email ?? '').contains(AuthSessionService.emailDomain)) {
//         phone = cu.email!.replaceAll(AuthSessionService.emailDomain, '');
//       } else if ((user_session.UserSession().phone ?? '').isNotEmpty) {
//         phone = user_session.UserSession().phone!;
//       } else {
//         phone = user_session.UserSession().uid ?? '';
//       }
//     }
//     _currentUserId = _normalizePhoneForDoc(phone);
//     _loadCurrentUser();

//     // Mark all unread messages as read when chat is opened
//     _chatService.markMessagesAsRead(widget.conversationId);
//   }

//   void _loadCurrentUser() async {
//     try {
//       // Look up user profile using phone number as document ID
//       final userDoc = await _firestore
//           .collection('users')
//           .doc(_currentUserId)
//           .get();

//       if (!userDoc.exists) {
//         print('User profile not found for phone: $_currentUserId');
//         return;
//       }

//       final data = userDoc.data() as Map<String, dynamic>;
//       final firstName = data['firstName'] ?? '';
//       final lastName = data['lastName'] ?? '';

//       setState(() {
//         _currentUser = UserModel(
//           uid: _currentUserId,
//           phoneNumber: _currentUserId,
//           firstName: firstName,
//           lastName: lastName,
//           profileImageUrl: data['profileImageUrl'],
//           role: data['role'] ?? 'buyer',
//           preferredLanguage: data['preferredLanguage'] ?? 'en',
//           bio: data['bio'],
//           rating: (data['rating'] as num?)?.toDouble(),
//           totalReviews: data['totalReviews'] ?? 0,
//           isOnline: data['isOnline'] ?? false,
//           status: data['status'],
//         );
//         _selectedLanguage = _currentUser.preferredLanguage ?? 'en';
//       });
//     } catch (e) {
//       print('Error loading current user: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _chatService.sendTypingIndicator(
//       conversationId: widget.conversationId,
//       userId: _currentUserId,
//       isTyping: false,
//     );
//     super.dispose();
//   }

//   /// Format timestamp to 12-hour format with AM/PM (WhatsApp style)
//   String _formatMessageTime(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
//     final minute = date.minute.toString().padLeft(2, '0');
//     final ampm = date.hour < 12 ? 'AM' : 'PM';
//     return '$hour:$minute $ampm';
//   }

//   /// Save language preference to Firestore
//   Future<void> _saveLanguagePreference(String languageCode) async {
//     try {
//       await _firestore.collection('users').doc(_currentUserId).update({
//         'preferredLanguage': languageCode,
//       });
//       print('Language preference saved: $languageCode');
//     } catch (e) {
//       print('Error saving language preference: $e');
//     }
//   }

//   /// Show translation language selector modal
//   void _showTranslationLanguageSelector() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.6,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Select Auto-Translation Language',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   children: TranslationService.supportedLanguages.entries.map((
//                     entry,
//                   ) {
//                     final isSelected = _selectedLanguage == entry.key;
//                     return ListTile(
//                       title: Text(entry.value),
//                       trailing: isSelected
//                           ? const Icon(Icons.check, color: Color(0xFF2B7CD3))
//                           : null,
//                       onTap: () {
//                         setState(() => _selectedLanguage = entry.key);
//                         _saveLanguagePreference(entry.key);
//                         Navigator.pop(context);
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           // Messages list
//           Expanded(
//             child: StreamBuilder<List<MessageModel>>(
//               stream: _chatService.getMessages(widget.conversationId),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data ?? [];
//                 if (messages.isEmpty) {
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
//                           'No messages yet. Start the conversation!',
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
//                   reverse: true,
//                   controller: _scrollController,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     return _buildMessageBubble(context, message);
//                   },
//                 );
//               },
//             ),
//           ),

//           // Typing indicator
//           StreamBuilder<List<String>>(
//             stream: _chatService.getTypingIndicators(widget.conversationId),
//             builder: (context, snapshot) {
//               final typingUsers = snapshot.data ?? [];
//               final isOtherTyping = typingUsers.contains(widget.otherUserId);

//               if (!isOtherTyping) {
//                 return const SizedBox.shrink();
//               }

//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     Text(
//                       '${widget.otherUserName} is typing',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 20,
//                       height: 10,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildTypingDot(0),
//                           _buildTypingDot(1),
//                           _buildTypingDot(2),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           // Language selector and input
//           _buildInputArea(),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.otherUserName),
//           // Real-time presence status using UserPresenceService
//           StreamBuilder<String>(
//             stream: _presenceService.getUserStatusStream(widget.otherUserId),
//             builder: (context, snapshot) {
//               final status = snapshot.data ?? 'Offline';
//               final isOnline = status == 'Online';

//               return Text(
//                 status,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isOnline ? Colors.green : Colors.grey,
//                   fontWeight: FontWeight.normal,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       actions: [
//         // Direct phone call button - uses device phone app
//         IconButton(
//           icon: const Icon(Icons.call),
//           tooltip: 'Call ${widget.otherUserName}',
//           onPressed: () => _makePhoneCall(widget.otherUserId),
//         ),
//         // Chat info button
//         IconButton(
//           icon: const Icon(Icons.info_outline),
//           tooltip: 'Chat info',
//           onPressed: () => _showUserInfo(),
//         ),
//       ],
//     );
//   }

//   /// Make a direct phone call using the system phone dialer
//   /// The phoneNumber should be the user's phone number (UID format: +923XXXXXXXXX)
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     // Sanitize phone number: remove spaces, dashes, and parentheses
//     final sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-()]+'), '');

//     // Ensure the number is in proper international format
//     // If it starts with 0, convert to +92 (Pakistan example - adjust for your region)
//     final formattedNumber = sanitizedNumber.startsWith('0')
//         ? '+92${sanitizedNumber.substring(1)}'
//         : sanitizedNumber;

//     // Create tel URI
//     final Uri launchUri = Uri(scheme: 'tel', path: formattedNumber);

//     try {
//       // Check if the tel scheme can be launched
//       if (await canLaunchUrl(launchUri)) {
//         // Launch with externalApplication mode to open system phone app
//         await launchUrl(launchUri, mode: LaunchMode.externalApplication);
//       } else {
//         // Phone calling not supported on this device
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Phone calling not supported. Number: $formattedNumber',
//               ),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       // Log error for debugging
//       print('Error making phone call to $formattedNumber: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Call failed: ${e.toString()}'),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildMessageBubble(BuildContext context, MessageModel message) {
//     final isSentByMe = message.senderId == _currentUserId;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: Row(
//         mainAxisAlignment: isSentByMe
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           if (!isSentByMe) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: message.senderProfileImage != null
//                   ? NetworkImage(message.senderProfileImage!)
//                   : null,
//               child: message.senderProfileImage == null
//                   ? Text(message.senderName[0])
//                   : null,
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: GestureDetector(
//               onLongPress: () => _showMessageOptions(context, message),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: isSentByMe
//                       ? const Color(0xFF2B7CD3)
//                       : Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Original message
//                     Text(
//                       message.originalText,
//                       style: TextStyle(
//                         color: isSentByMe ? Colors.white : Colors.black87,
//                         fontSize: 14,
//                       ),
//                     ),

//                     // Translated message if available
//                     if (message.translationsByLanguage != null &&
//                         message.translationsByLanguage!.containsKey(
//                           _selectedLanguage,
//                         ) &&
//                         _selectedLanguage != message.originalLanguage)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 6),
//                         child: Text(
//                           message.translationsByLanguage![_selectedLanguage]!,
//                           style: TextStyle(
//                             color: isSentByMe ? Colors.white70 : Colors.black54,
//                             fontSize: 12,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),

//                     // Message info
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             _formatMessageTime(message.timestamp),
//                             style: TextStyle(
//                               color: isSentByMe
//                                   ? Colors.white70
//                                   : Colors.grey[600],
//                               fontSize: 11,
//                             ),
//                           ),
//                           if (isSentByMe) ...[
//                             const SizedBox(width: 4),
//                             // Show read indicator for sent messages
//                             // Use isRead flag for WhatsApp-like read receipts
//                             Icon(
//                               message.isRead
//                                   ? Icons
//                                         .done_all // Double check = message read
//                                   : Icons
//                                         .done_all, // Double check = message delivered
//                               size: 14,
//                               color: message.isRead
//                                   ? Colors
//                                         .lightBlue // Blue when read
//                                   : Colors.white70, // Gray when only delivered
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),

//                     if (message.isEdited)
//                       Text(
//                         'edited',
//                         style: TextStyle(
//                           color: isSentByMe ? Colors.white70 : Colors.grey[600],
//                           fontSize: 10,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByMe) const SizedBox(width: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputArea() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey[300]!)),
//       ),
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           // Auto-Translation Language Selector - moved to settings menu
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Row(
//               children: [
//                 Text(
//                   'Auto-Translate to: ',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(width: 4),
//                 InkWell(
//                   onTap: _showTranslationLanguageSelector,
//                   child: Chip(
//                     label: Text(
//                       TranslationService
//                               .supportedLanguages[_selectedLanguage] ??
//                           'English',
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     avatar: const Icon(Icons.translate, size: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Message input
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.emoji_emotions_outlined),
//                   onPressed: () {
//                     // TODO: Implement emoji picker
//                   },
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                     ),
//                     maxLines: null,
//                     onChanged: (value) {
//                       if (value.isEmpty && _isTyping) {
//                         _chatService.sendTypingIndicator(
//                           conversationId: widget.conversationId,
//                           userId: _currentUserId,
//                           isTyping: false,
//                         );
//                         setState(() => _isTyping = false);
//                       } else if (value.isNotEmpty && !_isTyping) {
//                         _chatService.sendTypingIndicator(
//                           conversationId: widget.conversationId,
//                           userId: _currentUserId,
//                           isTyping: true,
//                         );
//                         setState(() => _isTyping = true);
//                       }
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   color: const Color(0xFF2B7CD3),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     if (_messageController.text.isEmpty) return;

//     final text = _messageController.text;
//     _messageController.clear();

//     _chatService.sendTypingIndicator(
//       conversationId: widget.conversationId,
//       userId: _currentUserId,
//       isTyping: false,
//     );
//     setState(() => _isTyping = false);

//     _chatService.sendMessage(
//       conversationId: widget.conversationId,
//       text: text,
//       userId: _currentUserId,
//       senderName: _currentUser.fullName,
//       senderProfileImage: _currentUser.profileImageUrl,
//       sourceLanguage: null, // Auto-detect message language
//     );

//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   void _showMessageOptions(BuildContext context, MessageModel message) {
//     final isSentByMe = message.senderId == _currentUserId;

//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.copy),
//               title: const Text('Copy'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Implement copy to clipboard
//               },
//             ),
//             if (_selectedLanguage != message.originalLanguage)
//               ListTile(
//                 leading: const Icon(Icons.translate),
//                 title: Text('Translate'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _translateMessage(message);
//                 },
//               ),
//             if (isSentByMe)
//               ListTile(
//                 leading: const Icon(Icons.edit),
//                 title: const Text('Edit'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _editMessage(message);
//                 },
//               ),
//             if (isSentByMe)
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.red),
//                 title: const Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _deleteMessage(message);
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _translateMessage(MessageModel message) {
//     _chatService.translateMessage(
//       messageId: message.id,
//       conversationId: widget.conversationId,
//       text: message.originalText,
//       targetLanguage: _selectedLanguage,
//       sourceLanguage: message.originalLanguage,
//     );
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Translating message...')));
//   }

//   void _editMessage(MessageModel message) {
//     final editController = TextEditingController(text: message.originalText);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Message'),
//         content: TextField(
//           controller: editController,
//           autofocus: true,
//           maxLines: null,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _chatService.editMessage(
//                 conversationId: widget.conversationId,
//                 messageId: message.id,
//                 newText: editController.text,
//               );
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text('Message edited')));
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deleteMessage(MessageModel message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Message?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _chatService.deleteMessage(
//                 conversationId: widget.conversationId,
//                 messageId: message.id,
//               );
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text('Message deleted')));
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showUserInfo() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('User Info'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: FutureBuilder<DocumentSnapshot>(
//             future: _firestore
//                 .collection('users')
//                 .doc(widget.otherUserId)
//                 .get(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const CircularProgressIndicator();
//               }

//               if (!snapshot.data!.exists) {
//                 return const Text('User not found');
//               }

//               final data = snapshot.data!.data() as Map<String, dynamic>;
//               final firstName = data['firstName'] ?? '';
//               final lastName = data['lastName'] ?? '';

//               final user = UserModel(
//                 uid: widget.otherUserId,
//                 phoneNumber: widget.otherUserId,
//                 firstName: firstName,
//                 lastName: lastName,
//                 profileImageUrl: data['profileImageUrl'],
//                 role: data['role'] ?? 'buyer',
//                 preferredLanguage: data['preferredLanguage'] ?? 'en',
//                 bio: data['bio'],
//                 rating: (data['rating'] as num?)?.toDouble(),
//                 totalReviews: data['totalReviews'] ?? 0,
//               );

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (user.profileImageUrl != null)
//                     Center(
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundImage: NetworkImage(user.profileImageUrl!),
//                       ),
//                     ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Name: ${user.fullName}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text('Phone: ${user.phoneNumber}'),
//                   Text('Role: ${user.role.toUpperCase()}'),
//                   if (user.rating != null && user.rating! > 0)
//                     Text(
//                       'Rating: ${user.rating} ★ (${user.totalReviews} reviews)',
//                     ),
//                   if (user.bio != null && (user.bio as String).isNotEmpty)
//                     Text('Bio: ${user.bio}'),
//                   Text(
//                     'Preferred Language: ${TranslationService.getLanguageName(user.preferredLanguage ?? 'en')}',
//                   ),
//                 ],
//               );
//             },
//           ),
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

//   Widget _buildTypingDot(int index) {
//     return Container(
//       width: 8,
//       height: 8,
//       decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
//     );
//   }
// }



// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';
// import 'tts_translation_service.dart';   // ✅ TranslatedText, SpeakButton, GlobalLanguageButton

// // ═══════════════════════════════════════════════════════════════
// //  CHAT DETAIL SCREEN
// //
// //  ✅ Per-message listen button (SpeakButton from TtsTranslationService)
// //  ✅ Per-message translate toggle (TranslatedText from TtsTranslationService)
// //  ✅ NO Claude API auto-translation (removed)
// //  ✅ Professional WhatsApp-style bubble UI
// //  ✅ Real-time messages via Firestore stream
// //  ✅ Marks unread as read on open
// // ═══════════════════════════════════════════════════════════════
// class ChatDetailScreen extends StatefulWidget {
//   final String convId, myUid, otherUid, otherName, otherImage, otherRole, jobTitle;
//   const ChatDetailScreen({
//     super.key,
//     required this.convId,
//     required this.myUid,
//     required this.otherUid,
//     required this.otherName,
//     required this.otherImage,
//     required this.otherRole,
//     this.jobTitle = '',
//   });
//   @override
//   State<ChatDetailScreen> createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<ChatDetailScreen> {
//   final _msgCtrl    = TextEditingController();
//   final _scrollCtrl = ScrollController();
//   bool _sending     = false;

//   @override
//   void initState() {
//     super.initState();
//     TtsTranslationService().init();
//     _markRead();
//   }

//   @override
//   void dispose() {
//     _msgCtrl.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _markRead() async {
//     await FirebaseFirestore.instance.collection('conversations').doc(widget.convId).update({
//       'unreadCounts.${widget.myUid}': 0,
//     });
//   }

//   Future<void> _sendMessage() async {
//     final text = _msgCtrl.text.trim();
//     if (text.isEmpty) return;
//     _msgCtrl.clear();
//     setState(() => _sending = true);
//     try {
//       final db  = FirebaseFirestore.instance;
//       final now = Timestamp.now();
//       final msgRef = db.collection('conversations').doc(widget.convId).collection('messages').doc();
//       await msgRef.set({
//         'senderId': widget.myUid,
//         'text': text,
//         'createdAt': now,
//         'isRead': false,
//       });
//       await db.collection('conversations').doc(widget.convId).update({
//         'lastMessage': text,
//         'lastMessageAt': now,
//         'unreadCounts.${widget.otherUid}': FieldValue.increment(1),
//         'unreadCounts.${widget.myUid}': 0,
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       });
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Send failed: $e'), backgroundColor: Colors.red));
//     } finally { if (mounted) setState(() => _sending = false); }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5),
//       appBar: _buildAppBar(),
//       body: Column(children: [
//         if (widget.jobTitle.isNotEmpty) _JobBanner(jobTitle: widget.jobTitle),
//         Expanded(child: _MessagesList(convId: widget.convId, myUid: widget.myUid, scrollCtrl: _scrollCtrl)),
//         _InputBar(ctrl: _msgCtrl, sending: _sending, onSend: _sendMessage),
//       ]),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
//         onPressed: () => Navigator.pop(context),
//       ),
//       titleSpacing: 0,
//       title: Row(children: [
//         CircleAvatar(
//           radius: 20,
//           backgroundColor: const Color(0xFF00695C).withOpacity(0.12),
//           backgroundImage: widget.otherImage.isNotEmpty ? NetworkImage(widget.otherImage) : null,
//           child: widget.otherImage.isEmpty ? Text(
//             widget.otherName.isNotEmpty ? widget.otherName[0].toUpperCase() : '?',
//             style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 16),
//           ) : null,
//         ),
//         const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(widget.otherName,
//             style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.black87),
//             maxLines: 1, overflow: TextOverflow.ellipsis),
//           Text(
//             widget.otherRole == 'seller' ? '🔧 Worker' : '👤 Client',
//             style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
//           ),
//         ])),
//       ]),
//       actions: const [
//         Padding(padding: EdgeInsets.only(right: 12), child: GlobalLanguageButton(color: Color(0xFF00695C))),
//       ],
//       bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade100)),
//     );
//   }
// }

// // ── Job banner ────────────────────────────────────────────────
// class _JobBanner extends StatelessWidget {
//   final String jobTitle;
//   const _JobBanner({required this.jobTitle});
//   @override
//   Widget build(BuildContext context) => Container(
//     color: Colors.white,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Row(children: [
//       Icon(Icons.work_outline_rounded, size: 14, color: Colors.grey[500]),
//       const SizedBox(width: 8),
//       Expanded(child: Text(jobTitle,
//         style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
//         maxLines: 1, overflow: TextOverflow.ellipsis)),
//     ]),
//   );
// }

// // ── Messages List ─────────────────────────────────────────────
// class _MessagesList extends StatelessWidget {
//   final String convId, myUid;
//   final ScrollController scrollCtrl;
//   const _MessagesList({required this.convId, required this.myUid, required this.scrollCtrl});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('conversations')
//           .doc(convId)
//           .collection('messages')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (ctx, snap) {
//         if (snap.connectionState == ConnectionState.waiting)
//           return const Center(child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2));
//         final docs = snap.data?.docs ?? [];
//         if (docs.isEmpty) return const _NoMessages();
//         return ListView.builder(
//           controller: scrollCtrl,
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           itemCount: docs.length,
//           itemBuilder: (ctx, i) {
//             final curr = docs[i].data() as Map<String, dynamic>;
//             final prev = i < docs.length - 1 ? docs[i + 1].data() as Map<String, dynamic> : null;
//             final next = i > 0 ? docs[i - 1].data() as Map<String, dynamic> : null;
//             final isMe = curr['senderId'] == myUid;

//             // Date separator
//             bool showDate = false;
//             if (prev != null) {
//               final currDate = (curr['createdAt'] as Timestamp?)?.toDate();
//               final prevDate = (prev['createdAt'] as Timestamp?)?.toDate();
//               if (currDate != null && prevDate != null)
//                 showDate = !_sameDay(currDate, prevDate);
//             } else { showDate = true; }

//             final isFirstInGroup = prev == null || (prev['senderId'] != curr['senderId']) || showDate;
//             final isLastInGroup  = next == null || next['senderId'] != curr['senderId'];

//             return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//               if (showDate) _DateSeparator(ts: curr['createdAt'] as Timestamp?),
//               _MessageBubble(
//                 data: curr, msgId: docs[i].id,
//                 isMe: isMe, isFirst: isFirstInGroup, isLast: isLastInGroup,
//                 convId: convId,
//               ),
//             ]);
//           },
//         );
//       },
//     );
//   }

//   bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
// }

// class _NoMessages extends StatelessWidget {
//   const _NoMessages();
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//       Icon(Icons.waving_hand_outlined, size: 48, color: Colors.grey[300]),
//       const SizedBox(height: 12),
//       Text('Say hello!', style: TextStyle(fontSize: 16, color: Colors.grey[400], fontWeight: FontWeight.w600)),
//       const SizedBox(height: 6),
//       Text('Messages are end-to-end readable\nand translatable in any language.', style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
//     ]),
//   );
// }

// // ── Date Separator ────────────────────────────────────────────
// class _DateSeparator extends StatelessWidget {
//   final Timestamp? ts;
//   const _DateSeparator({this.ts});
//   @override
//   Widget build(BuildContext context) {
//     if (ts == null) return const SizedBox();
//     final dt  = ts!.toDate();
//     final now = DateTime.now();
//     String label;
//     if (_sameDay(dt, now)) label = 'Today';
//     else if (_sameDay(dt, now.subtract(const Duration(days: 1)))) label = 'Yesterday';
//     else label = DateFormat('MMMM d, yyyy').format(dt);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(children: [
//         Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
//         Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey[500], fontWeight: FontWeight.w600))),
//         Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
//       ]),
//     );
//   }
//   bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
// }

// // ── Message Bubble ────────────────────────────────────────────
// class _MessageBubble extends StatefulWidget {
//   final Map<String, dynamic> data;
//   final String msgId, convId;
//   final bool isMe, isFirst, isLast;
//   const _MessageBubble({required this.data, required this.msgId, required this.convId, required this.isMe, required this.isFirst, required this.isLast});
//   @override
//   State<_MessageBubble> createState() => _MessageBubbleState();
// }

// class _MessageBubbleState extends State<_MessageBubble> {
//   // ✅ Toggle translation inline (same as TranslatedText but for chat bubble)
//   bool _showTranslation = false;

//   @override
//   Widget build(BuildContext context) {
//     final text   = widget.data['text'] as String? ?? '';
//     final ts     = widget.data['createdAt'] as Timestamp?;
//     final timeStr = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '';
//     final isMe   = widget.isMe;

//     // Bubble shape
//     final radius = BorderRadius.only(
//       topLeft:     Radius.circular(isMe || !widget.isFirst ? 18 : 4),
//       topRight:    Radius.circular(!isMe || !widget.isFirst ? 18 : 4),
//       bottomLeft:  Radius.circular(isMe || !widget.isLast ? 18 : 4),
//       bottomRight: Radius.circular(!isMe || !widget.isLast ? 18 : 4),
//     );

//     return Padding(
//       padding: EdgeInsets.only(
//         top:    widget.isFirst ? 4 : 1.5,
//         bottom: widget.isLast  ? 4 : 1.5,
//         left:   isMe ? 60 : 0,
//         right:  isMe ? 0 : 60,
//       ),
//       child: Row(
//         mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // ✅ Listen + Translate buttons for OTHER person's messages
//           if (!isMe) _MsgActions(text: text, msgId: widget.msgId, showTranslation: _showTranslation, onToggleTranslate: () => setState(() => _showTranslation = !_showTranslation)),
          
//           // Bubble
//           Flexible(child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
//             decoration: BoxDecoration(
//               color: isMe ? const Color(0xFF00695C) : Colors.white,
//               borderRadius: radius,
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
//             ),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               // Main message text
//               Text(text, style: TextStyle(
//                 fontSize: 14.5, color: isMe ? Colors.white : Colors.black87, height: 1.4,
//               )),

//               // ✅ Translation shown inline below message (for received messages)
//               if (!isMe && _showTranslation) ...[
//                 const SizedBox(height: 6),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: TranslatedText(
//                     text: text,
//                     contentId: 'msg_${widget.msgId}',
//                     style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
//                     showListenButton: false,
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 3),
//               // Timestamp + read tick
//               Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
//                 Text(timeStr, style: TextStyle(fontSize: 10.5, color: isMe ? Colors.white.withOpacity(0.65) : Colors.grey[400])),
//                 if (isMe) ...[
//                   const SizedBox(width: 3),
//                   Icon(widget.data['isRead'] == true ? Icons.done_all_rounded : Icons.done_rounded,
//                     size: 13, color: widget.data['isRead'] == true ? Colors.blue[200] : Colors.white.withOpacity(0.5)),
//                 ],
//               ]),
//             ]),
//           )),

//           // ✅ Listen + Translate buttons for MY OWN messages
//           if (isMe) _MsgActions(text: text, msgId: widget.msgId, showTranslation: _showTranslation, onToggleTranslate: () => setState(() => _showTranslation = !_showTranslation), isMe: true),
//         ],
//       ),
//     );
//   }
// }

// // ── Message Action Buttons (Listen + Translate) ───────────────
// // ✅ Uses existing TtsTranslationService — same as order descriptions
// class _MsgActions extends StatelessWidget {
//   final String text, msgId;
//   final bool showTranslation;
//   final bool isMe;
//   final VoidCallback onToggleTranslate;
//   const _MsgActions({required this.text, required this.msgId, required this.showTranslation, required this.onToggleTranslate, this.isMe = false});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(left: isMe ? 0 : 4, right: isMe ? 4 : 0, bottom: 4),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         // 🔊 Listen button — speaks the message aloud
//         SpeakButton(text: text, contentId: 'msg_$msgId'),
//         const SizedBox(height: 4),
//         // 🌐 Translate button — shows translation below message
//         GestureDetector(
//           onTap: onToggleTranslate,
//           child: Container(
//             width: 28, height: 28,
//             decoration: BoxDecoration(
//               color: showTranslation ? const Color(0xFF00695C).withOpacity(0.12) : Colors.grey.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.translate_rounded, size: 14,
//               color: showTranslation ? const Color(0xFF00695C) : Colors.grey[400]),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ── Input Bar ─────────────────────────────────────────────────
// class _InputBar extends StatelessWidget {
//   final TextEditingController ctrl;
//   final bool sending;
//   final VoidCallback onSend;
//   const _InputBar({required this.ctrl, required this.sending, required this.onSend});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.only(
//         left: 12, right: 12,
//         top: 10,
//         bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 10,
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
//         // Text field
//         Expanded(child: Container(
//           constraints: const BoxConstraints(maxHeight: 120),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF5F6F8),
//             borderRadius: BorderRadius.circular(26),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: TextField(
//             controller: ctrl,
//             maxLines: null,
//             textCapitalization: TextCapitalization.sentences,
//             style: const TextStyle(fontSize: 15, color: Colors.black87),
//             decoration: InputDecoration(
//               hintText: 'Type a message…',
//               hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.5),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//             ),
//           ),
//         )),
//         const SizedBox(width: 8),
//         // Send button
//         GestureDetector(
//           onTap: sending ? null : onSend,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             width: 46, height: 46,
//             decoration: BoxDecoration(
//               color: sending ? Colors.grey.shade300 : const Color(0xFF00695C),
//               shape: BoxShape.circle,
//             ),
//             child: sending
//                 ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
//                 : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//           ),
//         ),
//       ]),
//     );
//   }
// }








import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_session.dart';
import 'tts_translation_service.dart';

// ═══════════════════════════════════════════════════════════════
//  CHAT DETAIL SCREEN
//
//  ✅ Per-message Listen button  (SpeakButton — TTS)
//  ✅ Per-message Translate toggle (TranslatedText — TTS)
//  ✅ Call icon → opens device phone dialer
//  ✅ Info icon → shows person profile sheet
//  ✅ WhatsApp-style bubble UI
//  ✅ Real-time Firestore messages
//  ✅ Read/unread tick marks (single = delivered, double blue = read)
//  ✅ Marks unread as read on open
// ═══════════════════════════════════════════════════════════════
class ChatDetailScreen extends StatefulWidget {
  final String convId, myUid, otherUid, otherName, otherImage, otherRole;
  final String jobTitle;
  const ChatDetailScreen({
    super.key,
    required this.convId,
    required this.myUid,
    required this.otherUid,
    required this.otherName,
    required this.otherImage,
    required this.otherRole,
    this.jobTitle = '',
  });
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const _teal = Color(0xFF00695C);

  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending     = false;

  @override
  void initState() {
    super.initState();
    TtsTranslationService().init();
    _markRead();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.convId)
          .update({'unreadCounts.${widget.myUid}': 0});
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      final db  = FirebaseFirestore.instance;
      final now = Timestamp.now();
      await db.collection('conversations').doc(widget.convId).collection('messages').add({
        'senderId': widget.myUid,
        'text': text,
        'createdAt': now,
        'isRead': false,
      });
      await db.collection('conversations').doc(widget.convId).update({
        'lastMessage': text,
        'lastMessageAt': now,
        'unreadCounts.${widget.otherUid}': FieldValue.increment(1),
        'unreadCounts.${widget.myUid}': 0,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send failed: $e'), backgroundColor: Colors.red));
      }
    } finally { if (mounted) setState(() => _sending = false); }
  }

  // ── Make phone call ──────────────────────────────────────────
  Future<void> _makeCall() async {
    // otherUid is the phone number in FixRight's architecture (+92XXXXXXXXXX)
    String phone = widget.otherUid.trim();
    // If starts with 0, convert to +92
    if (phone.startsWith('0') && !phone.startsWith('+')) {
      phone = '+92${phone.substring(1)}';
    }
    // Remove spaces/dashes
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open dialer for $phone'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call failed: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  // ── Info sheet ───────────────────────────────────────────────
  void _showUserInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserInfoSheet(
        uid: widget.otherUid,
        name: widget.otherName,
        image: widget.otherImage,
        role: widget.otherRole,
        jobTitle: widget.jobTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(children: [
        if (widget.jobTitle.isNotEmpty) _JobBanner(jobTitle: widget.jobTitle),
        Expanded(child: _MessagesList(
          convId: widget.convId,
          myUid: widget.myUid,
          scrollCtrl: _scrollCtrl,
        )),
        _InputBar(ctrl: _msgCtrl, sending: _sending, onSend: _sendMessage),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: _showUserInfo,
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _teal.withOpacity(0.1),
            backgroundImage: widget.otherImage.isNotEmpty ? NetworkImage(widget.otherImage) : null,
            child: widget.otherImage.isEmpty ? Text(
              widget.otherName.isNotEmpty ? widget.otherName[0].toUpperCase() : '?',
              style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 16),
            ) : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.otherName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              widget.otherRole == 'seller' ? '🔧 Worker' : widget.otherRole == 'buyer' ? '👤 Client' : 'Tap for info',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ])),
        ]),
      ),
      actions: [
        // ✅ Call button — opens device phone dialer
        IconButton(
          icon: const Icon(Icons.call_outlined, color: _teal, size: 22),
          tooltip: 'Call ${widget.otherName}',
          onPressed: _makeCall,
        ),
        // ✅ Info button — shows person profile sheet
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: _teal, size: 22),
          tooltip: 'View Profile',
          onPressed: _showUserInfo,
        ),
        // Language selector
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: GlobalLanguageButton(color: _teal),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade100),
      ),
    );
  }
}

// ── User Info Bottom Sheet ────────────────────────────────────
class _UserInfoSheet extends StatefulWidget {
  final String uid, name, image, role, jobTitle;
  const _UserInfoSheet({required this.uid, required this.name, required this.image, required this.role, required this.jobTitle});
  @override
  State<_UserInfoSheet> createState() => _UserInfoSheetState();
}

class _UserInfoSheetState extends State<_UserInfoSheet> {
  static const _teal = Color(0xFF00695C);
  Map<String, dynamic>? _profileData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // Try users collection first, then sellers
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (userDoc.exists) {
        setState(() { _profileData = userDoc.data(); _loading = false; });
        return;
      }
      final sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(widget.uid).get();
      if (sellerDoc.exists) {
        setState(() { _profileData = sellerDoc.data(); _loading = false; });
        return;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final data = _profileData ?? {};
    final firstName = data['firstName'] as String? ?? '';
    final lastName  = data['lastName']  as String? ?? '';
    final fullName  = widget.name.trim().isNotEmpty ? widget.name : '$firstName $lastName'.trim();
    final city      = data['city']    as String? ?? '';
    final phone     = data['phone']   as String? ?? widget.uid;
    final bio       = data['bio']     as String? ?? '';
    final skills    = List<String>.from(data['skills'] ?? []);
    final rating    = (data['Rating'] ?? data['rating'] ?? 0.0).toDouble();
    final jobsDone  = (data['Jobs_Completed'] ?? 0) as int;
    final isSeller  = widget.role == 'seller';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag handle
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

        // Avatar
        CircleAvatar(
          radius: 42,
          backgroundColor: _teal.withOpacity(0.1),
          backgroundImage: widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
          child: widget.image.isEmpty ? Text(
            fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 34),
          ) : null,
        ),
        const SizedBox(height: 14),

        // Name
        Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 4),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSeller ? const Color(0xFF2E7D32).withOpacity(0.1) : const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isSeller ? '🔧 Worker / Seller' : '👤 Client / Buyer',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: isSeller ? const Color(0xFF2E7D32) : const Color(0xFF1565C0)),
          ),
        ),
        const SizedBox(height: 16),

        if (_loading) ...[
          const CircularProgressIndicator(color: _teal, strokeWidth: 2),
          const SizedBox(height: 12),
        ] else ...[
          // Stats row (for sellers)
          if (isSeller && (rating > 0 || jobsDone > 0)) ...[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (rating > 0) _stat('⭐', rating.toStringAsFixed(1), 'Rating'),
              if (rating > 0 && jobsDone > 0) const SizedBox(width: 24),
              if (jobsDone > 0) _stat('✅', '$jobsDone', 'Jobs Done'),
            ]),
            const SizedBox(height: 14),
          ],

          // Info rows
          if (city.isNotEmpty) _infoRow(Icons.location_city_outlined, city),
          if (bio.isNotEmpty) ...[const SizedBox(height: 6), _infoRow(Icons.info_outline, bio, maxLines: 3)],
          if (widget.jobTitle.isNotEmpty) ...[const SizedBox(height: 6), _infoRow(Icons.work_outline_rounded, 'Re: ${widget.jobTitle}')],

          // Skills
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: Text('Skills', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700]))),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 6,
              children: skills.take(8).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: _teal.withOpacity(0.15))),
                child: Text(s, style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Call button
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            String p = widget.uid.trim();
            if (p.startsWith('0')) p = '+92${p.substring(1)}';
            p = p.replaceAll(RegExp(r'[\s\-()]'), '');
            final uri = Uri(scheme: 'tel', path: p);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          icon: const Icon(Icons.call_rounded, size: 20),
          label: const Text('Call Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        )),
      ]),
    );
  }

  Widget _stat(String icon, String value, String label) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
  ]);

  Widget _infoRow(IconData icon, String text, {int maxLines = 1}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: Colors.grey[400]),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: maxLines, overflow: TextOverflow.ellipsis)),
  ]);
}

// ── Job Banner ────────────────────────────────────────────────
class _JobBanner extends StatelessWidget {
  final String jobTitle;
  const _JobBanner({required this.jobTitle});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Icon(Icons.work_outline_rounded, size: 13, color: Colors.grey[400]),
      const SizedBox(width: 8),
      Expanded(child: Text(jobTitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]),
  );
}

// ── Messages List ─────────────────────────────────────────────
class _MessagesList extends StatelessWidget {
  final String convId, myUid;
  final ScrollController scrollCtrl;
  const _MessagesList({required this.convId, required this.myUid, required this.scrollCtrl});

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations').doc(convId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const _NoMessages();

        return ListView.builder(
          controller: scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final curr = docs[i].data() as Map<String, dynamic>;
            final prev = i < docs.length - 1 ? docs[i + 1].data() as Map<String, dynamic> : null;
            final next = i > 0 ? docs[i - 1].data() as Map<String, dynamic> : null;
            final isMe = curr['senderId'] == myUid;

            bool showDate = false;
            if (prev != null) {
              final a = (curr['createdAt'] as Timestamp?)?.toDate();
              final b = (prev['createdAt'] as Timestamp?)?.toDate();
              if (a != null && b != null) showDate = !_sameDay(a, b);
            } else { showDate = true; }

            final isFirstGroup = prev == null || prev['senderId'] != curr['senderId'] || showDate;
            final isLastGroup  = next == null || next['senderId'] != curr['senderId'];

            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (showDate) _DateSeparator(ts: curr['createdAt'] as Timestamp?),
              _MessageBubble(data: curr, msgId: docs[i].id, convId: convId,
                  isMe: isMe, isFirst: isFirstGroup, isLast: isLastGroup),
            ]);
          },
        );
      },
    );
  }
}

class _NoMessages extends StatelessWidget {
  const _NoMessages();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.waving_hand_outlined, size: 46, color: Colors.grey[300]),
      const SizedBox(height: 12),
      Text('Say hello!', style: TextStyle(fontSize: 16, color: Colors.grey[400], fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Messages are translatable to any language\nusing the 🌐 globe button per message.',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
    ]),
  );
}

// ── Date Separator ────────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final Timestamp? ts;
  const _DateSeparator({this.ts});
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  @override
  Widget build(BuildContext context) {
    if (ts == null) return const SizedBox();
    final dt  = ts!.toDate();
    final now = DateTime.now();
    String label;
    if (_sameDay(dt, now)) {
      label = 'Today';
    } else if (_sameDay(dt, now.subtract(const Duration(days: 1)))) label = 'Yesterday';
    else label = DateFormat('MMMM d, yyyy').format(dt);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.7)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(label,
        style: TextStyle(fontSize: 11.5, color: Colors.grey[500], fontWeight: FontWeight.w600))),
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.7)),
    ]));
  }
}

// ── Message Bubble ────────────────────────────────────────────
class _MessageBubble extends StatefulWidget {
  final Map<String, dynamic> data;
  final String msgId, convId;
  final bool isMe, isFirst, isLast;
  const _MessageBubble({required this.data, required this.msgId, required this.convId,
      required this.isMe, required this.isFirst, required this.isLast});
  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final text    = widget.data['text'] as String? ?? '';
    final ts      = widget.data['createdAt'] as Timestamp?;
    final timeStr = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '';
    final isMe    = widget.isMe;
    const teal    = Color(0xFF00695C);

    final radius = BorderRadius.only(
      topLeft:     Radius.circular(!isMe && widget.isFirst ? 4 : 18),
      topRight:    Radius.circular(isMe && widget.isFirst ? 4 : 18),
      bottomLeft:  Radius.circular(!isMe && widget.isLast ? 4 : 18),
      bottomRight: Radius.circular(isMe && widget.isLast ? 4 : 18),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: widget.isFirst ? 4 : 1.5, bottom: widget.isLast ? 4 : 1.5,
        left: isMe ? 56 : 0, right: isMe ? 0 : 56,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Actions for RECEIVED messages (left side)
          if (!isMe) _MsgActions(text: text, msgId: widget.msgId,
            showTranslation: _showTranslation,
            onToggleTranslate: () => setState(() => _showTranslation = !_showTranslation)),

          // Bubble
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: isMe ? teal : Colors.white,
              borderRadius: radius,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, style: TextStyle(fontSize: 14.5, color: isMe ? Colors.white : Colors.black87, height: 1.4)),

              // ✅ Inline translation (received messages only)
              if (!isMe && _showTranslation) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200)),
                  child: TranslatedText(
                    text: text,
                    contentId: 'msg_${widget.msgId}',
                    style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
                    showListenButton: false,
                  ),
                ),
              ],

              const SizedBox(height: 3),
              // ✅ Timestamp + read receipts
              Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(timeStr, style: TextStyle(fontSize: 10.5, color: isMe ? Colors.white.withOpacity(0.65) : Colors.grey[400])),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  Icon(
                    widget.data['isRead'] == true ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 13,
                    color: widget.data['isRead'] == true ? Colors.lightBlue[200] : Colors.white.withOpacity(0.5)),
                ],
              ]),
            ]),
          )),

          // ✅ Actions for SENT messages (right side)
          if (isMe) _MsgActions(text: text, msgId: widget.msgId,
            showTranslation: _showTranslation, isMe: true,
            onToggleTranslate: () => setState(() => _showTranslation = !_showTranslation)),
        ],
      ),
    );
  }
}

// ── Per-message Listen + Translate buttons ────────────────────
// ✅ Reuses SpeakButton from tts_translation_service.dart (same as orders/job cards)
class _MsgActions extends StatelessWidget {
  final String text, msgId;
  final bool showTranslation, isMe;
  final VoidCallback onToggleTranslate;
  const _MsgActions({required this.text, required this.msgId, required this.showTranslation,
      required this.onToggleTranslate, this.isMe = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: isMe ? 0 : 4, right: isMe ? 4 : 0, bottom: 4),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // 🔊 Speak — existing SpeakButton widget (chip style, icon only)
      SpeakButton(text: text, contentId: 'msg_$msgId'),
      const SizedBox(height: 4),
      // 🌐 Translate toggle
      GestureDetector(
        onTap: onToggleTranslate,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: showTranslation ? const Color(0xFF00695C).withOpacity(0.12) : Colors.grey.shade100,
            shape: BoxShape.circle),
          child: Icon(Icons.translate_rounded, size: 14,
            color: showTranslation ? const Color(0xFF00695C) : Colors.grey[400]),
        ),
      ),
    ]),
  );
}

// ── Input Bar ─────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Container(
          constraints: const BoxConstraints(maxHeight: 120),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.grey.shade200)),
          child: TextField(
            controller: ctrl,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Type a message…',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.5),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: sending ? null : onSend,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: sending ? Colors.grey.shade300 : const Color(0xFF00695C),
              shape: BoxShape.circle),
            child: sending
                ? const Center(child: SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}