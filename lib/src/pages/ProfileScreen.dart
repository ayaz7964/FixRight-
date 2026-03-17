// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../services/auth_service.dart';
// import '../../services/user_session.dart';
// import '../../services/user_data_helper.dart';
// import '../../services/location_service.dart';
// import '../../services/profile_service.dart';
// import 'LocationMapScreen.dart';
// import '../../services/profileImageUploader.dart';
// import '../../services/test.dart';
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

//   // User profile data
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
//   String sellerStatus = ''; // 'none', 'submitted', 'approved'
//   String adminComments = ''; // Track admip comments

//   @override
//   void initState() {
//     super.initState();
//     // Use provided phoneUID or get from UserSession or AuthService
//     phoneDocId =
//         widget.phoneUID ??
//         UserSession().phoneUID ??
//         _authService.getUserPhoneDocId() ??
//         '';
//     _loadUserProfile();
//   }

//   /// Get seller status from Firestore sellers collection and sync with user Role
//   Future<String> _getSellerStatus() async {
//     try {
//       final sellerDoc = await _firestore
//           .collection('sellers')
//           .doc(phoneDocId)
//           .get();
//       if (sellerDoc.exists) {
//         final status = sellerDoc.data()?['status'] ?? 'none';
//         final comments = sellerDoc.data()?['comments'] ?? '';

//         // Store admin comments
//         setState(() {
//           adminComments = comments;
//         });

//         // Auto-sync: If seller is approved, update user Role to 'seller'
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

//   /// Get seller status label for UI display
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
//       'Role': 'seller', // ← Automatic update from "buyer" to "seller"
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

//         // Load address details from coordinates using LocationService
//         String loadedCity = data['city'] ?? '';
//         String loadedCountry = data['country'] ?? '';
//         String loadedAddress = data['address'] ?? '';
//         String ProfileImage = data['profileImage'] ?? '';
//         imageUrl = ProfileImage;

//         // Get so there is one last issue 
//         //, when the seller has applied and he also sucessfull entertain the feedback and at last when the admin have approved the seller so the issue is that instead of updating the users role to seller in users document it just giving the option became seller and accourding to our login when the admin approves the seller so the users role should be converted to seller and after that the switch bar apppers automatically and seller mode on and off and switch automaticallu status
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

//   // Options for the BUYER/Client mode
//   final List<Map<String, dynamic>> _buyerOptions = [
//     {'icon': Icons.diamond, 'title': 'Get inspired'},
//     {'icon': Icons.favorite_border, 'title': 'Saved lists'},
//     {'icon': Icons.insights, 'title': 'My interests'},
//     {'icon': Icons.send, 'title': 'Invite friends'},
//   ];

//   // Options for the SELLER/Worker mode
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
//       trailing: const Icon(
//         Icons.arrow_forward_ios,
//         size: 16,
//         color: Colors.grey,
//       ),
//       onTap:
//           onTap ??
//           () {
//             debugPrint('Tapped: $title');
//           },
//     );
//   }

//   /// Edit profile screen - fully functional with data loading and image upload
//   Widget _UpdateUserProfileScreen(String phoneDocId) {
//     return _EditProfileScreen(phoneDocId: phoneDocId);
//   }

//   void _showEditProfileDialog(phoneDocId) {
//     final firstNameController = TextEditingController(text: firstName);
//     final lastNameController = TextEditingController(text: lastName);
//     final addressController = TextEditingController(text: address);
//     final phoneNumberController = TextEditingController(text: mobile);

