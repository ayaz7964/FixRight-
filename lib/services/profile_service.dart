import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents user profile data from Firestore
class UserProfile {
  final String phoneDocId;
  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String address;
  final String phoneNumber;
  final String? profileImageUrl;

  UserProfile({
    required this.phoneDocId,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.address,
    required this.phoneNumber,
    this.profileImageUrl,
  });

  /// Convert Firestore document to UserProfile
  factory UserProfile.fromFirestore(DocumentSnapshot doc, String phoneDocId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      phoneDocId: phoneDocId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? phoneDocId,
      profileImageUrl: data['profileImageUrl'],
    );
  }
}

/// Service for all profile-related Firestore operations
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch user profile from Firestore
  Future<UserProfile?> fetchProfile(String phoneDocId) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneDocId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc, phoneDocId);
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  /// Update profile fields (merge - doesn't overwrite other fields)
  Future<void> updateProfile(
    String phoneDocId, {
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'country': country,
        'address': address,
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update only profile image URL
  Future<void> updateProfileImage(String phoneDocId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  /// Validate profile data before saving
  static String? validateProfile({
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String address,
  }) {
    if (firstName.trim().isEmpty) return 'First name is required';
    if (lastName.trim().isEmpty) return 'Last name is required';
    if (city.trim().isEmpty) return 'City is required';
    if (country.trim().isEmpty) return 'Country is required';
    if (address.trim().isEmpty) return 'Address is required';
    return null; // Valid
  }
}
