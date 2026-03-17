import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
//  SUPPORTED LANGUAGES
//  User can pick their preferred language — stored in prefs
// ═══════════════════════════════════════════════════════════════

class SupportedLanguage {
  final String code;      // BCP-47 e.g. "ur"
  final String ttsLocale; // flutter_tts locale e.g. "ur-PK"
  final String label;     // Native name
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.ttsLocale,
    required this.label,
    required this.flag,
  });
}

const kSupportedLanguages = [
  SupportedLanguage(code: 'en', ttsLocale: 'en-US', label: 'English',    flag: '🇺🇸'),
  SupportedLanguage(code: 'ur', ttsLocale: 'ur-PK', label: 'اردو',       flag: '🇵🇰'),
  SupportedLanguage(code: 'hi', ttsLocale: 'hi-IN', label: 'हिन्दी',     flag: '🇮🇳'),
  SupportedLanguage(code: 'ar', ttsLocale: 'ar-SA', label: 'العربية',    flag: '🇸🇦'),
  SupportedLanguage(code: 'pa', ttsLocale: 'pa-PK', label: 'پنجابی',     flag: '🇵🇰'),
  SupportedLanguage(code: 'ps', ttsLocale: 'ps-AF', label: 'پښتو',       flag: '🇦🇫'),
  SupportedLanguage(code: 'sd', ttsLocale: 'sd-PK', label: 'سنڌي',       flag: '🇵🇰'),
  SupportedLanguage(code: 'zh', ttsLocale: 'zh-CN', label: '中文',        flag: '🇨🇳'),
  SupportedLanguage(code: 'tr', ttsLocale: 'tr-TR', label: 'Türkçe',     flag: '🇹🇷'),
  SupportedLanguage(code: 'fr', ttsLocale: 'fr-FR', label: 'Français',   flag: '🇫🇷'),
];

// ═══════════════════════════════════════════════════════════════
//  TTS + TRANSLATION SERVICE
// ═══════════════════════════════════════════════════════════════

class TtsTranslationService {
  static final TtsTranslationService _instance = TtsTranslationService._();
  factory TtsTranslationService() => _instance;
  TtsTranslationService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;
  String _currentJobId = '';

  // Translation cache: "jobId_langCode" → translated text
  final Map<String, String> _cache = {};

  // ── Preferred language ─────────────────────────────────
  SupportedLanguage _lang = kSupportedLanguages[0]; // default English
  SupportedLanguage get currentLanguage => _lang;

  final ValueNotifier<SupportedLanguage> langNotifier =
      ValueNotifier(kSupportedLanguages[0]);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Load saved preference
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tts_lang_code') ?? 'en';
    final found = kSupportedLanguages.firstWhere(
      (l) => l.code == saved,
      orElse: () => kSupportedLanguages[0],
    );
    _lang = found;
    langNotifier.value = found;

