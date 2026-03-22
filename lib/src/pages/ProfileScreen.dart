// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../services/auth_service.dart';
// import '../../services/user_session.dart';
// import '../../services/user_data_helper.dart';
// import '../../services/location_service.dart';
// import '../../services/profile_service.dart';
// import 'LocationMapScreen.dart';
// import './cloudinary_service.dart';
// import '../pages/sellerForm.dart';

// class ProfileScreen extends StatefulWidget {
//   final bool isSellerMode;
//   final ValueChanged<bool> onToggleMode;
//   final String? phoneUID;

//   const ProfileScreen({
//     super.key,
//     required this.isSellerMode,
//     required this.onToggleMode,
//     this.phoneUID,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final AuthService _authService = AuthService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late String phoneDocId;
//   bool isLoading = true;
//   final mobile = UserSession().phoneUID;
//   final UserDataHelper _userDataHelper = UserDataHelper();
//   Object userData = {};

//   UserDataHelper userDataHelper = UserDataHelper();

//   String firstName = '';
//   String lastName = '';
//   String address = '';
//   String phoneNumber = '';
//   String UserRole = '';
//   double longitude = 0;
//   double latitude = 0;
//   String city = '';
//   String country = '';
//   String fullAddress = '';
//   String imageUrl = '';
//   String sellerStatus = '';
//   String adminComments = '';

//   @override
//   void initState() {
//     super.initState();
//     phoneDocId =
//         widget.phoneUID ??
//         UserSession().phoneUID ??
//         _authService.getUserPhoneDocId() ??
//         '';
//     _loadUserProfile();
//   }

//   Future<String> _getSellerStatus() async {
//     try {
//       final sellerDoc = await _firestore
//           .collection('sellers')
//           .doc(phoneDocId)
//           .get();
//       if (sellerDoc.exists) {
//         final status = sellerDoc.data()?['status'] ?? 'none';
//         final comments = sellerDoc.data()?['comments'] ?? '';

//         setState(() {
//           adminComments = comments;
//         });

//         if (status == 'approved' && UserRole != 'seller') {
//           try {
//             await _firestore.collection('users').doc(phoneDocId).update({
//               'Role': 'seller',
//             });
//             print('User role automatically updated to seller');
//           } catch (e) {
//             print('Error auto-updating user role: $e');
//           }
//         }

//         return status;
//       }
//       return 'none';
//     } catch (e) {
//       print('Error getting seller status: $e');
//       return 'none';
//     }
//   }

//   String _getSellerLabel() {
//     if (UserRole == 'seller') {
//       return 'Seller';
//     } else if (sellerStatus == 'submitted') {
//       return adminComments.isNotEmpty
//           ? 'Address Feedback'
//           : 'Submitted (Under Review)';
//     } else {
//       return 'Became Seller';
//     }
//   }

//   Future<void> updateRole() async {
//     await _firestore.collection('users').doc(phoneDocId).update({
//       'Role': 'seller',
//     });
//     print('User role automatically updated to seller');
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final userDoc = await _authService.getUserProfile(phoneDocId);

//       if (userDoc != null) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         userData = data;

//         final lat = (data['latitude'] ?? 0).toDouble();
//         final lng = (data['longitude'] ?? 0).toDouble();

//         String loadedCity = data['city'] ?? '';
//         String loadedCountry = data['country'] ?? '';
//         String loadedAddress = data['address'] ?? '';
//         String ProfileImage = data['profileImage'] ?? '';
//         imageUrl = ProfileImage;

//         final status = await _getSellerStatus();

//         if (lat != 0 && lng != 0) {
//           try {
//             final locationDetails =
//                 await LocationService.getAddressFromCoordinates(lat, lng);
//             loadedCity = locationDetails['city'] ?? loadedCity;
//             loadedCountry = locationDetails['country'] ?? loadedCountry;
//             loadedAddress = LocationService.formatAddress(locationDetails);
//           } catch (e) {
//             print('Error getting location details: $e');
//           }
//         }

//         setState(() {
//           firstName = data['firstName'] ?? '';
//           lastName = data['lastName'] ?? '';
//           address = loadedAddress;
//           phoneNumber = data['phoneNumber'] ?? '';
//           UserRole = data['Role'] ?? '';
//           longitude = lng;
//           latitude = lat;
//           city = loadedCity;
//           country = loadedCountry;
//           fullAddress = loadedAddress;
//           sellerStatus = status;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print('Error loading profile: $e');
//       setState(() => isLoading = false);
//     }
//   }

//   final List<Map<String, dynamic>> _buyerOptions = [
//     {'icon': Icons.diamond, 'title': 'Get inspired'},
//     {'icon': Icons.favorite_border, 'title': 'Saved lists'},
//     {'icon': Icons.insights, 'title': 'My interests'},
//     {'icon': Icons.send, 'title': 'Invite friends'},
//   ];

//   final List<Map<String, dynamic>> _sellerOptions = [
//     {'icon': Icons.account_balance_wallet, 'title': 'Earnings'},
//     {'icon': Icons.description, 'title': 'Custom offer templates'},
//     {'icon': Icons.text_snippet, 'title': 'Briefs'},
//     {'icon': Icons.share, 'title': 'Share Gigs'},
//   ];

//   Widget _buildProfileOption({
//     required IconData icon,
//     required String title,
//     required Color color,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: color),
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//       onTap: onTap ?? () { debugPrint('Tapped: $title'); },
//     );
//   }

//   Widget _UpdateUserProfileScreen(String phoneDocId) {
//     return _EditProfileScreen(phoneDocId: phoneDocId);
//   }

//   void _showEditProfileDialog(phoneDocId) {
//     final firstNameController = TextEditingController(text: firstName);
//     final lastNameController = TextEditingController(text: lastName);
//     final addressController = TextEditingController(text: address);
//     final phoneNumberController = TextEditingController(text: mobile);
//   }

//   Future<void> _updateProfile(
//     String newFirstName,
//     String newLastName,
//     String newAddress,
//   ) async {
//     try {
//       await _firestore.collection('users').doc(phoneDocId).update({
//         'firstName': newFirstName,
//         'lastName': newLastName,
//         'address': newAddress,
//       });

