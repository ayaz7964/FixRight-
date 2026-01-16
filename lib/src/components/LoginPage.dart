import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool codeSent = false;
  String verificationId = '';
  bool isLoading = false;

  Country selectedCountry = Country(
    phoneCode: '92',
    countryCode: 'PK',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Pakistan',
    example: 'Pakistan',
    displayName: 'Pakistan',
    displayNameNoCountryCode: 'Pakistan',
    e164Key: '',
  );

  // Future<void> _verifyPhone() async {
  //   setState(() => isLoading = true);
  //   await _auth.verifyPhoneNumber(
  //     phoneNumber:
  //         '+${selectedCountry.phoneCode}${_phoneController.text.trim()}',
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await _auth.signInWithCredential(credential);
  //       _navigateToHome();
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.message ?? 'Error')),
  //       ); // error throen here
  //       setState(() => isLoading = false);
  //     },
  //     codeSent: (String verId, int? resendToken) {
  //       setState(() {
  //         verificationId = verId;
  //         codeSent = true;
  //         isLoading = false;
  //       });
  //     },
  //     codeAutoRetrievalTimeout: (String verId) {
  //       verificationId = verId;
  //     },
  //   );
  // }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter phone number")));
      return;
    }

    setState(() => isLoading = true);

    final phoneNumber =
        '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (rare but possible)
          await _auth.signInWithCredential(credential);
          // await _requestLocationAndNavigate();
        },

        verificationFailed: (FirebaseAuthException e) {
          setState(() => isLoading = false);

          String message = 'Verification failed';

          if (e.code == 'invalid-phone-number') {
            message = 'Invalid phone number';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many attempts. Try later.';
          } else {
            message = e.message ?? message;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },

        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            codeSent = true;
            isLoading = false;
          });
        },

        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  // Future<void> _verifyOTP() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: _otpController.text.trim(),
  //     );
  //     await _auth.signInWithCredential(credential);
  //     await _requestLocationAndNavigate();
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
  //     setState(() => isLoading = false);
  //   }
  // }

  void _test() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test file working fine'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> checkUserAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.phoneNumber == null) {
        throw Exception("User not authenticated");
      }

      final String uid = user.phoneNumber!; // 📱 UID = verified phone number

      // ✅ Store phone UID in UserSession for global access
      UserSession().setPhoneUID(uid);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // ✅ User exists → LOGIN
      if (doc.exists) {
        // 🔴 Start live location tracking for existing user
        _startLiveLocationTracking(uid);
        _navigateToHome(uid);
        return;
      }

      // ❌ User does not exist → SIGNUP
      await createNewUser(uid);
    } catch (e) {
      print('Error in checkUserAndNavigate: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Start live location tracking for a user
  void _startLiveLocationTracking(String uid) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'liveLocation': {
          'lat': position.latitude,
          'lng': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
    });
  }

  Future<void> createNewUser(String uid) async {
    String city = 'Unknown City';
    String country = 'Unknown country';
    double latitude = 0.0;
    double longitude = 0.0;

    try {
      // 📍 Step 1: Ask location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 📍 Step 2: Get location if allowed
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          latitude = position.latitude;
          longitude = position.longitude;

          // Try to get city and country via geocoding
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );

            if (placemarks.isNotEmpty) {
              city = placemarks.first.locality ?? city;
              country = placemarks.first.country ?? country;
            }
          } catch (e) {
            // Geocoding failed (common on web), use defaults
            print('Geocoding error: $e');
          }

          // 🔴 Step 3: Start live location tracking
          _startLiveLocationTracking(uid);
        } catch (e) {
          print('Location error: $e');
          // Location access failed, continue with dummy values
        }
      } else {
        print('Location permission denied');
      }

      // 🧾 Step 4: Create Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'mobile': uid,
        'firstName': 'User',
        'lastName': 'Account',
        'city': city,
        'country': country,
        'Role': 'Buyer',
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🚀 Navigate to Home
      _navigateToHome(uid);
    } catch (e) {
      print('Error creating user: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter 6 digit OTP")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      // Check user and navigate (handles both login and signup)
      if (mounted) {
        await checkUserAndNavigate();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'invalid-verification-code'
                  ? 'Invalid OTP'
                  : 'Verification failed: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Request location permission after successful login and update user profile
  // Future<void> _requestLocationAndNavigate() async {
  //   final phoneDocId = _authService.getUserPhoneDocId();

  //   if (phoneDocId == null) {
  //     _navigateToHome();
  //     return;
  //   }

  //   try {
  //     // Request location permission
  //     final permission = await Geolocator.requestPermission();

  //     if (permission == LocationPermission.whileInUse ||
  //         permission == LocationPermission.always) {
  //       // Update user location in Firestore
  //       await _authService.updateUserLocation(phoneDocId);
  //     } else if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       // Show dialog explaining why location is needed
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text(
  //               'Location access is needed for Live Tracking. You can enable it in settings.',
  //             ),
  //             duration: Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }

  //     _navigateToHome();
  //   } catch (e) {
  //     print('Error requesting location: $e');
  //     _navigateToHome();
  //   }
  // }

  void _navigateToHome(String uid) {
    setState(() => isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Image.network(
                  'https://thumbs.dreamstime.com/b/house-cleaning-service-logo-illustration-art-isolated-background-130445019.jpg',
                  height: 90,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 15),
                Text(
                  'Welcome to FixRight',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (!codeSent)
                          Column(
                            children: [
                              Text(
                                'Select Country',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
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
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${selectedCountry.flagEmoji}  ${selectedCountry.name} (+${selectedCountry.phoneCode})',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: '3001234567',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              ElevatedButton(
                                onPressed: _verifyPhone,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Send OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),

                              // 3. UI: ADDED GOOGLE BUTTON AND DIVIDER HERE
                              // const SizedBox(height: 20),
                              // Row(children: <Widget>[
                              //   Expanded(child: Divider(color: Colors.grey.shade400)),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 10),
                              //     child: Text("OR", style: TextStyle(color: Colors.grey.shade600)),
                              //   ),
                              //   Expanded(child: Divider(color: Colors.grey.shade400)),
                              // ]),
                              const SizedBox(height: 20),
                              // OutlinedButton(
                              //   onPressed: isLoading ? null : _signInWithGoogle,
                              //   style: OutlinedButton.styleFrom(
                              //     padding: const EdgeInsets.symmetric(vertical: 12),
                              //     side: BorderSide(color: Colors.grey.shade300),
                              //     shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(15)),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.network(
                              //         'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                              //         height: 24,
                              //       ),
                              //       const SizedBox(width: 10),
                              //       const Text(
                              //         "Continue with Google",
                              //         style: TextStyle(
                              //             fontSize: 16, color: Colors.black87),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // ----------------------------------------
                            ],
                          ),

                        if (codeSent)
                          Column(
                            children: [
                              TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Enter OTP',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              ElevatedButton(
                                onPressed: _verifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  setState(() => codeSent = false);
                                },
                                child: const Text('Change Number'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text(
                    'New user? Register here',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    'Navigate Home Page    ',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
