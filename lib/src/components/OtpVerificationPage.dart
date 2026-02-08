import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../services/user_presence_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String address;
  final String pin;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.address,
    required this.pin,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isVerifying = false;
  int resendTimer = 60;
  bool canResend = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Start countdown timer for resend
  void _startResendTimer() {
    setState(() {
      canResend = false;
      resendTimer = 60;
    });

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

  /// Verify OTP and create user
  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isVerifying = true);

    try {
      // Step 1: Verify OTP with Firebase
      final user = await _authService.verifyOtp(
        widget.verificationId,
        _otpController.text.trim(),
      );

      if (user == null) {
        throw Exception('Failed to authenticate user');
      }

      // Step 2: Create user profile in Firestore (uid will be set to phone number)
      await _authService.createUserProfile(
        phoneNumber: widget.phoneNumber,
        firstName: widget.firstName,
        lastName: widget.lastName,
        city: widget.city,
        country: widget.country,
        address: widget.address,
      );

      // Step 3: Save PIN to auth collection (uid will be set to phone number)
      await _authService.savePin(
        phoneNumber: widget.phoneNumber,
        pin: widget.pin,
      );

      if (!mounted) return;

      // Step 4: Set user session
      final UserModel userData = UserModel(
        uid: widget.phoneNumber,
        phone: widget.phoneNumber,
        firstName: widget.firstName,
        lastName: widget.lastName,
        city: widget.city,
        country: widget.country,
        address: widget.address,
        role: 'buyer',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      UserSession().setUserSession(
        phone: widget.phoneNumber,
        uid: widget.phoneNumber,
        userData: userData,
      );

      // Step 5: Initialize presence
      try {
        final presenceService = UserPresenceService();
        await presenceService.initializePresence();
      } catch (e) {
        print('Error initializing presence: $e');
      }

      // Step 6: Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
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

  /// Resend OTP
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

  /// Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Verify Phone'),
        elevation: 0,
        backgroundColor: Colors.blue.shade50,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sms, size: 48, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify Your Number',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      const TextSpan(text: 'We sent a verification code to\n'),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input (Pinput)
                Pinput(
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 55,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 55,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                      color: Colors.white,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 55,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.white,
                    ),
                  ),
                  onCompleted: (pin) {
                    // Auto-verify when 6 digits are entered
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted && !isVerifying) {
                        _verifyOtp();
                      }
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isVerifying
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend Code
                Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (!canResend)
                      Text(
                        'Resend in ${resendTimer}s',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _resendOtp,
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