//       setState(() {
//         firstName = newFirstName;
//         lastName = newLastName;
//         address = newAddress;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final currentOptions = widget.isSellerMode ? _sellerOptions : _buyerOptions;
//     final primaryColor = widget.isSellerMode
//         ? Colors.green.shade700
//         : const Color(0xFF2B7CD3);
//     final headerText = widget.isSellerMode ? 'Selling' : 'My FixRight';
//     final Color optionColor = widget.isSellerMode
//         ? Colors.green.shade700
//         : const Color(0xFF2B7CD3);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [Text('My Profile'), Icon(Icons.notifications)],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               height: 230,
//               padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
//               decoration: BoxDecoration(color: primaryColor),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 35,
//                             backgroundColor: Colors.white,
//                             backgroundImage: imageUrl.isNotEmpty
//                                 ? NetworkImage(imageUrl)
//                                 : null,
//                             child: imageUrl.isEmpty
//                                 ? Text(
//                                     firstName.isNotEmpty
//                                         ? firstName[0].toUpperCase()
//                                         : 'U',
//                                     style: const TextStyle(
//                                       fontSize: 32,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                           Positioned(
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.greenAccent.shade400,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 2),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '$firstName $lastName'.trim(),
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             'UserRole:$UserRole ',
//                             style: const TextStyle(fontSize: 14, color: Colors.white),
//                           ),
//                           Text(
//                             'Address: $address \nCity: $city \nCounty:  $country',
//                             style: const TextStyle(fontSize: 14, color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const Spacer(),
//                   UserRole == 'seller'
//                       ? Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Seller Mode',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                               Switch(
//                                 value: widget.isSellerMode,
//                                 activeThumbColor: primaryColor,
//                                 onChanged: (bool newValue) {
//                                   widget.onToggleMode(newValue);
//                                 },
//                               ),
//                             ],
//                           ),
//                         )
//                       : Padding(
//                           padding: const EdgeInsets.all(14.0),
//                           child: ElevatedButton(
//                             onPressed: (sellerStatus == 'submitted' && adminComments.isEmpty)
//                                 ? null
//                                 : () => Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => Sellerform(
//                                           uid: widget.phoneUID,
//                                           userData: userData,
//                                         ),
//                                       ),
//                                     ),
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(double.infinity, 50),
//                               backgroundColor: adminComments.isNotEmpty
//                                   ? Colors.red.shade600
//                                   : (sellerStatus == 'submitted'
//                                       ? Colors.orange.shade600
//                                       : Colors.white),
//                               disabledBackgroundColor: Colors.orange.shade600,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               _getSellerLabel(),
//                               style: TextStyle(
//                                 color: (sellerStatus == 'submitted' || adminComments.isNotEmpty)
//                                     ? Colors.white
//                                     : Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
//               child: Text(
//                 'Account',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const Divider(height: 15),
//             _buildProfileOption(
//               icon: Icons.person,
//               title: 'Update Profile ',
//               color: optionColor,
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => _UpdateUserProfileScreen(phoneDocId),
//                 ),
//               ),
//             ),

//             if (latitude != 0 && longitude != 0)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.location_on, color: optionColor),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Your Location',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: optionColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '$city, $country',
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                         if (fullAddress.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               fullAddress,
//                               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         const SizedBox(height: 8),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => LocationMapScreen(
//                                     latitude: latitude,
//                                     longitude: longitude,
//                                     userName: '$firstName $lastName'.trim(),
//                                     userRole: UserRole.toLowerCase(),
//                                     address: fullAddress,
//                                     phoneUID: phoneDocId,
//                                   ),
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.map),
//                             label: const Text('View on Map'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: optionColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             Padding(
//               padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
//               child: Text(
//                 headerText,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const Divider(height: 15),

//             ...currentOptions.map(
//               (option) => _buildProfileOption(
//                 icon: option['icon'] as IconData,
//                 title: option['title'] as String,
//                 color: optionColor,
//               ),
//             ),

//             const Padding(
//               padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
//               child: Text(
//                 'Settings',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//               ),
//             ),
//             const Divider(height: 15),
//             _buildProfileOption(
//               icon: Icons.settings,
//               title: 'Preferences',
//               color: Colors.grey.shade700,
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await _authService.signOut();
//                   Navigator.pushReplacementNamed(context, '/');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
//               ),
//             ),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  EDIT PROFILE SCREEN  — all cross-document sync lives here
// // ═══════════════════════════════════════════════════════════════
// class _EditProfileScreen extends StatefulWidget {
//   final String phoneDocId;
//   const _EditProfileScreen({required this.phoneDocId});

//   @override
//   State<_EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<_EditProfileScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late ProfileService _profileService;
//   late UserProfile _profile;

//   bool isLoading = true;
//   bool isSaving = false;
//   bool isUploadingImage = false;
//   String? errorMessage;

//   // Local image file selected by user (not yet saved)
//   File? _pickedImageFile;
//   // The URL that will be saved — starts as existing, updates after upload
//   String? _currentImageUrl;

//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _cityController;
//   late TextEditingController _countryController;
//   late TextEditingController _addressController;
//   late TextEditingController _phoneController;

//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _profileService = ProfileService();
//     _loadProfile();
//   }

//   Future<void> _loadProfile() async {
//     try {
//       final profile = await _profileService.fetchProfile(widget.phoneDocId);
//       if (profile != null) {
//         setState(() {
//           _profile = profile;
//           _currentImageUrl = profile.profileImageUrl;
//           _initializeControllers(profile);
//           isLoading = false;
//         });
//       } else {
//         setState(() { isLoading = false; errorMessage = 'Profile not found'; });
//       }
//     } catch (e) {
//       setState(() { isLoading = false; errorMessage = 'Error loading profile: $e'; });
//     }
//   }

//   void _initializeControllers(UserProfile profile) {
//     _firstNameController = TextEditingController(text: profile.firstName);
//     _lastNameController  = TextEditingController(text: profile.lastName);
//     _cityController      = TextEditingController(text: profile.city);
//     _countryController   = TextEditingController(text: profile.country);
//     _addressController   = TextEditingController(text: profile.address);
//     _phoneController     = TextEditingController(text: profile.phoneNumber);
//   }

//   // ── Image Picker ─────────────────────────────────────────────
//   Future<void> _pickImage() async {
//     final ImageSource? source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40, height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Change Profile Photo',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(child: _sourceButton(
//                     icon: Icons.photo_library_outlined,
//                     label: 'Gallery',
//                     color: Colors.blue,
//                     onTap: () => Navigator.pop(context, ImageSource.gallery),
//                   )),
//                   const SizedBox(width: 12),
//                   Expanded(child: _sourceButton(
//                     icon: Icons.camera_alt_outlined,
//                     label: 'Camera',
//                     color: Colors.green,
//                     onTap: () => Navigator.pop(context, ImageSource.camera),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (source == null) return;

//     final XFile? picked = await _picker.pickImage(
//       source: source,
//       imageQuality: 85,
//     );
//     if (picked == null) return;

//     setState(() => _pickedImageFile = File(picked.path));
//   }

