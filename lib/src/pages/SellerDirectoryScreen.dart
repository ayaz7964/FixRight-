// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/user_session.dart';
// import 'ChatDetailScreen.dart';
// import 'tts_translation_service.dart';

// // ═══════════════════════════════════════════════════════════════
// //  SELLER DIRECTORY SCREEN
// //
// //  Data model (confirmed from Firestore):
// //    sellers/{uid}  — Rating, Jobs_Completed, skills, firstName, lastName, status
// //    users/{uid}    — profileImage, city  (NOT in sellers doc)
// //
// //  Strategy: fetch sellers (status=approved) + batch-fetch users
// //  for city + profileImage, merge client-side.
// //  All sorting done client-side → no composite Firestore index.
// // ═══════════════════════════════════════════════════════════════
// class SellerDirectoryScreen extends StatefulWidget {
//   final String? phoneUID;
//   final String  buyerCity;
//   const SellerDirectoryScreen({super.key, this.phoneUID, this.buyerCity = ''});

//   @override
//   State<SellerDirectoryScreen> createState() => _SellerDirectoryScreenState();
// }

// class _SellerDirectoryScreenState extends State<SellerDirectoryScreen> {
//   static const _teal = Color(0xFF00695C);

//   // ── Data ──────────────────────────────────────────────────
//   StreamSubscription<QuerySnapshot>? _sellerSub;
//   List<Map<String, dynamic>> _mergedSellers = [];
//   Map<String, Map<String, dynamic>> _userCache = {};
//   bool _loading = true;

//   // ── Filter state ─────────────────────────────────────────
//   final _searchCtrl = TextEditingController();
//   String _query    = '';
//   bool   _cityOnly = false;
//   String _sortBy   = 'rating'; // 'rating' | 'jobs'

//   @override
//   void initState() {
//     super.initState();
//     _cityOnly = widget.buyerCity.isNotEmpty;
//     _searchCtrl.addListener(() =>
//         setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
//     _listenToSellers();
//   }

//   @override
//   void dispose() {
//     _sellerSub?.cancel();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   // ── Subscribe + merge ─────────────────────────────────────
//   void _listenToSellers() {
//     _sellerSub = FirebaseFirestore.instance
//         .collection('sellers')
//         .where('status', isEqualTo: 'approved')
//         .snapshots()
//         .listen((snap) async {
//       final sellerDocs = snap.docs;
//       final uids = sellerDocs.map((d) => d.id).toList();

//       // Batch-fetch missing user profiles
//       final missing = uids.where((id) => !_userCache.containsKey(id)).toList();
//       if (missing.isNotEmpty) await _batchFetchUsers(missing);

//       // Merge: seller doc fields + user doc fields
//       final merged = sellerDocs.map((doc) {
//         final sd   = doc.data() as Map<String, dynamic>;
//         final ud   = _userCache[doc.id] ?? {};
//         // firstName/lastName: prefer users doc (more up-to-date), fall back to sellers
//         final firstName = (ud['firstName'] as String? ?? sd['firstName'] as String? ?? '').trim();
//         final lastName  = (ud['lastName']  as String? ?? sd['lastName']  as String? ?? '').trim();
//         return {
//           ...sd,
//           '_uid':       doc.id,
//           'firstName':  firstName,
//           'lastName':   lastName,
//           'profileImage': (ud['profileImage'] as String? ?? '').trim(),
//           'city':         (ud['city']         as String? ?? '').trim(),
//           // Firestore field names (capital letters)
//           'Rating':         sd['Rating']         ?? 0.0,
//           'Jobs_Completed': sd['Jobs_Completed'] ?? 0,
//           'skills':         sd['skills']         ?? [],
//           'bio':            ud['bio'] ?? sd['bio'] ?? '',
//         };
//       }).toList();

//       if (mounted) setState(() { _mergedSellers = merged; _loading = false; });
//     }, onError: (_) {
//       if (mounted) setState(() => _loading = false);
//     });
//   }

//   Future<void> _batchFetchUsers(List<String> uids) async {
//     const chunk = 30;
//     for (int i = 0; i < uids.length; i += chunk) {
//       final batch = uids.skip(i).take(chunk).toList();
//       try {
//         final snap = await FirebaseFirestore.instance
//             .collection('users')
//             .where(FieldPath.documentId, whereIn: batch)
//             .get();
//         for (final doc in snap.docs) {
//           _userCache[doc.id] = doc.data() as Map<String, dynamic>;
//         }
//       } catch (_) {}
//     }
//   }

//   // ── Filter + sort ─────────────────────────────────────────
//   List<Map<String, dynamic>> get _filtered {
//     var list = List<Map<String, dynamic>>.from(_mergedSellers);

//     // City filter — lowercase comparison
//     if (_cityOnly && widget.buyerCity.isNotEmpty) {
//       final bC = widget.buyerCity.trim().toLowerCase();
//       list = list.where((s) =>
//         (s['city'] as String? ?? '').trim().toLowerCase() == bC).toList();
//     }

//     // Search
//     if (_query.isNotEmpty) {
//       list = list.where((s) {
//         final first  = (s['firstName'] as String? ?? '').toLowerCase();
//         final last   = (s['lastName']  as String? ?? '').toLowerCase();
//         final city   = (s['city']      as String? ?? '').toLowerCase();
//         final skills = List<String>.from(s['skills'] ?? []).join(' ').toLowerCase();
//         return first.contains(_query) || last.contains(_query) ||
//             city.contains(_query) || skills.contains(_query);
//       }).toList();
//     }

