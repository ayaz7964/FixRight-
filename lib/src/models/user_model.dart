import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String role; // 'buyer' or 'seller'
  final String? preferredLanguage; // 'en', 'ur', 'es', etc.
  final String? bio;
  final double? rating;
  final int? totalReviews;
  final bool isOnline;
  final Timestamp? lastSeen;
  final String? status; // 'online', 'away', 'offline'

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.role,
    this.preferredLanguage = 'en',
    this.bio,
    this.rating,
    this.totalReviews,
    this.isOnline = false,
    this.lastSeen,
    this.status = 'offline',
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'profileImageUrl': profileImageUrl,
        'role': role,
        'preferredLanguage': preferredLanguage,
        'bio': bio,
        'rating': rating,
        'totalReviews': totalReviews,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
        'status': status,
      };

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      // In FixRight, `users` docs are keyed by phone number, and the
      // Firebase Auth UID is stored in `firebaseUid`.
      uid: (data['firebaseUid'] ?? data['uid'] ?? doc.id).toString(),
      phoneNumber: (data['phoneNumber'] ?? doc.id).toString(),
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] ?? 'buyer',
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      bio: data['bio'],
      rating: (data['rating'] as num?)?.toDouble(),
      totalReviews: data['totalReviews'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'],
      status: data['status'] ?? 'offline',
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? role,
    String? preferredLanguage,
    String? bio,
    double? rating,
    int? totalReviews,
    bool? isOnline,
    Timestamp? lastSeen,
    String? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
    );
  }
}