//     // showDialog(
//     //   context: context,
//     //   builder: (context) => AlertDialog(
//     //     title: const Text('Edit Profile '),
//     //     content: SingleChildScrollView(
//     //       child: Column(
//     //         mainAxisSize: MainAxisSize.min,
//     //         children: [
//     //           TextField(
//     //             controller: firstNameController,
//     //             decoration: const InputDecoration(
//     //               labelText: 'First Name',
//     //               border: OutlineInputBorder(),
//     //             ),
//     //           ),
//     //           const SizedBox(height: 12),
//     //           TextField(
//     //             controller: lastNameController,
//     //             decoration: const InputDecoration(
//     //               labelText: 'Last Name',
//     //               border: OutlineInputBorder(),
//     //             ),
//     //           ),
//     //           const SizedBox(height: 12),
//     //           TextField(
//     //             controller: addressController,
//     //             decoration: const InputDecoration(
//     //               labelText: 'Address',
//     //               border: OutlineInputBorder(),
//     //             ),
//     //             maxLines: 3,
//     //           ),
//     //           const SizedBox(height: 12),
//     //           TextField(
//     //             controller: phoneNumberController,
//     //             decoration: InputDecoration(
//     //               labelText: mobile ?? '',
//     //               border: OutlineInputBorder(),
//     //             ),
//     //             enabled: false,
//     //           ),
//     //         ],
//     //       ),
//     //     ),
//     //     actions: [
//     //       TextButton(
//     //         onPressed: () => Navigator.pop(context),
//     //         child: const Text('Cancel'),
//     //       ),
//     //       ElevatedButton(
//     //         onPressed: () async {
//     //           await _updateProfile(
//     //             firstNameController.text,
//     //             lastNameController.text,
//     //             addressController.text,
//     //           );
//     //           Navigator.pop(context);
//     //         },
//     //         child: const Text('Save'),
//     //       ),
//     //     ],
//     //   ),

//     // );
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
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
//     }
//   }

//   // --- Main Build Method ---
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
//             // 1. Header Container (Dynamic Color)
//             Container(
//               width: double.infinity,
//               height: 230,
//               padding: const EdgeInsets.only(
//                 top: 20,
//                 bottom: 10,
//                 left: 16,
//                 right: 16,
//               ),
//               decoration: BoxDecoration(color: primaryColor),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Profile Info Row (Avatar, Name, Balance)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Stack for Avatar + Online Dot
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
//                           // Online Status Dot
//                           Positioned(
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.greenAccent.shade400,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 10),
//                       // User Name and Balance
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
//                           Text('UserRole:$UserRole ',style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                             ),),
//                            Text(
//                             'Address: $address \nCity: $city \nCounty:  $country',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10,),
//                   const Spacer(),
//                   UserRole == 'seller'
//                       ? // Seller Mode Switch Container
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
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
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
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
//                       : // Not Seller - Show Status Button
//                         Padding(
//                           padding: const EdgeInsets.all(14.0),
//                           child: ElevatedButton(
//                             onPressed:
//                                 (sellerStatus == 'submitted' &&
//                                     adminComments.isEmpty)
//                                 ? null
//                                 : () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => Sellerform(
//                                         uid: widget.phoneUID,
//                                         userData: userData,
//                                       ),
//                                     ),
//                                   ),
  
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(double.infinity, 50),
//                               backgroundColor: adminComments.isNotEmpty
//                                   ? Colors
//                                         .red
//                                         .shade600 // Red when feedback exists
//                                   : (sellerStatus == 'submitted'
//                                         ? Colors.orange.shade600
//                                         : Colors.white),
//                               disabledBackgroundColor: Colors.orange.shade600,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               _getSellerLabel(),
//                               style: TextStyle(
//                                 color:
//                                     (sellerStatus == 'submitted' ||
//                                         adminComments.isNotEmpty)
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

//             // 2. "My Profile" Tile (Edit Form)
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
//               // onTap: () => _showEditProfileDialog(phoneDocId),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => _UpdateUserProfileScreen(phoneDocId),
//                 ),
//               ),
//             ),

