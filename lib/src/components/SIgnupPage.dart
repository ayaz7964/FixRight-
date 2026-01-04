// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:uuid/uuid.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';

// // -------------------------------------------------------------------
// // 🎯 MOCK/PLACEHOLDER SERVICE CLASSES
// // These simulate successful data persistence (Firestore/Cloudinary)
// // -------------------------------------------------------------------

// class UserService {
//   static String? savedGlobalUserId; 

//   Future<void> createUserProfile({
//     required String uid,
//     required String uniqueId,
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String city,
//     required String county,
//     String? photoUrl,
//   }) async {
//     // Simulating database saving delay (e.g., Firestore write)
//     await Future.delayed(const Duration(seconds: 1)); 
//     savedGlobalUserId = uniqueId; 

//     print('✅ User profile saved to Firebase/DB: $uniqueId');
//     print('   - Photo URL: ${photoUrl ?? 'None'}');
//   }
// }

// class ImageService {
//   Future<String?> uploadToCloudinary(File image) async {
//     // Simulating image upload delay (e.g., Cloudinary API call)
//     await Future.delayed(const Duration(seconds: 1));
//     return 'https://cloudinary.com/user_uploads/${const Uuid().v4()}';
//   }
// }

// // -------------------------------------------------------------------
// // 🏠 Dummy Home Screen (Target navigation)
// // -------------------------------------------------------------------

// class HomeScreen extends StatelessWidget {
//   static const routeName = '/home';
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final registeredId = UserService.savedGlobalUserId ?? 'N/A';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Welcome Home!'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green, size: 80),
//               const SizedBox(height: 20),
//               const Text(
//                 'Registration & Authentication Complete!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   'Your Unique App User ID (Proof of persistence):\n$registeredId',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () async {
//                   // Simulate Firebase logout
//                   await FirebaseAuth.instance.signOut(); 
//                   UserService.savedGlobalUserId = null; 
//                   Navigator.of(context).pushNamedAndRemoveUntil(SignupScreen.routeName, (Route<dynamic> route) => false);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Logout'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // -------------------------------------------------------------------
// // 🔐 OTP Verification Screen
// // -------------------------------------------------------------------
// class OtpScreen extends StatefulWidget {
//   final String verificationId;
//   final Map<String, dynamic> userData;

//   const OtpScreen({
//     super.key,
//     required this.verificationId,
//     required this.userData,
//   });

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _isVerifying = false;
//   final _formKey = GlobalKey<FormState>();
//   final Color blue = const Color(0xFF2B7CD3);

//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   // Final step: Authenticate, Save Data, and Navigate
//   Future<void> _verifyAndRegister() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isVerifying = true);
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
//     try {
//       final String smsCode = _otpController.text.trim();

//       final credential = PhoneAuthProvider.credential(
//           verificationId: widget.verificationId, smsCode: smsCode);

//       // Sign in the user with the credential
//       await FirebaseAuth.instance.signInWithCredential(credential);

//       // User authenticated: Proceed to save data in services 
//       await _saveUserDataAndNavigate(widget.userData);

//     } on FirebaseAuthException catch (e) {
//       String message = 'Verification failed. Please check the code.';
//       if (e.code == 'invalid-verification-code') {
//         message = 'The 6-digit code entered is invalid.';
//       } else if (e.code == 'session-expired') {
//         message = 'Code expired. Please go back and resend the code.';
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Auth Error: $message')),
//       );

//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Registration Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isVerifying = false);
//     }
//   }

//   // Data saving logic: Cloudinary (ImageService) and Firestore (UserService)
//   Future<void> _saveUserDataAndNavigate(Map<String, dynamic> data) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     // Step 1: Upload profile image to Cloudinary (Simulated)
//     String? photoUrl;
//     File? imageFile = data['imageFile'] as File?;
//     if (imageFile != null) {
//       photoUrl = await ImageService().uploadToCloudinary(imageFile);
//     }

//     // Step 2: Generate unique userId (UUID)
//     final String userId = const Uuid().v4();

//     // Step 3: Store user info in Firestore (Simulated)
//     await UserService().createUserProfile(
//       uid: user.uid,
//       uniqueId: userId,
//       firstName: data['firstName'],
//       lastName: data['lastName'],
//       phone: data['phone'],
//       // Use "N/A" if location was skipped/failed
//       city: data['city'] ?? 'N/A', 
//       county: data['country'] ?? 'N/A',
//       photoUrl: photoUrl,
//     );
    
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Registration Complete! Redirecting...')));
    
