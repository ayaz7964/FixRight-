import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_provider.dart';

/// ConfigService: manages AI provider configurations stored in Firestore
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ConfigService._internal();

  factory ConfigService() {
    return _instance;
  }

  /// Get all enabled AI providers from admin/providers
  Future<List<AIProvider>> getEnabledProviders() async {
    try {
      final snap = await _firestore
          .collection('admin')
          .doc('config')
          .collection('providers')
          .where('enabled', isEqualTo: true)
          .get();
      return snap.docs.map((d) => AIProvider.fromDoc(d)).toList();
    } catch (e) {
      print('Error fetching providers: $e');
      return [];
    }
  }

  /// Get a specific provider by ID
  Future<AIProvider?> getProvider(String providerId) async {
    try {
      final doc = await _firestore
          .collection('admin')
          .doc('config')
          .collection('providers')
          .doc(providerId)
          .get();
      if (!doc.exists) return null;
      return AIProvider.fromDoc(doc);
    } catch (e) {
      print('Error fetching provider $providerId: $e');
      return null;
    }
  }

  /// Stream enabled providers (real-time)
  Stream<List<AIProvider>> providersStream() {
    return _firestore
        .collection('admin')
        .doc('config')
        .collection('providers')
        .where('enabled', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AIProvider.fromDoc(d)).toList());
  }

  /// Get default provider (first enabled, or null)
  Future<AIProvider?> getDefaultProvider() async {
    try {
      final providers = await getEnabledProviders();
      return providers.isNotEmpty ? providers.first : null;
    } catch (e) {
      print('Error getting default provider: $e');
      return null;
    }
  }

  /// Get preferred translation provider (if configured)
  Future<String?> getTranslationProvider() async {
    try {
      final doc = await _firestore.collection('admin').doc('config').get();
      final data = doc.data() ?? {};
      return data['translationProvider'];
    } catch (e) {
      print('Error fetching translation provider: $e');
      return null;
    }
  }
}
