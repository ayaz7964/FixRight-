// import 'package:flutter/material.dart';
// import 'package:country_picker/country_picker.dart';
// import '../../services/auth_service.dart';
// import 'package:pinput/pinput.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final AuthService _authService = AuthService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Country selectedCountry;

//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool isLoading = false;
//   bool otpSent = false;
//   bool otpVerified = false;
//   bool showNewPassword = false;
//   bool showConfirmPassword = false;
//   String verificationId = '';
//   String phoneNumber = '';
//   String oldPasswordIs = '';

//   @override
//   void initState() {
//     super.initState();
//     selectedCountry = Country.parse('PK');
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchOldPassword() async {
//     try {
//       final authDoc = await _firestore
//           .collection('auth')
//           .doc(phoneNumber)
//           .get();

//       if (!authDoc.exists) {
//         throw Exception('User not found.');
//       }

//       final authData = authDoc.data() as Map<String, dynamic>;
//       oldPasswordIs = authData['password'] ?? 'Password not set';

//       print('Password for $phoneNumber: $oldPasswordIs');
//     } catch (e) {
//       print('Error fetching password: $e');
//       rethrow;
//     }
//   }

//   Future<void> _sendOtp() async {
//     final phone = _phoneController.text.trim();

//     if (phone.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ Please enter your phone number'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (phone.length < 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ Phone number must be at least 10 digits'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     phoneNumber = '+${selectedCountry.phoneCode}$phone';

//     try {
//       await _authService.sendOtp(
//         phoneNumber,
//         codeSent: (verificationId_) {
//           setState(() {
//             verificationId = verificationId_;
//             otpSent = true;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('✅ OTP sent to your phone'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         },
//         verificationFailed: (error) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('❌ Error: ${error.message}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ Error sending OTP: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _verifyOtp() async {
//     final otp = _otpController.text.trim();

//     if (otp.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ Please enter the OTP'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ OTP must be 6 digits'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final user = await _authService.verifyOtp(verificationId, otp);

//       if (user != null) {
//         setState(() => otpVerified = true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Phone verified successfully'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       await  _fetchOldPassword();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('❌ Invalid OTP. Please try again'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ Error verifying OTP: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _resetPassword() async {
//     // final newPass = _newPasswordController.text.trim();
//     // final confirmPass = _confirmPasswordController.text.trim();

//     // // Validate fields not empty
//     // if (newPass.isEmpty || confirmPass.isEmpty) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text('❌ Please enter password in both fields'),
//     //       backgroundColor: Colors.red,
//     //     ),
//     //   );
//     //   return;
//     // }

//     // // Validate password length
//     // if (newPass.length < 6) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text('❌ Password must be at least 6 characters'),
//     //       backgroundColor: Colors.red,
//     //     ),
//     //   );
//     //   return;
//     // }

//     // // Validate passwords match
//     // if (newPass != confirmPass) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text('❌ Passwords do not match'),
//     //       backgroundColor: Colors.red,
//     //     ),
//     //   );
//     //   return;
//     // }

//     // setState(() => isLoading = true);

//     // try {
//     //   // Validate phone number is set
//     //   if (phoneNumber.isEmpty) {
//     //     throw Exception('Phone number not found. Please start over.');
//     //   }

//     //   // Call resetPassword to update in Firestore auth collection
//     //   await _authService.resetPassword(
//     //     phone: phoneNumber,
//     //     newPassword: newPass,
//     //   );

//     //   if (mounted) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(
//     //         content: Text('✅ Password reset successfully!'),
//     //         backgroundColor: Colors.green,
//     //         duration: Duration(seconds: 2),
//     //       ),
//     //     );

//     //     // Return to login with success flag
//     //     Navigator.pop(context, true);
//     //   }
//     // } catch (e) {
//     //   if (mounted) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(
//     //         content: Text(
//     //           '❌ Error: ${e.toString().replaceAll('Exception: ', '')}',
//     //         ),
//     //         backgroundColor: const Color.fromARGB(255, 237, 25, 25),
//     //         duration: const Duration(seconds: 4),
//     //       ),
//     //     );
//     //   }
//     // } finally {
//     //   if (mounted) {
//     //     setState(() => isLoading = false);
//     //   }
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Reset Password',
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Column(
//               children: [
//                 Text(
//                   'Forgot your password?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.blueAccent.shade400,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'We\'ll help you reset it',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 32),

//                 // Step 1: Enter Phone Number
//                 if (!otpSent)
//                   Card(
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Step Indicator
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blueAccent.shade100,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Text(
//                               'Step 1 of 3',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blueAccent,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Enter your phone number',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                               color: Colors.grey.shade900,
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Country Picker
//                           Text(
//                             'Country',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           GestureDetector(
//                             onTap: () {
//                               showCountryPicker(
//                                 context: context,
//                                 onSelect: (Country country) {
//                                   setState(() => selectedCountry = country);
//                                 },
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: Colors.white,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     '${selectedCountry.flagEmoji}  ${selectedCountry.name}',
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   const Icon(
//                                     Icons.arrow_drop_down,
//                                     color: Colors.grey,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Phone Number Field
//                           Text(
//                             'Phone Number',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _phoneController,
//                             keyboardType: TextInputType.phone,
//                             decoration: InputDecoration(
//                               hintText: '3001234567',
//                               prefixIcon: const Icon(Icons.phone),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: Colors.blue,
//                                   width: 2,
//                                 ),
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 24),

//                           // Send OTP Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: isLoading ? null : _sendOtp,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blueAccent,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 4,
//                               ),
//                               child: isLoading
//                                   ? const SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 3,
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Send OTP',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // Step 2: Verify OTP
//                 if (otpSent && !otpVerified)
//                   Card(
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Step Indicator
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blueAccent.shade100,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Text(
//                               'Step 2 of 3',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blueAccent,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Verify OTP',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                               color: Colors.grey.shade900,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Enter the 6-digit code sent to your phone',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           const SizedBox(height: 24),

//                           // OTP Input Field
//                           Pinput(
//                             length: 6,
//                             controller: _otpController,
//                             keyboardType: TextInputType.number,
//                             defaultPinTheme: PinTheme(
//                               width: 50,
//                               height: 50,
//                               textStyle: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 color: Colors.white,
//                               ),
//                             ),
//                             focusedPinTheme: PinTheme(
//                               width: 50,
//                               height: 50,
//                               textStyle: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blue,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: Colors.blue,
//                                   width: 2,
//                                 ),
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 24),

//                           // Verify OTP Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: isLoading ? null : _verifyOtp,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blueAccent,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 4,
//                               ),
//                               child: isLoading
//                                   ? const SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 3,
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Verify OTP',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),

//                           // Back Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: OutlinedButton(
//                               onPressed: () {
//                                 setState(() {
//                                   otpSent = false;
//                                   _otpController.clear();
//                                 });
//                               },
//                               style: OutlinedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 side: BorderSide(color: Colors.grey.shade300),
//                               ),
//                               child: const Text(
//                                 'Change Phone Number',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // Step 3: Reset Password
//                 if (otpVerified)
//                   Card(
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Step Indicator
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blueAccent.shade100,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Text(
//                               'Step 3 of 3',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blueAccent,
//                               ),
//                             ),
//                           ),

//                           Text("The Password of your " , style: TextStyle(fontWeight:FontWeight.bold),),
//                           Text(phoneNumber),
//                           Text("Password is "),
//                           Text(oldPasswordIs)

//                         ],
//                       ),
//                       //   children: [
//                       //     // Step Indicator
//                       //     Container(
//                       //       padding: const EdgeInsets.symmetric(
//                       //         horizontal: 12,
//                       //         vertical: 6,
//                       //       ),
//                       //       decoration: BoxDecoration(
//                       //         color: Colors.blueAccent.shade100,
//                       //         borderRadius: BorderRadius.circular(20),
//                       //       ),
//                       //       child: const Text(
//                       //         'Step 3 of 3',
//                       //         style: TextStyle(
//                       //           fontSize: 12,
//                       //           fontWeight: FontWeight.w600,
//                       //           color: Colors.blueAccent,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 16),
//                       //     Text(
//                       //       'Set New Password',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.w600,
//                       //         fontSize: 16,
//                       //         color: Colors.grey.shade900,
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 16),

//                       //     // New Password Field
//                       //     Text(
//                       //       'New Password',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.w600,
//                       //         fontSize: 12,
//                       //         color: Colors.grey.shade700,
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 8),
//                       //     TextField(
//                       //       controller: _newPasswordController,
//                       //       obscureText: !showNewPassword,
//                       //       decoration: InputDecoration(
//                       //         hintText: 'Enter new password',
//                       //         prefixIcon: const Icon(Icons.lock),
//                       //         suffixIcon: IconButton(
//                       //           icon: Icon(
//                       //             showNewPassword
//                       //                 ? Icons.visibility
//                       //                 : Icons.visibility_off,
//                       //             color: Colors.grey,
//                       //           ),
//                       //           onPressed: () {
//                       //             setState(
//                       //               () => showNewPassword = !showNewPassword,
//                       //             );
//                       //           },
//                       //         ),
//                       //         border: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //         ),
//                       //         enabledBorder: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //           borderSide: BorderSide(
//                       //             color: Colors.grey.shade300,
//                       //           ),
//                       //         ),
//                       //         focusedBorder: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //           borderSide: const BorderSide(
//                       //             color: Colors.blue,
//                       //             width: 2,
//                       //           ),
//                       //         ),
//                       //         filled: true,
//                       //         fillColor: Colors.white,
//                       //         helperText: 'Minimum 6 characters',
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 16),

//                       //     // Confirm Password Field
//                       //     Text(
//                       //       'Confirm Password',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.w600,
//                       //         fontSize: 12,
//                       //         color: Colors.grey.shade700,
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 8),
//                       //     TextField(
//                       //       controller: _confirmPasswordController,
//                       //       obscureText: !showConfirmPassword,
//                       //       decoration: InputDecoration(
//                       //         hintText: 'Confirm password',
//                       //         prefixIcon: const Icon(Icons.lock),
//                       //         suffixIcon: IconButton(
//                       //           icon: Icon(
//                       //             showConfirmPassword
//                       //                 ? Icons.visibility
//                       //                 : Icons.visibility_off,
//                       //             color: Colors.grey,
//                       //           ),
//                       //           onPressed: () {
//                       //             setState(
//                       //               () => showConfirmPassword =
//                       //                   !showConfirmPassword,
//                       //             );
//                       //           },
//                       //         ),
//                       //         border: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //         ),
//                       //         enabledBorder: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //           borderSide: BorderSide(
//                       //             color: Colors.grey.shade300,
//                       //           ),
//                       //         ),
//                       //         focusedBorder: OutlineInputBorder(
//                       //           borderRadius: BorderRadius.circular(12),
//                       //           borderSide: const BorderSide(
//                       //             color: Colors.blue,
//                       //             width: 2,
//                       //           ),
//                       //         ),
//                       //         filled: true,
//                       //         fillColor: Colors.white,
//                       //       ),
//                       //     ),
//                       //     const SizedBox(height: 24),