//             // 2B. Location Info Card
//             if (latitude != 0 && longitude != 0)
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
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
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         if (fullAddress.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               fullAddress,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade600,
//                               ),
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

//             // 3. Dynamic Options List
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

//             // Generate the list of options
//             ...currentOptions.map(
//               (option) => _buildProfileOption(
//                 icon: option['icon'] as IconData,
//                 title: option['title'] as String,
//                 color: optionColor,
//               ),
//             ),

//             // 4. General Settings (Visible in both modes)
//             const Padding(
//               padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
//               child: Text(
//                 'Settings',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const Divider(height: 15),
//             _buildProfileOption(
//               icon: Icons.settings,
//               title: 'Preferences',
//               color: Colors.grey.shade700,
//             ),

//             // Logout Button
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
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Logout',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Stateful edit profile screen with data loading and image upload
// class _EditProfileScreen extends StatefulWidget {
//   final String phoneDocId;

//   const _EditProfileScreen({required this.phoneDocId});

//   @override
//   State<_EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<_EditProfileScreen> {
//   late ProfileService _profileService;

//   late UserProfile _profile;
//   bool isLoading = true;
//   bool isSaving = false;
//   String? errorMessage;

//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _cityController;
//   late TextEditingController _countryController;
//   late TextEditingController _addressController;
//   late TextEditingController _phoneController;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _profileService = ProfileService();
//     _loadProfile();
//   }

//   /// Load profile data from Firestore
//   Future<void> _loadProfile() async {
//     try {
//       final profile = await _profileService.fetchProfile(widget.phoneDocId);
//       if (profile != null) {
//         setState(() {
//           _profile = profile;
//           _initializeControllers(profile);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Profile not found';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Error loading profile: $e';
//       });
//     }
//   }

//   /// Initialize text controllers with profile data
//   void _initializeControllers(UserProfile profile) {
//     _firstNameController = TextEditingController(text: profile.firstName);
//     _lastNameController = TextEditingController(text: profile.lastName);
//     _cityController = TextEditingController(text: profile.city);
//     _countryController = TextEditingController(text: profile.country);
//     _addressController = TextEditingController(text: profile.address);
//     _phoneController = TextEditingController(text: profile.phoneNumber);
//   }

//   /// Save profile changes to Firestore
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Validate using service
//     final validationError = ProfileService.validateProfile(
//       firstName: _firstNameController.text,
//       lastName: _lastNameController.text,
//       city: _cityController.text,
//       country: _countryController.text,
//       address: _addressController.text,
//     );

//     if (validationError != null) {
//       _showErrorSnackBar(validationError);
//       return;
//     }

//     setState(() => isSaving = true);

//     try {
//       await _profileService.updateProfile(
//         widget.phoneDocId,
//         firstName: _firstNameController.text,
//         lastName: _lastNameController.text,
//         city: _cityController.text,
//         country: _countryController.text,
//         address: _addressController.text,
//       );

//       _showSuccessSnackBar('Profile updated successfully');
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => isSaving = false);
//       _showErrorSnackBar('Error saving profile: $e');
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green.shade600),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
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
//         appBar: AppBar(title: const Text('My Profile ')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('My Profile ')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(errorMessage!),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _loadProfile,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Update My Profile '), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Profile Image
//               // CircleAvatar(
//               //   radius: 60,
//               //   backgroundColor: Colors.grey.shade300,
//               //   backgroundImage: _profile.profileImageUrl != null
//               //       ? NetworkImage(_profile.profileImageUrl!)
//               //       : null,
//               //   child: _profile.profileImageUrl == null
//               //       ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
//               //       : null,
//               // ),
//               ProfileImageUploader(
//                 uid: widget.phoneDocId,
//                 imageUrl: _profile.profileImageUrl,
//                 radius: 60,
//               ),

//               const SizedBox(height: 16),

//               // ImageUploadScreen(),
//               SizedBox(height: 24),

