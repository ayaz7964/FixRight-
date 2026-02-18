import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'user_presence_service.dart';
import 'auth_session_service.dart';

typedef CodeSentCallback = void Function(String verificationId);
typedef VerificationFailedCallback = void Function(FirebaseAuthException e);

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Retrieves the user's formatted phone number (used as Document ID in Firestore)
  String? getUserPhoneDocId() {
    final user = _auth.currentUser;
    if (user?.phoneNumber != null) {
      return user!.phoneNumber;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // REGISTRATION FLOW METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Step 1: Send OTP to phone number during registration
  Future<void> sendOtp(
    String phone, {
    required CodeSentCallback codeSent,
    required VerificationFailedCallback verificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          // Auto-verification happens rarely
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          print('OTP Verification Failed: ${e.code} - ${e.message}');
          verificationFailed(e);
        },
        codeSent: (verificationId, resendToken) {
          print('OTP Sent Successfully');
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print('OTP Auto-Retrieval Timeout');
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  /// Step 2: Verify OTP code during registration
  Future<User?> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to authenticate user');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('OTP Verification Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Step 3: Save password to auth collection (after OTP verification)
  Future<void> savePassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Validate password (minimum 6 characters)
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if auth record already exists
      final authDoc = await _firestore
          .collection('auth')
          .doc(phoneNumber)
          .get();

      if (authDoc.exists) {
        throw Exception('User already registered. Please login instead.');
      }

      // Store password in auth collection. Use phone number as uid.
      await _firestore.collection('auth').doc(phoneNumber).set({
        'phone': phoneNumber,
        'password': password,
        'uid': phoneNumber, // uid intentionally set to phone
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Password saved successfully for: $phoneNumber');
    } catch (e) {
      print('Error saving password: $e');
      rethrow;
    }
  }

  /// Step 4: Create user profile after successful OTP verification
  Future<void> createUserProfile({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String address,
    String role = 'buyer',
    double? latitude,
    double? longitude,
    Map<String, dynamic>? liveLocation,
    String? profileImage,
    String? profileUrl,
    Timestamp? updatedAt,
  }) async {
    try {
      // Build base payload
      final Map<String, dynamic> payload = {
        'uid': phoneNumber,
        'phone': phoneNumber,
        'mobile': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'country': country,
        'address': address,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      // Optional fields - only set when provided (preserve existing data on merge)
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (liveLocation != null) payload['liveLocation'] = liveLocation;
      if (profileImage != null) payload['profileImage'] = profileImage;
      if (profileUrl != null) payload['profileUrl'] = profileUrl;
      if (updatedAt != null) payload['updatedAt'] = updatedAt;

      // Also add placeholders so other code that expects the keys won't break
      payload.putIfAbsent('latitude', () => latitude);
      payload.putIfAbsent('longitude', () => longitude);
      payload.putIfAbsent('liveLocation', () => liveLocation ?? {});
      payload.putIfAbsent('profileImage', () => profileImage ?? '');
      payload.putIfAbsent('profileUrl', () => profileUrl ?? '');

      await _firestore
          .collection('users')
          .doc(phoneNumber)
          .set(payload, SetOptions(merge: true));

      print('User profile created/updated for: $phoneNumber');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN FLOW METHODS (PASSWORD-BASED, NO OTP)
  // ═══════════════════════════════════════════════════════════════

  /// Validate password during login (NO OTP required)
  Future<Map<String, dynamic>> validateLoginWithPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Validate password
      if (password.isEmpty || password.length < 6) {
        throw Exception('Invalid password format');
      }

      // Fetch auth credentials from Firestore
      final authDoc = await _firestore
          .collection('auth')
          .doc(phoneNumber)
          .get();

      if (!authDoc.exists) {
        throw Exception('User not found. Please register first.');
      }

      final authData = authDoc.data() as Map<String, dynamic>;

      // Verify password
      if (authData['password'] != password) {
        throw Exception('Invalid password. Please try again.');
      }

      if (authData['isVerified'] != true) {
        throw Exception('User account is not verified.');
      }

      // Use phoneNumber as uid (ensure consistency)
      final uid = phoneNumber;

      // Fetch user profile
      final userDoc = await _firestore
          .collection('users')
          .doc(phoneNumber)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Update last login
      await _firestore.collection('users').doc(phoneNumber).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'uid': uid,
        'phone': phoneNumber,
        'userData': userData,
      };
    } on FirebaseException catch (e) {
      print('Firebase Error during login: ${e.code} - ${e.message}');
      throw Exception('Database error. Please try again.');
    } catch (e) {
      print('Error validating PIN: $e');
      rethrow;
    }
  }

  /// Check if user already exists (to prevent duplicate registration)
  Future<bool> userExists(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('auth').doc(phoneNumber).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  /// Get user profile by phone number
  Future<DocumentSnapshot?> getUserProfile(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // FORGOT PASSWORD FLOW
  // ═══════════════════════════════════════════════════════════════

  /// Reset password after OTP verification
  /// Only updates Firestore auth document - simple and clean
  /// Firebase Auth will be updated automatically when user logs in
  




  // Future<void> resetPassword({
  //   required String phoneNumber,
  //   required String newPassword,
  // }) async {
  //   try {
  //     // Validate password
  //     if (newPassword.isEmpty || newPassword.length < 6) {
  //       throw Exception('Password must be at least 6 characters');
  //     }

  //     // Check if user exists
  //     final authDoc = await _firestore
  //         .collection('auth')
  //         .doc(phoneNumber)
  //         .get();

  //     if (!authDoc.exists) {
  //       throw Exception('User not found.');
  //     }

  //     // Update password in Firestore auth collection
  //     await _firestore.collection('auth').doc(phoneNumber).update({
  //       'password': newPassword,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });

  //     print('Password reset successfully for: $phoneNumber');
  //   } catch (e) {
  //     print('Error resetting password: $e');
  //     rethrow;
  //   }
  // }


   

//kay 
// throw errorr and handling them 

// problem is found and moving toward the solution of 
// reseeting the forward code 
Future<void> resetPassword({
  required String phone,
  required String newPassword,
}) async {

  final email = "$phone@yourapp.com";

  try {

    // Step 1: Sign in using a temporary custom token method
    // We can't sign in without password,
    // so we use signInWithEmailLink style trick.

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: "temporaryOldPassword",
    );

    await FirebaseAuth.instance.currentUser!
        .updatePassword(newPassword);

    await FirebaseAuth.instance.signOut();

  } catch (e) {
    print(e);
  }
}



// Future<void> resetPassword({
//   required String phoneNumber,
//   required String newPassword,
//   required String verificationId,
//   required String smsCode,
// }) async {
//   if (newPassword.length < 6) {
//     throw FirebaseAuthException(
//       code: 'weak-password',
//       message: 'Password must be at least 6 characters.',
//     );
//   }

//   final String email = phoneToEmail(phoneNumber);

//   try {
//     // 1️⃣ Create phone credential from OTP
//     final PhoneAuthCredential credential =
//         PhoneAuthProvider.credential(
//       verificationId: verificationId,
//       smsCode: smsCode,
//     );

//     // 2️⃣ Sign in with phone credential (IMPORTANT)
//     final UserCredential userCredential =
//         await _auth.signInWithCredential(credential);

//     final User? user = userCredential.user;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'not-authenticated',
//         message: 'OTP verification failed.',
//       );
//     }

//     // 3️⃣ Update password in FirebaseAuth (REAL PASSWORD UPDATE)
//     await user.updatePassword(newPassword);

//     // 4️⃣ Sign out to refresh token
//     await _auth.signOut();

//     // 5️⃣ Sign in with phone->email alias and NEW password
//     await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: newPassword,
//     );

//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'invalid-verification-code') {
//       throw FirebaseAuthException(
//         code: e.code,
//         message: 'Invalid OTP code.',
//       );
//     } else if (e.code == 'session-expired') {
//       throw FirebaseAuthException(
//         code: e.code,
//         message: 'OTP session expired. Please try again.',
//       );
//     } else if (e.code == 'weak-password') {
//       throw FirebaseAuthException(
//         code: e.code,
//         message: 'Password is too weak.',
//       );
//     } else if (e.code == 'requires-recent-login') {
//       throw FirebaseAuthException(
//         code: e.code,
//         message: 'Please verify OTP again.',
//       );
//     }
//     rethrow;
//   }
// }




  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Initialize seller profile with default financial fields
  Future<void> initializeSellerProfile(String phoneNumber) async {
    try {
      await _firestore.collection('sellers').doc(phoneNumber).set({
        'phone': phoneNumber,
        'availableBalance': 0.0,
        'jobsCompleted': 0,
        'earning': 0.0,
        'totalJobs': 0,
        'pendingJobs': 0,
        'deposit': 0.0,
        'withdrawal': 0.0,
        'rating': 0.0,
        'status': 'none', // 'none' | 'submitted' | 'approved'
        'comments': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Seller profile initialized for: $phoneNumber');
    } catch (e) {
      print('Error initializing seller profile: $e');
      rethrow;
    }
  }

  /// Sign out the user from both Firestore and Firebase Auth sessions
  Future<void> signOut() async {
    try {
      // Step 1: Update user presence to offline
      final presenceService = UserPresenceService();
      await presenceService.setOfflineBeforeLogout();
    } catch (e) {
      print('Error updating presence on logout: $e');
    }

    try {
      // Step 2: Sign out from Firebase Auth (session management)
      final sessionService = AuthSessionService();
      await sessionService.signOut();

      // Step 3: Sign out from Firebase Auth instance
      await _auth.signOut();
      print('User signed out successfully from all sessions');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        return result;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
      }

      return permission;
    } catch (e) {
      print('Error requesting location permission: $e');
      rethrow;
    }
  }
}
