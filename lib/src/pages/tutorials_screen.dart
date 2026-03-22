// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'tts_translation_service.dart';

// // ═══════════════════════════════════════════════════════════════
// //  FIRESTORE STRUCTURE (reference)
// //
// //  tutorials/{tutorialId}
// //    title: string
// //    description: string
// //    youtubeUrl: string          (full YouTube URL)
// //    language: string            (en, ur, hi, ar, …)
// //    category: string            (buyer | seller | both)
// //    order: number
// //    thumbnailUrl: string        (optional custom thumb)
// //    duration: string            (e.g. "12:34")
// //    isActive: bool
// //    createdAt: Timestamp
// //    questions: [                (MCQ list)
// //      { question, options: [A,B,C,D], correctIndex: int }
// //    ]
// //
// //  tutorial_progress/{uid}/courses/{tutorialId}
// //    watched: bool
// //    watchedAt: Timestamp
// //    quizPassed: bool
// //    quizScore: int
// //    quizAttempts: int
// //    completedAt: Timestamp
// // ═══════════════════════════════════════════════════════════════

// class TutorialsScreen extends StatefulWidget {
//   final String uid;
//   const TutorialsScreen({super.key, required this.uid});

//   @override
//   State<TutorialsScreen> createState() => _TutorialsScreenState();
// }

// class _TutorialsScreenState extends State<TutorialsScreen> {
//   static const _teal     = Color(0xFF00695C);
//   static const _tealDark = Color(0xFF004D40);

//   String _selectedLanguage = 'all';
//   String _selectedCategory = 'all';
//   Map<String, Map<String, dynamic>> _progress = {};

//   final List<Map<String, String>> _languages = [
//     {'code': 'all', 'label': 'All Languages', 'flag': '🌐'},
//     {'code': 'en',  'label': 'English',        'flag': '🇺🇸'},
//     {'code': 'ur',  'label': 'اردو',           'flag': '🇵🇰'},
//     {'code': 'hi',  'label': 'हिन्दी',         'flag': '🇮🇳'},
//     {'code': 'ar',  'label': 'العربية',        'flag': '🇸🇦'},
//     {'code': 'pa',  'label': 'پنجابی',         'flag': '🇵🇰'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadProgress();
//     TtsTranslationService().init();
//   }

//   Future<void> _loadProgress() async {
//     if (widget.uid.isEmpty) return;
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('tutorial_progress')
//           .doc(widget.uid)
//           .collection('courses')
//           .get();
//       final map = <String, Map<String, dynamic>>{};
//       for (final d in snap.docs) {
//         map[d.id] = d.data();
//       }
//       if (mounted) setState(() => _progress = map);
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           SliverAppBar(
//             expandedHeight: 160,
//             pinned: true,
//             backgroundColor: _teal,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(colors: [_teal, _tealDark],
//                       begin: Alignment.topLeft, end: Alignment.bottomRight)),
//                 child: SafeArea(child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     const Text('Tutorials', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
//                     const SizedBox(height: 4),
//                     Text('Master FixRight — learn step by step',
//                         style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13.5)),
//                   ]),
//                 )),
//               ),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(0),
//               child: const SizedBox(),
//             ),
//           ),
//         ],
//         body: Column(children: [
//           _buildFilters(),
//           Expanded(child: _buildList()),
//         ]),
//       ),
//     );
//   }

//   Widget _buildFilters() => Container(
//     color: Colors.white,
//     padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       // Category filter
//       Row(children: [
//         _filterChip('All', 'all', _selectedCategory,
//             () => setState(() => _selectedCategory = 'all')),
//         const SizedBox(width: 8),
//         _filterChip('For Buyers', 'buyer', _selectedCategory,
//             () => setState(() => _selectedCategory = 'buyer')),
//         const SizedBox(width: 8),
//         _filterChip('For Sellers', 'seller', _selectedCategory,
//             () => setState(() => _selectedCategory = 'seller')),
//       ]),
//       const SizedBox(height: 8),
//       // Language filter horizontal scroll
//       SizedBox(
//         height: 34,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: _languages.length,
//           itemBuilder: (_, i) {
//             final l = _languages[i];
//             final active = _selectedLanguage == l['code'];
//             return GestureDetector(
//               onTap: () => setState(() => _selectedLanguage = l['code']!),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 margin: const EdgeInsets.only(right: 8),
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: active ? const Color(0xFF00695C) : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: active ? const Color(0xFF00695C) : Colors.grey.shade200)),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   Text(l['flag']!, style: const TextStyle(fontSize: 14)),
//                   const SizedBox(width: 5),
//                   Text(l['label']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
//                       color: active ? Colors.white : Colors.grey[700])),
//                 ]),
//               ),
//             );
//           },
//         ),
//       ),
//     ]),
//   );

