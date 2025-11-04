// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserService {
//   final _firestore = FirebaseFirestore.instance;

//   Future<String> generateUniqueClientId(String base, String phone) async {
//     // remove non-alphanum and shorten
//     String candidateBase = base.replaceAll(RegExp(r'[^a-z0-9]'), '').toLowerCase();
//     if (candidateBase.isEmpty) candidateBase = 'user';
//     // attempt up to N suffixes
//     for (int i = 0; i < 10; i++) {
//       final suffix = (i == 0) ? '' : ('${i}');
//       final candidate = '$candidateBase${phone.substring(phone.length - 4)}$suffix';
//       final snap = await _firestore.collection('users').where('uniqueId', isEqualTo: candidate).limit(1).get();
//       if (snap.docs.isEmpty) return candidate;
//     }
//     // fallback random
//     final rnd = DateTime.now().millisecondsSinceEpoch % 100000;
//     return '$candidateBase${phone.substring(phone.length - 4)}$rnd';
//   }

//   Future<void> createUserProfile({
//     required String uid,
//     required String uniqueId,
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String city,
//     required String county,
//     String? photoUrl,
//   }) async {
//     final doc = _firestore.collection('users').doc(uid);
//     await doc.set({
//       'uniqueId': uniqueId,
//       'firstName': firstName,
//       'lastName': lastName,
//       'phone': phone,
//       'city': city,
//       'county': county,
//       'photoUrl': photoUrl ?? '',
//       'createdAt': FieldValue.serverTimestamp(),
//       'roles': ['client'],
//     }, SetOptions(merge: true));
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  /// Generate unique client ID (e.g. user_123456)
  Future<String> generateUniqueClientId(String first, String phone) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final id = 'user_${first.substring(0, 2)}_${timestamp.substring(timestamp.length - 4)}';
    return id;
  }

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String uniqueId,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String county,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uniqueId': uniqueId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'city': city,
      'country': county,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