//   Widget _sourceButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(height: 6),
//             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Save Profile + Sync All Documents ────────────────────────
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     final validationError = ProfileService.validateProfile(
//       firstName: _firstNameController.text,
//       lastName:  _lastNameController.text,
//       city:      _cityController.text,
//       country:   _countryController.text,
//       address:   _addressController.text,
//     );
//     if (validationError != null) { _showError(validationError); return; }

//     setState(() => isSaving = true);

//     try {
//       final String firstName = _firstNameController.text.trim();
//       final String lastName  = _lastNameController.text.trim();
//       final String fullName  = '$firstName $lastName'.trim();

//       // ── Step 1: Upload new image if user picked one ──────────
//       String? finalImageUrl = _currentImageUrl;
//       if (_pickedImageFile != null) {
//         setState(() => isUploadingImage = true);
//         final uploaded = await CloudinaryService.uploadImage(
//           _pickedImageFile!,
//           folder: 'fixright/profiles/${widget.phoneDocId}',
//         );
//         setState(() => isUploadingImage = false);

//         if (uploaded == null) {
//           _showError('Image upload failed. Please try again.');
//           setState(() => isSaving = false);
//           return;
//         }
//         finalImageUrl = uploaded;
//       }

//       // ── Step 2: Update users/{uid} ───────────────────────────
//       await _profileService.updateProfile(
//         widget.phoneDocId,
//         firstName: firstName,
//         lastName:  lastName,
//         city:      _cityController.text.trim(),
//         country:   _countryController.text.trim(),
//         address:   _addressController.text.trim(),
//       );

//       // Update profileImage in users doc if changed
//       if (finalImageUrl != null && finalImageUrl != _currentImageUrl) {
//         await _firestore.collection('users').doc(widget.phoneDocId).update({
//           'profileImage': finalImageUrl,
//         });
//       }

//       // ── Step 3: Update sellers/{uid} if doc exists ───────────
//       await _syncSellerDocument(firstName, lastName);

//       // ── Step 4: Update all conversations this user is in ─────
//       await _syncConversations(fullName, finalImageUrl);

//       // Refresh local state
//       setState(() => _currentImageUrl = finalImageUrl);

//       _showSuccess('Profile updated successfully');
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => isSaving = false);
//       _showError('Error saving profile: $e');
//     }
//   }

//   /// Update firstName & lastName in sellers collection (if seller doc exists)
//   Future<void> _syncSellerDocument(String firstName, String lastName) async {
//     try {
//       final sellerDoc = await _firestore
//           .collection('sellers')
//           .doc(widget.phoneDocId)
//           .get();

//       if (sellerDoc.exists) {
//         await _firestore
//             .collection('sellers')
//             .doc(widget.phoneDocId)
//             .update({
//           'firstName': firstName,
//           'lastName':  lastName,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//         print('✅ Seller document synced');
//       }
//     } catch (e) {
//       print('⚠️ Seller sync skipped: $e');
//       // Non-critical — don't block save
//     }
//   }

//   /// Update participantNames & participantProfileImages in all conversations
//   Future<void> _syncConversations(String fullName, String? imageUrl) async {
//     try {
//       // Find all conversations where this user is a participant
//       final conversationsSnap = await _firestore
//           .collection('conversations')
//           .where('participantIds', arrayContains: widget.phoneDocId)
//           .get();

//       if (conversationsSnap.docs.isEmpty) return;

//       // Batch write for efficiency
//       final WriteBatch batch = _firestore.batch();

//       for (final doc in conversationsSnap.docs) {
//         final Map<String, dynamic> updates = {
//           'participantNames.${widget.phoneDocId}': fullName,
//         };

//         // Only update image if we have one
//         if (imageUrl != null && imageUrl.isNotEmpty) {
//           updates['participantProfileImages.${widget.phoneDocId}'] = imageUrl;
//         }

//         batch.update(doc.reference, updates);
//       }

//       await batch.commit();
//       print('✅ ${conversationsSnap.docs.length} conversation(s) synced');
//     } catch (e) {
//       print('⚠️ Conversations sync skipped: $e');
//       // Non-critical — don't block save
//     }
//   }

//   void _showSuccess(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.green.shade600),
//     );
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
//     );
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _cityController.dispose();
//     _countryController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('My Profile Testing')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('My Profile AH')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(errorMessage!),
//               const SizedBox(height: 16),
//               ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Update My Profile'), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [

//               // ── Profile Image with Edit Button ───────────────
//               Center(
//                 child: Stack(
//                   children: [
//                     // Avatar — shows picked file first, then existing URL
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundColor: Colors.grey.shade200,
//                       backgroundImage: _pickedImageFile != null
//                           ? FileImage(_pickedImageFile!) as ImageProvider
//                           : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
//                               ? NetworkImage(_currentImageUrl!)
//                               : null),
//                       child: (_pickedImageFile == null &&
//                               (_currentImageUrl == null || _currentImageUrl!.isEmpty))
//                           ? Icon(Icons.person, size: 60, color: Colors.grey.shade500)
//                           : null,
//                     ),

//                     // Upload indicator overlay
//                     if (isUploadingImage)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black45,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Center(
//                             child: CircularProgressIndicator(color: Colors.white),
//                           ),
//                         ),
//                       ),

//                     // Edit button
//                     Positioned(
//                       bottom: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: isUploadingImage ? null : _pickImage,
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade600,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // "Tap to change" hint
//               if (_pickedImageFile != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     'New photo selected — will upload on save',
//                     style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
//                   ),
//                 ),

//               const SizedBox(height: 24),

//               // ── Form Fields ──────────────────────────────────
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   prefixIcon: const Icon(Icons.person_outline),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   prefixIcon: const Icon(Icons.person_outline),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: _cityController,
//                 decoration: InputDecoration(
//                   labelText: 'City',
//                   prefixIcon: const Icon(Icons.location_city_outlined),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: _countryController,
//                 decoration: InputDecoration(
//                   labelText: 'Country',
//                   prefixIcon: const Icon(Icons.flag_outlined),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: _addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Address',
//                   prefixIcon: const Icon(Icons.home_outlined),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 maxLines: 3,
//                 validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   prefixIcon: const Icon(Icons.phone_outlined),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   suffixIcon: Icon(Icons.lock, color: Colors.grey.shade400, size: 18),
//                 ),
//                 readOnly: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),

//               // ── Save Button ──────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isSaving ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     disabledBackgroundColor: Colors.grey.shade300,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: isSaving
//                       ? Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const SizedBox(
//                               width: 20, height: 20,
//                               child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               isUploadingImage ? 'Uploading photo...' : 'Saving...',
//                               style: const TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                           ],
//                         )
//                       : const Text(
//                           'Save Changes',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../services/auth_service.dart';
// import '../../services/user_session.dart';
// import '../../services/user_data_helper.dart';
// import '../../services/location_service.dart';
// import '../../services/profile_service.dart';
// import 'LocationMapScreen.dart';
// import './cloudinary_service.dart';
// import '../pages/sellerForm.dart';

// class ProfileScreen extends StatefulWidget {
//   final bool isSellerMode;
//   final ValueChanged<bool> onToggleMode;
//   final String? phoneUID;

//   const ProfileScreen({
//     super.key,
//     required this.isSellerMode,
//     required this.onToggleMode,
//     this.phoneUID,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final AuthService _authService = AuthService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   static const _teal     = Color(0xFF00695C);
//   static const _tealDark = Color(0xFF004D40);

//   late String phoneDocId;
//   bool isLoading = true;

//   Object userData = {};