//     // Sort client-side
//     list.sort((a, b) {
//       if (_sortBy == 'jobs') {
//         final aj = (a['Jobs_Completed'] ?? 0) as int;
//         final bj = (b['Jobs_Completed'] ?? 0) as int;
//         return bj.compareTo(aj);
//       }
//       final ar = (a['Rating'] ?? 0.0).toDouble();
//       final br = (b['Rating'] ?? 0.0).toDouble();
//       return br.compareTo(ar);
//     });

//     return list;
//   }

//   // ════════════════════════════════════════════════════════
//   //  BUILD
//   // ════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F5F8),
//       body: Column(children: [
//         _buildHeader(context),
//         _buildFilterRow(),
//         if (_loading)
//           const Expanded(child: Center(
//             child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2)))
//         else
//           Expanded(child: _buildList()),
//       ]),
//     );
//   }

//   // ── Header ────────────────────────────────────────────────
//   Widget _buildHeader(BuildContext ctx) => Container(
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
//         colors: [Color(0xFF00695C), Color(0xFF004D40)]),
//       borderRadius: BorderRadius.only(
//         bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
//       boxShadow: [BoxShadow(color: Color(0x44004D40), blurRadius: 16, offset: Offset(0, 6))]),
//     child: SafeArea(bottom: false, child: Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           GestureDetector(onTap: () => Navigator.pop(ctx),
//             child: Container(padding: const EdgeInsets.all(9),
//               decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
//               child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
//           const Spacer(),
//           const GlobalLanguageButton(color: Colors.white),
//         ]),
//         const SizedBox(height: 12),
//         const Text('Find Workers', style: TextStyle(color: Colors.white,
//           fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
//         const SizedBox(height: 4),
//         Text('${_filtered.length} workers available',
//           style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
//         const SizedBox(height: 14),
//         // Search bar
//         Container(
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]),
//           child: TextField(
//             controller: _searchCtrl,
//             style: const TextStyle(fontSize: 14),
//             decoration: InputDecoration(
//               hintText: 'Search by name, skill, city…',
//               hintStyle: TextStyle(color: Colors.grey[400]),
//               prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00695C)),
//               suffixIcon: _query.isNotEmpty
//                 ? IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey), onPressed: _searchCtrl.clear)
//                 : null,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             ),
//           ),
//         ),
//       ]),
//     )),
//   );

//   // ── Filter row ────────────────────────────────────────────
//   Widget _buildFilterRow() => Container(
//     color: Colors.white,
//     padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//     child: Row(children: [
//       if (widget.buyerCity.isNotEmpty) ...[
//         _pill('All', !_cityOnly, () => setState(() => _cityOnly = false)),
//         const SizedBox(width: 8),
//         _pill('📍 ${widget.buyerCity}', _cityOnly, () => setState(() => _cityOnly = true)),
//       ],
//       const Spacer(),
//       GestureDetector(
//         onTap: () => setState(() => _sortBy = _sortBy == 'rating' ? 'jobs' : 'rating'),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//           decoration: BoxDecoration(color: _teal.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: _teal.withOpacity(0.2))),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.sort_rounded, size: 14, color: _teal),
//             const SizedBox(width: 5),
//             Text(_sortBy == 'rating' ? 'By Rating' : 'By Jobs',
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _teal)),
//           ]),
//         ),
//       ),
//     ]),
//   );

//   Widget _pill(String l, bool active, VoidCallback onTap) => GestureDetector(
//     onTap: onTap,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 150),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//       decoration: BoxDecoration(
//         color: active ? _teal : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: active ? _teal : Colors.grey.shade200)),
//       child: Text(l, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
//         color: active ? Colors.white : Colors.grey[700])),
//     ),
//   );

//   // ── List ──────────────────────────────────────────────────
//   Widget _buildList() {
//     final sellers = _filtered;
//     if (sellers.isEmpty) return _emptyState();
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
//       itemCount: sellers.length,
//       itemBuilder: (ctx, i) => _SellerCard(
//         seller: sellers[i],
//         buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
//         buyerCity: widget.buyerCity,
//       ),
//     );
//   }

//   Widget _emptyState() => Center(child: Column(
//     mainAxisAlignment: MainAxisAlignment.center, children: [
//     Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey[300]),
//     const SizedBox(height: 14),
//     Text(_cityOnly ? 'No workers in ${widget.buyerCity} yet' : 'No workers found',
//       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[600])),
//     const SizedBox(height: 6),
//     Text(_cityOnly ? 'Try viewing all workers.' : 'Try a different search.',
//       style: TextStyle(fontSize: 13, color: Colors.grey[400])),
//   ]));
// }

// // ═══════════════════════════════════════════════════════════════
// //  SELLER CARD
// // ═══════════════════════════════════════════════════════════════
// class _SellerCard extends StatelessWidget {
//   final Map<String, dynamic> seller;
//   final String buyerUid, buyerCity;
//   static const _teal = Color(0xFF00695C);

//   const _SellerCard({required this.seller, required this.buyerUid, required this.buyerCity});

//   @override
//   Widget build(BuildContext context) {
//     final uid      = seller['_uid']          as String? ?? '';
//     final first    = seller['firstName']     as String? ?? '';
//     final last     = seller['lastName']      as String? ?? '';
//     final name     = '$first $last'.trim();
//     final img      = seller['profileImage']  as String? ?? '';  // from users
//     final city     = seller['city']          as String? ?? '';  // from users
//     final rating   = (seller['Rating']       ?? 0.0).toDouble(); // capital R
//     final jobs     = (seller['Jobs_Completed'] ?? 0) as int;
//     final skills   = List<String>.from(seller['skills'] ?? []);
//     final bio      = seller['bio'] as String? ?? '';
//     final sameCity = city.trim().toLowerCase() == buyerCity.trim().toLowerCase() && buyerCity.isNotEmpty;