//     Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (Route<dynamic> route) => false);
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify Phone'),
//         backgroundColor: blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.message_rounded, size: 70, color: blue),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Enter the 6-digit code sent to ${widget.userData['phone']}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: _otpController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(6),
//                   ],
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
//                   decoration: InputDecoration(
//                     hintText: '• • • • • •',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                   ),
//                   validator: (v) => (v == null || v.length < 6) ? 'Must be 6 digits' : null,
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isVerifying ? null : _verifyAndRegister,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: blue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       elevation: 4,
//                     ),
//                     child: _isVerifying
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 3,
//                             ),
//                           )
//                         : const Text(
//                             'Verify & Register',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -------------------------------------------------------------------
// // 📝 SIGNUP SCREEN (Initial Data Entry)
// // -------------------------------------------------------------------

// class SignupScreen extends StatefulWidget {
//   static const routeName = '/signup';
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _first = TextEditingController();
//   final _last = TextEditingController();

//   String phone = '';
//   // Initial values set to null to indicate they haven't been fetched yet
//   String? city;
//   String? country;
//   File? _image;

//   bool _saving = false;
//   bool _fetchingLocation = true;
//   final Color blue = const Color(0xFF2B7CD3);

//   @override
//   void initState() {
//     super.initState();
//     // Start fetching location immediately when the screen initializes
//     _getUserLocation();
//   }

//   @override
//   void dispose() {
//     _first.dispose();
//     _last.dispose();
//     super.dispose();
//   }

//   /// ---------------- LOCATION FIXES ----------------
//   Future<void> _getUserLocation() async {
//     try {
//       setState(() => _fetchingLocation = true);
      
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location service disabled.');
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permission denied by user.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions permanently denied.');
//       }

//       // Set timeout for professional experience (prevents ANR)
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium, 
//         timeLimit: const Duration(seconds: 8), // Reduced time to prevent blocking
//       );

//       final placemarks =
//           await placemarkFromCoordinates(pos.latitude, pos.longitude);

//       // Safety check for empty placemarks
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         setState(() {
//           // Use 'Unknown' instead of null placeholder for readability
//           city = p.locality ?? p.subAdministrativeArea ?? 'Unknown City';
//           country = p.country ?? 'Unknown Country';
//         });
//       } else {
//          throw Exception('Could not reverse geocode location.');
//       }
//     } catch (e) {
//       // ⚠️ IMPORTANT FIX: Log error but allow registration to continue.
//       print('Location Fetch Error: ${e.toString()}'); 
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('⚠️ Location could not be detected. Registration will proceed without it.'),
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       // Set to specific values on failure so UI reflects the failure
//       setState(() {
//         city = 'Skipped';
//         country = 'Skipped';
//       });
//     } finally {
//       setState(() => _fetchingLocation = false);
//     }
//   }

//   /// ---------------- IMAGE PICKER ----------------
//   Future<void> _pickImage() async {
//     final picked =
//         await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (picked != null) {
//       setState(() => _image = File(picked.path));
//     }
//   }

//   /// ---------------- PHONE AUTH & NAVIGATION ----------------
//   Future<void> _register() async {
//     // 1. Initial Validation
//     if (!_formKey.currentState!.validate()) return;
//     if (phone.isEmpty || phone.length < 10) { 
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Please enter a complete phone number.')));
//       return;
//     }

//     setState(() => _saving = true);
//     ScaffoldMessenger.of(context).hideCurrentSnackBar(); 

//     try {
//       // 2. Start Firebase Phone Authentication
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phone,
        
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           // If auto-verified, go straight to saving data (passing current state data)
//           await _onUserAuthenticated(FirebaseAuth.instance.currentUser, isAuto: true);
//         },
        
//         // 3. Error Handling for common failures
//         verificationFailed: (e) {
//           setState(() => _saving = false);
//           String message = 'Phone verification failed.';
//           if (e.code == 'invalid-phone-number') {
//             message = 'Invalid phone number format or country code.';
//           } else if (e.code == 'too-many-requests') {
//             message = 'Too many requests. Please try again later.';
//           } else {
//             message = e.message ?? 'Unknown authentication error.';
//           }
        
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('❌ Auth Error: $message')));
//         },
        
//         // 4. Code Sent: Navigate to OTP Screen
//         codeSent: (verificationId, resendToken) async {
          
//           setState(() => _saving = false);

//           final userData = {
//             'firstName': _first.text.trim(),
//             'lastName': _last.text.trim(),
//             'phone': phone,
//             // Pass actual location data, or null/skipped markers
//             'city': city, 
//             'country': country,
//             'imageFile': _image,
//           };
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Verification code sent. Redirecting...')),
//           );

//           // Push to the dedicated OTP screen for verification
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (ctx) => OtpScreen(
//                 verificationId: verificationId,
//                 userData: userData,
//               ),
//             ),
//           );
//         },
        
//         codeAutoRetrievalTimeout: (verificationId) {},
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('❌ Critical Error: ${e.toString()}')));
//       setState(() => _saving = false);
//     }
//   }

//   // Handles data saving for the rare auto-verification path
//   Future<void> _onUserAuthenticated(User? user, {required bool isAuto}) async {
//     if (user == null || !isAuto) return;
    