    // Configure TTS
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) { _isSpeaking = false; debugPrint('TTS error: $msg'); });

    await _applyLanguage(_lang);
  }

  Future<void> _applyLanguage(SupportedLanguage lang) async {
    // Check if TTS engine supports the locale, fallback to English
    try {
      await _tts.setLanguage(lang.ttsLocale);
    } catch (_) {
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> setLanguage(SupportedLanguage lang) async {
    _lang = lang;
    langNotifier.value = lang;
    await _applyLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_lang_code', lang.code);
    await stop();
  }

  // ── Translation via Google Translate (free endpoint) ───
  Future<String> translate(String text, {String? targetLang}) async {
    final target = targetLang ?? _lang.code;
    if (target == 'en') return text; // no translation needed

    final cacheKey = '${text.hashCode}_$target';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=auto&tl=$target&dt=t'
        '&q=${Uri.encodeComponent(text)}',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final translated = (json[0] as List)
            .map((chunk) => chunk[0]?.toString() ?? '')
            .join();
        _cache[cacheKey] = translated;
        return translated;
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    return text; // fallback to original
  }

  // ── Speak a text (with optional translation) ───────────
  Future<void> speak({
    required String text,
    required String jobId,
    bool translateFirst = true,
  }) async {
    await init();

    // Stop any current speech
    if (_isSpeaking) await stop();
    _currentJobId = jobId;
    _isSpeaking = true;

    String toSpeak = text;
    if (translateFirst && _lang.code != 'en') {
      toSpeak = await translate(text);
    }

    // Split long text into sentences for smoother playback
    final sentences = _splitToSentences(toSpeak);
    for (final sentence in sentences) {
      if (!_isSpeaking || _currentJobId != jobId) break;
      await _tts.speak(sentence);
      // Small pause between sentences
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _isSpeaking = false;
  }

  List<String> _splitToSentences(String text) {
    // Split on sentence-ending punctuation while keeping reasonable chunks
    final parts = text.split(RegExp(r'(?<=[.!?۔؟])\s+'));
    final result = <String>[];
    StringBuffer buffer = StringBuffer();
    for (final p in parts) {
      buffer.write('$p ');
      if (buffer.length > 200) {
        result.add(buffer.toString().trim());
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) result.add(buffer.toString().trim());
    return result.isEmpty ? [text] : result;
  }

  Future<void> stop() async {
    _isSpeaking = false;
    _currentJobId = '';
    await _tts.stop();
  }

  bool get isSpeaking => _isSpeaking;
  String get currentJobId => _currentJobId;
}

// ═══════════════════════════════════════════════════════════════
//  SPEAK BUTTON WIDGET
//  Drop-in anywhere — handles play/stop/loading states
// ═══════════════════════════════════════════════════════════════

class SpeakButton extends StatefulWidget {
  /// The raw text (in English) to translate + speak
  final String text;

  /// Unique identifier for this content (jobId, bidId, etc.)
  final String contentId;

  /// Button style: 'icon' = just an icon, 'chip' = icon + label
  final SpeakButtonStyle style;

  /// Color theme
  final Color color;

  const SpeakButton({
    super.key,
    required this.text,
    required this.contentId,
    this.style = SpeakButtonStyle.icon,
    this.color = Colors.teal,
  });

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

enum SpeakButtonStyle { icon, chip }

class _SpeakButtonState extends State<SpeakButton>
    with SingleTickerProviderStateMixin {
  final _svc = TtsTranslationService();
  bool _loading = false;
  bool _speaking = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    await _svc.init();
    if (_speaking || _svc.currentJobId == widget.contentId) {
      await _svc.stop();
      if (mounted) setState(() { _speaking = false; _loading = false; });
      return;
    }
    if (mounted) setState(() { _loading = true; _speaking = false; });
    await _svc.speak(text: widget.text, jobId: widget.contentId);
    if (mounted) setState(() { _loading = false; _speaking = false; });
  }

  bool get _isThisActive => _svc.currentJobId == widget.contentId && _svc.isSpeaking;

  @override
  Widget build(BuildContext context) {
    final active = _isThisActive;
    final c = widget.color;

    if (widget.style == SpeakButtonStyle.chip) {
      return GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? c.withOpacity(0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? c : Colors.grey.shade300),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _buildIcon(active, c, size: 14),
            const SizedBox(width: 5),
            Text(
              _loading ? 'Translating...' : active ? 'Stop' : 'Listen',
              style: TextStyle(fontSize: 11, color: active ? c : Colors.grey[600], fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      );
    }

    // Icon style
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.12) : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: active ? c : Colors.grey.shade200),
        ),
        child: Center(child: _buildIcon(active, c, size: 16)),
      ),
    );
  }

  Widget _buildIcon(bool active, Color c, {double size = 16}) {
    if (_loading) {
      return SizedBox(width: size, height: size, child: CircularProgressIndicator(strokeWidth: 1.5, color: c));
    }
    if (active) {
      return ScaleTransition(
        scale: _pulseAnim,
        child: Icon(Icons.stop_circle_outlined, size: size + 2, color: c),
      );
    }
    return Icon(Icons.volume_up_outlined, size: size, color: Colors.grey[600]);
  }
}

