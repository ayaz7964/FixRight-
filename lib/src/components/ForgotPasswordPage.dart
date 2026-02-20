import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session_service.dart';
import 'package:pinput/pinput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
  String verificationId = '';
  String phoneNumber = '';
  String oldPasswordIs = '';

  @override
  void initState() {
    super.initState();
    selectedCountry = Country.parse('PK');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchOldPassword() async {
    try {
      final authDoc = await _firestore
          .collection('auth')
          .doc(phoneNumber)
          .get();

      if (!authDoc.exists) {
        throw Exception('User not found.');
      }

      final authData = authDoc.data() as Map<String, dynamic>;
      final password = authData['password'] ?? 'Password not set';

      print('Password for $phoneNumber: $password');
    } catch (e) {
      print('Error fetching password: $e');
      rethrow;
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Phone number must be at least 10 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    phoneNumber = '+${selectedCountry.phoneCode}$phone';

    try {
      await _authService.sendOtp(
        phoneNumber,
        codeSent: (verificationId_) {
          setState(() {
            verificationId = verificationId_;
            otpSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ OTP sent to your phone'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        },
        verificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error sending OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please enter the OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ OTP must be 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.verifyOtp(verificationId, otp);

      if (user != null) {
        setState(() => otpVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Phone verified successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Invalid OTP. Please try again'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error verifying OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    // final newPass = _newPasswordController.text.trim();
    // final confirmPass = _confirmPasswordController.text.trim();

    // // Validate fields not empty
    // if (newPass.isEmpty || confirmPass.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('❌ Please enter password in both fields'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // // Validate password length
    // if (newPass.length < 6) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('❌ Password must be at least 6 characters'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // // Validate passwords match
    // if (newPass != confirmPass) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('❌ Passwords do not match'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // setState(() => isLoading = true);

    // try {
    //   // Validate phone number is set
    //   if (phoneNumber.isEmpty) {
    //     throw Exception('Phone number not found. Please start over.');
    //   }

    //   // Call resetPassword to update in Firestore auth collection
    //   await _authService.resetPassword(
    //     phone: phoneNumber,
    //     newPassword: newPass,
    //   );

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('✅ Password reset successfully!'),
    //         backgroundColor: Colors.green,
    //         duration: Duration(seconds: 2),
    //       ),
    //     );

    //     // Return to login with success flag
    //     Navigator.pop(context, true);
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           '❌ Error: ${e.toString().replaceAll('Exception: ', '')}',
    //         ),
    //         backgroundColor: const Color.fromARGB(255, 237, 25, 25),
    //         duration: const Duration(seconds: 4),
    //       ),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() => isLoading = false);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll help you reset it',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Step 1: Enter Phone Number
                if (!otpSent)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Step 1 of 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter your phone number',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Country Picker
                          Text(
                            'Country',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                onSelect: (Country country) {
                                  setState(() => selectedCountry = country);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${selectedCountry.flagEmoji}  ${selectedCountry.name}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number Field
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '3001234567',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Send OTP Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Step 2: Verify OTP
                if (otpSent && !otpVerified)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Step 2 of 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 6-digit code sent to your phone',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // OTP Input Field
                          Pinput(
                            length: 6,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            defaultPinTheme: PinTheme(
                              width: 50,
                              height: 50,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 50,
                              height: 50,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Verify OTP Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Back Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  otpSent = false;
                                  _otpController.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'Change Phone Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Step 3: Reset Password
                if (otpVerified)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Step 3 of 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),

                          Text("Password is"),
                        ],
                      ),
                      //   children: [
                      //     // Step Indicator
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 12,
                      //         vertical: 6,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: Colors.blueAccent.shade100,
                      //         borderRadius: BorderRadius.circular(20),
                      //       ),
                      //       child: const Text(
                      //         'Step 3 of 3',
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w600,
                      //           color: Colors.blueAccent,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(height: 16),
                      //     Text(
                      //       'Set New Password',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 16,
                      //         color: Colors.grey.shade900,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 16),

                      //     // New Password Field
                      //     Text(
                      //       'New Password',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 12,
                      //         color: Colors.grey.shade700,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 8),
                      //     TextField(
                      //       controller: _newPasswordController,
                      //       obscureText: !showNewPassword,
                      //       decoration: InputDecoration(
                      //         hintText: 'Enter new password',
                      //         prefixIcon: const Icon(Icons.lock),
                      //         suffixIcon: IconButton(
                      //           icon: Icon(
                      //             showNewPassword
                      //                 ? Icons.visibility
                      //                 : Icons.visibility_off,
                      //             color: Colors.grey,
                      //           ),
                      //           onPressed: () {
                      //             setState(
                      //               () => showNewPassword = !showNewPassword,
                      //             );
                      //           },
                      //         ),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         enabledBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide: BorderSide(
                      //             color: Colors.grey.shade300,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide: const BorderSide(
                      //             color: Colors.blue,
                      //             width: 2,
                      //           ),
                      //         ),
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         helperText: 'Minimum 6 characters',
                      //       ),
                      //     ),
                      //     const SizedBox(height: 16),

                      //     // Confirm Password Field
                      //     Text(
                      //       'Confirm Password',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 12,
                      //         color: Colors.grey.shade700,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 8),
                      //     TextField(
                      //       controller: _confirmPasswordController,
                      //       obscureText: !showConfirmPassword,
                      //       decoration: InputDecoration(
                      //         hintText: 'Confirm password',
                      //         prefixIcon: const Icon(Icons.lock),
                      //         suffixIcon: IconButton(
                      //           icon: Icon(
                      //             showConfirmPassword
                      //                 ? Icons.visibility
                      //                 : Icons.visibility_off,
                      //             color: Colors.grey,
                      //           ),
                      //           onPressed: () {
                      //             setState(
                      //               () => showConfirmPassword =
                      //                   !showConfirmPassword,
                      //             );
                      //           },
                      //         ),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         enabledBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide: BorderSide(
                      //             color: Colors.grey.shade300,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide: const BorderSide(
                      //             color: Colors.blue,
                      //             width: 2,
                      //           ),
                      //         ),
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 24),

                      //     // Reset Password Button
                      //     SizedBox(
                      //       width: double.infinity,
                      //       child: ElevatedButton(
                      //         onPressed: isLoading ? null : _resetPassword,
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.green.shade600,
                      //           foregroundColor: Colors.white,
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 16,
                      //           ),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           elevation: 4,
                      //         ),
                      //         child: isLoading
                      //             ? const SizedBox(
                      //                 height: 24,
                      //                 width: 24,
                      //                 child: CircularProgressIndicator(
                      //                   color: Colors.white,
                      //                   strokeWidth: 3,
                      //                 ),
                      //               )
                      //             : const Text(
                      //                 'Reset Password',
                      //                 style: TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w700,
                      //                 ),
                      //               ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
