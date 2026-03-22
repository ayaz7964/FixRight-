// // // import 'package:flutter/material.dart';
// // // import 'package:country_picker/country_picker.dart';
// // // import '../../services/auth_service.dart';
// // // import 'OtpVerificationPage.dart';

// // // class RegistrationPage extends StatefulWidget {
// // //   const RegistrationPage({super.key});

// // //   @override
// // //   State<RegistrationPage> createState() => _RegistrationPageState();
// // // }

// // // class _RegistrationPageState extends State<RegistrationPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _firstNameController = TextEditingController();
// // //   final _lastNameController = TextEditingController();
// // //   final _phoneController = TextEditingController();
// // //   final _cityController = TextEditingController();
// // //   final _addressController = TextEditingController();
// // //   final _passwordController = TextEditingController();
// // //   final _confirmPasswordController = TextEditingController();

// // //   bool isLoading = false;
// // //   String? selectedCountryCode;
// // //   String? selectedCountryName;
// // //   bool _showPassword = false;
// // //   bool _showConfirmPassword = false;

// // //   // Default to Pakistan
// // //   Country selectedCountry = Country(
// // //     phoneCode: '92',
// // //     countryCode: 'PK',
// // //     e164Sc: 0,
// // //     geographic: true,
// // //     level: 1,
// // //     name: 'Pakistan',
// // //     example: 'Pakistan',
// // //     displayName: 'Pakistan',
// // //     displayNameNoCountryCode: 'Pakistan',
// // //     e164Key: '',
// // //   );

// // //   final AuthService _authService = AuthService();

// // //   @override
// // //   void dispose() {
// // //     _firstNameController.dispose();
// // //     _lastNameController.dispose();
// // //     _phoneController.dispose();
// // //     _cityController.dispose();
// // //     _addressController.dispose();
// // //     _passwordController.dispose();
// // //     _confirmPasswordController.dispose();
// // //     super.dispose();
// // //   }

// // //   /// Validate password (minimum 6 characters)
// // //   bool _validatePassword(String password) {
// // //     return password.length >= 6;
// // //   }

// // //   /// Send OTP to phone number
// // //   Future<void> _sendOtp() async {
// // //     if (!_formKey.currentState!.validate()) {
// // //       return;
// // //     }

// // //     // Validate password
// // //     if (!_validatePassword(_passwordController.text.trim())) {
// // //       _showError('Password must be at least 6 characters');
// // //       return;
// // //     }

// // //     // Validate passwords match
// // //     if (_passwordController.text.trim() !=
// // //         _confirmPasswordController.text.trim()) {
// // //       _showError('Passwords do not match');
// // //       return;
// // //     }

// // //     // Check if user already exists
// // //     final phoneNumber =
// // //         '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';
// // //     final userExists = await _authService.userExists(phoneNumber);

// // //     if (userExists) {
// // //       if (mounted) {
// // //         _showError('User already registered. Please login instead.');
// // //       }
// // //       return;
// // //     }

// // //     setState(() => isLoading = true);

// // //     try {
// // //       await _authService.sendOtp(
// // //         phoneNumber,
// // //         codeSent: (verificationId) {
// // //           if (mounted) {
// // //             setState(() => isLoading = false);
// // //             Navigator.of(context).push(
// // //               MaterialPageRoute(
// // //                 builder: (context) => OtpVerificationPage(
// // //                   verificationId: verificationId,
// // //                   phoneNumber: phoneNumber,
// // //                   firstName: _firstNameController.text.trim(),
// // //                   lastName: _lastNameController.text.trim(),
// // //                   city: _cityController.text.trim(),
// // //                   country: selectedCountry.name,
// // //                   address: _addressController.text.trim(),
// // //                   password: _passwordController.text.trim(),
// // //                 ),
// // //               ),
// // //             );
// // //           }
// // //         },
// // //         verificationFailed: (exception) {
// // //           if (mounted) {
// // //             setState(() => isLoading = false);
// // //             String message = 'OTP verification failed';
// // //             if (exception.code == 'invalid-phone-number') {
// // //               message = 'Invalid phone number';
// // //             } else if (exception.code == 'too-many-requests') {
// // //               message = 'Too many attempts. Please try again later.';
// // //             }
// // //             _showError(message);
// // //           }
// // //         },
// // //       );
// // //     } catch (e) {
// // //       if (mounted) {
// // //         setState(() => isLoading = false);
// // //         _showError('Error sending OTP: $e');
// // //       }
// // //     }
// // //   }

// // //   /// Show error snackbar
// // //   void _showError(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.red,
// // //         duration: const Duration(seconds: 4),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.blue.shade50,
// // //       appBar: AppBar(
// // //         title: const Text('Create Account'),
// // //         elevation: 0,
// // //         backgroundColor: Colors.blue.shade50,
// // //         leading: IconButton(
// // //           onPressed: () => Navigator.of(context).pop(),
// // //           icon: const Icon(Icons.arrow_back, color: Colors.black87),
// // //         ),
// // //       ),
// // //       body: SafeArea(
// // //         child: SingleChildScrollView(
// // //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// // //           child: Form(
// // //             key: _formKey,
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // Header
// // //                 const Text(
// // //                   'Register Now',
// // //                   style: TextStyle(
// // //                     fontSize: 24,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Colors.black87,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 const Text(
// // //                   'Create your account to get started',
// // //                   style: TextStyle(fontSize: 14, color: Colors.grey),
// // //                 ),
// // //                 const SizedBox(height: 24),

