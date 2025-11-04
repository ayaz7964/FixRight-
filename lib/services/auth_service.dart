import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef CodeSentCallback = void Function(String verificationId);
typedef VerificationFailedCallback = void Function(FirebaseAuthException e);

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> verifyPhone(String phone,
      {required CodeSentCallback codeSent, required VerificationFailedCallback verificationFailed}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        // Auto-sign in for some devices
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) => verificationFailed(e),
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: (id) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<User?> signInWithOtp(String verificationId, String smsCode) async {
    final cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final res = await _auth.signInWithCredential(cred);
    return res.user;
  }

  Future<bool> userProfileExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }
}