//     return GestureDetector(
//       onTap: () => _showProfile(context, uid),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(20),
//           border: sameCity ? Border.all(color: _teal.withOpacity(0.3), width: 1.5) : null,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
//         child: Padding(padding: const EdgeInsets.all(16), child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // ── Top row ────────────────────────────────────
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // Avatar
//             Stack(children: [
//               CircleAvatar(radius: 30, backgroundColor: _teal.withOpacity(0.1),
//                 backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
//                 child: img.isEmpty
//                     ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'W',
//                         style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 24))
//                     : null),
//               if (sameCity) Positioned(bottom: 0, right: 0, child: Container(
//                 width: 18, height: 18,
//                 decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
//                   boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 1.5)]),
//                 child: const Icon(Icons.location_on, size: 10, color: Colors.white))),
//             ]),
//             const SizedBox(width: 12),
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Expanded(child: Text(name.isEmpty ? 'Worker' : name,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87))),
//                 if (sameCity) Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(14)),
//                   child: const Text('Near You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
//               ]),
//               const SizedBox(height: 4),
//               Row(children: [
//                 Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
//                 const SizedBox(width: 3),
//                 Text(rating.toStringAsFixed(1),
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700])),
//                 Text('  ·  $jobs jobs', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//               ]),
//               if (city.isNotEmpty) ...[
//                 const SizedBox(height: 3),
//                 Row(children: [
//                   Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[400]),
//                   const SizedBox(width: 3),
//                   Text(city, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//                 ]),
//               ],
//             ])),
//           ]),

//           // ── Bio ────────────────────────────────────────
//           if (bio.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             Text(bio, style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4),
//               maxLines: 2, overflow: TextOverflow.ellipsis),
//           ],

//           // ── Skills ─────────────────────────────────────
//           if (skills.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             Wrap(spacing: 6, runSpacing: 5, children: skills.take(4).map((s) => Container(
//               padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//               decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: _teal.withOpacity(0.15))),
//               child: Text(s, style: const TextStyle(fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
//             )).toList()),
//             if (skills.length > 4) Padding(padding: const EdgeInsets.only(top: 4),
//               child: Text('+${skills.length - 4} more',
//                 style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic))),
//           ],

//           const SizedBox(height: 14),

//           // ── Actions ────────────────────────────────────
//           Row(children: [
//             Expanded(child: OutlinedButton.icon(
//               onPressed: () => _showProfile(context, uid),
//               icon: const Icon(Icons.person_outline_rounded, size: 16),
//               label: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w600)),
//               style: OutlinedButton.styleFrom(foregroundColor: _teal, side: const BorderSide(color: _teal),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//             )),
//             const SizedBox(width: 10),
//             Expanded(child: ElevatedButton.icon(
//               onPressed: () => _openChat(context, uid, name, img),
//               icon: const Icon(Icons.message_outlined, size: 16),
//               label: const Text('Contact', style: TextStyle(fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//             )),
//           ]),
//         ])),
//       ),
//     );
//   }

//   void _showProfile(BuildContext ctx, String uid) => showModalBottomSheet(
//     context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
//     builder: (_) => SellerProfileSheet(
//       sellerId: uid,
//       preloadedSellerDoc: seller,
//       buyerUid: buyerUid,
//       buyerCity: buyerCity,
//     ),
//   );

//   Future<void> _openChat(BuildContext ctx, String uid, String name, String img) async {
//     if (buyerUid.isEmpty) {
//       ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please log in first')));
//       return;
//     }
//     final db     = FirebaseFirestore.instance;
//     final phones = [buyerUid, uid]..sort();
//     final convId = '${phones[0]}_${phones[1]}';
//     if (!(await db.collection('conversations').doc(convId).get()).exists) {
//       final bd        = (await db.collection('users').doc(buyerUid).get()).data() ?? {};
//       final buyerName = '${bd['firstName'] ?? ''} ${bd['lastName'] ?? ''}'.trim();
//       await db.collection('conversations').doc(convId).set({
//         'participantIds': [buyerUid, uid],
//         'participantNames': {buyerUid: buyerName, uid: name},
//         'participantRoles': {buyerUid: 'buyer', uid: 'seller'},
//         'participantProfileImages': {buyerUid: bd['profileImage'] ?? '', uid: img},
//         'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
//         'unreadCounts': {buyerUid: 0, uid: 0},
//       });
//     }
//     if (ctx.mounted) {
//       Navigator.push(ctx, MaterialPageRoute(builder: (_) => ChatDetailScreen(
//         convId: convId, myUid: buyerUid, otherUid: uid,
//         otherName: name, otherImage: img, otherRole: 'seller')));
//     }
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  SELLER PROFILE SHEET
// //
// //  Reviews from: sellers/{uid}/ratings/{docId}
// //  Fields saved by RatingFeedbackSection:
// //    stars, comment, buyerName, buyerUid, jobTitle, createdAt, jobId
// //
// //  Seller data merge: sellers doc + users doc
// // ═══════════════════════════════════════════════════════════════
// class SellerProfileSheet extends StatefulWidget {
//   final String sellerId, buyerUid, buyerCity;
//   /// Pass already-merged seller data (has profileImage, city from users doc).
//   final Map<String, dynamic>? preloadedSellerDoc;

//   const SellerProfileSheet({
//     super.key,
//     required this.sellerId,
//     required this.buyerUid,
//     required this.buyerCity,
//     this.preloadedSellerDoc,
//   });

