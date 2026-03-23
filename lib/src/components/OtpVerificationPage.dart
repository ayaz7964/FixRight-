// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:pinput/pinput.dart';
// // import '../../services/auth_service.dart';
// // import '../../services/auth_session_service.dart';
// // import '../../services/user_session.dart';
// // import '../../services/user_presence_service.dart';

// // class OtpVerificationPage extends StatefulWidget {
// //   final String verificationId;
// //   final String phoneNumber;
// //   final String firstName;
// //   final String lastName;
// //   final String city;
// //   final String country;
// //   final String address;
// //   final String password;

// //   const OtpVerificationPage({
// //     super.key,
// //     required this.verificationId,
// //     required this.phoneNumber,
// //     required this.firstName,
// //     required this.lastName,
// //     required this.city,
// //     required this.country,
// //     required this.address,
// //     required this.password,
// //   });

// //   @override
// //   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// // }

// // class _OtpVerificationPageState extends State<OtpVerificationPage> {
// //   final _otpController = TextEditingController();
// //   final _formKey = GlobalKey<FormState>();
// //   bool isVerifying = false;
// //   int resendTimer = 60;
// //   bool canResend = false;

// //   final AuthService _authService = AuthService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _startResendTimer();
// //   }

// //   @override
// //   void dispose() {
// //     _otpController.dispose();
// //     super.dispose();
// //   }

// //   /// Start countdown timer for resend
// //   void _startResendTimer() {
// //     setState(() {
// //       canResend = false;
// //       resendTimer = 60;
// //     });

// //     Future.delayed(const Duration(seconds: 1), () {
// //       if (mounted) {
// //         setState(() {
// //           if (resendTimer > 0) {
// //             resendTimer--;
// //             _startResendTimer();
// //           } else {
// //             canResend = true;
// //           }
// //         });
// //       }
// //     });
// //   }

// //   /// Verify OTP and create user
// //   Future<void> _verifyOtp() async {
// //     if (!_formKey.currentState!.validate()) {
// //       return;
// //     }

// //     setState(() => isVerifying = true);

// //     try {
// //       // Step 1: Verify OTP with Firebase
// //       final user = await _authService.verifyOtp(
// //         widget.verificationId,
// //         _otpController.text.trim(),
// //       );

// //       if (user == null) {
// //         throw Exception('Failed to authenticate user');
// //       }

// //       // Step 2: Create user profile in Firestore (uid will be set to phone number)
// //       await _authService.createUserProfile(
// //         phoneNumber: widget.phoneNumber,
// //         firstName: widget.firstName,
// //         lastName: widget.lastName,
// //         city: widget.city,
// //         country: widget.country,
// //         address: widget.address,
// //       );

// //       // Step 3: Save Password to auth collection (uid will be set to phone number)
// //       await _authService.savePassword(
// //         phoneNumber: widget.phoneNumber,
// //         password: widget.password,
// //       );

// //       // Step 4: Create Firebase Auth account for session persistence (new layer)
// //       // This establishes a proper session that will persist across app restarts
// //       try {
// //         final sessionService = AuthSessionService();
// //         await sessionService.createAuthAccount(
// //           phoneNumber: widget.phoneNumber,
// //           password: widget.password,
// //         );
// //         print('✅ Firebase Auth account created for session persistence');
// //       } catch (e) {
// //         print('⚠️ Firebase Auth account creation failed: $e');
// //         // Don't block registration - user can still log in with Firestore
// //       }

// //       if (!mounted) return;

// //       // Step 5: Set user session
// //       final UserModel userData = UserModel(
// //         uid: widget.phoneNumber,
// //         phone: widget.phoneNumber,
// //         firstName: widget.firstName,
// //         lastName: widget.lastName,
// //         city: widget.city,
// //         country: widget.country,
// //         address: widget.address,
// //         role: 'buyer',
// //         createdAt: DateTime.now(),
// //         lastLogin: DateTime.now(),
// //       );