// // //                 // First Name
// // //                 TextFormField(
// // //                   controller: _firstNameController,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'First Name',
// // //                     prefixIcon: const Icon(Icons.person),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.trim().isEmpty) {
// // //                       return 'Please enter your first name';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Last Name
// // //                 TextFormField(
// // //                   controller: _lastNameController,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'Last Name',
// // //                     prefixIcon: const Icon(Icons.person),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.trim().isEmpty) {
// // //                       return 'Please enter your last name';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Country Picker
// // //                 Text(
// // //                   'Select Country',
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.w600,
// // //                     color: Colors.grey.shade700,
// // //                     fontSize: 14,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 GestureDetector(
// // //                   onTap: () {
// // //                     showCountryPicker(
// // //                       context: context,
// // //                       onSelect: (Country country) {
// // //                         setState(() => selectedCountry = country);
// // //                       },
// // //                     );
// // //                   },
// // //                   child: Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 12,
// // //                       vertical: 14,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       border: Border.all(color: Colors.grey.shade400),
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Text(
// // //                           '${selectedCountry.flagEmoji} ${selectedCountry.name} (+${selectedCountry.phoneCode})',
// // //                           style: const TextStyle(fontSize: 16),
// // //                         ),
// // //                         const Spacer(),
// // //                         const Icon(Icons.arrow_drop_down),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Phone Number
// // //                 TextFormField(
// // //                   controller: _phoneController,
// // //                   keyboardType: TextInputType.phone,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'Phone Number',
// // //                     prefixIcon: const Icon(Icons.phone),
// // //                     prefixText: '+${selectedCountry.phoneCode} ',
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.trim().isEmpty) {
// // //                       return 'Please enter your phone number';
// // //                     }
// // //                     if (value.length < 10) {
// // //                       return 'Phone number must be at least 10 digits';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // City
// // //                 TextFormField(
// // //                   controller: _cityController,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'City',
// // //                     prefixIcon: const Icon(Icons.location_city),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.trim().isEmpty) {
// // //                       return 'Please enter your city';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Address
// // //                 TextFormField(
// // //                   controller: _addressController,
// // //                   maxLines: 2,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'Full Address',
// // //                     prefixIcon: const Icon(Icons.home),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.trim().isEmpty) {
// // //                       return 'Please enter your address';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Password Field
// // //                 TextFormField(
// // //                   controller: _passwordController,
// // //                   obscureText: !_showPassword,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'Password ',
// // //                     prefixIcon: const Icon(Icons.lock),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     helperText: 'Minimum 6 characters',
// // //                     suffixIcon: IconButton(
// // //                       padding: EdgeInsets.zero,
// // //                       constraints: const BoxConstraints(minWidth: 40),
// // //                       splashRadius: 20,
// // //                       icon: Icon(
// // //                         _showPassword ? Icons.visibility : Icons.visibility_off,
// // //                         color: Colors.grey,
// // //                       ),
// // //                       onPressed: () =>
// // //                           setState(() => _showPassword = !_showPassword),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.isEmpty) {
// // //                       return 'Please enter a password';
// // //                     }
// // //                     if (value.length < 6) {
// // //                       return 'Password must be at least 6 characters';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Confirm Password Field
// // //                 TextFormField(
// // //                   controller: _confirmPasswordController,
// // //                   obscureText: !_showConfirmPassword,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'Confirm Password',
// // //                     prefixIcon: const Icon(Icons.lock_outline),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     suffixIcon: IconButton(
// // //                       padding: EdgeInsets.zero,
// // //                       constraints: const BoxConstraints(minWidth: 40),
// // //                       splashRadius: 20,
// // //                       icon: Icon(
// // //                         _showConfirmPassword
// // //                             ? Icons.visibility
// // //                             : Icons.visibility_off,
// // //                         color: Colors.grey,
// // //                       ),
// // //                       onPressed: () => setState(
// // //                         () => _showConfirmPassword = !_showConfirmPassword,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   validator: (value) {
// // //                     if (value == null || value.isEmpty) {
// // //                       return 'Please confirm your password';
// // //                     }
// // //                     if (value != _passwordController.text) {
// // //                       return 'Passwords do not match';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 24),

// // //                 // Send OTP Button
// // //                 SizedBox(
// // //                   width: double.infinity,
// // //                   child: ElevatedButton(
// // //                     onPressed: isLoading ? null : _sendOtp,
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.blue,
// // //                       foregroundColor: Colors.white,
// // //                       padding: const EdgeInsets.symmetric(vertical: 14),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(12),
// // //                       ),
// // //                     ),
// // //                     child: isLoading
// // //                         ? const SizedBox(
// // //                             height: 24,
// // //                             width: 24,
// // //                             child: CircularProgressIndicator(
// // //                               color: Colors.white,
// // //                               strokeWidth: 2.5,
// // //                             ),
// // //                           )
// // //                         : const Text(
// // //                             'Send Verification Code',
// // //                             style: TextStyle(
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.w600,
// // //                             ),
// // //                           ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 16),

// // //                 // Login Link
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     const Text(
// // //                       "Already have an account?  ",
// // //                       style: TextStyle(color: Colors.grey),
// // //                     ),
// // //                     GestureDetector(
// // //                       onTap: () => Navigator.of(context).pop(),
// // //                       child: const Text(
// // //                         'Login',
// // //                         style: TextStyle(
// // //                           color: Colors.blue,
// // //                           fontWeight: FontWeight.w600,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(height: 24),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }



// // import 'package:flutter/material.dart';
// // import 'package:country_picker/country_picker.dart';
// // import '../../services/auth_service.dart';
// // import '../pages/cloudinary_service.dart';
// // import 'OtpVerificationPage.dart';

// // class RegistrationPage extends StatefulWidget {
// //   const RegistrationPage({super.key});

// //   @override
// //   State<RegistrationPage> createState() => _RegistrationPageState();
// // }

// // class _RegistrationPageState extends State<RegistrationPage>
// //     with TickerProviderStateMixin {

// //   // ── Brand Palette (matches LoginPage) ─────────────────────
// //   static const Color _navy          = Color(0xFF0B1A2E);
// //   static const Color _navyMid       = Color(0xFF112240);
// //   static const Color _amber         = Color(0xFFF59E0B);
// //   static const Color _amberLight    = Color(0xFFFCD34D);
// //   static const Color _surface       = Color(0xFF172A45);
// //   static const Color _border        = Color(0xFF1E3A5F);
// //   static const Color _textPrimary   = Color(0xFFE2E8F0);
// //   static const Color _textSecondary = Color(0xFF8DA4BE);
// //   static const Color _red           = Color(0xFFEF4444);

// //   // ── Form ──────────────────────────────────────────────────
// //   final _formKey                  = GlobalKey<FormState>();
// //   final _firstNameController      = TextEditingController();
// //   final _lastNameController       = TextEditingController();
// //   final _phoneController          = TextEditingController();
// //   final _cityController           = TextEditingController();
// //   final _addressController        = TextEditingController();
// //   final _passwordController       = TextEditingController();
// //   final _confirmPasswordController= TextEditingController();

// //   bool    isLoading            = false;
// //   bool    _showPassword        = false;
// //   bool    _showConfirmPassword = false;
// //   String? _profileImageUrl;
// //   bool    _uploadingPhoto      = false;

// //   // ── Animation ─────────────────────────────────────────────
// //   AnimationController? _fadeCtrl;
// //   Animation<double>?   _fadeAnim;

// //   Country selectedCountry = Country(
// //     phoneCode: '92',
// //     countryCode: 'PK',
// //     e164Sc: 0,
// //     geographic: true,
// //     level: 1,
// //     name: 'Pakistan',
// //     example: 'Pakistan',
// //     displayName: 'Pakistan',
// //     displayNameNoCountryCode: 'Pakistan',
// //     e164Key: '',
// //   );

// //   final AuthService _authService = AuthService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fadeCtrl = AnimationController(
// //         vsync: this, duration: const Duration(milliseconds: 700));
// //     _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
// //     _fadeCtrl!.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _firstNameController.dispose();
// //     _lastNameController.dispose();
// //     _phoneController.dispose();
// //     _cityController.dispose();
// //     _addressController.dispose();
// //     _passwordController.dispose();
// //     _confirmPasswordController.dispose();
// //     _fadeCtrl?.dispose();
// //     super.dispose();
// //   }

// //   // ── Profile photo upload ───────────────────────────────────
// //   Future<void> _pickProfilePhoto() async {
// //     setState(() => _uploadingPhoto = true);
// //     try {
// //       final url = await CloudinaryService.pickWithSheet(
// //         context,
// //         folder: 'fixright/profiles',
// //         imageQuality: 85,
// //       );
// //       if (url != null && mounted) {
// //         setState(() => _profileImageUrl = url);
// //         _showSuccess('Profile photo uploaded ✓');
// //       }
// //     } catch (e) {
// //       _showError('Photo upload failed. Please try again.');
// //     } finally {
// //       if (mounted) setState(() => _uploadingPhoto = false);
// //     }
// //   }

// //   // ── Original logic — UNTOUCHED ────────────────────────────

// //   bool _validatePassword(String password) => password.length >= 6;

// //   Future<void> _sendOtp() async {
// //     if (!_formKey.currentState!.validate()) return;

// //     if (!_validatePassword(_passwordController.text.trim())) {
// //       _showError('Password must be at least 6 characters');
// //       return;
// //     }
// //     if (_passwordController.text.trim() !=
// //         _confirmPasswordController.text.trim()) {
// //       _showError('Passwords do not match');
// //       return;
// //     }

// //     final phoneNumber =
// //         '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';
// //     final userExists = await _authService.userExists(phoneNumber);
// //     if (userExists) {
// //       if (mounted) _showError('User already registered. Please login instead.');
// //       return;
// //     }

// //     setState(() => isLoading = true);

// //     try {
// //       await _authService.sendOtp(
// //         phoneNumber,
// //         codeSent: (verificationId) {
// //           if (mounted) {
// //             setState(() => isLoading = false);
// //             Navigator.of(context).push(MaterialPageRoute(
// //               builder: (context) => OtpVerificationPage(
// //                 verificationId: verificationId,
// //                 phoneNumber: phoneNumber,
// //                 firstName: _firstNameController.text.trim(),
// //                 lastName: _lastNameController.text.trim(),
// //                 city: _cityController.text.trim(),
// //                 country: selectedCountry.name,
// //                 address: _addressController.text.trim(),
// //                 password: _passwordController.text.trim(),
// //               ),
// //             ));
// //           }
// //         },
// //         verificationFailed: (exception) {
// //           if (mounted) {
// //             setState(() => isLoading = false);
// //             String message = 'OTP verification failed';
// //             if (exception.code == 'invalid-phone-number') {
// //               message = 'Invalid phone number';
// //             } else if (exception.code == 'too-many-requests') {
// //               message = 'Too many attempts. Please try again later.';
// //             }
// //             _showError(message);
// //           }
// //         },
// //       );
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => isLoading = false);
// //         _showError('Error sending OTP: $e');
// //       }
// //     }
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       content: Row(children: [
// //         const Icon(Icons.error_outline, color: Colors.white, size: 18),
// //         const SizedBox(width: 8),
// //         Expanded(child: Text(message)),
// //       ]),
// //       backgroundColor: _red,
// //       behavior: SnackBarBehavior.floating,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       duration: const Duration(seconds: 4),
// //     ));
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       content: Row(children: [
// //         const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
// //         const SizedBox(width: 8),
// //         Expanded(child: Text(message)),
// //       ]),
// //       backgroundColor: const Color(0xFF10B981),
// //       behavior: SnackBarBehavior.floating,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       duration: const Duration(seconds: 3),
// //     ));
// //   }

// //   // ── BUILD ──────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _navy,
// //       appBar: AppBar(
// //         backgroundColor: _navy,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new_rounded,
// //               color: _textPrimary, size: 20),
// //           onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
// //         ),
// //         title: const Text('Create Account',
// //             style: TextStyle(
// //                 color: _textPrimary,
// //                 fontWeight: FontWeight.w700,
// //                 fontSize: 17)),
// //       ),
// //       body: Stack(children: [
// //         // Background blobs
// //         Positioned(
// //           top: -60, right: -60,
// //           child: Container(
// //             width: 240, height: 240,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: RadialGradient(colors: [
// //                 _amber.withOpacity(0.12),
// //                 Colors.transparent,
// //               ]),
// //             ),
// //           ),
// //         ),
// //         Positioned(
// //           bottom: -80, left: -60,
// //           child: Container(
// //             width: 280, height: 280,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: RadialGradient(colors: [
// //                 const Color(0xFF1E40AF).withOpacity(0.15),
// //                 Colors.transparent,
// //               ]),
// //             ),
// //           ),
// //         ),

// //         // Content
// //         SafeArea(
// //           child: _fadeAnim != null
// //               ? FadeTransition(
// //                   opacity: _fadeAnim!,
// //                   child: _buildScrollContent(),
// //                 )
// //               : _buildScrollContent(),
// //         ),
// //       ]),
// //     );
// //   }

// //   Widget _buildScrollContent() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
// //       child: Form(
// //         key: _formKey,
// //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// //           // ── Page header ───────────────────────────────────
// //           _buildPageHeader(),
// //           const SizedBox(height: 28),

// //           // ── Profile photo ─────────────────────────────────
// //           _buildProfilePhotoSection(),
// //           const SizedBox(height: 24),

// //           // ── Personal Info card ────────────────────────────
// //           _sectionCard(
// //             icon: Icons.person_outline_rounded,
// //             title: 'Personal Info',
// //             children: [
// //               _buildRow(
// //                 child1: _styledField(
// //                   controller: _firstNameController,
// //                   hint: 'First Name',
// //                   icon: Icons.badge_outlined,
// //                   validator: (v) => (v == null || v.trim().isEmpty)
// //                       ? 'Required'
// //                       : null,
// //                 ),
// //                 child2: _styledField(
// //                   controller: _lastNameController,
// //                   hint: 'Last Name',
// //                   icon: Icons.badge_outlined,
// //                   validator: (v) => (v == null || v.trim().isEmpty)
// //                       ? 'Required'
// //                       : null,
// //                 ),
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 16),

// //           // ── Contact Info card ─────────────────────────────
// //           _sectionCard(
// //             icon: Icons.phone_outlined,
// //             title: 'Contact',
// //             children: [
// //               // Country picker
// //               _label('Country'),
// //               const SizedBox(height: 8),
// //               GestureDetector(
// //                 onTap: () => showCountryPicker(
// //                   context: context,
// //                   onSelect: (c) => setState(() => selectedCountry = c),
// //                 ),
// //                 child: _inputContainer(
// //                   child: Row(children: [
// //                     Text(
// //                       '${selectedCountry.flagEmoji}  ${selectedCountry.name}  (+${selectedCountry.phoneCode})',
// //                       style: const TextStyle(
// //                           fontSize: 13,
// //                           fontWeight: FontWeight.w500,
// //                           color: _textPrimary),
// //                     ),
// //                     const Spacer(),
// //                     const Icon(Icons.keyboard_arrow_down_rounded,
// //                         color: _textSecondary, size: 22),
// //                   ]),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),

// //               _label('Phone Number'),
// //               const SizedBox(height: 8),
// //               _styledField(
// //                 controller: _phoneController,
// //                 hint: '3001234567',
// //                 icon: Icons.phone_outlined,
// //                 keyboardType: TextInputType.phone,
// //                 prefixText: '+${selectedCountry.phoneCode} ',
// //                 validator: (v) {
// //                   if (v == null || v.trim().isEmpty) return 'Required';
// //                   if (v.trim().length < 10) return 'At least 10 digits';
// //                   return null;
// //                 },
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 16),

// //           // ── Location card ─────────────────────────────────
// //           _sectionCard(
// //             icon: Icons.location_on_outlined,
// //             title: 'Location',
// //             children: [
// //               _styledField(
// //                 controller: _cityController,
// //                 hint: 'City',
// //                 icon: Icons.location_city_outlined,
// //                 validator: (v) => (v == null || v.trim().isEmpty)
// //                     ? 'Required'
// //                     : null,
// //               ),
// //               const SizedBox(height: 16),
// //               _styledField(
// //                 controller: _addressController,
// //                 hint: 'Full Address',
// //                 icon: Icons.home_outlined,
// //                 maxLines: 2,
// //                 validator: (v) => (v == null || v.trim().isEmpty)
// //                     ? 'Required'
// //                     : null,
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 16),

// //           // ── Security card ─────────────────────────────────
// //           _sectionCard(
// //             icon: Icons.lock_outline_rounded,
// //             title: 'Security',
// //             children: [
// //               _styledField(
// //                 controller: _passwordController,
// //                 hint: 'Password (min 6 chars)',
// //                 icon: Icons.lock_outline_rounded,
// //                 obscureText: !_showPassword,
// //                 helperText: 'Minimum 6 characters',
// //                 suffix: IconButton(
// //                   icon: Icon(
// //                     _showPassword
// //                         ? Icons.visibility_outlined
// //                         : Icons.visibility_off_outlined,
// //                     color: _textSecondary,
// //                     size: 20,
// //                   ),
// //                   onPressed: () =>
// //                       setState(() => _showPassword = !_showPassword),
// //                 ),
// //                 validator: (v) {
// //                   if (v == null || v.isEmpty) return 'Required';
// //                   if (v.length < 6) return 'Min 6 characters';
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 16),
// //               _styledField(
// //                 controller: _confirmPasswordController,
// //                 hint: 'Confirm Password',
// //                 icon: Icons.lock_outline_rounded,
// //                 obscureText: !_showConfirmPassword,
// //                 suffix: IconButton(
// //                   icon: Icon(
// //                     _showConfirmPassword
// //                         ? Icons.visibility_outlined
// //                         : Icons.visibility_off_outlined,
// //                     color: _textSecondary,
// //                     size: 20,
// //                   ),
// //                   onPressed: () => setState(
// //                       () => _showConfirmPassword = !_showConfirmPassword),
// //                 ),
// //                 validator: (v) {
// //                   if (v == null || v.isEmpty) return 'Required';
// //                   if (v != _passwordController.text) {
// //                     return 'Passwords do not match';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 28),

// //           // ── Submit button ─────────────────────────────────
// //           _buildSubmitButton(),

// //           const SizedBox(height: 20),

// //           // ── Login link ────────────────────────────────────
// //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// //             const Text("Already have an account?",
// //                 style: TextStyle(color: _textSecondary, fontSize: 13)),
// //             TextButton(
// //               onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
// //               style: TextButton.styleFrom(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8),
// //                 minimumSize: const Size(0, 32),
// //               ),
// //               child: const Text('Login',
// //                   style: TextStyle(
// //                       color: _amber,
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 13)),
// //             ),
// //           ]),
// //         ]),
// //       ),
// //     );
// //   }