//   Widget _filterChip(String label, String value, String current, VoidCallback onTap) {
//     final active = current == value;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           color: active ? const Color(0xFF00695C) : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: active ? const Color(0xFF00695C) : Colors.grey.shade200)),
//         child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
//             color: active ? Colors.white : Colors.grey[700])),
//       ),
//     );
//   }

//   Widget _buildList() {
//     Query query = FirebaseFirestore.instance
//         .collection('tutorials')
//         .where('isActive', isEqualTo: true)
//         .orderBy('order');

//     if (_selectedLanguage != 'all') {
//       query = query.where('language', isEqualTo: _selectedLanguage);
//     }
//     if (_selectedCategory != 'all') {
//       // category can be 'buyer', 'seller', or 'both'
//       // We get all and filter client-side for 'both' to work
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: query.snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2));
//         }
//         var docs = snap.data?.docs ?? [];

//         // category filter client-side (handles 'both')
//         if (_selectedCategory != 'all') {
//           docs = docs.where((d) {
//             final cat = (d.data() as Map<String, dynamic>)['category'] as String? ?? 'both';
//             return cat == _selectedCategory || cat == 'both';
//           }).toList();
//         }

//         if (docs.isEmpty) {
//           return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(Icons.video_library_outlined, size: 56, color: Colors.grey[300]),
//             const SizedBox(height: 12),
//             Text('No tutorials available', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
//             const SizedBox(height: 6),
//             Text('Check back soon for new courses!', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
//           ]));
//         }

//         // Progress summary header
//         final total     = docs.length;
//         final completed = docs.where((d) => _progress[d.id]?['quizPassed'] == true).length;

//         return Column(children: [
//           if (total > 0) _buildProgressBanner(completed, total),
//           Expanded(child: ListView.builder(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
//             itemCount: docs.length,
//             itemBuilder: (_, i) {
//               final doc  = docs[i];
//               final data = doc.data() as Map<String, dynamic>;
//               final prog = _progress[doc.id] ?? {};
//               return _TutorialCard(
//                 tutorialId: doc.id,
//                 data: data,
//                 progress: prog,
//                 uid: widget.uid,
//                 onProgressUpdate: _loadProgress,
//               );
//             },
//           )),
//         ]);
//       },
//     );
//   }

//   Widget _buildProgressBanner(int completed, int total) {
//     final pct = total == 0 ? 0.0 : completed / total;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('Your Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87)),
//             Text('$completed of $total courses completed',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//           ])),
//           Container(
//             width: 46, height: 46,
//             decoration: BoxDecoration(
//               color: const Color(0xFF00695C).withOpacity(0.1), shape: BoxShape.circle),
//             child: Center(child: Text('${(pct * 100).round()}%',
//                 style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF00695C)))),
//           ),
//         ]),
//         const SizedBox(height: 10),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: LinearProgressIndicator(
//             value: pct, minHeight: 8,
//             backgroundColor: Colors.grey.shade100,
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00695C)),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  TUTORIAL CARD
// // ═══════════════════════════════════════════════════════════════
// class _TutorialCard extends StatelessWidget {
//   final String tutorialId, uid;
//   final Map<String, dynamic> data, progress;
//   final VoidCallback onProgressUpdate;