//   String firstName     = '';
//   String lastName      = '';
//   String address       = '';
//   String phoneNumber   = '';
//   String userRole      = '';
//   double longitude     = 0;
//   double latitude      = 0;
//   String city          = '';
//   String country       = '';
//   String fullAddress   = '';
//   String imageUrl      = '';
//   String sellerStatus  = '';
//   String adminComments = '';

//   @override
//   void initState() {
//     super.initState();
//     phoneDocId = widget.phoneUID ??
//         UserSession().phoneUID ??
//         _authService.getUserPhoneDocId() ??
//         '';
//     _loadUserProfile();
//   }

//   Future<String> _getSellerStatus() async {
//     try {
//       final doc = await _firestore.collection('sellers').doc(phoneDocId).get();
//       if (doc.exists) {
//         final status   = doc.data()?['status']   ?? 'none';
//         final comments = doc.data()?['comments'] ?? '';
//         setState(() => adminComments = comments);
//         if (status == 'approved' && userRole != 'seller') {
//           await _firestore.collection('users').doc(phoneDocId).update({'Role': 'seller'});
//         }
//         return status;
//       }
//       return 'none';
//     } catch (_) { return 'none'; }
//   }

//   String _getSellerLabel() {
//     if (userRole == 'seller') return 'Seller';
//     if (sellerStatus == 'submitted') {
//       return adminComments.isNotEmpty ? 'Address Feedback' : 'Submitted (Under Review)';
//     }
//     return 'Become a Seller';
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final userDoc = await _authService.getUserProfile(phoneDocId);
//       if (userDoc != null) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         userData = data;

//         final lat = (data['latitude']  ?? 0).toDouble();
//         final lng = (data['longitude'] ?? 0).toDouble();

//         String loadedCity    = data['city']    ?? '';
//         String loadedCountry = data['country'] ?? '';
//         String loadedAddress = data['address'] ?? '';

//         final status = await _getSellerStatus();

//         if (lat != 0 && lng != 0) {
//           try {
//             final loc = await LocationService.getAddressFromCoordinates(lat, lng);
//             loadedCity    = loc['city']    ?? loadedCity;
//             loadedCountry = loc['country'] ?? loadedCountry;
//             loadedAddress = LocationService.formatAddress(loc);
//           } catch (_) {}
//         }

//         setState(() {
//           firstName    = data['firstName']    ?? '';
//           lastName     = data['lastName']     ?? '';
//           address      = loadedAddress;
//           phoneNumber  = data['phoneNumber']  ?? '';
//           userRole     = data['Role']         ?? '';
//           longitude    = lng;
//           latitude     = lat;
//           city         = loadedCity;
//           country      = loadedCountry;
//           fullAddress  = loadedAddress;
//           imageUrl     = data['profileImage'] ?? '';
//           sellerStatus = status;
//           isLoading    = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (_) {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//           body: Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2)));
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(child: _buildHeader()),
//           SliverToBoxAdapter(child: _buildSellerToggleOrBecomeCard()),
//           SliverToBoxAdapter(child: _buildSectionLabel('Account')),
//           SliverToBoxAdapter(child: _buildMenuCard([
//             _menuTile(
//               icon: Icons.person_outline_rounded,
//               title: 'Edit Profile',
//               subtitle: 'Update your name, photo, address',
//               onTap: () => Navigator.push(context, MaterialPageRoute(
//                   builder: (_) => _EditProfileScreen(phoneDocId: phoneDocId)))
//                   .then((_) => _loadUserProfile()),
//             ),
//             if (latitude != 0 && longitude != 0)
//               _menuTile(
//                 icon: Icons.location_on_outlined,
//                 title: 'My Location',
//                 subtitle: '$city, $country',
//                 onTap: () => Navigator.push(context, MaterialPageRoute(
//                     builder: (_) => LocationMapScreen(
//                       latitude: latitude, longitude: longitude,
//                       userName: '$firstName $lastName'.trim(),
//                       userRole: userRole.toLowerCase(),
//                       address: fullAddress, phoneUID: phoneDocId,
//                     ))),
//               ),
//           ])),
//           SliverToBoxAdapter(child: _buildSectionLabel('Settings')),
//           SliverToBoxAdapter(child: _buildMenuCard([
//             _menuTile(
//               icon: Icons.notifications_none_rounded,
//               title: 'Notifications',
//               subtitle: 'Manage alerts and push notifications',
//               onTap: () {},
//             ),
//             _menuTile(
//               icon: Icons.lock_outline_rounded,
//               title: 'Privacy & Security',
//               subtitle: 'Control your data and privacy',
//               onTap: () {},
//             ),
//             _menuTile(
//               icon: Icons.help_outline_rounded,
//               title: 'Help & Support',
//               subtitle: 'FAQs, contact us',
//               onTap: () {},
//             ),
//           ])),
//           SliverToBoxAdapter(child: _buildLogoutBtn()),
//           SliverToBoxAdapter(child: _buildVersionTag()),
//           const SliverToBoxAdapter(child: SizedBox(height: 60)),
//         ],
//       ),
//     );
//   }

//   // ── Header ────────────────────────────────────────────────
//   Widget _buildHeader() {
//     final name = '$firstName $lastName'.trim();

//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//             begin: Alignment.topLeft, end: Alignment.bottomRight,
//             colors: [_teal, _tealDark]),
//         borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
//         boxShadow: [BoxShadow(color: Color(0x55004D40), blurRadius: 20, offset: Offset(0, 8))],
//       ),
//       child: SafeArea(bottom: false, child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // top row
//           Row(children: [
//             const Text('Account',
//                 style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
//             const Spacer(),
//             Icon(Icons.notifications_none_rounded, color: Colors.white.withOpacity(0.85), size: 26),
//           ]),

//           const SizedBox(height: 20),

//           // profile row
//           Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//             // avatar
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
//                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
//               ),
//               child: Stack(children: [
//                 CircleAvatar(
//                   radius: 36, backgroundColor: Colors.white.withOpacity(0.2),
//                   backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
//                   child: imageUrl.isEmpty
//                       ? Text(firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28))
//                       : null,
//                 ),
//                 Positioned(bottom: 2, right: 2, child: Container(
//                   width: 13, height: 13,
//                   decoration: BoxDecoration(
//                     color: Colors.greenAccent.shade400, shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2)),
//                 )),
//               ]),
//             ),

//             const SizedBox(width: 16),

//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(name.isNotEmpty ? name : 'User',
//                   style: const TextStyle(color: Colors.white, fontSize: 20,
//                       fontWeight: FontWeight.w900, letterSpacing: -0.3)),
//               const SizedBox(height: 4),
//               if (city.isNotEmpty)
//                 Row(children: [
//                   const Icon(Icons.location_on, size: 13, color: Colors.white60),
//                   const SizedBox(width: 3),
//                   Text('$city, $country',
//                       style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
//                 ]),
//               const SizedBox(height: 6),
//               // role badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Text(
//                   userRole == 'seller' ? '🔧 Verified Seller' : '🛒 Buyer',
//                   style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ])),