// //   // ── PAGE HEADER ────────────────────────────────────────────

// //   Widget _buildPageHeader() {
// //     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       RichText(
// //         text: const TextSpan(children: [
// //           TextSpan(
// //             text: 'Join ',
// //             style: TextStyle(
// //                 fontSize: 26,
// //                 fontWeight: FontWeight.w900,
// //                 color: _textPrimary,
// //                 letterSpacing: -0.5),
// //           ),
// //           TextSpan(
// //             text: 'Fix',
// //             style: TextStyle(
// //                 fontSize: 26,
// //                 fontWeight: FontWeight.w900,
// //                 color: _textPrimary,
// //                 letterSpacing: -0.5),
// //           ),
// //           TextSpan(
// //             text: 'Right',
// //             style: TextStyle(
// //                 fontSize: 26,
// //                 fontWeight: FontWeight.w900,
// //                 color: _amber,
// //                 letterSpacing: -0.5),
// //           ),
// //         ]),
// //       ),
// //       const SizedBox(height: 4),
// //       const Text('Create your account to get started',
// //           style: TextStyle(fontSize: 13, color: _textSecondary)),
// //     ]);
// //   }

// //   // ── PROFILE PHOTO ──────────────────────────────────────────

// //   Widget _buildProfilePhotoSection() {
// //     return Center(
// //       child: Column(children: [
// //         GestureDetector(
// //           onTap: _uploadingPhoto ? null : _pickProfilePhoto,
// //           child: Stack(alignment: Alignment.center, children: [
// //             // Avatar circle
// //             Container(
// //               width: 96,
// //               height: 96,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 gradient: _profileImageUrl != null
// //                     ? null
// //                     : const LinearGradient(
// //                         colors: [_surface, _navyMid],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight),
// //                 border: Border.all(
// //                     color: _profileImageUrl != null
// //                         ? _amber
// //                         : _border,
// //                     width: 2),
// //                 image: _profileImageUrl != null
// //                     ? DecorationImage(
// //                         image: NetworkImage(_profileImageUrl!),
// //                         fit: BoxFit.cover)
// //                     : null,
// //                 boxShadow: _profileImageUrl != null
// //                     ? [
// //                         BoxShadow(
// //                             color: _amber.withOpacity(0.3),
// //                             blurRadius: 16,
// //                             offset: const Offset(0, 4))
// //                       ]
// //                     : [],
// //               ),
// //               child: _uploadingPhoto
// //                   ? const SizedBox(
// //                       width: 28,
// //                       height: 28,
// //                       child: CircularProgressIndicator(
// //                           color: _amber, strokeWidth: 2.5))
// //                   : _profileImageUrl == null
// //                       ? const Icon(Icons.person_outline_rounded,
// //                           color: _textSecondary, size: 40)
// //                       : null,
// //             ),
// //             // Camera badge
// //             if (!_uploadingPhoto)
// //               Positioned(
// //                 bottom: 0, right: 0,
// //                 child: Container(
// //                   width: 30, height: 30,
// //                   decoration: BoxDecoration(
// //                     color: _amber,
// //                     shape: BoxShape.circle,
// //                     border: Border.all(color: _navy, width: 2),
// //                     boxShadow: [
// //                       BoxShadow(
// //                           color: _amber.withOpacity(0.4),
// //                           blurRadius: 8)
// //                     ],
// //                   ),
// //                   child: const Icon(Icons.camera_alt_rounded,
// //                       color: _navy, size: 15),
// //                 ),
// //               ),
// //           ]),
// //         ),
// //         const SizedBox(height: 10),
// //         Text(
// //           _profileImageUrl != null
// //               ? 'Tap to change photo'
// //               : 'Add profile photo (optional)',
// //           style: const TextStyle(
// //               fontSize: 12, color: _textSecondary, fontWeight: FontWeight.w500),
// //         ),
// //       ]),
// //     );
// //   }

