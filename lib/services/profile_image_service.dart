import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for profile image display
/// Handles caching and retrieval of profile image URLs
class ProfileImageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, String> _imageCache = {};

  /// Get profile image URL from Firestore
  /// Returns null if user or image not found
  Future<String?> getProfileImageUrl(String uid) async {
    if (uid.isEmpty) return null;

    // Check cache first
    if (_imageCache.containsKey(uid)) {
      return _imageCache[uid];
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final imageUrl = doc.data()?['profileImageUrl'] as String?;
      if (imageUrl != null) {
        _imageCache[uid] = imageUrl;
      }
      return imageUrl;
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
    }
  }

  /// Cache image URL in memory
  static void setCachedImageUrl(String uid, String? imageUrl) {
    if (imageUrl != null) {
      _imageCache[uid] = imageUrl;
    } else {
      _imageCache.remove(uid);
    }
  }

  /// Get cached image URL
  static String? getCachedImageUrl(String uid) {
    return _imageCache[uid];
  }

  /// Clear image cache
  static void clearImageCache() {
    _imageCache.clear();
  }
}