//   @override
//   State<SellerProfileSheet> createState() => _SellerProfileSheetState();
// }

// class _SellerProfileSheetState extends State<SellerProfileSheet> {
//   static const _teal = Color(0xFF00695C);

//   Map<String, dynamic> _sellerData = {};
//   List<Map<String, dynamic>> _reviews = [];
//   bool _loadingSeller  = true;
//   bool _loadingReviews = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadSeller();
//     _loadReviews();
//   }

//   Future<void> _loadSeller() async {
//     // If preloaded data already has profileImage it's already merged
//     final pre = widget.preloadedSellerDoc ?? {};
//     if (pre.containsKey('profileImage')) {
//       setState(() { _sellerData = pre; _loadingSeller = false; });
//       return;
//     }
//     // Load from both collections and merge
//     try {
//       final results = await Future.wait([
//         FirebaseFirestore.instance.collection('sellers').doc(widget.sellerId).get(),
//         FirebaseFirestore.instance.collection('users').doc(widget.sellerId).get(),
//       ]);
//       final sd = results[0].data() as Map<String, dynamic>? ?? {};
//       final ud = results[1].data() as Map<String, dynamic>? ?? {};
//       final merged = {
//         ...sd,
//         'profileImage': (ud['profileImage'] as String? ?? '').trim(),
//         'city':         (ud['city']         as String? ?? '').trim(),
//         'firstName':    (ud['firstName'] as String? ?? sd['firstName'] as String? ?? '').trim(),
//         'lastName':     (ud['lastName']  as String? ?? sd['lastName']  as String? ?? '').trim(),
//         'bio':          ud['bio'] ?? sd['bio'] ?? '',
//       };
//       if (mounted) setState(() { _sellerData = merged; _loadingSeller = false; });
//     } catch (_) {
//       if (mounted) setState(() { _sellerData = pre; _loadingSeller = false; });
//     }
//   }

//   // ✅ Reads from sellers/{uid}/ratings  (where RatingFeedbackSection saves)
//   Future<void> _loadReviews() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(widget.sellerId)
//           .collection('ratings')
//           .limit(20)
//           .get();
//       final reviews = snap.docs
//           .map((d) => d.data() as Map<String, dynamic>)
//           .toList();
//       // Sort client-side descending by createdAt
//       reviews.sort((a, b) {
//         final at = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
//         final bt = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
//         return bt.compareTo(at);
//       });
//       if (mounted) setState(() { _reviews = reviews; _loadingReviews = false; });
//     } catch (_) {
//       if (mounted) setState(() => _loadingReviews = false);
//     }
//   }

//   Future<void> _openChat() async {
//     final name = '${_sellerData['firstName'] ?? ''} ${_sellerData['lastName'] ?? ''}'.trim();
//     final img  = _sellerData['profileImage'] as String? ?? '';
//     if (widget.buyerUid.isEmpty) return;
//     final db     = FirebaseFirestore.instance;
//     final phones = [widget.buyerUid, widget.sellerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';
//     if (!(await db.collection('conversations').doc(convId).get()).exists) {
//       final bd = (await db.collection('users').doc(widget.buyerUid).get()).data() ?? {};
//       final buyerName = '${bd['firstName'] ?? ''} ${bd['lastName'] ?? ''}'.trim();
//       await db.collection('conversations').doc(convId).set({
//         'participantIds': [widget.buyerUid, widget.sellerId],
//         'participantNames': {widget.buyerUid: buyerName, widget.sellerId: name},
//         'participantRoles': {widget.buyerUid: 'buyer', widget.sellerId: 'seller'},
//         'participantProfileImages': {widget.buyerUid: bd['profileImage'] ?? '', widget.sellerId: img},
//         'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
//         'unreadCounts': {widget.buyerUid: 0, widget.sellerId: 0},
//       });
//     }
//     if (mounted) {
//       Navigator.pop(context);
//       Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
//         convId: convId, myUid: widget.buyerUid, otherUid: widget.sellerId,
//         otherName: name, otherImage: img, otherRole: 'seller')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final name   = '${_sellerData['firstName'] ?? ''} ${_sellerData['lastName'] ?? ''}'.trim();
//     final img    = _sellerData['profileImage'] as String? ?? '';
//     final city   = _sellerData['city']         as String? ?? '';
//     final rating = (_sellerData['Rating']      ?? 0.0).toDouble();
//     final jobs   = (_sellerData['Jobs_Completed'] ?? 0) as int;
//     final skills = List<String>.from(_sellerData['skills'] ?? []);
//     final bio    = _sellerData['bio'] as String? ?? '';

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.92,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
//       child: Column(children: [
//         // Drag handle
//         Container(width: 44, height: 4,
//           margin: const EdgeInsets.only(top: 12, bottom: 8),
//           decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

//         Expanded(child: _loadingSeller
//           ? const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
//           : ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [

//             // ── Hero ──────────────────────────────────────
//             Center(child: Stack(alignment: Alignment.bottomRight, children: [
//               CircleAvatar(radius: 50, backgroundColor: _teal.withOpacity(0.1),
//                 backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
//                 child: img.isEmpty
//                   ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'W',
//                       style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 38))
//                   : null),
//               Container(width: 26, height: 26,
//                 decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
//                   boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2)]),
//                 child: const Icon(Icons.build_rounded, size: 14, color: Colors.white)),
//             ])),
//             const SizedBox(height: 12),