// //   // ── SECTION CARD ──────────────────────────────────────────

// //   Widget _sectionCard({
// //     required IconData icon,
// //     required String title,
// //     required List<Widget> children,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _surface,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: _border, width: 1),
// //         boxShadow: [
// //           BoxShadow(
// //               color: Colors.black.withOpacity(0.25),
// //               blurRadius: 20,
// //               offset: const Offset(0, 8)),
// //         ],
// //       ),
// //       padding: const EdgeInsets.all(20),
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         // Section header
// //         Row(children: [
// //           Container(
// //             width: 32, height: 32,
// //             decoration: BoxDecoration(
// //               color: _amber.withOpacity(0.12),
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: _amber.withOpacity(0.3)),
// //             ),
// //             child: Icon(icon, color: _amber, size: 17),
// //           ),
// //           const SizedBox(width: 10),
// //           Text(title,
// //               style: const TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w700,
// //                   color: _amber,
// //                   letterSpacing: 0.3)),
// //         ]),
// //         const SizedBox(height: 16),
// //         Container(height: 1, color: _border),
// //         const SizedBox(height: 16),
// //         ...children,
// //       ]),
// //     );
// //   }

// //   // ── SUBMIT BUTTON ──────────────────────────────────────────

// //   Widget _buildSubmitButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 52,
// //       child: ElevatedButton(
// //         onPressed: isLoading ? null : _sendOtp,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.transparent,
// //           shadowColor: Colors.transparent,
// //           padding: EdgeInsets.zero,
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(14)),
// //         ).copyWith(
// //           overlayColor: WidgetStateProperty.all(
// //               Colors.white.withOpacity(0.08)),
// //         ),
// //         child: Ink(
// //           decoration: BoxDecoration(
// //             gradient: isLoading
// //                 ? null
// //                 : const LinearGradient(
// //                     colors: [_amber, Color(0xFFD97706)],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight),
// //             color: isLoading ? _border : null,
// //             borderRadius: BorderRadius.circular(14),
// //             boxShadow: isLoading
// //                 ? []
// //                 : [
// //                     BoxShadow(
// //                         color: _amber.withOpacity(0.40),
// //                         blurRadius: 16,
// //                         offset: const Offset(0, 6))
// //                   ],
// //           ),
// //           child: Container(
// //             alignment: Alignment.center,
// //             child: isLoading
// //                 ? const SizedBox(
// //                     height: 22, width: 22,
// //                     child: CircularProgressIndicator(
// //                         color: _textSecondary, strokeWidth: 2.5))
// //                 : const Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.send_rounded, color: _navy, size: 18),
// //                       SizedBox(width: 10),
// //                       Text('Send Verification Code',
// //                           style: TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w800,
// //                               color: _navy,
// //                               letterSpacing: 0.3)),
// //                     ],
// //                   ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── HELPERS ────────────────────────────────────────────────

