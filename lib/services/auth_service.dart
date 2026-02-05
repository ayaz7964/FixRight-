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
      return user!.phoneNumber; // Format: +923001234567
    }
    return null;
  }

  /// Verify phone number and send OTP
  Future<void> verifyPhone(
    String phone, {
    required CodeSentCallback codeSent,
    required VerificationFailedCallback verificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) => verificationFailed(e),
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: (id) {},
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in with OTP and create/retrieve user document using phone number as Document ID
  Future<User?> signInWithOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null && user.phoneNumber != null) {
        // Use the formatted phone number as the Document ID
        final phoneDocId = user.phoneNumber!; // e.g., "+923001234567"

        // Check if user profile exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(phoneDocId)
            .get();

        if (!userDoc.exists) {
          // Create new user profile with default values
          await _createUserProfile(phoneDocId, user);
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user profile document (default role: "buyer")
  Future<void> _createUserProfile(String phoneDocId, User firebaseUser) async {
    await _firestore.collection('users').doc(phoneDocId).set({
      'phoneNumber': phoneDocId,
      'firebaseUid': firebaseUser.uid,
      'firstName': '',
      'ProfileImage': 'uploading Picture',
      'lastName': '',
      'address': '',
      'role': 'buyer', // Default role
      'createdAt': FieldValue.serverTimestamp(),
      'location': null, // GeoPoint will be set later
    }, SetOptions(merge: true));
  }

  /// Initialize seller profile with default financial and status fields
  /// Call this when a user first becomes a seller
  Future<void> initializeSellerProfile(String uid) async {
    try {
      await _firestore.collection('sellers').doc(uid).set({
        'uid': uid,
        'Available_Balance': 0,
        'Jobs_Completed': 0,
        'Earning': 0,
        'Total_Jobs': 0,
        'Pending_Jobs': 0,
        'Deposit': 0,
        'withdrawal': 0,
        'Rating': 0,
        'status': 'none', // 'none', 'submitted', 'approved'
        'comments': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error initializing seller profile: $e');
      rethrow;
    }
  }

  /// Check if user profile exists using phone number as Document ID
  Future<bool> userProfileExists(String phoneDocId) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneDocId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }

  /// Get user profile by phone number (Document ID)
  Future<DocumentSnapshot?> getUserProfile(String phoneDocId) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneDocId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Request location permission with dialog
  Future<LocationPermission> requestLocationPermission({
    required Function() onDenied,
  }) async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result;
    }

    if (permission == LocationPermission.deniedForever) {
      onDenied();
    }

    return permission;
  }

  /// Update user location with GeoPoint and human-readable address
  Future<void> updateUserLocation(String phoneDocId) async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied ||
            result == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to human-readable address
      String addressString = '';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Format: "City, Country"
          final city = place.locality ?? '';
          final country = place.country ?? '';
          addressString = [city, country].where((s) => s.isNotEmpty).join(', ');
        }
      } catch (e) {
        print('Error getting address: $e');
        addressString =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      // Update Firestore with location data
      await _firestore.collection('users').doc(phoneDocId).update({
        'location': GeoPoint(position.latitude, position.longitude),
        'address': addressString,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  /// Get human-readable address from GeoPoint
  Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? '';
        final country = place.country ?? '';
        return [city, country].where((s) => s.isNotEmpty).join(', ');
      }

      return '${geoPoint.latitude.toStringAsFixed(4)}, ${geoPoint.longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('Error getting address: $e');
      return '${geoPoint.latitude.toStringAsFixed(4)}, ${geoPoint.longitude.toStringAsFixed(4)}';
    }
  }

  /// Sign out the user
  /// First marks user as offline, then signs out from Firebase
  Future<void> signOut() async {
    try {
      // Mark user as offline before signing out
      final presenceService = UserPresenceService();
      await presenceService.setOfflineBeforeLogout();
    } catch (e) {
      print('Error updating presence on logout: $e');
      // Continue with logout even if presence update fails
    }

    // Sign out from Firebase Auth
    await _auth.signOut();
  }
}