//             Center(child: Text(name.isEmpty ? 'Worker' : name,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
//               textAlign: TextAlign.center)),
//             if (city.isNotEmpty) ...[
//               const SizedBox(height: 5),
//               Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
//                 const SizedBox(width: 3),
//                 Text(city, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
//               ])),
//             ],
//             const SizedBox(height: 18),

//             // ── Stats ─────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 color: _teal.withOpacity(0.05), borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: _teal.withOpacity(0.12))),
//               child: Row(children: [
//                 _stat('⭐', rating.toStringAsFixed(1), 'Rating'),
//                 _vDiv(),
//                 _stat('✅', '$jobs', 'Jobs Done'),
//                 _vDiv(),
//                 _stat('💬', '${_reviews.length}', 'Reviews'),
//               ]),
//             ),
//             const SizedBox(height: 20),

//             // ── Bio ───────────────────────────────────────
//             if (bio.isNotEmpty) ...[
//               _sec('About'),
//               const SizedBox(height: 8),
//               Text(bio, style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5)),
//               const SizedBox(height: 20),
//             ],

//             // ── Skills ────────────────────────────────────
//             if (skills.isNotEmpty) ...[
//               _sec('Skills & Services'),
//               const SizedBox(height: 10),
//               Wrap(spacing: 7, runSpacing: 7, children: skills.map((s) => Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: _teal.withOpacity(0.2))),
//                 child: Text(s, style: const TextStyle(fontSize: 12.5, color: _teal, fontWeight: FontWeight.w600)),
//               )).toList()),
//               const SizedBox(height: 20),
//             ],

//             // ── Reviews ───────────────────────────────────
//             _sec('Buyer Reviews (${_reviews.length})'),
//             const SizedBox(height: 10),
//             if (_loadingReviews)
//               const Center(child: Padding(padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(color: _teal, strokeWidth: 2)))
//             else if (_reviews.isEmpty)
//               _noReviews()
//             else
//               ..._reviews.map((r) => _ReviewCard(r)),

//             const SizedBox(height: 24),

//             // ── Buttons ───────────────────────────────────
//             Row(children: [
//               Expanded(child: OutlinedButton.icon(
//                 onPressed: _openChat,
//                 icon: const Icon(Icons.message_outlined, size: 18),
//                 label: const Text('Message', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//                 style: OutlinedButton.styleFrom(foregroundColor: _teal, side: const BorderSide(color: _teal, width: 1.5),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
//               )),
//               const SizedBox(width: 12),
//               Expanded(child: ElevatedButton.icon(
//                 onPressed: _openChat,
//                 icon: const Icon(Icons.bolt_rounded, size: 18),
//                 label: const Text('Hire Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//                 style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
//               )),
//             ]),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _noReviews() => Container(
//     padding: const EdgeInsets.all(24),
//     decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: Colors.grey.shade200)),
//     child: Center(child: Column(children: [
//       Icon(Icons.reviews_outlined, size: 38, color: Colors.grey[300]),
//       const SizedBox(height: 10),
//       Text('No reviews yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[500])),
//       const SizedBox(height: 4),
//       Text('Be the first to hire and leave a review!',
//         style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
//     ])),
//   );

//   Widget _stat(String e, String v, String l) => Expanded(child: Column(children: [
//     Text(e, style: const TextStyle(fontSize: 18)),
//     const SizedBox(height: 2),
//     Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
//     Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//   ]));

//   Widget _vDiv() => Container(width: 1, height: 40, color: Colors.grey.shade200);

//   Widget _sec(String t) => Text(t, style: const TextStyle(
//     fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.black87));
// }

// // ── Review Card ───────────────────────────────────────────────
// class _ReviewCard extends StatelessWidget {
//   final Map<String, dynamic> r;
//   const _ReviewCard(this.r);

//   @override
//   Widget build(BuildContext context) {
//     final name     = r['buyerName']  as String? ?? 'Client';  // saved by RatingFeedbackSection
//     final comment  = r['comment']    as String? ?? '';         // 'comment' field
//     final stars    = (r['stars']     ?? 5) as int;             // 'stars' field
//     final jobTitle = r['jobTitle']   as String? ?? '';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade100,
//             child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
//               style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14))),
//           const SizedBox(width: 10),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
//             if (jobTitle.isNotEmpty) Text(jobTitle,
//               style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
//           ])),
//           Row(mainAxisSize: MainAxisSize.min,
//             children: List.generate(5, (i) => Icon(
//               i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
//               size: 14, color: Colors.amber[600]))),
//         ]),
//         if (comment.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           Text(comment, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
//         ],
//       ]),
//     );
//   }
// }




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_session.dart';
import 'ChatDetailScreen.dart';
import 'tts_translation_service.dart';

class SellerDirectoryScreen extends StatefulWidget {
  final String? phoneUID;
  final String  buyerCity;
  const SellerDirectoryScreen({super.key, this.phoneUID, this.buyerCity = ''});

  @override
  State<SellerDirectoryScreen> createState() => _SellerDirectoryScreenState();
}

class _SellerDirectoryScreenState extends State<SellerDirectoryScreen> {
  static const _teal = Color(0xFF00695C);

  StreamSubscription<QuerySnapshot>? _sellerSub;
  List<Map<String, dynamic>> _mergedSellers = [];
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _loading = true;

  final _searchCtrl = TextEditingController();
  String _query    = '';
  bool   _cityOnly = false;
  String _sortBy   = 'rating';