// //   Widget _buildRow({required Widget child1, required Widget child2}) {
// //     return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       Expanded(child: child1),
// //       const SizedBox(width: 12),
// //       Expanded(child: child2),
// //     ]);
// //   }

// //   Widget _label(String text) {
// //     return Text(text,
// //         style: const TextStyle(
// //             fontWeight: FontWeight.w600,
// //             fontSize: 12,
// //             color: _textSecondary,
// //             letterSpacing: 0.4));
// //   }

// //   Widget _inputContainer({required Widget child}) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
// //       decoration: BoxDecoration(
// //         color: _navyMid,
// //         border: Border.all(color: _border),
// //         borderRadius: BorderRadius.circular(13),
// //       ),
// //       child: child,
// //     );
// //   }

// //   Widget _styledField({
// //     required TextEditingController controller,
// //     required String hint,
// //     required IconData icon,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool obscureText = false,
// //     int maxLines = 1,
// //     Widget? suffix,
// //     String? prefixText,
// //     String? helperText,
// //     String? Function(String?)? validator,
// //   }) {
// //     return TextFormField(
// //       controller: controller,
// //       keyboardType: keyboardType,
// //       obscureText: obscureText,
// //       maxLines: maxLines,
// //       style: const TextStyle(color: _textPrimary, fontSize: 14),
// //       cursorColor: _amber,
// //       validator: validator,
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle:
// //             TextStyle(color: _textSecondary.withOpacity(0.55), fontSize: 13),
// //         prefixIcon: Icon(icon, color: _textSecondary, size: 19),
// //         prefixText: prefixText,
// //         prefixStyle: const TextStyle(color: _textSecondary, fontSize: 13),
// //         suffixIcon: suffix,
// //         helperText: helperText,
// //         helperStyle:
// //             const TextStyle(color: _textSecondary, fontSize: 11),
// //         errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
// //         filled: true,
// //         fillColor: _navyMid,
// //         contentPadding:
// //             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(13),
// //           borderSide: const BorderSide(color: _border),
// //         ),
// //         enabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(13),
// //           borderSide: const BorderSide(color: _border),
// //         ),
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(13),
// //           borderSide: const BorderSide(color: _amber, width: 1.8),
// //         ),
// //         errorBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(13),
// //           borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
// //         ),
// //         focusedErrorBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(13),
// //           borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
// //         ),
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:country_picker/country_picker.dart';
// import '../../services/auth_service.dart';
// import '../pages/cloudinary_service.dart';
// import 'OtpVerificationPage.dart';

// class RegistrationPage extends StatefulWidget {
//   const RegistrationPage({super.key});

//   @override
//   State<RegistrationPage> createState() => _RegistrationPageState();
// }

// class _RegistrationPageState extends State<RegistrationPage>
//     with TickerProviderStateMixin {

//   // ── Brand Palette ──────────────────────────────────────────
//   static const Color _navy          = Color(0xFF0B1A2E);
//   static const Color _navyMid       = Color(0xFF112240);
//   static const Color _amber         = Color(0xFFF59E0B);
//   static const Color _amberLight    = Color(0xFFFCD34D);
//   static const Color _surface       = Color(0xFF172A45);
//   static const Color _border        = Color(0xFF1E3A5F);
//   static const Color _textPrimary   = Color(0xFFE2E8F0);
//   static const Color _textSecondary = Color(0xFF8DA4BE);
//   static const Color _red           = Color(0xFFEF4444);

//   // ── Form ──────────────────────────────────────────────────
//   final _formKey                   = GlobalKey<FormState>();
//   final _firstNameController       = TextEditingController();
//   final _lastNameController        = TextEditingController();
//   final _phoneController           = TextEditingController();
//   final _cityController            = TextEditingController();
//   final _addressController         = TextEditingController();
//   final _passwordController        = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool    isLoading            = false;
//   bool    _showPassword        = false;
//   bool    _showConfirmPassword = false;
//   String? _profileImageUrl;
//   bool    _uploadingPhoto      = false;

//   AnimationController? _fadeCtrl;
//   Animation<double>?   _fadeAnim;

//   Country selectedCountry = Country(
//     phoneCode: '92', countryCode: 'PK', e164Sc: 0,
//     geographic: true, level: 1, name: 'Pakistan',
//     example: 'Pakistan', displayName: 'Pakistan',
//     displayNameNoCountryCode: 'Pakistan', e164Key: '',
//   );

//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 700));
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
//     _fadeCtrl!.forward();
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _addressController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _fadeCtrl?.dispose();
//     super.dispose();
//   }

//   // ── Profile photo upload ───────────────────────────────────
//   Future<void> _pickProfilePhoto() async {
//     setState(() => _uploadingPhoto = true);
//     try {
//       final url = await CloudinaryService.pickWithSheet(
//         context, folder: 'fixright/profiles', imageQuality: 85);
//       if (url != null && mounted) {
//         setState(() => _profileImageUrl = url);
//         _showSuccess('Profile photo uploaded ✓');
//       }
//     } catch (e) {
//       _showError('Photo upload failed. Please try again.');
//     } finally {
//       if (mounted) setState(() => _uploadingPhoto = false);
//     }
//   }

//   // ── Original logic — UNTOUCHED ────────────────────────────
//   bool _validatePassword(String password) => password.length >= 6;

//   Future<void> _sendOtp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_validatePassword(_passwordController.text.trim())) {
//       _showError('Password must be at least 6 characters');
//       return;
//     }
//     if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
//       _showError('Passwords do not match');
//       return;
//     }

