// import 'package:flutter/material.dart';
// // Temporary LoginPage (you can replace this later with a real one)
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushReplacementNamed(context, '/home');
//           },
//           child: const Text('Login and go to Home'),
//         ),
//       ),
//     );

//   return Scaffold(
//     backgroundColor: Colors.blue,
//     body: Center(
//       child: Container(
//         margin: EdgeInsets.all(25),

//         height: 500,

//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Center(
//           child: Column(children:
//            [
//           Image( width: 200,  image: NetworkImage("data:image/jpeg;base64,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"))

//           ,SizedBox(height: 20,),
//           Text('Welcome to FixRight', style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold, ),),
//           Text('Login to Continue', style: TextStyle(fontSize: 16 , color: const Color.fromARGB(255, 52, 71, 69), ),),

//           Expanded
//           (

//         child: Center(
//           child: IntlPhoneField(
//             // Padding for the flag button
//             flagsButtonPadding: const EdgeInsets.all(8),
//             // Position of the dropdown icon
//             dropdownIconPosition: IconPosition.trailing,
//             decoration: const InputDecoration(
//               // Label for the input field
//               labelText: 'Phone Number',
//               // Border style for the input field
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(),
//               ),
//             ),
//             // Default country code (India)
//             initialCountryCode: 'IN',
//             // Displays the cursor in the input field
//             showCursor: true,
//             // Shows the dropdown icon for country selection
//             showDropdownIcon: true,
//             onChanged: (phone) {
//               // Callback when the phone number changes
//               // Prints the complete phone number
//               print(phone.completeNumber);
//             },
//           ),))
//            ]

//           ),
//         ),
//       ),
//     ),
//   );
// }
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// // import '../services/auth_service.dart';
// import '../../services/auth_service.dart';
// import '../components/SIgnupPage.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   String phoneComplete = '';
//   bool sending = false;

//   @override
//   Widget build(BuildContext context) {
//     final blue = const Color(0xFF2B7CD3);
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(color: blue), // blue background
//           Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 width: 360,
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 8),
//                     const Text(
//                       'fixRight',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Welcome',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     IntlPhoneField(
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                       ),
//                       initialCountryCode: 'PK',
//                       onChanged: (phone) {
//                         phoneComplete = phone.completeNumber;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: sending || phoneComplete.isEmpty
//                             ? null
//                             : () async {
//                                 setState(() => sending = true);
//                                 try {
//                                   await AuthService().verifyPhone(
//                                     phoneComplete,
//                                     codeSent: (verificationId) async {
//                                       // navigate to OTP entry dialog/sheet
//                                       final otp = await showDialog<String>(
//                                         context: context,
//                                         builder: (_) => OTPDialog(
//                                           verificationId: verificationId,
//                                         ),
//                                       );
//                                       if (otp != null) {
//                                         final user = await AuthService()
//                                             .signInWithOtp(verificationId, otp);
//                                         if (user != null) {
//                                           // Check if user has profile in Firestore
//                                           final exists = await AuthService()
//                                               .userProfileExists(user.uid);
//                                           if (!exists) {
//                                             // go to signup
//                                             Navigator.of(
//                                               context,
//                                             ).pushReplacementNamed(
//                                               SignupScreen.routeName,
//                                             );
//                                           } else {
//                                             // go to app home (not implemented here)
//                                             ScaffoldMessenger.of(
//                                               context,
//                                             ).showSnackBar(
//                                               const SnackBar(
//                                                 content: Text(
//                                                   'Login successful',
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                         }
//                                       }
//                                     },
//                                     verificationFailed: (e) {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'Verification failed: ${e.message}',
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Error: $e')),
//                                   );
//                                 } finally {
//                                   setState(() => sending = false);
//                                 }
//                               },
//                         child: sending
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : const Text('Continue'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     TextButton(
//                       onPressed: () {
//                         /* Show terms */
//                         Navigator.pushReplacementNamed(context, '/signup');
//                       },
//                       child: const Text(
//                         'Register Now',
//                         style: TextStyle(decoration: TextDecoration.underline),
//                       ),
//                     ),TextButton(
//                       onPressed: () {
//                         /* Show terms */
//                         Navigator.pushReplacementNamed(context, '/home');
//                       },
//                       child: const Text(
//                         'Enter Home without Login',
//                         style: TextStyle(decoration: TextDecoration.underline),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         /* Show terms */
//                       },
//                       child: const Text(
//                         'Terms of Service and Privacy Policy',
//                         style: TextStyle(decoration: TextDecoration.underline),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OTPDialog extends StatefulWidget {
//   final String verificationId;
//   const OTPDialog({Key? key, required this.verificationId}) : super(key: key);

//   @override
//   State<OTPDialog> createState() => _OTPDialogState();
// }

// class _OTPDialogState extends State<OTPDialog> {
//   final codeCtl = TextEditingController();
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Enter OTP'),
//       content: TextField(
//         controller: codeCtl,
//         keyboardType: TextInputType.number,
//         decoration: const InputDecoration(hintText: '6-digit code'),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: loading
//               ? null
//               : () {
//                   Navigator.pop(context, codeCtl.text.trim());
//                 },
//           child: loading
//               ? const CircularProgressIndicator()
//               : const Text('Submit'),
//         ),
//       ],
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
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

  Future<void> _verifyPhone() async {
    setState(() => isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: '+${selectedCountry.phoneCode}${_phoneController.text.trim()}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
        setState(() => isLoading = false);
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
  }

  Future<void> _verifyOTP() async {
    setState(() => isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      setState(() => isLoading = false);
    }
  }

  void _navigateToHome() {
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
                // App Logo
                // Image.asset(
                //   'assets/logo.png',
                //   height: 90,
                // ),
                Image.network('https://thumbs.dreamstime.com/b/house-cleaning-service-logo-illustration-art-isolated-background-130445019.jpg', height: 90,),
                const SizedBox(height: 10),

                // Worker Illustration
                // Image.asset(
                //   'assets/worker.png',
                //   height: 180,
                // ),
                
                // Image.network('https://www.totalmobile.com/wp-content/uploads/2023/03/mobile-worker-header.jpg',height: 180,),
                const SizedBox(height: 15),
                Text(
                  'Welcome to Smart Domestic Services',
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
                      borderRadius: BorderRadius.circular(20)),
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
                                    color: Colors.grey.shade700),
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
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade400),
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
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Send OTP',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                              ),
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
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
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
                // Lottie.asset(
                //   'assets/worker_animation.json',
                //   height: 100,
                //   repeat: true,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