// //       UserSession().setUserSession(
// //         phone: widget.phoneNumber,
// //         uid: widget.phoneNumber,
// //         userData: userData,
// //       );

// //       // Step 6: Initialize presence
// //       try {
// //         final presenceService = UserPresenceService();
// //         await presenceService.initializePresence();
// //       } catch (e) {
// //         print('Error initializing presence: $e');
// //       }

// //       // Step 7: Navigate to home
// //       if (mounted) {
// //         Navigator.of(context).pushReplacementNamed('/home');
// //       }
// //     } on FirebaseAuthException catch (e) {
// //       if (mounted) {
// //         setState(() => isVerifying = false);
// //         String message = 'Verification failed';
// //         if (e.code == 'invalid-verification-code') {
// //           message = 'Invalid OTP. Please check and try again.';
// //         } else if (e.code == 'session-expired') {
// //           message = 'OTP has expired. Please request a new one.';
// //         }
// //         _showError(message);
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => isVerifying = false);
// //         _showError('Error: $e');
// //       }
// //     }
// //   }

// //   /// Resend OTP
// //   Future<void> _resendOtp() async {
// //     if (!canResend) return;

// //     setState(() => isVerifying = true);

// //     try {
// //       await _authService.sendOtp(
// //         widget.phoneNumber,
// //         codeSent: (verificationId) {
// //           if (mounted) {
// //             setState(() => isVerifying = false);
// //             _startResendTimer();
// //             _showSuccess('OTP sent successfully');
// //           }
// //         },
// //         verificationFailed: (exception) {
// //           if (mounted) {
// //             setState(() => isVerifying = false);
// //             _showError('Failed to resend OTP: ${exception.message}');
// //           }
// //         },
// //       );
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => isVerifying = false);
// //         _showError('Error resending OTP: $e');
// //       }
// //     }
// //   }

// //   /// Show error snackbar
// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 4),
// //       ),
// //     );
// //   }