//     final phoneNumber = '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';
//     final userExists  = await _authService.userExists(phoneNumber);
//     if (userExists) {
//       if (mounted) _showError('User already registered. Please login instead.');
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       await _authService.sendOtp(
//         phoneNumber,
//         codeSent: (verificationId) {
//           if (mounted) {
//             setState(() => isLoading = false);
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => OtpVerificationPage(
//                 verificationId: verificationId,
//                 phoneNumber:    phoneNumber,
//                 firstName:      _firstNameController.text.trim(),
//                 lastName:       _lastNameController.text.trim(),
//                 city:           _cityController.text.trim(),
//                 country:        selectedCountry.name,
//                 address:        _addressController.text.trim(),
//                 password:       _passwordController.text.trim(),
//                 // ✅ Profile image URL passed forward
//                 profileImageUrl: _profileImageUrl,
//               ),
//             ));
//           }
//         },
//         verificationFailed: (exception) {
//           if (mounted) {
//             setState(() => isLoading = false);
//             String message = 'OTP verification failed';
//             if (exception.code == 'invalid-phone-number') {
//               message = 'Invalid phone number';
//             } else if (exception.code == 'too-many-requests') {
//               message = 'Too many attempts. Please try again later.';
//             }
//             _showError(message);
//           }
//         },
//       );
//     } catch (e) {
//       if (mounted) {
//         setState(() => isLoading = false);
//         _showError('Error sending OTP: $e');
//       }
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         const Icon(Icons.error_outline, color: Colors.white, size: 18),
//         const SizedBox(width: 8),
//         Expanded(child: Text(message)),
//       ]),
//       backgroundColor: _red,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       duration: const Duration(seconds: 4),
//     ));
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
//         const SizedBox(width: 8),
//         Expanded(child: Text(message)),
//       ]),
//       backgroundColor: const Color(0xFF10B981),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       duration: const Duration(seconds: 3),
//     ));
//   }

//   // ── BUILD ──────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _navy,
//       appBar: AppBar(
//         backgroundColor: _navy,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: _textPrimary, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Create Account',
//             style: TextStyle(
//                 color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
//       ),
//       body: Stack(children: [
//         // Amber glow top-right
//         Positioned(
//           top: -60, right: -60,
//           child: Container(
//             width: 240, height: 240,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: RadialGradient(colors: [
//                 _amber.withOpacity(0.12), Colors.transparent,
//               ]),
//             ),
//           ),
//         ),
//         // Blue glow bottom-left
//         Positioned(
//           bottom: -80, left: -60,
//           child: Container(
//             width: 280, height: 280,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: RadialGradient(colors: [
//                 const Color(0xFF1E40AF).withOpacity(0.15), Colors.transparent,
//               ]),
//             ),
//           ),
//         ),

//         SafeArea(
//           child: _fadeAnim != null
//               ? FadeTransition(opacity: _fadeAnim!, child: _buildForm())
//               : _buildForm(),
//         ),
//       ]),
//     );
//   }

//   Widget _buildForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
//       child: Form(
//         key: _formKey,
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // ── Header ────────────────────────────────────────
//           RichText(
//             text: const TextSpan(children: [
//               TextSpan(text: 'Join ',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
//                       color: _textPrimary, letterSpacing: -0.5)),
//               TextSpan(text: 'Fix',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
//                       color: _textPrimary, letterSpacing: -0.5)),
//               TextSpan(text: 'Right',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
//                       color: _amber, letterSpacing: -0.5)),
//             ]),
//           ),
//           const SizedBox(height: 4),
//           const Text('Create your account to get started',
//               style: TextStyle(fontSize: 13, color: _textSecondary)),

//           const SizedBox(height: 24),

//           // ── Profile photo ─────────────────────────────────
//           Center(
//             child: GestureDetector(
//               onTap: _uploadingPhoto ? null : _pickProfilePhoto,
//               child: Stack(alignment: Alignment.center, children: [
//                 Container(
//                   width: 90, height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: _profileImageUrl != null ? null
//                         : const LinearGradient(
//                             colors: [_surface, _navyMid],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight),
//                     border: Border.all(
//                         color: _profileImageUrl != null ? _amber : _border,
//                         width: 2),
//                     image: _profileImageUrl != null
//                         ? DecorationImage(
//                             image: NetworkImage(_profileImageUrl!),
//                             fit: BoxFit.cover)
//                         : null,
//                     boxShadow: _profileImageUrl != null ? [
//                       BoxShadow(color: _amber.withOpacity(0.3),
//                           blurRadius: 14, offset: const Offset(0, 4))
//                     ] : [],
//                   ),
//                   child: _uploadingPhoto
//                       ? const SizedBox(width: 26, height: 26,
//                           child: CircularProgressIndicator(
//                               color: _amber, strokeWidth: 2.5))
//                       : _profileImageUrl == null
//                           ? const Icon(Icons.person_outline_rounded,
//                               color: _textSecondary, size: 36)
//                           : null,
//                 ),
//                 if (!_uploadingPhoto)
//                   Positioned(
//                     bottom: 0, right: 0,
//                     child: Container(
//                       width: 28, height: 28,
//                       decoration: BoxDecoration(
//                         color: _amber, shape: BoxShape.circle,
//                         border: Border.all(color: _navy, width: 2),
//                       ),
//                       child: const Icon(Icons.camera_alt_rounded,
//                           color: _navy, size: 14),
//                     ),
//                   ),
//               ]),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Center(
//             child: Text(
//               _profileImageUrl != null
//                   ? 'Tap to change photo'
//                   : 'Add profile photo (optional)',
//               style: const TextStyle(fontSize: 11, color: _textSecondary),
//             ),
//           ),

//           const SizedBox(height: 28),

//           // ── Main form card ────────────────────────────────
//           Container(
//             decoration: BoxDecoration(
//               color: _surface,
//               borderRadius: BorderRadius.circular(22),
//               border: Border.all(color: _border, width: 1),
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.28),
//                     blurRadius: 24, offset: const Offset(0, 10)),
//               ],
//             ),
//             padding: const EdgeInsets.all(24),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//               // ── Personal Info ──────────────────────────────
//               _sectionDivider('Personal Info', Icons.person_outline_rounded),
//               const SizedBox(height: 16),

//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Expanded(child: _styledField(
//                   controller: _firstNameController,
//                   hint: 'First Name',
//                   icon: Icons.badge_outlined,
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 )),
//                 const SizedBox(width: 12),
//                 Expanded(child: _styledField(
//                   controller: _lastNameController,
//                   hint: 'Last Name',
//                   icon: Icons.badge_outlined,
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 )),
//               ]),

//               const SizedBox(height: 24),

//               // ── Contact ────────────────────────────────────
//               _sectionDivider('Contact', Icons.phone_outlined),
//               const SizedBox(height: 16),

//               // Country picker
//               GestureDetector(
//                 onTap: () => showCountryPicker(
//                   context: context,
//                   onSelect: (c) => setState(() => selectedCountry = c),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
//                   decoration: BoxDecoration(
//                     color: _navyMid,
//                     border: Border.all(color: _border),
//                     borderRadius: BorderRadius.circular(13),
//                   ),
//                   child: Row(children: [
//                     const Icon(Icons.flag_outlined, color: _textSecondary, size: 19),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         '${selectedCountry.flagEmoji}  ${selectedCountry.name}  (+${selectedCountry.phoneCode})',
//                         style: const TextStyle(
//                             color: _textPrimary, fontSize: 13,
//                             fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                     const Icon(Icons.keyboard_arrow_down_rounded,
//                         color: _textSecondary, size: 22),
//                   ]),
//                 ),
//               ),
//               const SizedBox(height: 14),