//   static const _teal = Color(0xFF00695C);

//   const _TutorialCard({
//     required this.tutorialId,
//     required this.data,
//     required this.progress,
//     required this.uid,
//     required this.onProgressUpdate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final title       = (data['title']       as String? ?? 'Tutorial').trim();
//     final description = (data['description'] as String? ?? '').trim();
//     final duration    = (data['duration']    as String? ?? '').trim();
//     final language    = (data['language']    as String? ?? 'en').trim();
//     final category    = (data['category']    as String? ?? 'both').trim();
//     final thumbUrl    = (data['thumbnailUrl'] as String? ?? '').trim();

//     final watched    = progress['watched']    == true;
//     final quizPassed = progress['quizPassed'] == true;
//     final score      = (progress['quizScore'] as int? ?? 0);

//     return GestureDetector(
//       onTap: () => Navigator.push(context, MaterialPageRoute(
//           builder: (_) => TutorialDetailScreen(
//             tutorialId: tutorialId, data: data, uid: uid,
//             progress: progress, onProgressUpdate: onProgressUpdate))),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(18),
//           border: quizPassed ? Border.all(color: _teal.withOpacity(0.3), width: 1.5) : null,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // Thumbnail / header
//           Stack(children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
//               child: thumbUrl.isNotEmpty
//                   ? Image.network(thumbUrl, height: 160, width: double.infinity, fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _defaultThumb())
//                   : _defaultThumb(),
//             ),
//             // play overlay
//             Positioned.fill(child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.25),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
//               child: Center(child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
//                 child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00695C), size: 30),
//               )),
//             )),
//             // badges
//             Positioned(top: 10, left: 10, child: Row(children: [
//               _badge(_langFlag(language), Colors.black54),
//               const SizedBox(width: 6),
//               _badge(category == 'buyer' ? '🛒 Buyer' : category == 'seller' ? '🔧 Seller' : '👥 All',
//                   Colors.black54),
//             ])),
//             // status badge top right
//             Positioned(top: 10, right: 10, child:
//               quizPassed ? _badge('✅ Completed', Colors.green.shade700)
//               : watched  ? _badge('📺 Watched',  Colors.orange.shade700)
//               :             _badge('New', Colors.blueGrey.shade600)
//             ),
//             // duration bottom right
//             if (duration.isNotEmpty)
//               Positioned(bottom: 10, right: 10, child: _badge('⏱ $duration', Colors.black54)),
//           ]),