  @override
  void initState() {
    super.initState();
    _cityOnly = widget.buyerCity.isNotEmpty;
    _searchCtrl.addListener(() =>
        setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
    _listenToSellers();
  }

  @override
  void dispose() {
    _sellerSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _listenToSellers() {
    _sellerSub = FirebaseFirestore.instance
        .collection('sellers')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snap) async {
      final sellerDocs = snap.docs;
      final uids = sellerDocs.map((d) => d.id).toList();

      final missing = uids.where((id) => !_userCache.containsKey(id)).toList();
      if (missing.isNotEmpty) await _batchFetchUsers(missing);

      final myUid = (widget.phoneUID ?? UserSession().phoneUID ?? '').trim();

      final merged = sellerDocs
          // ── exclude the logged-in user from their own directory view ──
          .where((doc) => doc.id.trim() != myUid)
          .map((doc) {
        final sd        = doc.data();
        final ud        = _userCache[doc.id] ?? {};
        final firstName = (ud['firstName'] as String? ?? sd['firstName'] as String? ?? '').trim();
        final lastName  = (ud['lastName']  as String? ?? sd['lastName']  as String? ?? '').trim();
        return {
          ...sd,
          '_uid':           doc.id,
          'firstName':      firstName,
          'lastName':       lastName,
          'profileImage':   (ud['profileImage'] as String? ?? '').trim(),
          'city':           (ud['city']         as String? ?? '').trim(),
          'Rating':         sd['Rating']         ?? 0.0,
          'Jobs_Completed': sd['Jobs_Completed'] ?? 0,
          'skills':         sd['skills']         ?? [],
          'bio':            ud['bio'] ?? sd['bio'] ?? '',
        };
      }).toList();

      if (mounted) setState(() { _mergedSellers = merged; _loading = false; });
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _batchFetchUsers(List<String> uids) async {
    const chunk = 30;
    for (int i = 0; i < uids.length; i += chunk) {
      final batch = uids.skip(i).take(chunk).toList();
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          _userCache[doc.id] = doc.data();
        }
      } catch (_) {}
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = List<Map<String, dynamic>>.from(_mergedSellers);

    if (_cityOnly && widget.buyerCity.isNotEmpty) {
      final bC = widget.buyerCity.trim().toLowerCase();
      list = list.where((s) =>
        (s['city'] as String? ?? '').trim().toLowerCase() == bC).toList();
    }

    if (_query.isNotEmpty) {
      list = list.where((s) {
        final first  = (s['firstName'] as String? ?? '').toLowerCase();
        final last   = (s['lastName']  as String? ?? '').toLowerCase();
        final city   = (s['city']      as String? ?? '').toLowerCase();
        final skills = List<String>.from(s['skills'] ?? []).join(' ').toLowerCase();
        return first.contains(_query) || last.contains(_query) ||
            city.contains(_query) || skills.contains(_query);
      }).toList();
    }

    list.sort((a, b) {
      if (_sortBy == 'jobs') {
        final aj = (a['Jobs_Completed'] ?? 0) as int;
        final bj = (b['Jobs_Completed'] ?? 0) as int;
        return bj.compareTo(aj);
      }
      final ar = (a['Rating'] ?? 0.0).toDouble();
      final br = (b['Rating'] ?? 0.0).toDouble();
      return br.compareTo(ar);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: Column(children: [
        _buildHeader(context),
        _buildFilterRow(),
        if (_loading)
          const Expanded(child: Center(
            child: CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2)))
        else
          Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildHeader(BuildContext ctx) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF00695C), Color(0xFF004D40)]),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      boxShadow: [BoxShadow(color: Color(0x44004D40), blurRadius: 16, offset: Offset(0, 6))]),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => Navigator.pop(ctx),
            child: Container(padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
          const Spacer(),
          const GlobalLanguageButton(color: Colors.white),
        ]),
        const SizedBox(height: 12),
        const Text('Find Workers', style: TextStyle(color: Colors.white,
          fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('${_filtered.length} workers available',
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name, skill, city…',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00695C)),
              suffixIcon: _query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey), onPressed: _searchCtrl.clear)
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ]),
    )),
  );

  Widget _buildFilterRow() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    child: Row(children: [
      if (widget.buyerCity.isNotEmpty) ...[
        _pill('All', !_cityOnly, () => setState(() => _cityOnly = false)),
        const SizedBox(width: 8),
        _pill('📍 ${widget.buyerCity}', _cityOnly, () => setState(() => _cityOnly = true)),
      ],
      const Spacer(),
      GestureDetector(
        onTap: () => setState(() => _sortBy = _sortBy == 'rating' ? 'jobs' : 'rating'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: _teal.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _teal.withOpacity(0.2))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sort_rounded, size: 14, color: _teal),
            const SizedBox(width: 5),
            Text(_sortBy == 'rating' ? 'By Rating' : 'By Jobs',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _teal)),
          ]),
        ),
      ),
    ]),
  );

  Widget _pill(String l, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _teal : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _teal : Colors.grey.shade200)),
      child: Text(l, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
        color: active ? Colors.white : Colors.grey[700])),
    ),
  );

  Widget _buildList() {
    final sellers = _filtered;
    if (sellers.isEmpty) return _emptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
      itemCount: sellers.length,
      itemBuilder: (ctx, i) => _SellerCard(
        seller: sellers[i],
        buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
        buyerCity: widget.buyerCity,
      ),
    );
  }

  Widget _emptyState() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey[300]),
    const SizedBox(height: 14),
    Text(_cityOnly ? 'No workers in ${widget.buyerCity} yet' : 'No workers found',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[600])),
    const SizedBox(height: 6),
    Text(_cityOnly ? 'Try viewing all workers.' : 'Try a different search.',
      style: TextStyle(fontSize: 13, color: Colors.grey[400])),
  ]));
}