//               _styledField(
//                 controller: _phoneController,
//                 hint: '3001234567',
//                 icon: Icons.phone_outlined,
//                 keyboardType: TextInputType.phone,
//                 prefixText: '+${selectedCountry.phoneCode} ',
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) return 'Required';
//                   if (v.trim().length < 10) return 'At least 10 digits';
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 24),

//               // ── Location ───────────────────────────────────
//               _sectionDivider('Location', Icons.location_on_outlined),
//               const SizedBox(height: 16),

//               _styledField(
//                 controller: _cityController,
//                 hint: 'City',
//                 icon: Icons.location_city_outlined,
//                 validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),
//               const SizedBox(height: 14),
//               _styledField(
//                 controller: _addressController,
//                 hint: 'Full Address',
//                 icon: Icons.home_outlined,
//                 maxLines: 2,
//                 validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),

//               const SizedBox(height: 24),

//               // ── Security ───────────────────────────────────
//               _sectionDivider('Security', Icons.lock_outline_rounded),
//               const SizedBox(height: 16),

//               _styledField(
//                 controller: _passwordController,
//                 hint: 'Password (min 6 chars)',
//                 icon: Icons.lock_outline_rounded,
//                 obscureText: !_showPassword,
//                 helperText: 'Minimum 6 characters',
//                 suffix: IconButton(
//                   icon: Icon(
//                     _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                     color: _textSecondary, size: 20,
//                   ),
//                   onPressed: () => setState(() => _showPassword = !_showPassword),
//                 ),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Required';
//                   if (v.length < 6) return 'Min 6 characters';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 14),
//               _styledField(
//                 controller: _confirmPasswordController,
//                 hint: 'Confirm Password',
//                 icon: Icons.lock_outline_rounded,
//                 obscureText: !_showConfirmPassword,
//                 suffix: IconButton(
//                   icon: Icon(
//                     _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                     color: _textSecondary, size: 20,
//                   ),
//                   onPressed: () =>
//                       setState(() => _showConfirmPassword = !_showConfirmPassword),
//                 ),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Required';
//                   if (v != _passwordController.text) return 'Passwords do not match';
//                   return null;
//                 },
//               ),
//             ]),
//           ),

//           const SizedBox(height: 28),