//     final String userId = const Uuid().v4();
//     String? photoUrl;
//     if (_image != null) {
//         photoUrl = await ImageService().uploadToCloudinary(_image!);
//     }

//     await UserService().createUserProfile(
//         uid: user.uid,
//         uniqueId: userId,
//         firstName: _first.text.trim(),
//         lastName: _last.text.trim(),
//         phone: phone,
//         city: city ?? 'N/A',
//         county: country ?? 'N/A',
//         photoUrl: photoUrl,
//     );
    
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Auto Registration Complete!')));
            
//     Navigator.pushReplacementNamed(context, HomeScreen.routeName);
//   }


//   /// ---------------- UI BUILD ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Gradient background
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [blue, const Color(0xFF1366C0)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),

//           // Content Card
//           Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                 padding: const EdgeInsets.all(26),
//                 constraints: const BoxConstraints(maxWidth: 400),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(22),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 15,
//                       spreadRadius: 3,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       // Header
//                       Row(
//                         children: [
//                           IconButton(
//                             onPressed:() => Navigator.pushReplacementNamed(context, '/')
//                             //  () => Navigator.of(context).pop()
//                              ,
//                             icon: Icon(Icons.arrow_back_ios_new_rounded,
//                                 color: blue),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Create Account',
//                             style: TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.w800,
//                               color: blue,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),

//                       // Avatar 
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             CircleAvatar(
//                               radius: 55,
//                               backgroundColor: Colors.grey[200],
//                               backgroundImage:
//                                   _image != null ? FileImage(_image!) as ImageProvider : null,
//                               child: _image == null
//                                   ? Icon(Icons.camera_alt_outlined,
//                                       color: Colors.grey[600], size: 36)
//                                   : null,
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: blue,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 3),
//                               ),
//                               padding: const EdgeInsets.all(6),
//                               child: const Icon(Icons.edit,
//                                   size: 18, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 30),

//                       // Form fields
//                       _buildTextField(_first, 'First Name', Icons.person),
//                       const SizedBox(height: 18),
//                       _buildTextField(_last, 'Last Name', Icons.person_outline),
//                       const SizedBox(height: 18),

//                       // Location section - Handles loading, success, or failure state
//                       _fetchingLocation
//                           ? Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               child: Column(
//                                 children: [
//                                   LinearProgressIndicator(color: blue),
//                                   const SizedBox(height: 8),
//                                   const Text('Detecting location. Please wait...',
//                                       style: TextStyle(color: Colors.grey)),
//                                 ],
//                               ),
//                             )
//                           : Column(
//                               children: [
//                                 _buildReadOnlyField(
//                                   label: 'City',
//                                   value: city ?? 'Skipped/Unavailable',
//                                   icon: Icons.location_city,
//                                 ),
//                                 const SizedBox(height: 18),
//                                 _buildReadOnlyField(
//                                   label: 'Country',
//                                   value: country ?? 'Skipped/Unavailable',
//                                   icon: Icons.flag_circle_outlined,
//                                 ),
//                               ],
//                             ),

//                       const SizedBox(height: 18),
                      
//                       // Phone Number Field
//                       IntlPhoneField(
//                         initialCountryCode: 'PK', // Default country code
//                         decoration: _buildInputDecoration(
//                             labelText: 'Phone Number', icon: Icons.phone),
//                         onChanged: (p) => phone = p.completeNumber,
//                         validator: (p) => (p == null || p.number.isEmpty || p.number.length < 5)
//                             ? 'Please enter your phone number'
//                             : null,
//                       ),
                      
//                       const SizedBox(height: 30),

//                       // Register Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _saving ? null : _register,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: blue,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             elevation: 8,
//                           ),
//                           child: _saving
//                               ? const SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 3,
//                                   ),
//                                 )
//                               : const Text(
//                                   'Send Verification Code',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper for consistent Input Decoration styling
//   InputDecoration _buildInputDecoration({required String labelText, required IconData icon}) {
//     return InputDecoration(
//       labelText: labelText,
//       prefixIcon: Icon(icon, color: blue),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: blue, width: 2.0),
//       ),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }

//   /// ---------------- REUSABLE UI COMPONENTS ----------------
//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon) {
//     return TextFormField(
//       controller: controller,
//       decoration: _buildInputDecoration(labelText: label, icon: icon),
//       validator: (v) => v!.trim().isEmpty ? 'Enter $label' : null,
//     );
//   }

//   Widget _buildReadOnlyField(
//       {required String label, required String value, required IconData icon}) {
//     return TextFormField(
//       readOnly: true,
//       initialValue: value,
//       decoration: _buildInputDecoration(labelText: label, icon: icon).copyWith(
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//     );
//   }
// }



import 'dart:ui';

import 'package:flutter/material.dart';
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            
          ],
        )
      ),
    );
  }
}