// ═══════════════════════════════════════════════════════════════
//  SELLER CARD
// ═══════════════════════════════════════════════════════════════
class _SellerCard extends StatelessWidget {
  final Map<String, dynamic> seller;
  final String buyerUid, buyerCity;
  static const _teal = Color(0xFF00695C);

  const _SellerCard({required this.seller, required this.buyerUid, required this.buyerCity});

  @override
  Widget build(BuildContext context) {
    final uid      = seller['_uid']          as String? ?? '';
    final first    = seller['firstName']     as String? ?? '';
    final last     = seller['lastName']      as String? ?? '';
    final name     = '$first $last'.trim();
    final img      = seller['profileImage']  as String? ?? '';
    final city     = seller['city']          as String? ?? '';
    final rating   = (seller['Rating']       ?? 0.0).toDouble();
    final jobs     = (seller['Jobs_Completed'] ?? 0) as int;
    final skills   = List<String>.from(seller['skills'] ?? []);
    final bio      = seller['bio'] as String? ?? '';
    final sameCity = city.trim().toLowerCase() == buyerCity.trim().toLowerCase() && buyerCity.isNotEmpty;

    return GestureDetector(
      onTap: () => _showProfile(context, uid),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: sameCity ? Border.all(color: _teal.withOpacity(0.3), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              CircleAvatar(radius: 30, backgroundColor: _teal.withOpacity(0.1),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'W',
                        style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 24))
                    : null),
              if (sameCity) Positioned(bottom: 0, right: 0, child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 1.5)]),
                child: const Icon(Icons.location_on, size: 10, color: Colors.white))),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(name.isEmpty ? 'Worker' : name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87))),
                if (sameCity) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(14)),
                  child: const Text('Near You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
                const SizedBox(width: 3),
                Text(rating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                Text('  ·  $jobs jobs', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
              if (city.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(city, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ]),
              ],
            ])),
          ]),

          if (bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(bio, style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],

          if (skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 5, children: skills.take(4).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _teal.withOpacity(0.15))),
              child: Text(s, style: const TextStyle(fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
            )).toList()),
            if (skills.length > 4) Padding(padding: const EdgeInsets.only(top: 4),
              child: Text('+${skills.length - 4} more',
                style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic))),
          ],

          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _showProfile(context, uid),
              icon: const Icon(Icons.person_outline_rounded, size: 16),
              label: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: _teal, side: const BorderSide(color: _teal),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _openChat(context, uid, name, img),
              icon: const Icon(Icons.message_outlined, size: 16),
              label: const Text('Contact', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
          ]),
        ])),
      ),
    );
  }

  void _showProfile(BuildContext ctx, String uid) => showModalBottomSheet(
    context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => SellerProfileSheet(
      sellerId: uid, preloadedSellerDoc: seller,
      buyerUid: buyerUid, buyerCity: buyerCity),
  );

  Future<void> _openChat(BuildContext ctx, String uid, String name, String img) async {
    if (buyerUid.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    final db     = FirebaseFirestore.instance;
    final phones = [buyerUid, uid]..sort();
    final convId = '${phones[0]}_${phones[1]}';
    if (!(await db.collection('conversations').doc(convId).get()).exists) {
      final bd        = (await db.collection('users').doc(buyerUid).get()).data() ?? {};
      final buyerName = '${bd['firstName'] ?? ''} ${bd['lastName'] ?? ''}'.trim();
      await db.collection('conversations').doc(convId).set({
        'participantIds': [buyerUid, uid],
        'participantNames': {buyerUid: buyerName, uid: name},
        'participantRoles': {buyerUid: 'buyer', uid: 'seller'},
        'participantProfileImages': {buyerUid: bd['profileImage'] ?? '', uid: img},
        'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
        'unreadCounts': {buyerUid: 0, uid: 0},
      });
    }
    if (ctx.mounted) {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => ChatDetailScreen(
        convId: convId, myUid: buyerUid, otherUid: uid,
        otherName: name, otherImage: img, otherRole: 'seller')));
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  SELLER PROFILE SHEET
// ═══════════════════════════════════════════════════════════════
class SellerProfileSheet extends StatefulWidget {
  final String sellerId, buyerUid, buyerCity;
  final Map<String, dynamic>? preloadedSellerDoc;

  const SellerProfileSheet({
    super.key,
    required this.sellerId,
    required this.buyerUid,
    required this.buyerCity,
    this.preloadedSellerDoc,
  });

  @override
  State<SellerProfileSheet> createState() => _SellerProfileSheetState();
}

class _SellerProfileSheetState extends State<SellerProfileSheet> {
  static const _teal = Color(0xFF00695C);

  Map<String, dynamic> _sellerData = {};
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingSeller  = true;
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadSeller();
    _loadReviews();
  }

  Future<void> _loadSeller() async {
    final pre = widget.preloadedSellerDoc ?? {};
    if (pre.containsKey('profileImage')) {
      setState(() { _sellerData = pre; _loadingSeller = false; });
      return;
    }
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('sellers').doc(widget.sellerId).get(),
        FirebaseFirestore.instance.collection('users').doc(widget.sellerId).get(),
      ]);
      final sd = results[0].data() ?? {};
      final ud = results[1].data() ?? {};
      final merged = {
        ...sd,
        'profileImage': (ud['profileImage'] as String? ?? '').trim(),
        'city':         (ud['city']         as String? ?? '').trim(),
        'firstName':    (ud['firstName'] as String? ?? sd['firstName'] as String? ?? '').trim(),
        'lastName':     (ud['lastName']  as String? ?? sd['lastName']  as String? ?? '').trim(),
        'bio':          ud['bio'] ?? sd['bio'] ?? '',
      };
      if (mounted) setState(() { _sellerData = merged; _loadingSeller = false; });
    } catch (_) {
      if (mounted) setState(() { _sellerData = pre; _loadingSeller = false; });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sellers').doc(widget.sellerId)
          .collection('ratings').limit(20).get();
      final reviews = snap.docs.map((d) => d.data()).toList();
      reviews.sort((a, b) {
        final at = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bt = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bt.compareTo(at);
      });
      if (mounted) setState(() { _reviews = reviews; _loadingReviews = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _openChat() async {
    final name = '${_sellerData['firstName'] ?? ''} ${_sellerData['lastName'] ?? ''}'.trim();
    final img  = _sellerData['profileImage'] as String? ?? '';
    if (widget.buyerUid.isEmpty) return;
    final db     = FirebaseFirestore.instance;
    final phones = [widget.buyerUid, widget.sellerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';
    if (!(await db.collection('conversations').doc(convId).get()).exists) {
      final bd = (await db.collection('users').doc(widget.buyerUid).get()).data() ?? {};
      final buyerName = '${bd['firstName'] ?? ''} ${bd['lastName'] ?? ''}'.trim();
      await db.collection('conversations').doc(convId).set({
        'participantIds': [widget.buyerUid, widget.sellerId],
        'participantNames': {widget.buyerUid: buyerName, widget.sellerId: name},
        'participantRoles': {widget.buyerUid: 'buyer', widget.sellerId: 'seller'},
        'participantProfileImages': {widget.buyerUid: bd['profileImage'] ?? '', widget.sellerId: img},
        'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
        'unreadCounts': {widget.buyerUid: 0, widget.sellerId: 0},
      });
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
        convId: convId, myUid: widget.buyerUid, otherUid: widget.sellerId,
        otherName: name, otherImage: img, otherRole: 'seller')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name   = '${_sellerData['firstName'] ?? ''} ${_sellerData['lastName'] ?? ''}'.trim();
    final img    = _sellerData['profileImage'] as String? ?? '';
    final city   = _sellerData['city']         as String? ?? '';
    final rating = (_sellerData['Rating']      ?? 0.0).toDouble();
    final jobs   = (_sellerData['Jobs_Completed'] ?? 0) as int;
    final skills = List<String>.from(_sellerData['skills'] ?? []);
    final bio    = _sellerData['bio'] as String? ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        Container(width: 44, height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Expanded(child: _loadingSeller
          ? const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
          : ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
            Center(child: Stack(alignment: Alignment.bottomRight, children: [
              CircleAvatar(radius: 50, backgroundColor: _teal.withOpacity(0.1),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'W',
                      style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 38))
                  : null),
              Container(width: 26, height: 26,
                decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2)]),
                child: const Icon(Icons.build_rounded, size: 14, color: Colors.white)),
            ])),
            const SizedBox(height: 12),
            Center(child: Text(name.isEmpty ? 'Worker' : name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
              textAlign: TextAlign.center)),
            if (city.isNotEmpty) ...[
              const SizedBox(height: 5),
              Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 3),
                Text(city, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ])),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.05), borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _teal.withOpacity(0.12))),
              child: Row(children: [
                _stat('⭐', rating.toStringAsFixed(1), 'Rating'),
                _vDiv(),
                _stat('✅', '$jobs', 'Jobs Done'),
                _vDiv(),
                _stat('💬', '${_reviews.length}', 'Reviews'),
              ]),
            ),
            const SizedBox(height: 20),
            if (bio.isNotEmpty) ...[
              _sec('About'),
              const SizedBox(height: 8),
              Text(bio, style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 20),
            ],
            if (skills.isNotEmpty) ...[
              _sec('Skills & Services'),
              const SizedBox(height: 10),
              Wrap(spacing: 7, runSpacing: 7, children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _teal.withOpacity(0.2))),
                child: Text(s, style: const TextStyle(fontSize: 12.5, color: _teal, fontWeight: FontWeight.w600)),
              )).toList()),
              const SizedBox(height: 20),
            ],
            _sec('Buyer Reviews (${_reviews.length})'),
            const SizedBox(height: 10),
            if (_loadingReviews)
              const Center(child: Padding(padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: _teal, strokeWidth: 2)))
            else if (_reviews.isEmpty)
              _noReviews()
            else
              ..._reviews.map((r) => _ReviewCard(r)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.message_outlined, size: 18),
                label: const Text('Message', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: OutlinedButton.styleFrom(foregroundColor: _teal, side: const BorderSide(color: _teal, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Hire Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _noReviews() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200)),
    child: Center(child: Column(children: [
      Icon(Icons.reviews_outlined, size: 38, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text('No reviews yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[500])),
      const SizedBox(height: 4),
      Text('Be the first to hire and leave a review!',
        style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
    ])),
  );

  Widget _stat(String e, String v, String l) => Expanded(child: Column(children: [
    Text(e, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
  ]));

  Widget _vDiv() => Container(width: 1, height: 40, color: Colors.grey.shade200);
  Widget _sec(String t) => Text(t, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.black87));
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> r;
  const _ReviewCard(this.r);

  @override
  Widget build(BuildContext context) {
    final name     = r['buyerName']  as String? ?? 'Client';
    final comment  = r['comment']    as String? ?? '';
    final stars    = (r['stars']     ?? 5) as int;
    final jobTitle = r['jobTitle']   as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade100,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
            if (jobTitle.isNotEmpty) Text(jobTitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 14, color: Colors.amber[600]))),
        ]),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(comment, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
        ],
      ]),
    );
  }
}