//           // ── Submit button ─────────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: isLoading ? null : _sendOtp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 padding: EdgeInsets.zero,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//               ).copyWith(
//                 overlayColor: WidgetStateProperty.all(
//                     Colors.white.withOpacity(0.08)),
//               ),
//               child: Ink(
//                 decoration: BoxDecoration(
//                   gradient: isLoading ? null
//                       : const LinearGradient(
//                           colors: [_amber, Color(0xFFD97706)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight),
//                   color: isLoading ? _border : null,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: isLoading ? [] : [
//                     BoxShadow(color: _amber.withOpacity(0.40),
//                         blurRadius: 16, offset: const Offset(0, 6))
//                   ],
//                 ),
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: isLoading
//                       ? const SizedBox(height: 22, width: 22,
//                           child: CircularProgressIndicator(
//                               color: _textSecondary, strokeWidth: 2.5))
//                       : const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.send_rounded, color: _navy, size: 18),
//                             SizedBox(width: 10),
//                             Text('Send Verification Code',
//                                 style: TextStyle(
//                                     fontSize: 15, fontWeight: FontWeight.w800,
//                                     color: _navy, letterSpacing: 0.3)),
//                           ],
//                         ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ── Login link ────────────────────────────────────
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             const Text("Already have an account?",
//                 style: TextStyle(color: _textSecondary, fontSize: 13)),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   minimumSize: const Size(0, 32)),
//               child: const Text('Login',
//                   style: TextStyle(color: _amber,
//                       fontWeight: FontWeight.w700, fontSize: 13)),
//             ),
//           ]),
//         ]),
//       ),
//     );
//   }

//   // ── Section divider ────────────────────────────────────────

//   Widget _sectionDivider(String title, IconData icon) {
//     return Row(children: [
//       Container(
//         width: 28, height: 28,
//         decoration: BoxDecoration(
//           color: _amber.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(7),
//           border: Border.all(color: _amber.withOpacity(0.3)),
//         ),
//         child: Icon(icon, color: _amber, size: 15),
//       ),
//       const SizedBox(width: 8),
//       Text(title,
//           style: const TextStyle(
//               fontSize: 12, fontWeight: FontWeight.w700,
//               color: _amber, letterSpacing: 0.4)),
//       const SizedBox(width: 10),
//       Expanded(child: Container(height: 1, color: _border)),
//     ]);
//   }

//   // ── Styled field ───────────────────────────────────────────

//   Widget _styledField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     int maxLines = 1,
//     Widget? suffix,
//     String? prefixText,
//     String? helperText,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//       maxLines: maxLines,
//       style: const TextStyle(color: _textPrimary, fontSize: 14),
//       cursorColor: _amber,
//       validator: validator,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(
//             color: _textSecondary.withOpacity(0.55), fontSize: 13),
//         prefixIcon: Icon(icon, color: _textSecondary, size: 19),
//         prefixText: prefixText,
//         prefixStyle: const TextStyle(color: _textSecondary, fontSize: 13),
//         suffixIcon: suffix,
//         helperText: helperText,
//         helperStyle: const TextStyle(color: _textSecondary, fontSize: 11),
//         errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
//         filled: true,
//         fillColor: _navyMid,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: _border)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: _border)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: _amber, width: 1.8)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8)),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import '../pages/cloudinary_service.dart'; // ✅ FIX: correct path
import 'OtpVerificationPage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {

  // ── Brand Palette ──────────────────────────────────────────
  static const Color _navy          = Color(0xFF0B1A2E);
  static const Color _navyMid       = Color(0xFF112240);
  static const Color _amber         = Color(0xFFF59E0B);
  static const Color _amberLight    = Color(0xFFFCD34D);
  static const Color _surface       = Color(0xFF172A45);
  static const Color _border        = Color(0xFF1E3A5F);
  static const Color _textPrimary   = Color(0xFFE2E8F0);
  static const Color _textSecondary = Color(0xFF8DA4BE);
  static const Color _red           = Color(0xFFEF4444);

  // ── Form controllers ──────────────────────────────────────
  final _formKey                   = GlobalKey<FormState>();
  final _firstNameController       = TextEditingController();
  final _lastNameController        = TextEditingController();
  final _phoneController           = TextEditingController();
  final _cityController            = TextEditingController();
  final _addressController         = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool    isLoading            = false;
  bool    _showPassword        = false;
  bool    _showConfirmPassword = false;
  String? _profileImageUrl;
  bool    _uploadingPhoto      = false;

  AnimationController? _fadeCtrl;
  Animation<double>?   _fadeAnim;

  Country selectedCountry = Country(
    phoneCode: '92', countryCode: 'PK', e164Sc: 0,
    geographic: true, level: 1, name: 'Pakistan',
    example: 'Pakistan', displayName: 'Pakistan',
    displayNameNoCountryCode: 'Pakistan', e164Key: '',
  );

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
    _fadeCtrl!.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeCtrl?.dispose();
    super.dispose();
  }

  // ── Profile photo upload ───────────────────────────────────
  Future<void> _pickProfilePhoto() async {
    setState(() => _uploadingPhoto = true);
    try {
      final url = await CloudinaryService.pickWithSheet(
        context, folder: 'fixright/profiles', imageQuality: 85);
      if (url != null && mounted) {
        setState(() => _profileImageUrl = url);
        _showSuccess('Profile photo uploaded ✓');
      }
    } catch (e) {
      _showError('Photo upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  // ── ALL ORIGINAL LOGIC — UNTOUCHED ────────────────────────
  bool _validatePassword(String password) => password.length >= 6;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validatePassword(_passwordController.text.trim())) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showError('Passwords do not match');
      return;
    }

    final phoneNumber =
        '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';
    final userExists = await _authService.userExists(phoneNumber);
    if (userExists) {
      if (mounted) _showError('User already registered. Please login instead.');
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.sendOtp(
        phoneNumber,
        codeSent: (verificationId) {
          if (mounted) {
            setState(() => isLoading = false);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                verificationId:  verificationId,
                phoneNumber:     phoneNumber,
                firstName:       _firstNameController.text.trim(),
                lastName:        _lastNameController.text.trim(),
                city:            _cityController.text.trim(),
                country:         selectedCountry.name,
                address:         _addressController.text.trim(),
                password:        _passwordController.text.trim(),
                profileImageUrl: _profileImageUrl, // ✅ passed forward
              ),
            ));
          }
        },
        verificationFailed: (exception) {
          if (mounted) {
            setState(() => isLoading = false);
            String message = 'OTP verification failed';
            if (exception.code == 'invalid-phone-number') {
              message = 'Invalid phone number';
            } else if (exception.code == 'too-many-requests') {
              message = 'Too many attempts. Please try again later.';
            }
            _showError(message);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Error sending OTP: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: _red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        title: const Text('Create Account',
            style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ),
      body: Stack(children: [
        // Amber glow top-right
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _amber.withOpacity(0.12), Colors.transparent,
              ]),
            ),
          ),
        ),
        // Blue glow bottom-left
        Positioned(
          bottom: -80, left: -60,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF1E40AF).withOpacity(0.15), Colors.transparent,
              ]),
            ),
          ),
        ),

        SafeArea(
          child: _fadeAnim != null
              ? FadeTransition(opacity: _fadeAnim!, child: _buildForm())
              : _buildForm(),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header ────────────────────────────────────────
          RichText(
            text: const TextSpan(children: [
              TextSpan(text: 'Join ',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: _textPrimary, letterSpacing: -0.5)),
              TextSpan(text: 'Fix',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: _textPrimary, letterSpacing: -0.5)),
              TextSpan(text: 'Right',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: _amber, letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(height: 4),
          const Text('Create your account to get started',
              style: TextStyle(fontSize: 13, color: _textSecondary)),

          const SizedBox(height: 24),

          // ── Profile photo ─────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _uploadingPhoto ? null : _pickProfilePhoto,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _profileImageUrl != null
                        ? null
                        : const LinearGradient(
                            colors: [_surface, _navyMid],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                    border: Border.all(
                        color: _profileImageUrl != null ? _amber : _border,
                        width: 2),
                    image: _profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_profileImageUrl!),
                            fit: BoxFit.cover)
                        : null,
                    boxShadow: _profileImageUrl != null
                        ? [BoxShadow(color: _amber.withOpacity(0.3),
                              blurRadius: 14, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: _uploadingPhoto
                      ? const SizedBox(width: 26, height: 26,
                          child: CircularProgressIndicator(
                              color: _amber, strokeWidth: 2.5))
                      : _profileImageUrl == null
                          ? const Icon(Icons.person_outline_rounded,
                              color: _textSecondary, size: 36)
                          : null,
                ),
                if (!_uploadingPhoto)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: _navy, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: _navy, size: 14),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _profileImageUrl != null
                  ? 'Tap to change photo'
                  : 'Add profile photo (optional)',
              style: const TextStyle(fontSize: 11, color: _textSecondary),
            ),
          ),

          const SizedBox(height: 28),

          // ── Single form card ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.28),
                    blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // Personal Info section
              _sectionDivider('Personal Info', Icons.person_outline_rounded),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _styledField(
                  controller: _firstNameController,
                  hint: 'First Name',
                  icon: Icons.badge_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: _styledField(
                  controller: _lastNameController,
                  hint: 'Last Name',
                  icon: Icons.badge_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                )),
              ]),

              const SizedBox(height: 24),

              // Contact section
              _sectionDivider('Contact', Icons.phone_outlined),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => showCountryPicker(
                  context: context,
                  onSelect: (c) => setState(() => selectedCountry = c),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: _navyMid,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(children: [
                    const Icon(Icons.flag_outlined,
                        color: _textSecondary, size: 19),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${selectedCountry.flagEmoji}  '
                        '${selectedCountry.name}  '
                        '(+${selectedCountry.phoneCode})',
                        style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _textSecondary, size: 22),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              _styledField(
                controller: _phoneController,
                hint: '3001234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                prefixText: '+${selectedCountry.phoneCode} ',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10) return 'At least 10 digits';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Location section
              _sectionDivider('Location', Icons.location_on_outlined),
              const SizedBox(height: 16),
              _styledField(
                controller: _cityController,
                hint: 'City',
                icon: Icons.location_city_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _styledField(
                controller: _addressController,
                hint: 'Full Address',
                icon: Icons.home_outlined,
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Security section
              _sectionDivider('Security', Icons.lock_outline_rounded),
              const SizedBox(height: 16),
              _styledField(
                controller: _passwordController,
                hint: 'Password (min 6 chars)',
                icon: Icons.lock_outline_rounded,
                obscureText: !_showPassword,
                helperText: 'Minimum 6 characters',
                suffix: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _textSecondary, size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _styledField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                obscureText: !_showConfirmPassword,
                suffix: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _textSecondary, size: 20,
                  ),
                  onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ]),
          ),

          const SizedBox(height: 28),

          // ── Submit button ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.08)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isLoading
                      ? null
                      : const LinearGradient(
                          colors: [_amber, Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                  color: isLoading ? _border : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                              color: _amber.withOpacity(0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: isLoading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(
                              color: _textSecondary, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: _navy, size: 18),
                            SizedBox(width: 10),
                            Text('Send Verification Code',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _navy,
                                    letterSpacing: 0.3)),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Login link ────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Already have an account?",
                style: TextStyle(color: _textSecondary, fontSize: 13)),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32)),
              child: const Text('Login',
                  style: TextStyle(
                      color: _amber,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _sectionDivider(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: _amber.withOpacity(0.12),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _amber.withOpacity(0.3)),
        ),
        child: Icon(icon, color: _amber, size: 15),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _amber,
              letterSpacing: 0.4)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _border)),
    ]);
  }

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffix,
    String? prefixText,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      cursorColor: _amber,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: _textSecondary.withOpacity(0.55), fontSize: 13),
        prefixIcon: Icon(icon, color: _textSecondary, size: 19),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        suffixIcon: suffix,
        helperText: helperText,
        helperStyle: const TextStyle(color: _textSecondary, fontSize: 11),
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
        filled: true,
        fillColor: _navyMid,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _amber, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide:
                const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide:
                const BorderSide(color: Color(0xFFEF4444), width: 1.8)),
      ),
    );
  }
}