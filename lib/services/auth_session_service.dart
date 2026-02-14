import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage Firebase Authentication sessions
/// Handles session persistence and sign in/out
///
/// This service only deals with Firebase Auth - it does NOT handle
/// credential validation. Credential validation still happens in AuthService
/// using Firestore auth documents.
///
/// Purpose: Establish authenticated user session for Firestore rules
/// and app session management.
class AuthSessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String emailDomain = '@app.fixright.com';

  // Get current Firebase Auth user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated in Firebase Auth
  bool get isAuthenticated => _auth.currentUser != null;

  // Get current user's Firebase Auth UID
  String? get currentUserId => _auth.currentUser?.uid;

  // ═══════════════════════════════════════════════════════════════
  // SIGN IN / SIGN UP METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Convert phone number to email alias
  /// Example: +923334567890 -> 923334567890@app.fixright.com
  static String phoneToEmailAlias(String phoneNumber) {
    // Remove + and special characters, keep only digits
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '$digits$emailDomain';
  }

  /// Sign in using phone number + password (creates Firebase Auth session)
  /// This is called BEFORE Firestore access, to establish the authenticated session.
  ///
  /// The phone number is converted to an email alias for Firebase Auth.
  /// This method handles both cases:
  /// 1. User registered via Firebase Auth → Direct sign-in
  /// 2. User registered via Firestore only → Create account then sign in
  Future<UserCredential> signInWithPhonePassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final emailAlias = phoneToEmailAlias(phoneNumber);

      try {
        // Try to sign in directly
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailAlias,
          password: password,
        );

        print('✅ Firebase Auth session established for: $emailAlias');
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Account doesn't exist - create it and then sign in
          // This handles users who registered via Firestore but not Firebase Auth yet
          print('⚠️ Account not found, creating new account...');

          try {
            final userCredential = await _auth.createUserWithEmailAndPassword(
              email: emailAlias,
              password: password,
            );
            print(
              '✅ Firebase Auth account created and signed in for: $emailAlias',
            );
            return userCredential;
          } catch (createError) {
            if (createError is FirebaseAuthException &&
                createError.code == 'email-already-in-use') {
              // Race condition - account was created by another request
              // Try signing in again
              final userCredential = await _auth.signInWithEmailAndPassword(
                email: emailAlias,
                password: password,
              );
              return userCredential;
            }
            rethrow;
          }
        } else {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Sign In Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Error signing in to Firebase Auth: $e');
      throw Exception('Failed to establish session: $e');
    }
  }

  /// Create Firebase Auth account (used after Firestore registration completes)
  ///
  /// This happens AFTER the user completes:
  /// 1. OTP verification (Firebase Auth)
  /// 2. Creating user profile in Firestore
  /// 3. Saving password in Firestore auth collection
  //  identifing the bug of login 
  ///
  /// Now we need to create a proper Firebase Auth account for session persistence.
  Future<UserCredential> createAuthAccount({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final emailAlias = phoneToEmailAlias(phoneNumber);

      // Create Firebase Auth account with email alias and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailAlias,
        password: password,
      );

      print('✅ Firebase Auth account created for: $emailAlias');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Account already exists - just sign in
        return signInWithPhonePassword(
          phoneNumber: phoneNumber,
          password: password,
        );
      }
      print('Firebase Auth Create Account Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Error creating Firebase Auth account: $e');
      throw Exception('Failed to create session account: $e');
    }
  }

  /// Sign out from Firebase Auth and clear session
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Firebase Auth session signed out');
    } catch (e) {
      print('Error signing out from Firebase Auth: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PASSWORD RESET METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Update password in Firebase Auth (after Firestore password update)
  ///
  /// This is called AFTER the user verifies their phone via OTP
  /// and the password has been updated in Firestore.
  ///
  /// Used during forgot password flow to sync new password with Firebase Auth.
  ///
  /// Approach:
  /// 1. Sign in with new password (creates account if needed, updates if exists)
  /// 2. Immediately sign out (keep user logged out during forgot password flow)
  /// 3. Password is now synced between Firestore and Firebase Auth
  /// 4. User can log in on next login with new password
  Future<void> updatePassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      // Sign in with the new password
      // This will:
      // - Create account if it doesn't exist (old Firestore-only users)
      // - Update password if account exists
      // - Work regardless of current authentication state
      await signInWithPhonePassword(
        phoneNumber: phoneNumber,
        password: newPassword,
      );

      // Sign out immediately (don't keep user logged in during forgot password)
      await _auth.signOut();

      print('✅ Firebase Auth password synced');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Password Sync Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Error syncing Firebase Auth password: $e');
      throw Exception('Failed to sync password: $e');
    }
  }

  /// Send password reset email using Firebase Auth
  ///
  /// User enters phone, we convert to email alias and send reset email.
  /// This provides an alternative to OTP-based password reset.
  Future<void> sendPasswordResetEmail({required String phoneNumber}) async {
    try {
      final emailAlias = phoneToEmailAlias(phoneNumber);

      await _auth.sendPasswordResetEmail(email: emailAlias);
      print('✅ Password reset email sent to: $emailAlias');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Password Reset Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw Exception('Failed to send reset email: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════

  /// Convert Firebase Auth exceptions to user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('User account not found. Please register first.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'weak-password':
        return Exception('Password is too weak. Use at least 6 characters.');
      case 'invalid-email':
        return Exception('Invalid email format.');
      case 'email-already-in-use':
        return Exception('This phone number is already registered.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Check if Firebase Auth session is active
  /// Useful for app startup to determine if user is already logged in
  Future<bool> isSessionActive() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Optionally refresh the token to ensure session is still valid
      await user.reload();
      return _auth.currentUser != null;
    } catch (e) {
      print('Error checking session: $e');
      return false;
    }
  }

  /// Get the current Firebase Auth session token
  /// Can be used for custom HTTP requests to backend
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken(true);
      return token;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }
}
