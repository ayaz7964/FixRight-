import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported AI provider types
enum AIProviderType {
  openai('openai'),
  claude('claude'),
  gemini('gemini'),
  deepseek('deepseek'),
  custom('custom');

  final String value;
  const AIProviderType(this.value);

  factory AIProviderType.fromString(String val) {
    return values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => AIProviderType.custom,
    );
  }
}

/// Configuration for an AI provider (stored in admin/providers/{providerId})
class AIProvider {
  final String id; // e.g., 'openai-gpt4', 'claude-opus', 'gemini-pro'
  final AIProviderType type;
  final String name; // Display name
  final String
  apiEndpoint; // API URL (e.g., https://api.openai.com/v1/chat/completions)
  final String apiKey; // Encrypted/stored securely in Firestore
  final String? model; // Model identifier (e.g., gpt-4, claude-3-opus)
  final bool enabled;
  final Map<String, dynamic>?
  settings; // Extra provider settings (temp, tokens, etc.)
  final Timestamp createdAt;
  final Timestamp updatedAt;

  AIProvider({
    required this.id,
    required this.type,
    required this.name,
    required this.apiEndpoint,
    required this.apiKey,
    this.model,
    this.enabled = true,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.value,
    'name': name,
    'apiEndpoint': apiEndpoint,
    'apiKey': apiKey, // TODO: Consider encrypting before storing
    'model': model,
    'enabled': enabled,
    'settings': settings ?? {},
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory AIProvider.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIProvider(
      id: doc.id,
      type: AIProviderType.fromString(data['type'] ?? 'custom'),
      name: data['name'] ?? '',
      apiEndpoint: data['apiEndpoint'] ?? '',
      apiKey: data['apiKey'] ?? '',
      model: data['model'],
      enabled: data['enabled'] ?? true,
      settings: data['settings'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Prompt template for this provider (can override)
  String buildPrompt(String userMessage, String recipientLanguage) {
    final prompt =
        '''You are a professional assistant for a marketplace app. Respond in $recipientLanguage language. Keep replies short and clear.

User message: $userMessage

Provide a brief, professional assistant reply.''';
    return prompt;
  }
}