// //   /// Show success snackbar
// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.blue.shade50,
// //       appBar: AppBar(
// //         title: const Text('Verify Phone'),
// //         elevation: 0,
// //         backgroundColor: Colors.blue.shade50,
// //         leading: IconButton(
// //           onPressed: () => Navigator.of(context).pop(),
// //           icon: const Icon(Icons.arrow_back, color: Colors.black87),
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               children: [
// //                 // Icon
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.blue.shade100,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Icon(Icons.sms, size: 48, color: Colors.blue.shade700),
// //                 ),
// //                 const SizedBox(height: 24),

// //                 // Title
// //                 const Text(
// //                   'Verify Your Number',
// //                   style: TextStyle(
// //                     fontSize: 22,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),

// //                 // Subtitle
// //                 RichText(
// //                   textAlign: TextAlign.center,
// //                   text: TextSpan(
// //                     style: const TextStyle(color: Colors.grey, fontSize: 14),
// //                     children: [
// //                       const TextSpan(text: 'We sent a verification code to\n'),
// //                       TextSpan(
// //                         text: widget.phoneNumber,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),

// //                 // OTP Input (Pinput)
// //                 Pinput(
// //                   length: 6,
// //                   controller: _otpController,
// //                   keyboardType: TextInputType.number,
// //                   defaultPinTheme: PinTheme(
// //                     width: 55,
// //                     height: 55,
// //                     textStyle: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.black,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.grey.shade300),
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   focusedPinTheme: PinTheme(
// //                     width: 55,
// //                     height: 55,
// //                     textStyle: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.blue,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.blue, width: 2),
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   submittedPinTheme: PinTheme(
// //                     width: 55,
// //                     height: 55,
// //                     textStyle: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.green,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.green, width: 2),
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   onCompleted: (pin) {
// //                     // Auto-verify when 6 digits are entered
// //                     Future.delayed(const Duration(milliseconds: 500), () {
// //                       if (mounted && !isVerifying) {
// //                         _verifyOtp();
// //                       }
// //                     });
// //                   },
// //                 ),
// //                 const SizedBox(height: 32),

// //                 // Verify Button
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: isVerifying ? null : _verifyOtp,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 14),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                     ),
// //                     child: isVerifying
// //                         ? const SizedBox(
// //                             height: 24,
// //                             width: 24,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2.5,
// //                             ),
// //                           )
// //                         : const Text(
// //                             'Verify OTP',
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Resend Code
// //                 Column(
// //                   children: [
// //                     const Text(
// //                       "Didn't receive the code?",
// //                       style: TextStyle(color: Colors.grey, fontSize: 14),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     if (!canResend)
// //                       Text(
// //                         'Resend in ${resendTimer}s',
// //                         style: const TextStyle(
// //                           color: Colors.grey,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       )
// //                     else
// //                       GestureDetector(
// //                         onTap: _resendOtp,
// //                         child: const Text(
// //                           'Resend Code',
// //                           style: TextStyle(
// //                             color: Colors.blue,
// //                             fontWeight: FontWeight.w600,
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }




// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pinput/pinput.dart';
// import '../../services/auth_service.dart';
// import '../../services/auth_session_service.dart';
// import '../../services/user_session.dart';
// import '../../services/user_presence_service.dart';

// class OtpVerificationPage extends StatefulWidget {
//   final String  verificationId;
//   final String  phoneNumber;
//   final String  firstName;
//   final String  lastName;
//   final String  city;
//   final String  country;
//   final String  address;
//   final String  password;
//   // ✅ Profile image URL from Cloudinary (optional)
//   final String? profileImageUrl;

//   const OtpVerificationPage({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//     required this.firstName,
//     required this.lastName,
//     required this.city,
//     required this.country,
//     required this.address,
//     required this.password,
//     this.profileImageUrl,
//   });

//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }

// class _OtpVerificationPageState extends State<OtpVerificationPage>
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
//   static const Color _green         = Color(0xFF10B981);

//   final _otpController = TextEditingController();
//   final _formKey       = GlobalKey<FormState>();
//   bool isVerifying     = false;
//   int  resendTimer     = 60;
//   bool canResend       = false;

//   AnimationController? _fadeCtrl;
//   AnimationController? _pulseCtrl;
//   Animation<double>?   _fadeAnim;
//   Animation<double>?   _pulseAnim;

//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();

//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200))
//       ..repeat(reverse: true);

//     _fadeAnim  = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
//     _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut));

//     _fadeCtrl!.forward();
//   }

//   @override
//   void dispose() {
//     _otpController.dispose();
//     _fadeCtrl?.dispose();
//     _pulseCtrl?.dispose();
//     super.dispose();
//   }

//   // ── Original timer logic — UNTOUCHED ──────────────────────
//   void _startResendTimer() {
//     setState(() { canResend = false; resendTimer = 60; });
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         setState(() {
//           if (resendTimer > 0) {
//             resendTimer--;
//             _startResendTimer();
//           } else {
//             canResend = true;
//           }
//         });
//       }
//     });
//   }

//   // ── Original verify logic — profileImageUrl added ──────────
//   Future<void> _verifyOtp() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => isVerifying = true);

//     try {
//       // Step 1: Verify OTP with Firebase
//       final user = await _authService.verifyOtp(
//           widget.verificationId, _otpController.text.trim());

//       if (user == null) throw Exception('Failed to authenticate user');

//       // Step 2: Create user profile in Firestore
//       // ✅ profileImageUrl now passed here so it gets saved to users collection
//       await _authService.createUserProfile(
//         phoneNumber:    widget.phoneNumber,
//         firstName:      widget.firstName,
//         lastName:       widget.lastName,
//         city:           widget.city,
//         country:        widget.country,
//         address:        widget.address,
//         profileImage:   widget.profileImageUrl,   // ✅ saved to Firestore
//         profileUrl:     widget.profileImageUrl,   // ✅ saved to Firestore
//       );

//       // Step 3: Save password
//       await _authService.savePassword(
//         phoneNumber: widget.phoneNumber,
//         password:    widget.password,
//       );

//       // Step 4: Create Firebase Auth account for session persistence
//       try {
//         final sessionService = AuthSessionService();
//         await sessionService.createAuthAccount(
//           phoneNumber: widget.phoneNumber,
//           password:    widget.password,
//         );
//         print('✅ Firebase Auth account created for session persistence');
//       } catch (e) {
//         print('⚠️ Firebase Auth account creation failed: $e');
//       }

//       if (!mounted) return;

//       // Step 5: Set user session
//       final UserModel userData = UserModel(
//         uid:       widget.phoneNumber,
//         phone:     widget.phoneNumber,
//         firstName: widget.firstName,
//         lastName:  widget.lastName,
//         city:      widget.city,
//         country:   widget.country,
//         address:   widget.address,
//         role:      'buyer',
//         createdAt: DateTime.now(),
//         lastLogin: DateTime.now(),
//       );

//       UserSession().setUserSession(
//         phone:    widget.phoneNumber,
//         uid:      widget.phoneNumber,
//         userData: userData,
//       );

//       // Step 6: Initialize presence
//       try {
//         await UserPresenceService().initializePresence();
//       } catch (e) {
//         print('Error initializing presence: $e');
//       }

//       // Step 7: Navigate to home
//       if (mounted) Navigator.of(context).pushReplacementNamed('/home');

//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         setState(() => isVerifying = false);
//         String message = 'Verification failed';
//         if (e.code == 'invalid-verification-code') {
//           message = 'Invalid OTP. Please check and try again.';
//         } else if (e.code == 'session-expired') {
//           message = 'OTP has expired. Please request a new one.';
//         }
//         _showError(message);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => isVerifying = false);
//         _showError('Error: $e');
//       }
//     }
//   }

//   // ── Original resend logic — UNTOUCHED ─────────────────────
//   Future<void> _resendOtp() async {
//     if (!canResend) return;
//     setState(() => isVerifying = true);
//     try {
//       await _authService.sendOtp(
//         widget.phoneNumber,
//         codeSent: (verificationId) {
//           if (mounted) {
//             setState(() => isVerifying = false);
//             _startResendTimer();
//             _showSuccess('OTP sent successfully');
//           }
//         },
//         verificationFailed: (exception) {
//           if (mounted) {
//             setState(() => isVerifying = false);
//             _showError('Failed to resend OTP: ${exception.message}');
//           }
//         },
//       );
//     } catch (e) {
//       if (mounted) {
//         setState(() => isVerifying = false);
//         _showError('Error resending OTP: $e');
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
//       backgroundColor: const Color(0xFFDC2626),
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
//       backgroundColor: _green,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       duration: const Duration(seconds: 2),
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
//         title: const Text('Verify Phone',
//             style: TextStyle(
//                 color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
//       ),
//       body: Stack(children: [
//         // Amber blob top-right
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
//         // Blue blob bottom-left
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
//               ? FadeTransition(opacity: _fadeAnim!, child: _buildContent())
//               : _buildContent(),
//         ),
//       ]),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: Form(
//         key: _formKey,
//         child: Column(children: [

//           // ── Icon ──────────────────────────────────────────
//           ScaleTransition(
//             scale: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
//             child: Container(
//               width: 80, height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                     colors: [_amber, _amberLight],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight),
//                 boxShadow: [
//                   BoxShadow(color: _amber.withOpacity(0.35),
//                       blurRadius: 24, offset: const Offset(0, 8))
//                 ],
//               ),
//               child: const Icon(Icons.sms_outlined, color: _navy, size: 36),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // ── Title ─────────────────────────────────────────
//           const Text('Verify Your Number',
//               style: TextStyle(
//                   fontSize: 22, fontWeight: FontWeight.w900,
//                   color: _textPrimary, letterSpacing: -0.3)),

//           const SizedBox(height: 10),

//           // ── Subtitle ──────────────────────────────────────
//           RichText(
//             textAlign: TextAlign.center,
//             text: TextSpan(children: [
//               const TextSpan(
//                   text: 'We sent a 6-digit code to\n',
//                   style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.6)),
//               TextSpan(
//                   text: widget.phoneNumber,
//                   style: const TextStyle(
//                       color: _amber, fontWeight: FontWeight.w700, fontSize: 14)),
//             ]),
//           ),

//           const SizedBox(height: 36),

//           // ── OTP Card ──────────────────────────────────────
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
//             padding: const EdgeInsets.all(28),
//             child: Column(children: [

//               // Profile photo preview (if uploaded)
//               if (widget.profileImageUrl != null) ...[
//                 Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Container(
//                     width: 48, height: 48,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: _amber, width: 2),
//                       image: DecorationImage(
//                           image: NetworkImage(widget.profileImageUrl!),
//                           fit: BoxFit.cover),
//                       boxShadow: [
//                         BoxShadow(color: _amber.withOpacity(0.25),
//                             blurRadius: 10)
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('${widget.firstName} ${widget.lastName}',
//                         style: const TextStyle(
//                             color: _textPrimary,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700)),
//                     Text(widget.city,
//                         style: const TextStyle(
//                             color: _textSecondary, fontSize: 12)),
//                   ]),
//                 ]),
//                 const SizedBox(height: 20),
//                 Container(height: 1, color: _border),
//                 const SizedBox(height: 20),
//               ],

//               // OTP label
//               const Text('Enter 6-digit code',
//                   style: TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w600,
//                       color: _textSecondary, letterSpacing: 0.3)),
//               const SizedBox(height: 20),

//               // ── Pinput ──────────────────────────────────
//               Pinput(
//                 length: 6,
//                 controller: _otpController,
//                 keyboardType: TextInputType.number,
//                 defaultPinTheme: PinTheme(
//                   width: 48, height: 52,
//                   textStyle: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.w800,
//                       color: _textPrimary),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: _border, width: 1.5),
//                     color: _navyMid,
//                   ),
//                 ),
//                 focusedPinTheme: PinTheme(
//                   width: 48, height: 52,
//                   textStyle: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.w800,
//                       color: _amber),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: _amber, width: 2),
//                     color: _navyMid,
//                     boxShadow: [
//                       BoxShadow(color: _amber.withOpacity(0.2),
//                           blurRadius: 8)
//                     ],
//                   ),
//                 ),
//                 submittedPinTheme: PinTheme(
//                   width: 48, height: 52,
//                   textStyle: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.w800,
//                       color: _green),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: _green, width: 1.8),
//                     color: _navyMid,
//                   ),
//                 ),
//                 onCompleted: (pin) {
//                   // Auto-verify when 6 digits entered
//                   Future.delayed(const Duration(milliseconds: 400), () {
//                     if (mounted && !isVerifying) _verifyOtp();
//                   });
//                 },
//               ),

//               const SizedBox(height: 28),

//               // ── Verify button ───────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isVerifying ? null : _verifyOtp,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     padding: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient: isVerifying ? null
//                           : const LinearGradient(
//                               colors: [_amber, Color(0xFFD97706)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight),
//                       color: isVerifying ? _border : null,
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: isVerifying ? [] : [
//                         BoxShadow(color: _amber.withOpacity(0.40),
//                             blurRadius: 14, offset: const Offset(0, 5))
//                       ],
//                     ),
//                     child: Container(
//                       alignment: Alignment.center,
//                       child: isVerifying
//                           ? const SizedBox(height: 22, width: 22,
//                               child: CircularProgressIndicator(
//                                   color: Color(0xFF8DA4BE), strokeWidth: 2.5))
//                           : const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.verified_rounded,
//                                     color: _navy, size: 18),
//                                 SizedBox(width: 8),
//                                 Text('Verify OTP',
//                                     style: TextStyle(
//                                         fontSize: 15, fontWeight: FontWeight.w800,
//                                         color: _navy, letterSpacing: 0.3)),
//                               ],
//                             ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // ── Resend section ──────────────────────────
//               Column(children: [
//                 const Text("Didn't receive the code?",
//                     style: TextStyle(color: _textSecondary, fontSize: 13)),
//                 const SizedBox(height: 8),
//                 if (!canResend)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 7),
//                     decoration: BoxDecoration(
//                       color: _navyMid,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: _border),
//                     ),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       const Icon(Icons.timer_outlined,
//                           color: _textSecondary, size: 14),
//                       const SizedBox(width: 5),
//                       Text('Resend in ${resendTimer}s',
//                           style: const TextStyle(
//                               color: _textSecondary,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600)),
//                     ]),
//                   )
//                 else
//                   GestureDetector(
//                     onTap: isVerifying ? null : _resendOtp,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _amber.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: _amber.withOpacity(0.4)),
//                       ),
//                       child: Row(mainAxisSize: MainAxisSize.min, children: [
//                         const Icon(Icons.refresh_rounded,
//                             color: _amber, size: 15),
//                         const SizedBox(width: 6),
//                         const Text('Resend Code',
//                             style: TextStyle(
//                                 color: _amber,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13)),
//                       ]),
//                     ),
//                   ),
//               ]),
//             ]),
//           ),

//           const SizedBox(height: 24),

//           // ── Security note ─────────────────────────────────
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: _navyMid,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _border),
//             ),
//             child: const Row(children: [
//               Icon(Icons.shield_outlined, color: _textSecondary, size: 16),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Your code expires in 10 minutes. Never share it with anyone.',
//                   style: TextStyle(
//                       fontSize: 11, color: _textSecondary, height: 1.4),
//                 ),
//               ),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session_service.dart';
import '../../services/user_session.dart';
import '../../services/user_presence_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String  verificationId;
  final String  phoneNumber;
  final String  firstName;
  final String  lastName;
  final String  city;
  final String  country;
  final String  address;
  final String  password;
  final String? profileImageUrl; // ✅ optional — from Cloudinary upload

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.address,
    required this.password,
    this.profileImageUrl,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {

  // ── Brand Palette ──────────────────────────────────────────
  // static const Color _navy          = Color(0xFF0B1A2E);
  // static const Color _navyMid       = Color(0xFF112240);
  // static const Color _amber         = Color(0xFFF59E0B);
  // static const Color _amberLight    = Color(0xFFFCD34D);
  // static const Color _surface       = Color(0xFF172A45);
  // static const Color _border        = Color(0xFF1E3A5F);
  // static const Color _textPrimary   = Color(0xFFE2E8F0);
  // static const Color _textSecondary = Color(0xFF8DA4BE);
  // static const Color _green         = Color(0xFF10B981);

  static const Color _navy          = Color(0xFF042B1E);   // very dark green (was dark navy blue)
static const Color _navyMid       = Color(0xFF073D2A);   // dark green mid (was navy mid blue)
static const Color _amber         = Color(0xFF38BDF8);   // sky blue accent (was amber orange)
static const Color _amberLight    = Color(0xFF7DD3FC);   // light sky blue (was amber yellow)
static const Color _surface       = Color(0xFF0C3D26);   // dark green surface (was dark blue surface)
static const Color _border        = Color(0xFF155C38);   // green border (was blue border)
static const Color _textPrimary   = Color(0xFFE2F4EC);   // off-white green tint (was blue-white)
static const Color _textSecondary = Color(0xFF7AB89A);   // muted green-grey (was muted blue-grey)
static const Color _green         = Color(0xFF10B981);   // unchanged — already perfect

  final _otpController = TextEditingController();
  final _formKey       = GlobalKey<FormState>();
  bool isVerifying     = false;
  int  resendTimer     = 60;
  bool canResend       = false;

  AnimationController? _fadeCtrl;
  AnimationController? _pulseCtrl;
  Animation<double>?   _fadeAnim;
  Animation<double>?   _pulseAnim;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut));

    _fadeCtrl!.forward();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _fadeCtrl?.dispose();
    _pulseCtrl?.dispose();
    super.dispose();
  }

  // ── ALL ORIGINAL LOGIC — UNTOUCHED ────────────────────────

  void _startResendTimer() {
    setState(() { canResend = false; resendTimer = 60; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (resendTimer > 0) {
            resendTimer--;
            _startResendTimer();
          } else {
            canResend = true;
          }
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isVerifying = true);

    try {
      // Step 1: Verify OTP with Firebase
      final user = await _authService.verifyOtp(
          widget.verificationId, _otpController.text.trim());

      if (user == null) throw Exception('Failed to authenticate user');

      // Step 2: Create user profile in Firestore
      // ✅ profileImageUrl saved to both profileImage and profileUrl fields
      await _authService.createUserProfile(
        phoneNumber:  widget.phoneNumber,
        firstName:    widget.firstName,
        lastName:     widget.lastName,
        city:         widget.city,
        country:      widget.country,
        address:      widget.address,
        profileImage: widget.profileImageUrl,
        profileUrl:   widget.profileImageUrl,
      );

      // Step 3: Save password to auth collection
      await _authService.savePassword(
        phoneNumber: widget.phoneNumber,
        password:    widget.password,
      );

      // Step 4: Create Firebase Auth account for session persistence
      try {
        final sessionService = AuthSessionService();
        await sessionService.createAuthAccount(
          phoneNumber: widget.phoneNumber,
          password:    widget.password,
        );
        print('✅ Firebase Auth account created for session persistence');
      } catch (e) {
        print('⚠️ Firebase Auth account creation failed: $e');
      }

      if (!mounted) return;

      // Step 5: Set user session
      final UserModel userData = UserModel(
        uid:       widget.phoneNumber,
        phone:     widget.phoneNumber,
        firstName: widget.firstName,
        lastName:  widget.lastName,
        city:      widget.city,
        country:   widget.country,
        address:   widget.address,
        role:      'buyer',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      UserSession().setUserSession(
        phone:    widget.phoneNumber,
        uid:      widget.phoneNumber,
        userData: userData,
      );

      // Step 6: Initialize presence
      try {
        await UserPresenceService().initializePresence();
      } catch (e) {
        print('Error initializing presence: $e');
      }

      // Step 7: Navigate to home
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => isVerifying = false);
        String message = 'Verification failed';
        if (e.code == 'invalid-verification-code') {
          message = 'Invalid OTP. Please check and try again.';
        } else if (e.code == 'session-expired') {
          message = 'OTP has expired. Please request a new one.';
        }
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isVerifying = false);
        _showError('Error: $e');
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!canResend) return;
    setState(() => isVerifying = true);
    try {
      await _authService.sendOtp(
        widget.phoneNumber,
        codeSent: (verificationId) {
          if (mounted) {
            setState(() => isVerifying = false);
            _startResendTimer();
            _showSuccess('OTP sent successfully');
          }
        },
        verificationFailed: (exception) {
          if (mounted) {
            setState(() => isVerifying = false);
            _showError('Failed to resend OTP: ${exception.message}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isVerifying = false);
        _showError('Error resending OTP: $e');
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
      backgroundColor: const Color(0xFFDC2626),
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
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify Phone',
            style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ),
      body: Stack(children: [
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
        Positioned(
          bottom: -80, left: -60,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF1E40AF).withOpacity(0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        SafeArea(
          child: _fadeAnim != null
              ? FadeTransition(opacity: _fadeAnim!, child: _buildContent())
              : _buildContent(),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(children: [

          // ── Pulsing icon ──────────────────────────────────
          ScaleTransition(
            scale: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [_amber, _amberLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(color: _amber.withOpacity(0.35),
                      blurRadius: 24, offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.sms_outlined, color: _navy, size: 36),
            ),
          ),

          const SizedBox(height: 24),

          const Text('Verify Your Number',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900,
                  color: _textPrimary, letterSpacing: -0.3)),

          const SizedBox(height: 10),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              const TextSpan(
                  text: 'We sent a 6-digit code to\n',
                  style: TextStyle(
                      color: _textSecondary, fontSize: 13, height: 1.6)),
              TextSpan(
                  text: widget.phoneNumber,
                  style: const TextStyle(
                      color: _amber,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ]),
          ),

          const SizedBox(height: 32),

          // ── OTP Card ──────────────────────────────────────
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
            padding: const EdgeInsets.all(28),
            child: Column(children: [

              // Profile preview (if photo was uploaded)
              if (widget.profileImageUrl != null) ...[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _amber, width: 2),
                      image: DecorationImage(
                          image: NetworkImage(widget.profileImageUrl!),
                          fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(color: _amber.withOpacity(0.25),
                            blurRadius: 10)
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${widget.firstName} ${widget.lastName}',
                        style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text(widget.city,
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 12)),
                  ]),
                ]),
                const SizedBox(height: 20),
                Container(height: 1, color: _border),
                const SizedBox(height: 20),
              ],

              const Text('Enter 6-digit code',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                      letterSpacing: 0.3)),
              const SizedBox(height: 20),

              // ── Pinput ────────────────────────────────────
              Pinput(
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  width: 48, height: 52,
                  textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border, width: 1.5),
                    color: _navyMid,
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 48, height: 52,
                  textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _amber),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _amber, width: 2),
                    color: _navyMid,
                    boxShadow: [
                      BoxShadow(color: _amber.withOpacity(0.2),
                          blurRadius: 8)
                    ],
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 48, height: 52,
                  textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _green),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _green, width: 1.8),
                    color: _navyMid,
                  ),
                ),
                onCompleted: (pin) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted && !isVerifying) _verifyOtp();
                  });
                },
              ),

              const SizedBox(height: 28),

              // ── Verify button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isVerifying
                          ? null
                          : const LinearGradient(
                              colors: [_amber, Color(0xFFD97706)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                      color: isVerifying ? _border : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isVerifying
                          ? []
                          : [
                              BoxShadow(
                                  color: _amber.withOpacity(0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5))
                            ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: isVerifying
                          ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(
                                  color: _textSecondary, strokeWidth: 2.5))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: _navy, size: 18),
                                SizedBox(width: 8),
                                Text('Verify OTP',
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

              // ── Resend section ────────────────────────────
              Column(children: [
                const Text("Didn't receive the code?",
                    style: TextStyle(color: _textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                if (!canResend)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _navyMid,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.timer_outlined,
                          color: _textSecondary, size: 14),
                      const SizedBox(width: 5),
                      Text('Resend in ${resendTimer}s',
                          style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  )
                else
                  GestureDetector(
                    onTap: isVerifying ? null : _resendOtp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _amber.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.refresh_rounded,
                            color: _amber, size: 15),
                        const SizedBox(width: 6),
                        const Text('Resend Code',
                            style: TextStyle(
                                color: _amber,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ]),
                    ),
                  ),
              ]),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Security note ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _navyMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Row(children: [
              Icon(Icons.shield_outlined,
                  color: _textSecondary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your code expires in 10 minutes. Never share it with anyone.',
                  style: TextStyle(
                      fontSize: 11, color: _textSecondary, height: 1.4),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}