//             // edit icon
//             GestureDetector(
//               onTap: () => Navigator.push(context, MaterialPageRoute(
//                   builder: (_) => _EditProfileScreen(phoneDocId: phoneDocId)))
//                   .then((_) => _loadUserProfile()),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
//                 child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
//               ),
//             ),
//           ]),
//         ]),
//       )),
//     );
//   }

//   // ── Seller toggle / become seller ─────────────────────────
//   Widget _buildSellerToggleOrBecomeCard() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//       child: userRole == 'seller'
//           // ── Seller Mode Switch ──
//           ? Container(
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(18),
//                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
//               ),
//               child: Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(9),
//                   decoration: BoxDecoration(
//                     color: widget.isSellerMode ? _teal.withOpacity(0.1) : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12)),
//                   child: Icon(Icons.storefront_rounded,
//                       color: widget.isSellerMode ? _teal : Colors.grey.shade500, size: 22),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Seller Mode',
//                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
//                   Text(widget.isSellerMode ? 'Currently in seller view' : 'Switch to seller dashboard',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//                 ])),
//                 Switch(
//                   value: widget.isSellerMode,
//                   activeColor: _teal,
//                   onChanged: widget.onToggleMode,
//                 ),
//               ]),
//             )
//           // ── Become a Seller banner ──
//           : GestureDetector(
//               onTap: (sellerStatus == 'submitted' && adminComments.isEmpty)
//                   ? null
//                   : () => Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => Sellerform(uid: widget.phoneUID, userData: userData))),
//               child: Container(
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: adminComments.isNotEmpty
//                         ? [Colors.red.shade600, Colors.red.shade800]
//                         : sellerStatus == 'submitted'
//                             ? [Colors.orange.shade500, Colors.orange.shade700]
//                             : [_teal, _tealDark],
//                     begin: Alignment.topLeft, end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [BoxShadow(
//                     color: (adminComments.isNotEmpty ? Colors.red : _teal).withOpacity(0.35),
//                     blurRadius: 12, offset: const Offset(0, 5))],
//                 ),
//                 child: Row(children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
//                     child: Icon(
//                       adminComments.isNotEmpty
//                           ? Icons.warning_amber_rounded
//                           : sellerStatus == 'submitted'
//                               ? Icons.hourglass_top_rounded
//                               : Icons.rocket_launch_rounded,
//                       color: Colors.white, size: 24),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(_getSellerLabel(),
//                         style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 3),
//                     Text(
//                       adminComments.isNotEmpty
//                           ? 'Tap to view feedback and resubmit'
//                           : sellerStatus == 'submitted'
//                               ? 'Your application is under review'
//                               : 'Start earning by offering your skills',
//                       style: const TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ])),
//                   if (sellerStatus != 'submitted' || adminComments.isNotEmpty)
//                     const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
//                 ]),
//               ),
//             ),
//     );
//   }

//   // ── Section label ─────────────────────────────────────────
//   Widget _buildSectionLabel(String title) => Padding(
//     padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
//     child: Text(title,
//         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
//             color: Colors.grey[500], letterSpacing: 0.8)),
//   );

//   // ── Menu card container ───────────────────────────────────
//   Widget _buildMenuCard(List<Widget> tiles) => Container(
//     margin: const EdgeInsets.symmetric(horizontal: 16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
//     ),
//     child: Column(children: [
//       for (int i = 0; i < tiles.length; i++) ...[
//         tiles[i],
//         if (i < tiles.length - 1)
//           Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey.shade100),
//       ],
//     ]),
//   );

//   Widget _menuTile({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     required VoidCallback onTap,
//     Color? iconColor,
//     bool danger = false,
//   }) {
//     final color = danger ? Colors.red.shade600 : (iconColor ?? _teal);
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.09), borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title, style: TextStyle(
//                 fontSize: 14.5, fontWeight: FontWeight.w600,
//                 color: danger ? Colors.red.shade600 : Colors.black87)),
//             if (subtitle != null) ...[
//               const SizedBox(height: 2),
//               Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//             ],
//           ])),
//           Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
//         ]),
//       ),
//     );
//   }

//   // ── Logout ────────────────────────────────────────────────
//   Widget _buildLogoutBtn() => Padding(
//     padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
//     child: GestureDetector(
//       onTap: () async {
//         final confirmed = await showDialog<bool>(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
//             content: const Text('Are you sure you want to log out?'),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(ctx, false),
//                   child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
//               TextButton(onPressed: () => Navigator.pop(ctx, true),
//                   child: Text('Log Out', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700))),
//             ],
//           ),
//         );
//         if (confirmed == true) {
//           await _authService.signOut();
//           Navigator.pushReplacementNamed(context, '/');
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           color: Colors.red.shade50,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.red.shade200, width: 1.5),
//         ),
//         child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
//           const SizedBox(width: 8),
//           Text('Log Out', style: TextStyle(
//               color: Colors.red.shade600, fontSize: 15, fontWeight: FontWeight.w700)),
//         ]),
//       ),
//     ),
//   );

//   Widget _buildVersionTag() => Padding(
//     padding: const EdgeInsets.only(top: 20),
//     child: Center(child: Text('FixRight v1.0.0',
//         style: TextStyle(fontSize: 12, color: Colors.grey[400]))),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// //  EDIT PROFILE SCREEN — unchanged logic, improved visual
// // ═══════════════════════════════════════════════════════════════
// class _EditProfileScreen extends StatefulWidget {
//   final String phoneDocId;
//   const _EditProfileScreen({required this.phoneDocId});

//   @override
//   State<_EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<_EditProfileScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late ProfileService _profileService;

//   static const _teal = Color(0xFF00695C);

//   bool isLoading       = true;
//   bool isSaving        = false;
//   bool isUploadingImage = false;
//   String? errorMessage;

//   File? _pickedImageFile;
//   String? _currentImageUrl;

//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _cityController;
//   late TextEditingController _countryController;
//   late TextEditingController _addressController;
//   late TextEditingController _phoneController;

//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _profileService = ProfileService();
//     _loadProfile();
//   }

//   Future<void> _loadProfile() async {
//     try {
//       final profile = await _profileService.fetchProfile(widget.phoneDocId);
//       if (profile != null) {
//         setState(() {
//           _currentImageUrl      = profile.profileImageUrl;
//           _firstNameController  = TextEditingController(text: profile.firstName);
//           _lastNameController   = TextEditingController(text: profile.lastName);
//           _cityController       = TextEditingController(text: profile.city);
//           _countryController    = TextEditingController(text: profile.country);
//           _addressController    = TextEditingController(text: profile.address);
//           _phoneController      = TextEditingController(text: profile.phoneNumber);
//           isLoading             = false;
//         });
//       } else {
//         setState(() { isLoading = false; errorMessage = 'Profile not found'; });
//       }
//     } catch (e) {
//       setState(() { isLoading = false; errorMessage = 'Error: $e'; });
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImageSource? source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => SafeArea(child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
//           const Text('Change Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
//           const SizedBox(height: 16),
//           Row(children: [
//             Expanded(child: _srcBtn(Icons.photo_library_outlined, 'Gallery', Colors.blue,
//                 () => Navigator.pop(context, ImageSource.gallery))),
//             const SizedBox(width: 12),
//             Expanded(child: _srcBtn(Icons.camera_alt_outlined, 'Camera', _teal,
//                 () => Navigator.pop(context, ImageSource.camera))),
//           ]),
//         ]),
//       )),
//     );
//     if (source == null) return;
//     final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
//     if (picked == null) return;
//     setState(() => _pickedImageFile = File(picked.path));
//   }

//   Widget _srcBtn(IconData icon, String label, Color color, VoidCallback onTap) =>
//       GestureDetector(onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 18),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: color.withOpacity(0.2))),
//           child: Column(children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(height: 6),
//             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
//           ]),
//         ));

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => isSaving = true);
//     try {
//       final firstName = _firstNameController.text.trim();
//       final lastName  = _lastNameController.text.trim();
//       final fullName  = '$firstName $lastName'.trim();