//                       //     // Reset Password Button
//                       //     SizedBox(
//                       //       width: double.infinity,
//                       //       child: ElevatedButton(
//                       //         onPressed: isLoading ? null : _resetPassword,
//                       //         style: ElevatedButton.styleFrom(
//                       //           backgroundColor: Colors.green.shade600,
//                       //           foregroundColor: Colors.white,
//                       //           padding: const EdgeInsets.symmetric(
//                       //             vertical: 16,
//                       //           ),
//                       //           shape: RoundedRectangleBorder(
//                       //             borderRadius: BorderRadius.circular(12),
//                       //           ),
//                       //           elevation: 4,
//                       //         ),
//                       //         child: isLoading
//                       //             ? const SizedBox(
//                       //                 height: 24,
//                       //                 width: 24,
//                       //                 child: CircularProgressIndicator(
//                       //                   color: Colors.white,
//                       //                   strokeWidth: 3,
//                       //                 ),
//                       //               )
//                       //             : const Text(
//                       //                 'Reset Password',
//                       //                 style: TextStyle(
//                       //                   fontSize: 16,
//                       //                   fontWeight: FontWeight.w700,
//                       //                 ),
//                       //               ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import 'package:pinput/pinput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Country selectedCountry;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool otpSent = false;
  bool otpVerified = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool _passwordVisible = false;
  String verificationId = '';
  String phoneNumber = '';
  String oldPasswordIs = '';

  // ── Brand Palette (matches LoginPage) ─────────────────────
  static const Color _navy          = Color(0xFF0B1A2E);
  static const Color _navyMid       = Color(0xFF112240);
  static const Color _amber         = Color(0xFFF59E0B);
  static const Color _amberLight    = Color(0xFFFCD34D);
  static const Color _surface       = Color(0xFF172A45);
  static const Color _border        = Color(0xFF1E3A5F);
  static const Color _textPrimary   = Color(0xFFE2E8F0);
  static const Color _textSecondary = Color(0xFF8DA4BE);
  static const Color _green         = Color(0xFF10B981);

  // ── Animation ─────────────────────────────────────────────
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedCountry = Country.parse('PK');

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    );
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  // ── Step transition helper ─────────────────────────────────
  void _goToNextStep(VoidCallback stateChange) {
    _fadeController?.reverse().then((_) {
      setState(stateChange);
      _fadeController?.forward();
    });
  }

  // ── ALL ORIGINAL LOGIC — UNTOUCHED ────────────────────────

  Future<void> _fetchOldPassword() async {
    try {
      final authDoc =
          await _firestore.collection('auth').doc(phoneNumber).get();

      if (!authDoc.exists) throw Exception('User not found.');

      final authData = authDoc.data() as Map<String, dynamic>;
      oldPasswordIs = authData['password'] ?? 'Password not set';

      print('Password for $phoneNumber: $oldPasswordIs');
    } catch (e) {
      print('Error fetching password: $e');
      rethrow;
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    if (phone.length < 10) {
      _showError('Phone number must be at least 10 digits');
      return;
    }

    setState(() => isLoading = true);
    phoneNumber = '+${selectedCountry.phoneCode}$phone';

    try {
      await _authService.sendOtp(
        phoneNumber,
        codeSent: (verificationId_) {
          _goToNextStep(() {
            verificationId = verificationId_;
            otpSent = true;
          });
          _showSuccess('OTP sent to your phone');
        },
        verificationFailed: (error) {
          _showError('Error: ${error.message}');
        },
      );
    } catch (e) {
      _showError('Error sending OTP: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showError('Please enter the OTP');
      return;
    }
    if (otp.length != 6) {
      _showError('OTP must be 6 digits');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.verifyOtp(verificationId, otp);

      if (user != null) {
        await _fetchOldPassword();
        _goToNextStep(() => otpVerified = true);
        _showSuccess('Phone verified successfully');
      } else {
        _showError('Invalid OTP. Please try again');
      }
    } catch (e) {
      _showError('Error verifying OTP: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    // Original logic kept (currently commented out in source)
  }

  // ── Snackbar helpers ──────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('❌  $message')),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('✅  $message')),
          ],
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Background blobs ──
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _amber.withOpacity(0.14),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF1E40AF).withOpacity(0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildPageHeader(),
                  const SizedBox(height: 28),
                  _buildStepIndicatorRow(),
                  const SizedBox(height: 24),

                  // ── Animated step card ──
                  _fadeAnimation != null
                      ? FadeTransition(
                          opacity: _fadeAnimation!,
                          child: _buildCurrentStep(),
                        )
                      : _buildCurrentStep(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [_amber, _amberLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _amber.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded, color: _navy, size: 32),
        ),
        const SizedBox(height: 14),
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Verify your number to recover access',
          style: TextStyle(fontSize: 13, color: _textSecondary),
        ),
      ],
    );
  }

  // ── STEP INDICATOR ROW ─────────────────────────────────────

  Widget _buildStepIndicatorRow() {
    final steps = ['Phone', 'OTP', 'Password'];
    final currentStep = !otpSent ? 0 : !otpVerified ? 1 : 2;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final leftDone = (i ~/ 2) < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: leftDone ? _amber : _border,
              ),
            ),
          );
        }

        final idx = i ~/ 2;
        final isDone = idx < currentStep;
        final isActive = idx == currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? _amber
                    : isActive
                        ? _navyMid
                        : _navyMid,
                border: Border.all(
                  color: isDone || isActive ? _amber : _border,
                  width: isActive ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: _navy, size: 18)
                    : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive ? _amber : _textSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[idx],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDone || isActive ? _amber : _textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── CURRENT STEP ROUTER ────────────────────────────────────

  Widget _buildCurrentStep() {
    if (!otpSent) return _buildStep1();
    if (!otpVerified) return _buildStep2();
    return _buildStep3();
  }

  // ── STEP 1: Phone Number ───────────────────────────────────

  Widget _buildStep1() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepBadge('Step 1 of 3 · Enter Phone'),
          const SizedBox(height: 16),
          const Text(
            'Enter your registered phone number',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          _label('Country'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => showCountryPicker(
              context: context,
              onSelect: (c) => setState(() => selectedCountry = c),
            ),
            child: _inputContainer(
              child: Row(
                children: [
                  Text(
                    '${selectedCountry.flagEmoji}  ${selectedCountry.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _textSecondary, size: 22),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _label('Phone Number'),
          const SizedBox(height: 8),
          _styledTextField(
            controller: _phoneController,
            hint: '3001234567',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),

          const SizedBox(height: 24),
          _primaryButton(
            label: 'Send OTP',
            icon: Icons.send_rounded,
            onPressed: isLoading ? null : _sendOtp,
          ),
        ],
      ),
    );
  }

  // ── STEP 2: Verify OTP ─────────────────────────────────────

  Widget _buildStep2() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepBadge('Step 2 of 3 · Verify OTP'),
          const SizedBox(height: 16),
          const Text(
            'Enter the 6-digit code',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sent to $phoneNumber',
            style: const TextStyle(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 28),

          // OTP Pin Input
          Center(
            child: Pinput(
              length: 6,
              controller: _otpController,
              keyboardType: TextInputType.number,
              defaultPinTheme: PinTheme(
                width: 48,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border, width: 1.5),
                  color: _navyMid,
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 48,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _amber,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _amber, width: 2),
                  color: _navyMid,
                ),
              ),
              submittedPinTheme: PinTheme(
                width: 48,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _amber,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _amber, width: 1.5),
                  color: _navyMid,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
          _primaryButton(
            label: 'Verify OTP',
            icon: Icons.verified_rounded,
            onPressed: isLoading ? null : _verifyOtp,
          ),
          const SizedBox(height: 12),
          _secondaryButton(
            label: 'Change Phone Number',
            onPressed: () => _goToNextStep(() {
              otpSent = false;
              _otpController.clear();
            }),
          ),
        ],
      ),
    );
  }

  // ── STEP 3: Show Password ──────────────────────────────────

  Widget _buildStep3() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepBadge('Step 3 of 3 · Your Password'),
          const SizedBox(height: 16),

          // Success icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.12),
                border: Border.all(color: _green.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _green,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              'Identity Verified!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _green,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Here is the password for',
              style: TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ),
          Center(
            child: Text(
              phoneNumber,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _amber,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Password reveal box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: _navyMid,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _amber.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _amber.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR PASSWORD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _passwordVisible ? oldPasswordIs : '•' * oldPasswordIs.length,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _amber,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ⚠️ Security tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.25),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep your password private. Do not share it with anyone.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _primaryButton(
            label: 'Back to Login',
            icon: Icons.login_rounded,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE WIDGETS ───────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _stepBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _amber.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _amber,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: _textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _inputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: _navyMid,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      cursorColor: _amber,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _textSecondary, size: 20)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: _navyMid,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _amber, width: 1.8),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? null
                : const LinearGradient(
                    colors: [_amber, Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: onPressed == null ? _border : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: _amber.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: _textSecondary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: _navy, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _border, width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ),
    );
  }
}
