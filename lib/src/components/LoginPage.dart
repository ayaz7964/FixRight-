// import 'package:flutter/material.dart';
// import 'package:country_picker/country_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../services/auth_service.dart';
// import '../../services/auth_session_service.dart';
// import '../../services/user_session.dart';
// import '../../services/user_presence_service.dart';
// import 'ForgotPasswordPage.dart';

// // import 'package:firebase_auth/firebase_auth.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool isLoading = false;
//   bool showPassword = false;

//   Country selectedCountry = Country(
//     phoneCode: '92',
//     countryCode: 'PK',
//     e164Sc: 0,
//     geographic: true,
//     level: 1,
//     name: 'Pakistan',
//     example: 'Pakistan',
//     displayName: 'Pakistan',
//     displayNameNoCountryCode: 'Pakistan',
//     e164Key: '',
//   );

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _loginWithPassword() async {
//     if (_phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Enter a phone number')));
//       return;
//     }

//     if (_passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Enter your password')));
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final phoneNumber =
//           '+${selectedCountry.phoneCode}${_phoneController.text.trim()}';
//       final password = _passwordController.text.trim();

//       // Step 1: Sign in to Firebase Auth first
//       // This establishes the authentication session needed for Firestore access
//       final sessionService = AuthSessionService();
//       await sessionService.signInWithPhonePassword(
//         phoneNumber: phoneNumber,
//         password: password,
//       );
//       print('✅ Firebase Auth session established');

//       // Step 2: Fetch user profile from Firestore (now authenticated)
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(phoneNumber)
//           .get();

//       if (!userDoc.exists) {
//         throw Exception('User profile not found. Please contact support.');
//       }

//       final userData = userDoc.data() as Map<String, dynamic>;
//       final userModel = UserModel.fromFirestore(userData);
//       final uid = phoneNumber; // Phone is the UID

//       // Step 3: Update last login
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(phoneNumber)
//           .update({'lastLogin': FieldValue.serverTimestamp()});

//       // Step 4: Set user session
//       UserSession().setUserSession(
//         phone: phoneNumber,
//         uid: uid,
//         userData: userModel,
//       );

//       // Step 5: Initialize presence
//       final presenceService = UserPresenceService();
//       await presenceService.initializePresence();

//       // Step 6: Navigate to home
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         setState(() => isLoading = false);
//         String message = 'Login failed';
//         if (e.code == 'user-not-found') {
//           message = 'User not found. Please register first.';
//         } else if (e.code == 'wrong-password') {
//           message = 'Invalid password. Please try again.';
//         } else if (e.code == 'invalid-email') {
//           message = 'Invalid phone number format.';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ $message'),
//             duration: const Duration(seconds: 4),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌   ${e.toString().replaceAll('Exception: ', '')} '), // ${e.toString().replaceAll('Exception: ', '')}
//             duration: const Duration(seconds: 4),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _navigateToForgotPassword() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
//     );

//     // If password was reset successfully
//     if (result == true && mounted) {
//       _passwordController.clear();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('✅ Password reset successful. Please login.'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Column(
//               children: [
//                 // Logo
//                 Image.network(
//                   'https://thumbs.dreamstime.com/b/house-cleaning-service-logo-illustration-art-isolated-background-130445019.jpg',
//                   height: 90,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 90,
//                     height: 90,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.business, size: 50),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Welcome to FixRight ',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.blueAccent.shade400,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Login to your account',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 32),

//                 // Login Card
//                 Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Country Picker
//                         Text(
//                           'Country',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () {
//                             showCountryPicker(
//                               context: context,
//                               onSelect: (Country country) {
//                                 setState(() => selectedCountry = country);
//                               },
//                             );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 14,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey.shade300),
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.white,
//                             ),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   '${selectedCountry.flagEmoji}  ${selectedCountry.name}',
//                                   style: const TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 const Icon(
//                                   Icons.arrow_drop_down,
//                                   color: Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Phone Number Field
//                         Text(
//                           'Phone Number',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _phoneController,
//                           keyboardType: TextInputType.phone,
//                           decoration: InputDecoration(
//                             hintText: '3001234567',
//                             prefixIcon: const Icon(Icons.phone),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.blue,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Password Field with Eye Icon
//                         Text(
//                           'Password',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: !showPassword,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your password',
//                             prefixIcon: const Icon(Icons.lock),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 showPassword
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: Colors.grey,
//                               ),
//                               onPressed: () {
//                                 setState(() => showPassword = !showPassword);
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.blue,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         // Forgot Password Button
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: _navigateToForgotPassword,
//                             child: const Text(
//                               'Forgot Password?',
//                               style: TextStyle(
//                                 color: Colors.blueAccent,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: isLoading ? null : _loginWithPassword,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blueAccent,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 4,
//                             ),
//                             child: isLoading
//                                 ? const SizedBox(
//                                     height: 24,
//                                     width: 24,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 3,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Login',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Signup Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account?   ",
//                       style: TextStyle(color: Colors.grey.shade700),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacementNamed(context, '/signup');
//                       },
//                       child: const Text(
//                         'Register here',
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session_service.dart';
import '../../services/user_session.dart';
import '../../services/user_presence_service.dart';
import 'ForgotPasswordPage.dart';

// ─────────────────────────────────────────────────────────────
//  SharedPreferences Keys
// ─────────────────────────────────────────────────────────────
class _PrefKeys {
  static const String isLoggedIn    = 'is_logged_in';
  static const String savedPhone    = 'saved_phone';      // e.g. "3001234567"
  static const String savedPassword = 'saved_password';
  static const String savedPhoneCode= 'saved_phone_code'; // e.g. "92"
  static const String rememberMe    = 'remember_me';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading      = true;  // starts true → shows splash while checking session
  bool showPassword   = false;
  bool rememberMe     = false;
  bool _autoChecking  = true;  // true while we silently check saved session

  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>?   _fadeAnimation;
  Animation<Offset>?   _slideAnimation;

  // ── Brand Palette ──────────────────────────────────────────
  // static const Color _navy          = Color(0xFF0B1A2E);
  // static const Color _navyMid       = Color(0xFF112240);
  // static const Color _amber         = Color(0xFFF59E0B);
  // static const Color _amberLight    = Color(0xFFFCD34D);
  // static const Color _surface       = Color(0xFF172A45);
  // static const Color _border        = Color(0xFF1E3A5F);
  // static const Color _textPrimary   = Color(0xFFE2E8F0);
  // static const Color _textSecondary = Color(0xFF8DA4BE);

  static const Color _navy          = Color(0xFF042B1E);   // very dark green (was dark navy blue)
static const Color _navyMid       = Color(0xFF073D2A);   // dark green mid (was navy mid blue)
static const Color _amber         = Color(0xFF38BDF8);   // sky blue accent (was amber orange)
static const Color _amberLight    = Color(0xFF7DD3FC);   // light sky blue (was amber yellow)
static const Color _surface       = Color(0xFF0C3D26);   // dark green surface (was dark blue surface)
static const Color _border        = Color(0xFF155C38);   // green border (was blue border)
static const Color _textPrimary   = Color(0xFFE2F4EC);   // off-white green tint (was blue-white)
static const Color _textSecondary = Color(0xFF7AB89A);   // muted green-grey (was muted blue-grey)
static const Color _green         = Color(0xFF10B981);   // unchanged — already perfect

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

  // ── Init ───────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOut));

    // Check auto-login first, then load saved credentials
    _checkAutoLogin();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _fadeController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  // ── AUTO-LOGIN CHECK ───────────────────────────────────────
  // Called once on app open. If user was previously logged in
  // AND Firebase still has a valid auth session → go straight home.

  Future<void> _checkAutoLogin() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final wasLoggedIn  = prefs.getBool(_PrefKeys.isLoggedIn)  ?? false;
      final savedPhone   = prefs.getString(_PrefKeys.savedPhone)    ?? '';
      final savedPass    = prefs.getString(_PrefKeys.savedPassword)  ?? '';
      final savedCode    = prefs.getString(_PrefKeys.savedPhoneCode) ?? '92';
      final remember     = prefs.getBool(_PrefKeys.rememberMe) ?? false;

      // ── Case 1: Was logged in + Firebase session still alive → auto-login
      if (wasLoggedIn && FirebaseAuth.instance.currentUser != null) {
        final fullPhone = '+$savedCode$savedPhone';

        // Restore Firestore user data into session
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fullPhone)
            .get();

        if (userDoc.exists) {
          final userData  = userDoc.data() as Map<String, dynamic>;
          final userModel = UserModel.fromFirestore(userData);

          UserSession().setUserSession(
            phone: fullPhone,
            uid: fullPhone,
            userData: userModel,
          );

          await UserPresenceService().initializePresence();

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
            return; // ← exit early, never show login UI
          }
        }
      }

      // ── Case 2: No active session → load saved fields if rememberMe was on
      if (remember && savedPhone.isNotEmpty) {
        _phoneController.text    = savedPhone;
        _passwordController.text = savedPass;

        // Restore country code
        try {
          // Try to match by phone code — falls back to PK if not found
          selectedCountry = Country(
            phoneCode: savedCode,
            countryCode: savedCode == '92' ? 'PK' : '',
            e164Sc: 0,
            geographic: true,
            level: 1,
            name: savedCode == '92' ? 'Pakistan' : '+$savedCode',
            example: '',
            displayName: savedCode == '92' ? 'Pakistan' : '+$savedCode',
            displayNameNoCountryCode: savedCode == '92' ? 'Pakistan' : '+$savedCode',
            e164Key: '',
          );
        } catch (_) {}
      }

      setState(() {
        rememberMe    = remember;
        _autoChecking = false;
        isLoading     = false;
      });

      // Play entrance animation only after auto-check is done
      _fadeController?.forward();
      _slideController?.forward();
    } catch (_) {
      // If anything goes wrong just show the login form normally
      setState(() {
        _autoChecking = false;
        isLoading     = false;
      });
      _fadeController?.forward();
      _slideController?.forward();
    }
  }

  // ── SAVE SESSION TO PREFS ──────────────────────────────────

  Future<void> _saveSession({
    required String phone,
    required String password,
    required String phoneCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKeys.isLoggedIn, true);
    await prefs.setBool(_PrefKeys.rememberMe, rememberMe);

    if (rememberMe) {
      await prefs.setString(_PrefKeys.savedPhone,     phone);
      await prefs.setString(_PrefKeys.savedPassword,  password);
      await prefs.setString(_PrefKeys.savedPhoneCode, phoneCode);
    } else {
      // Don't store credentials if rememberMe is off — but still mark logged in
      await prefs.remove(_PrefKeys.savedPhone);
      await prefs.remove(_PrefKeys.savedPassword);
      await prefs.setString(_PrefKeys.savedPhoneCode, phoneCode);
    }
  }

  // ── CLEAR SESSION (call this from your logout button anywhere in app) ──
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKeys.isLoggedIn, false);
    await prefs.remove(_PrefKeys.savedPhone);
    await prefs.remove(_PrefKeys.savedPassword);
    await FirebaseAuth.instance.signOut();
  }

  // ── LOGIN LOGIC ────────────────────────────────────────────

  Future<void> _loginWithPassword() async {
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('Enter a phone number');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnack('Enter your password');
      return;
    }

    setState(() => isLoading = true);

    try {
      final rawPhone   = _phoneController.text.trim();
      final phoneCode  = selectedCountry.phoneCode;
      final fullPhone  = '+$phoneCode$rawPhone';
      final password   = _passwordController.text.trim();

      // Step 1: Firebase Auth sign-in
      final sessionService = AuthSessionService();
      await sessionService.signInWithPhonePassword(
        phoneNumber: fullPhone,
        password: password,
      );

      // Step 2: Fetch Firestore user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fullPhone)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found. Please contact support.');
      }

      final userData  = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromFirestore(userData);

      // Step 3: Update last login
      await FirebaseFirestore.instance
          .collection('users')
          .doc(fullPhone)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      // Step 4: Set session in memory
      UserSession().setUserSession(
        phone: fullPhone,
        uid: fullPhone,
        userData: userModel,
      );

      // Step 5: Save session/credentials to SharedPreferences
      await _saveSession(
        phone: rawPhone,
        password: password,
        phoneCode: phoneCode,
      );

      // Step 6: Initialize presence
      await UserPresenceService().initializePresence();

      // Step 7: Navigate home
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        String message = 'Login failed';
        if (e.code == 'user-not-found')  message = 'User not found. Please register first.';
        if (e.code == 'wrong-password')  message = 'Invalid password. Please try again.';
        if (e.code == 'invalid-email')   message = 'Invalid phone number format.';
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Invalid phone number or password. Please try again.')),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _navigateToForgotPassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
    if (result == true && mounted) {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Password reset successful. Please login.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // While silently checking auto-login → show splash/loader
    if (_autoChecking) return _buildSplash();

    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 36),
          _buildLoginCard(),
          const SizedBox(height: 28),
          _buildSignupRow(),
          const SizedBox(height: 24),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _amber.withOpacity(0.18),
                  _amber.withOpacity(0.0),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF1E40AF).withOpacity(0.22),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: _fadeAnimation != null && _slideAnimation != null
                ? FadeTransition(
                    opacity: _fadeAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: content,
                    ),
                  )
                : content,
          ),
        ],
      ),
    );
  }

  // ── SPLASH (auto-login check screen) ──────────────────────

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: _navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_amber, _amberLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _amber.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_repair_service,
                color: _navy,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: 'Fix',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Right',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _amber,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: _amber.withOpacity(0.7),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_amber, _amberLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _amber.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://thumbs.dreamstime.com/b/house-cleaning-service-logo-illustration-art-isolated-background-130445019.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.home_repair_service,
                color: _navy,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(children: [
            TextSpan(
              text: 'Fix',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: 'Right',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: _amber,
                letterSpacing: -0.5,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to your account',
          style: TextStyle(fontSize: 13, color: _textSecondary, letterSpacing: 0.3),
        ),
      ],
    );
  }

  // ── LOGIN CARD ─────────────────────────────────────────────

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Country Picker
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

          const SizedBox(height: 20),

          // Phone Number
          _label('Phone Number'),
          const SizedBox(height: 8),
          _styledTextField(
            controller: _phoneController,
            hint: '3001234567',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),

          const SizedBox(height: 20),

          // Password
          _label('Password'),
          const SizedBox(height: 8),
          _styledTextField(
            controller: _passwordController,
            hint: 'Enter your password',
            obscureText: !showPassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
          ),

          const SizedBox(height: 14),

          // ── Remember Me + Forgot Password row ──
          Row(
            children: [
              // Remember Me toggle
              GestureDetector(
                onTap: () => setState(() => rememberMe = !rememberMe),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: rememberMe ? _amber : Colors.transparent,
                        border: Border.all(
                          color: rememberMe ? _amber : _border,
                          width: 1.5,
                        ),
                      ),
                      child: rememberMe
                          ? const Icon(Icons.check_rounded,
                              color: _navy, size: 13)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Forgot Password
              TextButton(
                onPressed: _navigateToForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: _amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _loginWithPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                          end: Alignment.bottomRight,
                        ),
                  color: isLoading ? _border : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: _amber.withOpacity(0.40),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
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
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                            letterSpacing: 0.4,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SIGN UP ROW ────────────────────────────────────────────

  Widget _buildSignupRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: _textSecondary, fontSize: 13),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/signup'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
          child: const Text(
            'Register here',
            style: TextStyle(
              color: _amber,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ── HELPERS ────────────────────────────────────────────────

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
}