import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _googleTranslateUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // Supported languages map
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ur': 'Urdu',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'zh': 'Chinese',
    'pt': 'Portuguese',
    'ja': 'Japanese',
    'ru': 'Russian',
    'it': 'Italian',
  };

  // Cache for translations to reduce API calls
  static final Map<String, Map<String, String>> _translationCache = {};

  /// Translate text to target language
  /// Uses Google Translate API free alternative (via googleapis.com)
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      // Check cache first
      final cacheKey = '$text:$sourceLanguage:$targetLanguage';
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]![targetLanguage] ?? text;
      }

      final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print('Warning: GOOGLE_TRANSLATE_API_KEY not set in .env');
        return text; // Return original if no API key
      }

      final params = {
        'key': apiKey,
        'q': text,
        'target': targetLanguage,
      };

      if (sourceLanguage != null && sourceLanguage.isNotEmpty) {
        params['source'] = sourceLanguage;
      }

      final response = await http.get(
        Uri.parse(_googleTranslateUrl).replace(queryParameters: params),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['data']['translations'][0]['translatedText'] ?? text;

        // Cache the result
        _translationCache[cacheKey] = {
          targetLanguage: translatedText,
        };

        return translatedText;
      } else {
        print('Translation API error: ${response.statusCode}');
        return text; // Return original on error
      }
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original on error
    }
  }

  /// Translate text to multiple languages at once
  Future<Map<String, String>> translateToMultiple({
    required String text,
    required List<String> targetLanguages,
    String? sourceLanguage,
  }) async {
    final results = <String, String>{};
    for (final lang in targetLanguages) {
      results[lang] = await translate(
        text: text,
        targetLanguage: lang,
        sourceLanguage: sourceLanguage,
      );
    }
    return results;
  }

  /// Detect language of text
  /// Uses a simple heuristic approach or API call
  Future<String> detectLanguage(String text) async {
    try {
      if (text.isEmpty) return 'en';

      // Simple heuristic detection
      if (_containsUrduCharacters(text)) return 'ur';
      if (_containsArabicCharacters(text)) return 'ar';
      if (_containsChineseCharacters(text)) return 'zh';
      if (_containsSpanishCharacters(text)) return 'es';

      // Default to English
      return 'en';
    } catch (e) {
      return 'en';
    }
  }

  /// Get display name for language code
  static String getLanguageName(String code) {
    return supportedLanguages[code] ?? code.toUpperCase();
  }

  /// Clear translation cache
  static void clearCache() {
    _translationCache.clear();
  }

  // Helper methods for character detection
  static bool _containsUrduCharacters(String text) {
    final urduRegex = RegExp(r'[\u0600-\u06FF]');
    return urduRegex.hasMatch(text);
  }

  static bool _containsArabicCharacters(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  static bool _containsChineseCharacters(String text) {
    final chineseRegex = RegExp(r'[\u4E00-\u9FFF\u3040-\u309F\u30A0-\u30FF]');
    return chineseRegex.hasMatch(text);
  }

  static bool _containsSpanishCharacters(String text) {
    final spanishRegex = RegExp(r'[áéíóúüñ¡¿]');
    return spanishRegex.hasMatch(text);
  }
}
