import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'user_presence_service.dart';

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

  /// Step 3: Save PIN to auth collection (after OTP verification)
  Future<void> savePin({
    required String phoneNumber,
    required String pin,
    required String uid,
  }) async {
    try {
      // Validate PIN format
      if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
        throw Exception('PIN must be exactly 6 digits');
      }

      // Check if auth record already exists
      final authDoc = await _firestore
          .collection('auth')
          .doc(phoneNumber)
          .get();

      if (authDoc.exists) {
        throw Exception('User already registered. Please login instead.');
      }

      // Store PIN in auth collection
      await _firestore.collection('auth').doc(phoneNumber).set({
        'phone': phoneNumber,
        'pin': pin,
        'uid': uid,
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('PIN saved successfully for: $phoneNumber');
    } catch (e) {
      print('Error saving PIN: $e');
      rethrow;
    }
  }

  /// Step 4: Create user profile after successful OTP verification
  Future<void> createUserProfile({
    required String phoneNumber,
    required String uid,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).set({
        'uid': uid,
        'phone': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'country': country,
        'address': address,
        'role': 'buyer', // Default role
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('User profile created for: $phoneNumber');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN FLOW METHODS (PIN-BASED, NO OTP)
  // ═══════════════════════════════════════════════════════════════

  /// Validate PIN during login (NO OTP required)
  Future<Map<String, dynamic>> validateLoginWithPin({
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      // Validate PIN format
      if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
        throw Exception('PIN must be exactly 6 digits');
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

      // Verify PIN
      if (authData['pin'] != pin) {
        throw Exception('Invalid PIN. Please try again.');
      }

      if (authData['isVerified'] != true) {
        throw Exception('User account is not verified.');
      }

      final uid = authData['uid'] as String;

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

  /// Sign out the user
  Future<void> signOut() async {
    try {
      final presenceService = UserPresenceService();
      await presenceService.setOfflineBeforeLogout();
    } catch (e) {
      print('Error updating presence on logout: $e');
    }

    try {
      await _auth.signOut();
      print('User signed out successfully');
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
