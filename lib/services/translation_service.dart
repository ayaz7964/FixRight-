import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _googleTranslateUrl =
      'https://translation.googleapis.com/language/translate/v2';

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
        print('Translation cache hit: $cacheKey');
        return _translationCache[cacheKey]![targetLanguage] ?? text;
      }

      final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print('❌ ERROR: GOOGLE_TRANSLATE_API_KEY not set in .env');
        return text; // Return original if no API key
      }

      print('🔄 Translating: "$text" from $sourceLanguage to $targetLanguage');
      print('📝 API Key: ${apiKey.substring(0, 10)}...');

      final params = {'key': apiKey, 'q': text, 'target': targetLanguage};

      if (sourceLanguage != null && sourceLanguage.isNotEmpty) {
        params['source'] = sourceLanguage;
      }

      final uri = Uri.parse(
        _googleTranslateUrl,
      ).replace(queryParameters: params);
      print('🌐 Request URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('📋 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['data']['translations'][0]['translatedText'] ?? text;

        print('✅ Translation successful: "$translatedText"');

        // Cache the result
        _translationCache[cacheKey] = {targetLanguage: translatedText};

        return translatedText;
      } else {
        print('❌ Translation API error: ${response.statusCode}');
        print('Response: ${response.body}');
        return text; // Return original on error
      }
    } catch (e) {
      print('❌ Translation error: $e');
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

  /// Diagnose translation API setup
  static Future<void> testTranslationAPI() async {
    print('\n🔍 === TRANSLATION API DIAGNOSTIC ===');

    final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];
    print('1️⃣ API Key Status:');
    if (apiKey == null || apiKey.isEmpty) {
      print('   ❌ MISSING - Add GOOGLE_TRANSLATE_API_KEY to .env');
      return;
    }
    print('   ✅ Present (${apiKey.substring(0, 10)}...)');

    print('2️⃣ Testing translation...');
    try {
      final instance = TranslationService();
      final result = await instance.translate(
        text: 'Hello',
        targetLanguage: 'es',
      );
      if (result == 'Hello') {
        print('   ❌ API returned original text (not working)');
      } else {
        print('   ✅ Translation worked: "Hello" → "$result"');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }

    print('3️⃣ Recommendations:');
    print('   - Ensure GOOGLE_TRANSLATE_API_KEY is a valid Google Cloud key');
    print('   - Check API quota in Google Cloud Console');
    print('   - Verify Translation API is enabled in Google Cloud Project');
    print('================================\n');
  }
}