//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               // Title with translation
//               TranslatedText(
//                 text: title,
//                 contentId: 'tut_title_$tutorialId',
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87),
//                 maxLines: 2,
//                 showListenButton: false,
//               ),
//               const SizedBox(height: 6),
//               // Description with translation + listen
//               TranslatedText(
//                 text: description,
//                 contentId: 'tut_desc_$tutorialId',
//                 style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.45),
//                 maxLines: 2,
//                 showListenButton: true,
//               ),
//               if (quizPassed) ...[
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.green.shade200)),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.star_rounded, color: Colors.green.shade600, size: 15),
//                     const SizedBox(width: 5),
//                     Text('Quiz passed — score $score/${(data['questions'] as List?)?.length ?? 0}',
//                         style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w700)),
//                   ]),
//                 ),
//               ],
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _defaultThumb() => Container(
//     height: 160, width: double.infinity,
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(colors: [Color(0xFF00695C), Color(0xFF004D40)],
//           begin: Alignment.topLeft, end: Alignment.bottomRight),
//       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//     ),
//     child: const Icon(Icons.play_circle_outline_rounded, color: Colors.white54, size: 64),
//   );

//   Widget _badge(String text, Color bg) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
//     child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
//   );

//   String _langFlag(String code) {
//     const flags = {'en': '🇺🇸', 'ur': '🇵🇰', 'hi': '🇮🇳', 'ar': '🇸🇦', 'pa': '🇵🇰', 'zh': '🇨🇳'};
//     return flags[code] ?? '🌐';
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  TUTORIAL DETAIL SCREEN  — watch video + take quiz
// // ═══════════════════════════════════════════════════════════════
// class TutorialDetailScreen extends StatefulWidget {
//   final String tutorialId, uid;
//   final Map<String, dynamic> data, progress;
//   final VoidCallback onProgressUpdate;

//   const TutorialDetailScreen({
//     super.key,
//     required this.tutorialId,
//     required this.data,
//     required this.uid,
//     required this.progress,
//     required this.onProgressUpdate,
//   });

//   @override
//   State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
// }

// class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
//   static const _teal = Color(0xFF00695C);

//   YoutubePlayerController? _ytCtrl;
//   bool _videoEnded  = false;
//   bool _quizMode    = false;
//   bool _quizDone    = false;
//   bool _quizPassed  = false;
//   int  _quizScore   = 0;
//   int  _currentQ    = 0;
//   int? _selectedOpt;
//   bool _showAnswer  = false;

//   List<Map<String, dynamic>> _questions = [];
//   Map<int, int> _answers = {}; // questionIndex → selectedOptionIndex

//   @override
//   void initState() {
//     super.initState();
//     _initPlayer();
//     final qs = widget.data['questions'];
//     if (qs is List) {
//       _questions = qs.map((q) => Map<String, dynamic>.from(q as Map)).toList();
//     }
//     // If already passed, show that state
//     if (widget.progress['quizPassed'] == true) {
//       setState(() { _quizPassed = true; _quizDone = true; _videoEnded = true; });
//     }
//   }

//   void _initPlayer() {
//     final url = widget.data['youtubeUrl'] as String? ?? '';
//     final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
//     if (videoId.isEmpty) return;
//     _ytCtrl = YoutubePlayerController(
//       initialVideoId: videoId,
//       flags: const YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: false),
//     )..addListener(_onPlayerUpdate);
//   }

//   void _onPlayerUpdate() {
//     if (_ytCtrl == null) return;
//     if (_ytCtrl!.value.playerState == PlayerState.ended && !_videoEnded) {
//       setState(() => _videoEnded = true);
//       _markWatched();
//     }
//   }

//   Future<void> _markWatched() async {
//     if (widget.uid.isEmpty) return;
//     await FirebaseFirestore.instance
//         .collection('tutorial_progress').doc(widget.uid)
//         .collection('courses').doc(widget.tutorialId)
//         .set({'watched': true, 'watchedAt': Timestamp.now()}, SetOptions(merge: true));
//     widget.onProgressUpdate();
//   }

//   Future<void> _saveQuizResult(bool passed, int score) async {
//     if (widget.uid.isEmpty) return;
//     final attempts = ((widget.progress['quizAttempts'] as int?) ?? 0) + 1;
//     await FirebaseFirestore.instance
//         .collection('tutorial_progress').doc(widget.uid)
//         .collection('courses').doc(widget.tutorialId)
//         .set({
//       'quizPassed':   passed,
//       'quizScore':    score,
//       'quizAttempts': attempts,
//       if (passed) 'completedAt': Timestamp.now(),
//     }, SetOptions(merge: true));
//     widget.onProgressUpdate();
//   }

//   void _submitQuiz() {
//     int correct = 0;
//     for (int i = 0; i < _questions.length; i++) {
//       final q           = _questions[i];
//       final correctIdx  = (q['correctIndex'] as int? ?? 0);
//       final selected    = _answers[i];
//       if (selected == correctIdx) correct++;
//     }
//     final passed = (_questions.isNotEmpty && correct / _questions.length >= 0.6);
//     setState(() {
//       _quizDone    = true;
//       _quizPassed  = passed;
//       _quizScore   = correct;
//     });
//     _saveQuizResult(passed, correct);
//   }

//   @override
//   void dispose() {
//     _ytCtrl?.removeListener(_onPlayerUpdate);
//     _ytCtrl?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.data['title'] as String? ?? 'Tutorial';
//     final desc  = widget.data['description'] as String? ?? '';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       appBar: AppBar(
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
//             maxLines: 1, overflow: TextOverflow.ellipsis),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: _quizMode ? _buildQuiz() : _buildVideoView(title, desc),
//     );
//   }

//   // ── Video view ────────────────────────────────────────────
//   Widget _buildVideoView(String title, String desc) {
//     return SingleChildScrollView(
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//         // YouTube player
//         _ytCtrl != null
//             ? YoutubePlayer(
//                 controller: _ytCtrl!,
//                 showVideoProgressIndicator: true,
//                 progressIndicatorColor: _teal,
//               )
//             : Container(
//                 height: 220, color: Colors.black,
//                 child: const Center(child: Text('Video unavailable',
//                     style: TextStyle(color: Colors.white)))),

//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//             // Title
//             TranslatedText(
//               text: title,
//               contentId: 'vtitle_${widget.tutorialId}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
//               showListenButton: false,
//             ),
//             const SizedBox(height: 10),

//             // Description with translate + listen
//             TranslatedText(
//               text: desc,
//               contentId: 'vdesc_${widget.tutorialId}',
//               style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.55),
//               showListenButton: true,
//             ),

//             const SizedBox(height: 20),

//             // Quiz section
//             if (_questions.isNotEmpty) ...[
//               if (!_videoEnded && !_quizDone)
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.amber.shade200)),
//                   child: Row(children: [
//                     Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 20),
//                     const SizedBox(width: 10),
//                     Expanded(child: Text('Watch the full video to unlock the quiz.',
//                         style: TextStyle(fontSize: 13, color: Colors.amber.shade800))),
//                   ]),
//                 ),
//               if (_videoEnded && !_quizDone)
//                 _startQuizCard(),
//               if (_quizDone)
//                 _quizResultCard(),
//             ],