//       String? finalImageUrl = _currentImageUrl;
//       if (_pickedImageFile != null) {
//         setState(() => isUploadingImage = true);
//         final uploaded = await CloudinaryService.uploadImage(
//           _pickedImageFile!, folder: 'fixright/profiles/${widget.phoneDocId}');
//         setState(() => isUploadingImage = false);
//         if (uploaded == null) { _showErr('Image upload failed.'); setState(() => isSaving = false); return; }
//         finalImageUrl = uploaded;
//       }

//       await _profileService.updateProfile(widget.phoneDocId,
//           firstName: firstName, lastName: lastName,
//           city: _cityController.text.trim(),
//           country: _countryController.text.trim(),
//           address: _addressController.text.trim());

//       if (finalImageUrl != null && finalImageUrl != _currentImageUrl) {
//         await _firestore.collection('users').doc(widget.phoneDocId).update({'profileImage': finalImageUrl});
//       }

//       // sync sellers doc
//       try {
//         final sd = await _firestore.collection('sellers').doc(widget.phoneDocId).get();
//         if (sd.exists) await _firestore.collection('sellers').doc(widget.phoneDocId).update(
//             {'firstName': firstName, 'lastName': lastName, 'updatedAt': FieldValue.serverTimestamp()});
//       } catch (_) {}

//       // sync conversations
//       try {
//         final convs = await _firestore.collection('conversations')
//             .where('participantIds', arrayContains: widget.phoneDocId).get();
//         if (convs.docs.isNotEmpty) {
//           final batch = _firestore.batch();
//           for (final doc in convs.docs) {
//             final updates = <String, dynamic>{
//               'participantNames.${widget.phoneDocId}': fullName,
//             };
//             if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
//               updates['participantProfileImages.${widget.phoneDocId}'] = finalImageUrl;
//             }
//             batch.update(doc.reference, updates);
//           }
//           await batch.commit();
//         }
//       } catch (_) {}

//       setState(() => _currentImageUrl = finalImageUrl);
//       _showOk('Profile updated!');
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => isSaving = false);
//       _showErr('Error: $e');
//     }
//   }

//   void _showOk(String m) => ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(m), backgroundColor: Colors.green.shade600));
//   void _showErr(String m) => ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(m), backgroundColor: Colors.red.shade600));