// ═══════════════════════════════════════════════════════════════
//  LANGUAGE PICKER SHEET
//  Show anywhere with: LanguagePickerSheet.show(context)
// ═══════════════════════════════════════════════════════════════

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = TtsTranslationService();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            const Text('🌐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            const Text('Listen in your language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Text('Job descriptions will be translated & read aloud in your chosen language.', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ValueListenableBuilder<SupportedLanguage>(
            valueListenable: svc.langNotifier,
            builder: (context, current, _) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kSupportedLanguages.map((lang) {
                  final selected = current.code == lang.code;
                  return GestureDetector(
                    onTap: () async {
                      await svc.setLanguage(lang);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.teal : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? Colors.teal : Colors.grey.shade200, width: selected ? 2 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(lang.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? Colors.white : Colors.black87)),
                          Text(lang.code.toUpperCase(), style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : Colors.grey[500])),
                        ]),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        ],
                      ]),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TRANSLATED TEXT WIDGET
//  Shows original text + auto-translates, with listen button
// ═══════════════════════════════════════════════════════════════

class TranslatedText extends StatefulWidget {
  final String text;
  final String contentId;
  final TextStyle? style;
  final int? maxLines;
  final bool showListenButton;

  const TranslatedText({
    super.key,
    required this.text,
    required this.contentId,
    this.style,
    this.maxLines,
    this.showListenButton = true,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  final _svc = TtsTranslationService();
  String _displayText = '';
  bool _translating = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    _svc.langNotifier.addListener(_onLangChange);
    _loadTranslation();
  }

  @override
  void dispose() {
    _svc.langNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => _loadTranslation();

  Future<void> _loadTranslation() async {
    if (widget.text.isEmpty) return;
    await _svc.init();
    if (_svc.currentLanguage.code == 'en') {
      if (mounted) setState(() => _displayText = widget.text);
      return;
    }
    if (mounted) setState(() => _translating = true);
    final translated = await _svc.translate(widget.text);
    if (mounted) setState(() { _displayText = translated; _translating = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_translating)
          Row(children: [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.teal.shade300)),
            const SizedBox(width: 6),
            Text('Translating…', style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic)),
          ])
        else
          GestureDetector(
            onTap: widget.maxLines != null ? () => setState(() => _expanded = !_expanded) : null,
            child: Text(
              _displayText,
              style: widget.style,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded ? TextOverflow.visible : (widget.maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible),
            ),
          ),
        if (widget.maxLines != null && _displayText.length > 80)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Read less' : 'Read more', style: TextStyle(fontSize: 11, color: Colors.teal.shade600, fontWeight: FontWeight.bold)),
          ),
        if (widget.showListenButton && _displayText.isNotEmpty) ...[
          const SizedBox(height: 6),
          SpeakButton(
            text: widget.text, // always pass original English; service handles translation
            contentId: widget.contentId,
            style: SpeakButtonStyle.chip,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  GLOBAL LANGUAGE BUTTON
//  Drop into any AppBar actions list
// ═══════════════════════════════════════════════════════════════

class GlobalLanguageButton extends StatelessWidget {
  final Color color;
  const GlobalLanguageButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final svc = TtsTranslationService();
    return ValueListenableBuilder<SupportedLanguage>(
      valueListenable: svc.langNotifier,
      builder: (ctx, lang, _) {
        return IconButton(
          tooltip: 'Language: ${lang.label}',
          onPressed: () => LanguagePickerSheet.show(context),
          icon: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(lang.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, color: color, size: 16),
          ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  JOB CARD LISTEN ROW
//  Drop this below any job title/description
//  Usage:
//    JobListenRow(
//      title: jobData['title'],
//      description: jobData['description'],
//      location: jobData['location'],
//      jobId: jobId,
//    )
// ═══════════════════════════════════════════════════════════════

class JobListenRow extends StatelessWidget {
  final String title;
  final String? description;
  final String? location;
  final String? timing;
  final String jobId;

  const JobListenRow({
    super.key,
    required this.title,
    required this.jobId,
    this.description,
    this.location,
    this.timing,
  });

  String get _fullText {
    final parts = <String>[title];
    if (description != null && description!.isNotEmpty) parts.add(description!);
    if (location != null && location!.isNotEmpty) parts.add('Location: $location');
    if (timing != null && timing!.isNotEmpty) parts.add('Timing: $timing');
    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SupportedLanguage>(
      valueListenable: TtsTranslationService().langNotifier,
      builder: (_, lang, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpeakButton(
              text: _fullText,
              contentId: 'job_$jobId',
              style: SpeakButtonStyle.chip,
            ),
            if (lang.code != 'en') ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(lang.label, style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ],
        );
      },
    );
  }
}