//               // First Name
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               // Last Name
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               // City
//               TextFormField(
//                 controller: _cityController,
//                 decoration: InputDecoration(
//                   labelText: 'City',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               // Country
//               TextFormField(
//                 controller: _countryController,
//                 decoration: InputDecoration(
//                   labelText: 'Country',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               // Address
//               TextFormField(
//                 controller: _addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Address',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLines: 3,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               // Phone (Read-only)
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   suffixIcon: Icon(
//                     Icons.lock,
//                     color: Colors.grey.shade400,
//                     size: 18,
//                   ),
//                 ),
//                 readOnly: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),

//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isSaving ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     disabledBackgroundColor: Colors.grey.shade300,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: isSaving
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'Save Changes',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';
import '../../services/location_service.dart';
import '../../services/profile_service.dart';
import 'LocationMapScreen.dart';
import './cloudinary_service.dart';
import '../pages/sellerForm.dart';

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
  late String phoneDocId;
  bool isLoading = true;
  final mobile = UserSession().phoneUID;
  final UserDataHelper _userDataHelper = UserDataHelper();
  Object userData = {};

  UserDataHelper userDataHelper = UserDataHelper();

  String firstName = '';
  String lastName = '';
  String address = '';
  String phoneNumber = '';
  String UserRole = '';
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
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(phoneDocId)
          .get();
      if (sellerDoc.exists) {
        final status = sellerDoc.data()?['status'] ?? 'none';
        final comments = sellerDoc.data()?['comments'] ?? '';

        setState(() {
          adminComments = comments;
        });

        if (status == 'approved' && UserRole != 'seller') {
          try {
            await _firestore.collection('users').doc(phoneDocId).update({
              'Role': 'seller',
            });
            print('User role automatically updated to seller');
          } catch (e) {
            print('Error auto-updating user role: $e');
          }
        }

        return status;
      }
      return 'none';
    } catch (e) {
      print('Error getting seller status: $e');
      return 'none';
    }
  }

  String _getSellerLabel() {
    if (UserRole == 'seller') {
      return 'Seller';
    } else if (sellerStatus == 'submitted') {
      return adminComments.isNotEmpty
          ? 'Address Feedback'
          : 'Submitted (Under Review)';
    } else {
      return 'Became Seller';
    }
  }

  Future<void> updateRole() async {
    await _firestore.collection('users').doc(phoneDocId).update({
      'Role': 'seller',
    });
    print('User role automatically updated to seller');
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
        String ProfileImage = data['profileImage'] ?? '';
        imageUrl = ProfileImage;

        final status = await _getSellerStatus();

        if (lat != 0 && lng != 0) {
          try {
            final locationDetails =
                await LocationService.getAddressFromCoordinates(lat, lng);
            loadedCity = locationDetails['city'] ?? loadedCity;
            loadedCountry = locationDetails['country'] ?? loadedCountry;
            loadedAddress = LocationService.formatAddress(locationDetails);
          } catch (e) {
            print('Error getting location details: $e');
          }
        }

        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          address = loadedAddress;
          phoneNumber = data['phoneNumber'] ?? '';
          UserRole = data['Role'] ?? '';
          longitude = lng;
          latitude = lat;
          city = loadedCity;
          country = loadedCountry;
          fullAddress = loadedAddress;
          sellerStatus = status;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _buyerOptions = [
    {'icon': Icons.diamond, 'title': 'Get inspired'},
    {'icon': Icons.favorite_border, 'title': 'Saved lists'},
    {'icon': Icons.insights, 'title': 'My interests'},
    {'icon': Icons.send, 'title': 'Invite friends'},
  ];

  final List<Map<String, dynamic>> _sellerOptions = [
    {'icon': Icons.account_balance_wallet, 'title': 'Earnings'},
    {'icon': Icons.description, 'title': 'Custom offer templates'},
    {'icon': Icons.text_snippet, 'title': 'Briefs'},
    {'icon': Icons.share, 'title': 'Share Gigs'},
  ];

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ?? () { debugPrint('Tapped: $title'); },
    );
  }

  Widget _UpdateUserProfileScreen(String phoneDocId) {
    return _EditProfileScreen(phoneDocId: phoneDocId);
  }

  void _showEditProfileDialog(phoneDocId) {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final addressController = TextEditingController(text: address);
    final phoneNumberController = TextEditingController(text: mobile);
  }

  Future<void> _updateProfile(
    String newFirstName,
    String newLastName,
    String newAddress,
  ) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'firstName': newFirstName,
        'lastName': newLastName,
        'address': newAddress,
      });

      setState(() {
        firstName = newFirstName;
        lastName = newLastName;
        address = newAddress;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentOptions = widget.isSellerMode ? _sellerOptions : _buyerOptions;
    final primaryColor = widget.isSellerMode
        ? Colors.green.shade700
        : const Color(0xFF2B7CD3);
    final headerText = widget.isSellerMode ? 'Selling' : 'My FixRight';
    final Color optionColor = widget.isSellerMode
        ? Colors.green.shade700
        : const Color(0xFF2B7CD3);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('My Profile'), Icon(Icons.notifications)],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 230,
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? Text(
                                    firstName.isNotEmpty
                                        ? firstName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$firstName $lastName'.trim(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'UserRole:$UserRole ',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            'Address: $address \nCity: $city \nCounty:  $country',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Spacer(),
                  UserRole == 'seller'
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Seller Mode',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Switch(
                                value: widget.isSellerMode,
                                activeThumbColor: primaryColor,
                                onChanged: (bool newValue) {
                                  widget.onToggleMode(newValue);
                                },
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: ElevatedButton(
                            onPressed: (sellerStatus == 'submitted' && adminComments.isEmpty)
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Sellerform(
                                          uid: widget.phoneUID,
                                          userData: userData,
                                        ),
                                      ),
                                    ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: adminComments.isNotEmpty
                                  ? Colors.red.shade600
                                  : (sellerStatus == 'submitted'
                                      ? Colors.orange.shade600
                                      : Colors.white),
                              disabledBackgroundColor: Colors.orange.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _getSellerLabel(),
                              style: TextStyle(
                                color: (sellerStatus == 'submitted' || adminComments.isNotEmpty)
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 15),
            _buildProfileOption(
              icon: Icons.person,
              title: 'Update Profile ',
              color: optionColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _UpdateUserProfileScreen(phoneDocId),
                ),
              ),
            ),

            if (latitude != 0 && longitude != 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: optionColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: optionColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$city, $country',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (fullAddress.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              fullAddress,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationMapScreen(
                                    latitude: latitude,
                                    longitude: longitude,
                                    userName: '$firstName $lastName'.trim(),
                                    userRole: UserRole.toLowerCase(),
                                    address: fullAddress,
                                    phoneUID: phoneDocId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: optionColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                headerText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 15),

            ...currentOptions.map(
              (option) => _buildProfileOption(
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                color: optionColor,
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const Divider(height: 15),
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Preferences',
              color: Colors.grey.shade700,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EDIT PROFILE SCREEN  — all cross-document sync lives here
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
  late UserProfile _profile;

  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;
  String? errorMessage;

  // Local image file selected by user (not yet saved)
  File? _pickedImageFile;
  // The URL that will be saved — starts as existing, updates after upload
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
          _profile = profile;
          _currentImageUrl = profile.profileImageUrl;
          _initializeControllers(profile);
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; errorMessage = 'Profile not found'; });
      }
    } catch (e) {
      setState(() { isLoading = false; errorMessage = 'Error loading profile: $e'; });
    }
  }

  void _initializeControllers(UserProfile profile) {
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController  = TextEditingController(text: profile.lastName);
    _cityController      = TextEditingController(text: profile.city);
    _countryController   = TextEditingController(text: profile.country);
    _addressController   = TextEditingController(text: profile.address);
    _phoneController     = TextEditingController(text: profile.phoneNumber);
  }

  // ── Image Picker ─────────────────────────────────────────────
  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _sourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: Colors.blue,
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _sourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: Colors.green,
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  )),
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

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Save Profile + Sync All Documents ────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final validationError = ProfileService.validateProfile(
      firstName: _firstNameController.text,
      lastName:  _lastNameController.text,
      city:      _cityController.text,
      country:   _countryController.text,
      address:   _addressController.text,
    );
    if (validationError != null) { _showError(validationError); return; }

    setState(() => isSaving = true);

    try {
      final String firstName = _firstNameController.text.trim();
      final String lastName  = _lastNameController.text.trim();
      final String fullName  = '$firstName $lastName'.trim();

      // ── Step 1: Upload new image if user picked one ──────────
      String? finalImageUrl = _currentImageUrl;
      if (_pickedImageFile != null) {
        setState(() => isUploadingImage = true);
        final uploaded = await CloudinaryService.uploadImage(
          _pickedImageFile!,
          folder: 'fixright/profiles/${widget.phoneDocId}',
        );
        setState(() => isUploadingImage = false);

        if (uploaded == null) {
          _showError('Image upload failed. Please try again.');
          setState(() => isSaving = false);
          return;
        }
        finalImageUrl = uploaded;
      }

      // ── Step 2: Update users/{uid} ───────────────────────────
      await _profileService.updateProfile(
        widget.phoneDocId,
        firstName: firstName,
        lastName:  lastName,
        city:      _cityController.text.trim(),
        country:   _countryController.text.trim(),
        address:   _addressController.text.trim(),
      );

      // Update profileImage in users doc if changed
      if (finalImageUrl != null && finalImageUrl != _currentImageUrl) {
        await _firestore.collection('users').doc(widget.phoneDocId).update({
          'profileImage': finalImageUrl,
        });
      }

      // ── Step 3: Update sellers/{uid} if doc exists ───────────
      await _syncSellerDocument(firstName, lastName);

      // ── Step 4: Update all conversations this user is in ─────
      await _syncConversations(fullName, finalImageUrl);

      // Refresh local state
      setState(() => _currentImageUrl = finalImageUrl);

      _showSuccess('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSaving = false);
      _showError('Error saving profile: $e');
    }
  }

  /// Update firstName & lastName in sellers collection (if seller doc exists)
  Future<void> _syncSellerDocument(String firstName, String lastName) async {
    try {
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(widget.phoneDocId)
          .get();

      if (sellerDoc.exists) {
        await _firestore
            .collection('sellers')
            .doc(widget.phoneDocId)
            .update({
          'firstName': firstName,
          'lastName':  lastName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Seller document synced');
      }
    } catch (e) {
      print('⚠️ Seller sync skipped: $e');
      // Non-critical — don't block save
    }
  }

  /// Update participantNames & participantProfileImages in all conversations
  Future<void> _syncConversations(String fullName, String? imageUrl) async {
    try {
      // Find all conversations where this user is a participant
      final conversationsSnap = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: widget.phoneDocId)
          .get();

      if (conversationsSnap.docs.isEmpty) return;

      // Batch write for efficiency
      final WriteBatch batch = _firestore.batch();

      for (final doc in conversationsSnap.docs) {
        final Map<String, dynamic> updates = {
          'participantNames.${widget.phoneDocId}': fullName,
        };

        // Only update image if we have one
        if (imageUrl != null && imageUrl.isNotEmpty) {
          updates['participantProfileImages.${widget.phoneDocId}'] = imageUrl;
        }

        batch.update(doc.reference, updates);
      }

      await batch.commit();
      print('✅ ${conversationsSnap.docs.length} conversation(s) synced');
    } catch (e) {
      print('⚠️ Conversations sync skipped: $e');
      // Non-critical — don't block save
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green.shade600),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
    );
  }

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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // ── Profile Image with Edit Button ───────────────
              Center(
                child: Stack(
                  children: [
                    // Avatar — shows picked file first, then existing URL
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _pickedImageFile != null
                          ? FileImage(_pickedImageFile!) as ImageProvider
                          : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                              ? NetworkImage(_currentImageUrl!)
                              : null),
                      child: (_pickedImageFile == null &&
                              (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                          ? Icon(Icons.person, size: 60, color: Colors.grey.shade500)
                          : null,
                    ),

                    // Upload indicator overlay
                    if (isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),

                    // Edit button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: isUploadingImage ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // "Tap to change" hint
              if (_pickedImageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'New photo selected — will upload on save',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Form Fields ──────────────────────────────────
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: Icon(Icons.lock, color: Colors.grey.shade400, size: 18),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 32),

              // ── Save Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isUploadingImage ? 'Uploading photo...' : 'Saving...',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
}