//             if (_questions.isEmpty && _videoEnded)
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green.shade200)),
//                 child: Row(children: [
//                   Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 22),
//                   const SizedBox(width: 10),
//                   const Expanded(child: Text('Great job! You\'ve completed this tutorial.',
//                       style: TextStyle(fontSize: 13, color: Colors.black87))),
//                 ]),
//               ),

//             const SizedBox(height: 40),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _startQuizCard() => Container(
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF004D40)],
//           begin: Alignment.topLeft, end: Alignment.bottomRight),
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [BoxShadow(color: const Color(0xFF00695C).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
//     ),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Row(children: [
//         Icon(Icons.quiz_outlined, color: Colors.white, size: 24),
//         SizedBox(width: 10),
//         Text('Ready for the quiz?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
//       ]),
//       const SizedBox(height: 6),
//       Text('${_questions.length} questions • Pass score: 60%',
//           style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
//       const SizedBox(height: 14),
//       GestureDetector(
//         onTap: () => setState(() { _quizMode = true; _currentQ = 0; _answers = {}; }),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//           child: const Center(child: Text('Start Quiz',
//               style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w800, fontSize: 15))),
//         ),
//       ),
//     ]),
//   );

//   Widget _quizResultCard() {
//     final total = _questions.length;
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: _quizPassed ? Colors.green.shade50 : Colors.red.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _quizPassed ? Colors.green.shade200 : Colors.red.shade200),
//       ),
//       child: Column(children: [
//         Icon(_quizPassed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
//             color: _quizPassed ? Colors.green.shade600 : Colors.red.shade500, size: 36),
//         const SizedBox(height: 8),
//         Text(_quizPassed ? 'Quiz Passed! 🎉' : 'Not quite — try again',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
//                 color: _quizPassed ? Colors.green.shade700 : Colors.red.shade600)),
//         const SizedBox(height: 4),
//         Text('Score: $_quizScore / $total',
//             style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//         if (!_quizPassed) ...[
//           const SizedBox(height: 12),
//           GestureDetector(
//             onTap: () => setState(() { _quizMode = true; _currentQ = 0; _answers = {}; _quizDone = false; }),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//               decoration: BoxDecoration(color: Colors.red.shade500, borderRadius: BorderRadius.circular(10)),
//               child: const Text('Retry Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
//             ),
//           ),
//         ],
//       ]),
//     );
//   }

//   // ── Quiz view ─────────────────────────────────────────────
//   Widget _buildQuiz() {
//     final q       = _questions[_currentQ];
//     final opts    = List<String>.from(q['options'] as List? ?? []);
//     final correct = q['correctIndex'] as int? ?? 0;
//     final isLast  = _currentQ == _questions.length - 1;

//     return Column(children: [
//       // Progress bar
//       LinearProgressIndicator(
//         value: (_currentQ + 1) / _questions.length,
//         backgroundColor: Colors.grey.shade200,
//         valueColor: const AlwaysStoppedAnimation<Color>(_teal),
//         minHeight: 5,
//       ),

//       Expanded(child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           Text('Question ${_currentQ + 1} of ${_questions.length}',
//               style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w600)),
//           const SizedBox(height: 10),

//           Text(q['question'] as String? ?? '',
//               style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.4)),

//           const SizedBox(height: 24),

//           ...List.generate(opts.length, (i) {
//             final selected = _answers[_currentQ] == i;
//             final revealed = _showAnswer;
//             final isCorrect = i == correct;

//             Color bg = Colors.white;
//             Color border = Colors.grey.shade200;
//             Color textColor = Colors.black87;

//             if (selected && !revealed) { bg = _teal.withOpacity(0.08); border = _teal; }
//             if (revealed && isCorrect) { bg = Colors.green.shade50; border = Colors.green.shade400; textColor = Colors.green.shade800; }
//             if (revealed && selected && !isCorrect) { bg = Colors.red.shade50; border = Colors.red.shade300; textColor = Colors.red.shade700; }

//             return GestureDetector(
//               onTap: _showAnswer ? null : () => setState(() => _answers[_currentQ] = i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: border, width: 1.5)),
//                 child: Row(children: [
//                   Container(
//                     width: 28, height: 28,
//                     decoration: BoxDecoration(
//                       color: (revealed && isCorrect) ? Colors.green.shade500
//                           : (revealed && selected && !isCorrect) ? Colors.red.shade400
//                           : selected ? _teal : Colors.grey.shade100,
//                       shape: BoxShape.circle),
//                     child: Center(child: Text(String.fromCharCode(65 + i),
//                         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
//                             color: (selected || (revealed && isCorrect)) ? Colors.white : Colors.grey[600]))),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(child: Text(opts[i], style: TextStyle(fontSize: 14, color: textColor, height: 1.3))),
//                   if (revealed && isCorrect) Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 20),
//                   if (revealed && selected && !isCorrect) Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 20),
//                 ]),
//               ),
//             );
//           }),

//           const SizedBox(height: 20),

//           // Buttons
//           if (!_showAnswer && _answers.containsKey(_currentQ))
//             SizedBox(width: double.infinity, child: GestureDetector(
//               onTap: () => setState(() => _showAnswer = true),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade600, borderRadius: BorderRadius.circular(14)),
//                 child: const Center(child: Text('Check Answer',
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
//               ),
//             )),

//           if (_showAnswer)
//             SizedBox(width: double.infinity, child: GestureDetector(
//               onTap: () {
//                 if (isLast) {
//                   _submitQuiz();
//                   setState(() => _quizMode = false);
//                 } else {
//                   setState(() { _currentQ++; _showAnswer = false; });
//                 }
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(colors: [_teal, Color(0xFF004D40)]),
//                   borderRadius: BorderRadius.circular(14)),
//                 child: Center(child: Text(isLast ? 'Submit Quiz' : 'Next Question',
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
//               ),
//             )),
//         ]),
//       )),
//     ]);
//   }
// }