//   @override
//   void dispose() {
//     _firstNameController.dispose(); _lastNameController.dispose();
//     _cityController.dispose(); _countryController.dispose();
//     _addressController.dispose(); _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: _teal)));
//     if (errorMessage != null) return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Text(errorMessage!),
//         const SizedBox(height: 16),
//         ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
//       ])));

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       appBar: AppBar(
//         title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(children: [

//             // avatar
//             Center(child: Stack(children: [
//               Container(
//                 decoration: BoxDecoration(shape: BoxShape.circle,
//                     border: Border.all(color: _teal.withOpacity(0.3), width: 3)),
//                 child: CircleAvatar(
//                   radius: 56,
//                   backgroundColor: Colors.grey.shade200,
//                   backgroundImage: _pickedImageFile != null
//                       ? FileImage(_pickedImageFile!) as ImageProvider
//                       : (_currentImageUrl?.isNotEmpty == true ? NetworkImage(_currentImageUrl!) : null),
//                   child: (_pickedImageFile == null && (_currentImageUrl?.isEmpty ?? true))
//                       ? Icon(Icons.person, size: 56, color: Colors.grey.shade400) : null,
//                 ),
//               ),
//               if (isUploadingImage)
//                 Positioned.fill(child: Container(
//                   decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
//                   child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
//               Positioned(bottom: 4, right: 4, child: GestureDetector(
//                 onTap: isUploadingImage ? null : _pickImage,
//                 child: Container(
//                   padding: const EdgeInsets.all(7),
//                   decoration: BoxDecoration(color: _teal, shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2.5)),
//                   child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15)),
//               )),
//             ])),

//             if (_pickedImageFile != null) Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text('New photo selected — saves on update',
//                   style: TextStyle(fontSize: 12, color: _teal))),

//             const SizedBox(height: 24),

//             _fieldCard([
//               _field(_firstNameController, 'First Name', Icons.person_outline_rounded),
//               _divider(),
//               _field(_lastNameController, 'Last Name', Icons.person_outline_rounded),
//             ]),
//             const SizedBox(height: 12),
//             _fieldCard([
//               _field(_cityController, 'City', Icons.location_city_outlined),
//               _divider(),
//               _field(_countryController, 'Country', Icons.flag_outlined),
//               _divider(),
//               _field(_addressController, 'Address', Icons.home_outlined, maxLines: 3),
//             ]),
//             const SizedBox(height: 12),
//             _fieldCard([
//               _field(_phoneController, 'Phone Number', Icons.phone_outlined, readOnly: true),
//             ]),

//             const SizedBox(height: 28),

//             GestureDetector(
//               onTap: isSaving ? null : _saveProfile,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: double.infinity, height: 52,
//                 decoration: BoxDecoration(
//                   gradient: isSaving ? null : const LinearGradient(
//                       colors: [_teal, Color(0xFF004D40)],
//                       begin: Alignment.topLeft, end: Alignment.bottomRight),
//                   color: isSaving ? Colors.grey.shade300 : null,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: isSaving ? [] : [BoxShadow(
//                       color: _teal.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
//                 ),
//                 child: Center(child: isSaving
//                     ? Row(mainAxisSize: MainAxisSize.min, children: [
//                         const SizedBox(width: 20, height: 20,
//                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
//                         const SizedBox(width: 12),
//                         Text(isUploadingImage ? 'Uploading photo…' : 'Saving…',
//                             style: const TextStyle(color: Colors.white, fontSize: 15)),
//                       ])
//                     : const Text('Save Changes',
//                         style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget _fieldCard(List<Widget> children) => Container(
//     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
//     child: Column(children: children));

//   Widget _divider() => Divider(height: 1, indent: 52, endIndent: 16, color: Colors.grey.shade100);

//   Widget _field(TextEditingController ctrl, String label, IconData icon,
//       {bool readOnly = false, int maxLines = 1}) =>
//     TextFormField(
//       controller: ctrl, readOnly: readOnly, maxLines: maxLines,
//       style: TextStyle(fontSize: 14, color: readOnly ? Colors.grey.shade500 : Colors.black87),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
//         prefixIcon: Icon(icon, color: readOnly ? Colors.grey.shade400 : _teal, size: 20),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         suffixIcon: readOnly ? Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400) : null,
//       ),
//       validator: readOnly ? null : (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
//     );
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import 'notification_service.dart';
import 'tutorials_screen.dart';
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';
import '../../services/location_service.dart';
import '../../services/profile_service.dart';
import 'LocationMapScreen.dart';
import './cloudinary_service.dart';
import '../pages/sellerForm.dart';
import '../components/LoginPage.dart';

class ProfileScreen extends StatefulWidget {
  final bool isSellerMode;
  final ValueChanged<bool> onToggleMode;
  final String? phoneUID;

  const ProfileScreen({
    super.key,
    required this.isSellerMode,
    required this.onToggleMode,
    this.phoneUID,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _teal = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  late String phoneDocId;
  bool isLoading = true;

  Object userData = {};

  String firstName = '';
  String lastName = '';
  String address = '';
  String phoneNumber = '';
  String userRole = '';
  double longitude = 0;
  double latitude = 0;
  String city = '';
  String country = '';
  String fullAddress = '';
  String imageUrl = '';
  String sellerStatus = '';
  String adminComments = '';

  @override
  void initState() {
    super.initState();
    phoneDocId =
        widget.phoneUID ??
        UserSession().phoneUID ??
        _authService.getUserPhoneDocId() ??
        '';
    _loadUserProfile();
  }

  Future<String> _getSellerStatus() async {
    try {
      final doc = await _firestore.collection('sellers').doc(phoneDocId).get();
      if (doc.exists) {
        final status = doc.data()?['status'] ?? 'none';
        final comments = doc.data()?['comments'] ?? '';
        setState(() => adminComments = comments);
        if (status == 'approved' && userRole != 'seller') {
          await _firestore.collection('users').doc(phoneDocId).update({
            'Role': 'seller',
          });
        }
        return status;
      }
      return 'none';
    } catch (_) {
      return 'none';
    }
  }

  String _getSellerLabel() {
    if (userRole == 'seller') return 'Seller';
    if (sellerStatus == 'submitted') {
      return adminComments.isNotEmpty
          ? 'Address Feedback'
          : 'Submitted (Under Review)';
    }
    return 'Become a Seller';
  }

  Future<void> _loadUserProfile() async {
    try {
      final userDoc = await _authService.getUserProfile(phoneDocId);
      if (userDoc != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        userData = data;

        final lat = (data['latitude'] ?? 0).toDouble();
        final lng = (data['longitude'] ?? 0).toDouble();

        String loadedCity = data['city'] ?? '';
        String loadedCountry = data['country'] ?? '';
        String loadedAddress = data['address'] ?? '';

        final status = await _getSellerStatus();

        if (lat != 0 && lng != 0) {
          try {
            final loc = await LocationService.getAddressFromCoordinates(
              lat,
              lng,
            );
            loadedCity = loc['city'] ?? loadedCity;
            loadedCountry = loc['country'] ?? loadedCountry;
            loadedAddress = LocationService.formatAddress(loc);
          } catch (_) {}
        }

        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          address = loadedAddress;
          phoneNumber = data['phoneNumber'] ?? '';
          userRole = data['Role'] ?? '';
          longitude = lng;
          latitude = lat;
          city = loadedCity;
          country = loadedCountry;
          fullAddress = loadedAddress;
          imageUrl = data['profileImage'] ?? '';
          sellerStatus = status;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _teal, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildSellerToggleOrBecomeCard()),
          SliverToBoxAdapter(child: _buildSectionLabel('Account')),
          SliverToBoxAdapter(
            child: _buildMenuCard([
              _menuTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your name, photo, address',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _EditProfileScreen(phoneDocId: phoneDocId),
                  ),
                ).then((_) => _loadUserProfile()),
              ),
              if (latitude != 0 && longitude != 0)
                _menuTile(
                  icon: Icons.location_on_outlined,
                  title: 'My Location',
                  subtitle: '$city, $country',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                        userName: '$firstName $lastName'.trim(),
                        userRole: userRole.toLowerCase(),
                        address: fullAddress,
                        phoneUID: phoneDocId,
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          SliverToBoxAdapter(child: _buildSectionLabel('Learn & Support')),
          SliverToBoxAdapter(
            child: _buildMenuCard([
              _menuTile(
                icon: Icons.play_circle_outline_rounded,
                title: 'Tutorials',
                subtitle: 'Video courses to master FixRight',
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TutorialsScreen(uid: phoneDocId))),
              ),
              _menuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'FAQs and contact us',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HelpSupportScreen(uid: phoneDocId),
                  ),
                ),
              ),
            ]),
          ),
          SliverToBoxAdapter(child: _buildSectionLabel('Settings')),
          SliverToBoxAdapter(
            child: _buildMenuCard([
              _menuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Security',
                subtitle: 'Control your data and account security',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacySecurityScreen(),
                  ),
                ),
              ),
            ]),
          ),
          SliverToBoxAdapter(child: _buildLogoutBtn()),
          SliverToBoxAdapter(child: _buildVersionTag()),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    final name = '$firstName $lastName'.trim();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _tealDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x55004D40),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row
              Row(
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  NotificationBell(
                    uid: phoneDocId,
                    color: Colors.white,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsPage(uid: phoneDocId),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // profile row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? Text(
                                  firstName.isNotEmpty
                                      ? firstName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (city.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 13,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$city, $country',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 6),
                        // role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            userRole == 'seller'
                                ? '🔧 Verified Seller'
                                : '🛒 Buyer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // edit icon
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _EditProfileScreen(phoneDocId: phoneDocId),
                      ),
                    ).then((_) => _loadUserProfile()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Seller toggle / become seller ─────────────────────────
  Widget _buildSellerToggleOrBecomeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: userRole == 'seller'
          // ── Seller Mode Switch ──
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: widget.isSellerMode
                          ? _teal.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: widget.isSellerMode ? _teal : Colors.grey.shade500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seller Mode',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.isSellerMode
                              ? 'Currently in seller view'
                              : 'Switch to seller dashboard',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: widget.isSellerMode,
                    activeThumbColor: _teal,
                    onChanged: widget.onToggleMode,
                  ),
                ],
              ),
            )
          // ── Become a Seller banner ──
          : GestureDetector(
              onTap: (sellerStatus == 'submitted' && adminComments.isEmpty)
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Sellerform(
                          uid: widget.phoneUID,
                          userData: userData,
                        ),
                      ),
                    ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: adminComments.isNotEmpty
                        ? [Colors.red.shade600, Colors.red.shade800]
                        : sellerStatus == 'submitted'
                        ? [Colors.orange.shade500, Colors.orange.shade700]
                        : [_teal, _tealDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (adminComments.isNotEmpty ? Colors.red : _teal)
                          .withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        adminComments.isNotEmpty
                            ? Icons.warning_amber_rounded
                            : sellerStatus == 'submitted'
                            ? Icons.hourglass_top_rounded
                            : Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSellerLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            adminComments.isNotEmpty
                                ? 'Tap to view feedback and resubmit'
                                : sellerStatus == 'submitted'
                                ? 'Your application is under review'
                                : 'Start earning by offering your skills',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sellerStatus != 'submitted' || adminComments.isNotEmpty)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Section label ─────────────────────────────────────────
  Widget _buildSectionLabel(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 0.8,
      ),
    ),
  );

  // ── Menu card container ───────────────────────────────────
  Widget _buildMenuCard(List<Widget> tiles) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          tiles[i],
          if (i < tiles.length - 1)
            Divider(
              height: 1,
              indent: 56,
              endIndent: 16,
              color: Colors.grey.shade100,
            ),
        ],
      ],
    ),
  );

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool danger = false,
  }) {
    final color = danger ? Colors.red.shade600 : (iconColor ?? _teal);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: danger ? Colors.red.shade600 : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Widget _buildLogoutBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await _authService.signOut();
          // await LoginPage.clearSession();
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildVersionTag() => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Center(
      child: Text(
        'FixRight v1.0.0',
        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  EDIT PROFILE SCREEN — unchanged logic, improved visual
// ═══════════════════════════════════════════════════════════════
class _EditProfileScreen extends StatefulWidget {
  final String phoneDocId;
  const _EditProfileScreen({required this.phoneDocId});

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ProfileService _profileService;

  static const _teal = Color(0xFF00695C);

  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;
  String? errorMessage;

  File? _pickedImageFile;
  String? _currentImageUrl;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.fetchProfile(widget.phoneDocId);
      if (profile != null) {
        setState(() {
          _currentImageUrl = profile.profileImageUrl;
          _firstNameController = TextEditingController(text: profile.firstName);
          _lastNameController = TextEditingController(text: profile.lastName);
          _cityController = TextEditingController(text: profile.city);
          _countryController = TextEditingController(text: profile.country);
          _addressController = TextEditingController(text: profile.address);
          _phoneController = TextEditingController(text: profile.phoneNumber);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Profile not found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Change Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _srcBtn(
                      Icons.photo_library_outlined,
                      'Gallery',
                      Colors.blue,
                      () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _srcBtn(
                      Icons.camera_alt_outlined,
                      'Camera',
                      _teal,
                      () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _pickedImageFile = File(picked.path));
  }

  Widget _srcBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName'.trim();

      String? finalImageUrl = _currentImageUrl;
      if (_pickedImageFile != null) {
        setState(() => isUploadingImage = true);
        final uploaded = await CloudinaryService.uploadImage(
          _pickedImageFile!,
          folder: 'fixright/profiles/${widget.phoneDocId}',
        );
        setState(() => isUploadingImage = false);
        if (uploaded == null) {
          _showErr('Image upload failed.');
          setState(() => isSaving = false);
          return;
        }
        finalImageUrl = uploaded;
      }

      await _profileService.updateProfile(
        widget.phoneDocId,
        firstName: firstName,
        lastName: lastName,
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (finalImageUrl != null && finalImageUrl != _currentImageUrl) {
        await _firestore.collection('users').doc(widget.phoneDocId).update({
          'profileImage': finalImageUrl,
        });
      }

      // sync sellers doc
      try {
        final sd = await _firestore
            .collection('sellers')
            .doc(widget.phoneDocId)
            .get();
        if (sd.exists) {
          await _firestore.collection('sellers').doc(widget.phoneDocId).update({
            'firstName': firstName,
            'lastName': lastName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}

      // sync conversations
      try {
        final convs = await _firestore
            .collection('conversations')
            .where('participantIds', arrayContains: widget.phoneDocId)
            .get();
        if (convs.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in convs.docs) {
            final updates = <String, dynamic>{
              'participantNames.${widget.phoneDocId}': fullName,
            };
            if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
              updates['participantProfileImages.${widget.phoneDocId}'] =
                  finalImageUrl;
            }
            batch.update(doc.reference, updates);
          }
          await batch.commit();
        }
      } catch (_) {}

      setState(() => _currentImageUrl = finalImageUrl);
      _showOk('Profile updated!');
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSaving = false);
      _showErr('Error: $e');
    }
  }

  void _showOk(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: Colors.green.shade600),
  );
  void _showErr(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: Colors.red.shade600),
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _teal)),
      );
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _teal.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!) as ImageProvider
                            : (_currentImageUrl?.isNotEmpty == true
                                  ? NetworkImage(_currentImageUrl!)
                                  : null),
                        child:
                            (_pickedImageFile == null &&
                                (_currentImageUrl?.isEmpty ?? true))
                            ? Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.grey.shade400,
                              )
                            : null,
                      ),
                    ),
                    if (isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: isUploadingImage ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_pickedImageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'New photo selected — saves on update',
                    style: TextStyle(fontSize: 12, color: _teal),
                  ),
                ),

              const SizedBox(height: 24),

              _fieldCard([
                _field(
                  _firstNameController,
                  'First Name',
                  Icons.person_outline_rounded,
                ),
                _divider(),
                _field(
                  _lastNameController,
                  'Last Name',
                  Icons.person_outline_rounded,
                ),
              ]),
              const SizedBox(height: 12),
              _fieldCard([
                _field(_cityController, 'City', Icons.location_city_outlined),
                _divider(),
                _field(_countryController, 'Country', Icons.flag_outlined),
                _divider(),
                _field(
                  _addressController,
                  'Address',
                  Icons.home_outlined,
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 12),
              _fieldCard([
                _field(
                  _phoneController,
                  'Phone Number',
                  Icons.phone_outlined,
                  readOnly: true,
                ),
              ]),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: isSaving ? null : _saveProfile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isSaving
                        ? null
                        : const LinearGradient(
                            colors: [_teal, Color(0xFF004D40)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isSaving ? Colors.grey.shade300 : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSaving
                        ? []
                        : [
                            BoxShadow(
                              color: _teal.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: isSaving
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isUploadingImage
                                    ? 'Uploading photo…'
                                    : 'Saving…',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
      ],
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(
    height: 1,
    indent: 52,
    endIndent: 16,
    color: Colors.grey.shade100,
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool readOnly = false,
    int maxLines = 1,
  }) => TextFormField(
    controller: ctrl,
    readOnly: readOnly,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: 14,
      color: readOnly ? Colors.grey.shade500 : Colors.black87,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
      prefixIcon: Icon(
        icon,
        color: readOnly ? Colors.grey.shade400 : _teal,
        size: 20,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: readOnly
          ? Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400)
          : null,
    ),
    validator: readOnly
        ? null
        : (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
  );
}
