// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';
// import 'notification_service.dart';
// import 'tts_translation_service.dart';
// import 'ChatDetailScreen.dart';

// const int    kSellerFreeOrderLimit = 3;
// const double kSellerMinBalance     = 500.0;

// // ═══════════════════════════════════════════════════════════════
// class SellerOrdersPage extends StatefulWidget {
//   final String? phoneUID;
//   const SellerOrdersPage({super.key, this.phoneUID});
//   @override State<SellerOrdersPage> createState() => _SellerOrdersPageState();
// }

// class _SellerOrdersPageState extends State<SellerOrdersPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late String _uid;
//   String _sellerCity = '';
//   StreamSubscription? _balanceSub;
//   bool _bannerVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _uid = _resolveUid();
//     TtsTranslationService().init();
//     _loadSellerCity();
//     // ✅ Setup real-time balance listener AFTER first frame so ScaffoldMessenger is ready
//     WidgetsBinding.instance.addPostFrameCallback((_) => _setupBalanceListener());
//   }

//   String _resolveUid() {
//     final raw = widget.phoneUID ?? UserSession().phoneUID ?? UserSession().phone ?? UserSession().uid ?? '';
//     return _normalizePhone(raw);
//   }

//   String _normalizePhone(String raw) {
//     if (raw.isEmpty) return '';
//     final t = raw.trim();
//     if (t.startsWith('+')) return t;
//     if (RegExp(r'^\d+$').hasMatch(t)) return '+$t';
//     return t;
//   }

//   Future<void> _loadSellerCity() async {
//     if (_uid.isEmpty) return;
//     try {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
//       final city = (doc.data() ?? {})['city'] as String? ?? '';
//       if (mounted) setState(() => _sellerCity = city.trim());
//     } catch (_) {}
//   }

//   // ✅ Real-time balance listener — auto-shows AND auto-dismisses banner
//   void _setupBalanceListener() {
//     if (_uid.isEmpty) return;
//     _balanceSub = FirebaseFirestore.instance
//         .collection('sellers').doc(_uid).snapshots()
//         .listen((snap) {
//       if (!mounted || !snap.exists) return;
//       final data = snap.data()!;
//       final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//       final balance       = (data['Available_Balance'] ?? 0).toDouble();
//       final isLow         = jobsCompleted >= kSellerFreeOrderLimit && balance < 100;

//       if (isLow && !_bannerVisible) {
//         _bannerVisible = true;
//         ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
//           backgroundColor: Colors.red.shade50,
//           content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
//               const SizedBox(width: 8),
//               Text('Low Balance — Orders Paused',
//                   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 13)),
//             ]),
//             const SizedBox(height: 4),
//             Text('Free orders used. Balance: PKR ${balance.toStringAsFixed(0)}. Add funds to receive jobs.',
//                 style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
//           ]),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _bannerVisible = false;
//                 ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
//               },
//               child: const Text('DISMISS'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _bannerVisible = false;
//                 ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
//                 // TODO: navigate to deposit/wallet page
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
//               child: const Text('ADD FUNDS'),
//             ),
//           ],
//         ));
//       } else if (!isLow && _bannerVisible) {
//         // ✅ Auto-dismiss when balance is topped up
//         _bannerVisible = false;
//         ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _balanceSub?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_uid.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Find Jobs'), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
//         body: const Center(child: Text('Could not identify user. Please log in again.')),
//       );
//     }
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, elevation: 1, automaticallyImplyLeading: false,
//         title: const Text('Find Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
//         actions: [
//           const GlobalLanguageButton(color: Colors.white),
//           NotificationBell(uid: _uid, color: Colors.white, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage(uid: _uid)))),
//         ],
//         bottom: TabBar(
//           controller: _tabController, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white60, isScrollable: true,
//           tabs: const [Tab(text: 'Browse Jobs'), Tab(text: 'My Bids'), Tab(text: 'Active'), Tab(text: 'History')],
//         ),
//       ),
//       body: Column(children: [
//         _SellerBalanceBar(sellerUid: _uid),
//         Expanded(child: TabBarView(controller: _tabController, children: [
//           _OpenJobsList(sellerUid: _uid, sellerCity: _sellerCity),
//           _MyBidsList(sellerUid: _uid),
//           _ActiveJobsList(sellerUid: _uid),
//           _SellerHistoryTab(sellerUid: _uid),
//         ])),
//       ]),
//     );
//   }
// }

// // ── Balance Bar (real-time stream) ────────────────────────────
// class _SellerBalanceBar extends StatelessWidget {
//   final String sellerUid;
//   const _SellerBalanceBar({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).snapshots(),
//       builder: (context, snap) {
//         if (!snap.hasData) return const SizedBox();
//         final data          = snap.data?.data() as Map<String,dynamic>? ?? {};
//         final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//         final balance       = (data['Available_Balance'] ?? 0).toDouble();
//         final reserved      = (data['Reserved_Commission'] ?? 0).toDouble();
//         final earning       = (data['Earning'] ?? 0).toDouble();
//         final isFree        = jobsCompleted < kSellerFreeOrderLimit;
//         final freeLeft      = isFree ? kSellerFreeOrderLimit - jobsCompleted : 0;
//         final isLow         = !isFree && balance < 100;
//         final freeBalance   = balance - reserved;

//         Color barColor; Widget content;
//         if (isFree) {
//           barColor = Colors.green.shade700;
//           content = Row(children: [
//             const Icon(Icons.card_giftcard, size: 14, color: Colors.white70), const SizedBox(width: 8),
//             Text('$freeLeft free order(s) remaining', style: const TextStyle(color: Colors.white70, fontSize: 12)),
//             const Spacer(),
//             Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//               Text('Balance: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
//               Text('Earned: PKR ${earning.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white60, fontSize: 10)),
//             ]),
//           ]);
//         } else if (isLow) {
//           barColor = Colors.red.shade700;
//           content = Row(children: [
//             const Icon(Icons.warning_amber, size: 14, color: Colors.white), const SizedBox(width: 8),
//             Expanded(child: Text('Low balance (PKR ${balance.toStringAsFixed(0)}) — Add funds to receive orders', style: const TextStyle(color: Colors.white, fontSize: 12))),
//           ]);
//         } else {
//           barColor = Colors.green.shade800;
//           content = Row(children: [
//             const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white70), const SizedBox(width: 8),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text('Wallet: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
//               if (reserved > 0) Text('Reserved: PKR ${reserved.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
//               Text('Free: PKR ${freeBalance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white60, fontSize: 10)),
//             ]),
//             const Spacer(),
//             Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//               Text('Net Earned: PKR ${earning.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
//               StreamBuilder<DocumentSnapshot>(
//                 stream: FirebaseFirestore.instance.collection('config').doc('commission').snapshots(),
//                 builder: (ctx, cfgSnap) {
//                   final rate = cfgSnap.hasData && cfgSnap.data!.exists
//                       ? ((cfgSnap.data!.data() as Map)['rate'] ?? 0.10).toDouble()
//                       : 0.10;
//                   return Text('${(rate*100).toStringAsFixed(0)}% commission', style: const TextStyle(color: Colors.white54, fontSize: 10));
//                 },
//               ),
//             ]),
//           ]);
//         }
//         return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: barColor, child: content);
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  BROWSE OPEN JOBS
// // ═══════════════════════════════════════════════════════════════
// class _OpenJobsList extends StatefulWidget {
//   final String sellerUid, sellerCity;
//   const _OpenJobsList({required this.sellerUid, required this.sellerCity});
//   @override State<_OpenJobsList> createState() => _OpenJobsListState();
// }
// class _OpenJobsListState extends State<_OpenJobsList> {
//   String _searchQuery = ''; bool _showAllCities = false;
//   final _searchController = TextEditingController();
//   @override void dispose() { _searchController.dispose(); super.dispose(); }

//   @override Widget build(BuildContext context) {
//     return Column(children: [
//       Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
//         TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search by title or skill...',
//             prefixIcon: const Icon(Icons.search, color: Colors.green),
//             suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
//             filled: true, fillColor: Colors.grey.shade100,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           ),
//           onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
//         ),
//         if (widget.sellerCity.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           Row(children: [
//             Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.my_location, size: 13, color: Colors.green.shade700), const SizedBox(width: 4), Text('Your city: ${widget.sellerCity}', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600))])),
//             const Spacer(),
//             GestureDetector(
//               onTap: () => setState(() => _showAllCities = !_showAllCities),
//               child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _showAllCities ? Colors.blue.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: _showAllCities ? Colors.blue.shade300 : Colors.grey.shade300)),
//                 child: Text(_showAllCities ? '🌍 All Cities' : '📍 My City First', style: TextStyle(fontSize: 11, color: _showAllCities ? Colors.blue.shade700 : Colors.grey[700], fontWeight: FontWeight.bold))),
//             ),
//           ]),
//         ],
//       ])),
//       Expanded(child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('jobs').where('status', isEqualTo: 'open').snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//           if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.work_outline, message: 'No open jobs right now', subtitle: 'Check back soon');
//           var allDocs = snap.data!.docs.where((d) {
//             final data = d.data() as Map<String,dynamic>;
//             if (data['postedBy'] == widget.sellerUid) return false;
//             if (_searchQuery.isNotEmpty) {
//               final title  = (data['title']??'').toString().toLowerCase();
//               final skills = List<String>.from(data['skills']??[]).join(' ').toLowerCase();
//               return title.contains(_searchQuery) || skills.contains(_searchQuery);
//             }
//             return true;
//           }).toList();
//           if (widget.sellerCity.isNotEmpty && !_showAllCities) {
//             final myCity = widget.sellerCity.toLowerCase().trim();
//             final same   = allDocs.where((d) => ((d.data() as Map)['city']as String?  ??'').toLowerCase().trim() == myCity).toList();
//             final other  = allDocs.where((d) => ((d.data() as Map)['city']as String?  ??'').toLowerCase().trim() != myCity).toList();
//             for (final g in [same, other]) { g.sort((a,b){ final aT=(a.data()as Map)['postedAt']as Timestamp?; final bT=(b.data()as Map)['postedAt']as Timestamp?; if(aT==null||bT==null)return 0; return bT.compareTo(aT); }); }
//             allDocs = [...same, ...other];
//           } else {
//             allDocs.sort((a,b){ final aT=(a.data()as Map)['postedAt']as Timestamp?; final bT=(b.data()as Map)['postedAt']as Timestamp?; if(aT==null||bT==null)return 0; return bT.compareTo(aT); });
//           }
//           if (allDocs.isEmpty) return const _SellerEmptyState(icon: Icons.search_off, message: 'No jobs match your search', subtitle: 'Try different keywords');
//           return ListView.builder(padding: const EdgeInsets.all(12), itemCount: allDocs.length, itemBuilder: (ctx, i) {
//             final data = allDocs[i].data() as Map<String,dynamic>;
//             final isSameCity = widget.sellerCity.isNotEmpty && (data['city']as String?  ??'').toLowerCase().trim() == widget.sellerCity.toLowerCase().trim();
//             return _OpenJobCard(jobId: allDocs[i].id, jobData: data, sellerUid: widget.sellerUid, sellerCity: widget.sellerCity, isSameCity: isSameCity);
//           });
//         },
//       )),
//     ]);
//   }
// }

// class _OpenJobCard extends StatelessWidget {
//   final String jobId, sellerUid, sellerCity; final Map<String,dynamic> jobData; final bool isSameCity;
//   const _OpenJobCard({required this.jobId, required this.jobData, required this.sellerUid, required this.sellerCity, this.isSameCity = false});

//   @override Widget build(BuildContext context) {
//     final title       = jobData['title']??'Untitled';
//     final budget      = (jobData['budget']??0).toDouble();
//     final location    = jobData['location']??'';
//     final timing      = jobData['timing']??'';
//     final skills      = List<String>.from(jobData['skills']??[]);
//     final posterName  = jobData['posterName']??'Unknown Client';
//     final bidsCount   = jobData['bidsCount']??0;
//     final isInsured   = (jobData['orderType']??'simple') == 'insured';
//     final postedAt    = jobData['postedAt'] as Timestamp?;
//     final description = jobData['description']??'';
//     final jobCity     = jobData['city']as String?  ??'';
//     final currency    = jobData['budgetCurrency']as String?  ??'PKR';

//     return GestureDetector(
//       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))),
//       child: Container(
//         width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
//           border: isSameCity ? Border.all(color: Colors.green.shade400, width: 2) : isInsured ? Border.all(color: Colors.blue.shade200, width: 1.5) : null,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,3))]),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isSameCity ? Colors.green.shade50 : isInsured ? Colors.blue.shade50 : Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
//             child: Row(children: [
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [
//                   Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   if (isSameCity) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.near_me, size: 10, color: Colors.white), SizedBox(width: 3), Text('NEARBY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))])),
//                   if (isInsured) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 10, color: Colors.white), SizedBox(width: 3), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))]))],
//                 ]),
//                 const SizedBox(height: 3),
//                 Row(children: [
//                   Icon(Icons.person_outline, size: 12, color: Colors.grey[500]), const SizedBox(width: 3),
//                   Text('by $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                   if (jobCity.isNotEmpty) ...[const SizedBox(width: 8), Icon(Icons.location_city, size: 12, color: isSameCity ? Colors.green.shade600 : Colors.grey[400]), const SizedBox(width: 3), Text(jobCity, style: TextStyle(fontSize: 12, fontWeight: isSameCity ? FontWeight.bold : FontWeight.normal, color: isSameCity ? Colors.green.shade700 : Colors.grey[500])),
//                     if (!isSameCity && sellerCity.isNotEmpty) Text(' (you: $sellerCity)', style: TextStyle(fontSize: 10, color: Colors.grey[400]))],
//                 ]),
//               ])),
//               const SizedBox(width: 8),
//               Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                 Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700)),
//                 if (currency != 'PKR') Text('($currency)', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//                 Text('Max Budget', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//               ]),
//             ])),
//           Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [Icon(Icons.location_on, size: 13, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(location.isNotEmpty ? location : 'Location not specified', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)), Icon(Icons.schedule, size: 13, color: Colors.grey[500]), const SizedBox(width: 4), Text(timing, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
//             if (description.isNotEmpty) ...[const SizedBox(height: 6), TranslatedText(text: description, contentId: 'open_$jobId', style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4), maxLines: 2, showListenButton: false)],
//             const SizedBox(height: 8),
//             Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)))).toList()),
//             const SizedBox(height: 8),
//             JobListenRow(title: title, description: description, location: location, timing: timing, jobId: jobId),
//             const SizedBox(height: 10),
//             Row(children: [
//               Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: bidsCount > 0 ? Colors.orange.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: bidsCount > 0 ? Colors.orange.shade300 : Colors.grey.shade300)),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.gavel, size: 13, color: bidsCount > 0 ? Colors.orange : Colors.grey), const SizedBox(width: 5), Text('$bidsCount ${bidsCount==1?'Bid':'Bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: bidsCount > 0 ? Colors.orange : Colors.grey, fontSize: 12))])),
//               if (postedAt != null) ...[const SizedBox(width: 8), Text(DateFormat('dd MMM').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
//               const Spacer(),
//               Flexible(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))), icon: const Icon(Icons.visibility, size: 15), label: const Text('View & Bid'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//             ]),
//           ])),
//         ]),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  JOB DETAIL SCREEN
// // ═══════════════════════════════════════════════════════════════
// class _JobDetailScreen extends StatefulWidget {
//   final String jobId, sellerUid; final Map<String,dynamic> jobData;
//   const _JobDetailScreen({required this.jobId, required this.jobData, required this.sellerUid});
//   @override State<_JobDetailScreen> createState() => _JobDetailScreenState();
// }
// class _JobDetailScreenState extends State<_JobDetailScreen> {
//   bool _alreadyBid = false, _checkingBid = true;
//   Map<String,dynamic>? _sellerInfo;

//   @override void initState() { super.initState(); _loadData(); }

//   Future<void> _loadData() async {
//     try {
//       final bidDoc    = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid).get();
//       final sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).get();
//       final data      = sellerDoc.data()??{};
//       final jobsCompleted  = (data['Jobs_Completed']??0) as int;
//       final balance        = (data['Available_Balance']??0).toDouble();
//       final reserved       = (data['Reserved_Commission']??0).toDouble();
//       final freeBalance    = balance - reserved;
//       final isFree         = jobsCompleted < kSellerFreeOrderLimit;

//       // ✅ Read dynamic commission rate
//       double rate = 0.10;
//       try {
//         final cfgDoc = await FirebaseFirestore.instance.collection('config').doc('commission').get();
//         if (cfgDoc.exists) rate = (cfgDoc.data()?['rate']??0.10).toDouble();
//       } catch (_) {}

//       final budget             = (widget.jobData['budget']??0).toDouble();
//       final commissionRequired = isFree ? 0.0 : budget * rate;
//       final isEligible         = isFree || freeBalance >= commissionRequired;

//       if (mounted) setState(() {
//         _alreadyBid = bidDoc.exists;
//         _sellerInfo = {
//           'isFree': isFree, 'freeLeft': isFree ? kSellerFreeOrderLimit - jobsCompleted : 0,
//           'balance': balance, 'reserved': reserved, 'freeBalance': freeBalance,
//           'commissionRequired': commissionRequired, 'rate': rate,
//           'isEligible': isEligible,
//           'reason': isEligible ? null : 'Need PKR ${commissionRequired.toStringAsFixed(0)} free balance. Currently PKR ${freeBalance.toStringAsFixed(0)}.',
//         };
//         _checkingBid = false;
//       });
//     } catch (e) { if (mounted) setState(() => _checkingBid = false); }
//   }

//   @override Widget build(BuildContext context) {
//     final title       = widget.jobData['title']??'Job Detail';
//     final budget      = (widget.jobData['budget']??0).toDouble();
//     final location    = widget.jobData['location']??'';
//     final timing      = widget.jobData['timing']??'';
//     final description = widget.jobData['description']??'';
//     final skills      = List<String>.from(widget.jobData['skills']??[]);
//     final posterName  = widget.jobData['posterName']??'Client';
//     final posterImage = widget.jobData['posterImage'] as String?;
//     final bidsCount   = widget.jobData['bidsCount']??0;
//     final isInsured   = (widget.jobData['orderType']??'simple') == 'insured';
//     final postedAt    = widget.jobData['postedAt'] as Timestamp?;
//     final city        = widget.jobData['city']as String?  ??'';
//     final currency    = widget.jobData['budgetCurrency']as String?  ??'PKR';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, actions: [const GlobalLanguageButton(color: Colors.white)]),
//       body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
//             if (isInsured) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.white), SizedBox(width: 4), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]))],
//           ]),
//           const SizedBox(height: 8),
//           JobListenRow(title: title, description: description, location: location, timing: timing, jobId: widget.jobId),
//           const SizedBox(height: 12),
//           Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
//             child: Row(children: [
//               Icon(Icons.payments_outlined, color: Colors.green.shade700, size: 20), const SizedBox(width: 10),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//                 Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
//                 if (currency != 'PKR') Text('(originally $currency)', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//               ]),
//               const Spacer(),
//               Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade300)),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.gavel, size: 13, color: Colors.orange.shade700), const SizedBox(width: 5), Text('$bidsCount ${bidsCount==1?'bid':'bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700, fontSize: 12))])),
//             ])),
//           const SizedBox(height: 14),
//           Row(children: [
//             CircleAvatar(radius: 18, backgroundColor: Colors.teal.shade100, backgroundImage: posterImage!=null&&posterImage.isNotEmpty?NetworkImage(posterImage):null, child: posterImage==null||posterImage.isEmpty?Text(posterName.isNotEmpty?posterName[0].toUpperCase():'?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)):null),
//             const SizedBox(width: 10),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Posted by', style: TextStyle(fontSize: 11, color: Colors.grey)), Text(posterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]),
//             if (postedAt != null) ...[const Spacer(), Text(DateFormat('dd MMM yyyy').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
//           ]),
//           if (city.isNotEmpty) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_city, size: 13, color: Colors.teal.shade700), const SizedBox(width: 4), Text(city, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600))]))],
//           const Divider(height: 20),
//           if (location.isNotEmpty) ...[_ir(Icons.location_on, 'Address', location), const SizedBox(height: 8)],
//           if (timing.isNotEmpty) ...[_ir(Icons.schedule, 'Timing', timing), const SizedBox(height: 12)],
//           if (description.isNotEmpty) ...[
//             const Text('Job Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
//             Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
//               child: TranslatedText(text: description, contentId: 'detail_${widget.jobId}', style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5), showListenButton: false)),
//             const SizedBox(height: 14),
//           ],
//           if (skills.isNotEmpty) ...[
//             const Text('Skills Required', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
//             Wrap(spacing: 8, runSpacing: 6, children: skills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w500)))).toList()),
//           ],
//         ]))),
//         const SizedBox(height: 16),
//         if (isInsured) ...[
//           Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 18), const SizedBox(width: 8), Text('Insured Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14))]),
//               const SizedBox(height: 8),
//               Text('Payment held by company. Admin releases after 3-day claim window.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
//             ])),
//           const SizedBox(height: 16),
//         ],
//         if (_sellerInfo != null) ...[_buildEligibilityCard(), const SizedBox(height: 16)],
//         if (_checkingBid) const Center(child: CircularProgressIndicator(color: Colors.green))
//         else if (_alreadyBid)
//           Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 20), const SizedBox(width: 10), Expanded(child: Text('You have already placed a bid on this job', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14)))]))
//         else _buildPlaceBidSection(budget, isInsured),
//         const SizedBox(height: 20),
//       ])),
//     );
//   }

//   Widget _buildEligibilityCard() {
//     final isFree             = _sellerInfo!['isFree'] as bool;
//     final freeLeft           = _sellerInfo!['freeLeft'] as int;
//     final balance            = _sellerInfo!['balance'] as double;
//     final reserved           = _sellerInfo!['reserved'] as double;
//     final freeBalance        = _sellerInfo!['freeBalance'] as double;
//     final commissionRequired = _sellerInfo!['commissionRequired'] as double;
//     final rate               = _sellerInfo!['rate'] as double;
//     final isEligible         = _sellerInfo!['isEligible'] as bool;
//     final reason             = _sellerInfo!['reason'] as String?;

//     if (!isEligible) {
//       return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade300)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20), const SizedBox(width: 10), Text('Cannot Place Bid', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700))]),
//           const SizedBox(height: 8),
//           if (reason != null) Text(reason, style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
//           const SizedBox(height: 4),
//           _bRow('Wallet', 'PKR ${balance.toStringAsFixed(0)}', Colors.grey),
//           if (reserved > 0) _bRow('Reserved for other bids', '−PKR ${reserved.toStringAsFixed(0)}', Colors.orange),
//           _bRow('Free Balance', 'PKR ${freeBalance.toStringAsFixed(0)}', Colors.red),
//           _bRow('Commission needed', 'PKR ${commissionRequired.toStringAsFixed(0)} (${(rate*100).toStringAsFixed(0)}%)', Colors.red),
//           const SizedBox(height: 10),
//           SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_card), label: const Text('Deposit Funds to Enable Bidding'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//         ]));
//     }
//     if (isFree) return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
//       child: Row(children: [Icon(Icons.card_giftcard, color: Colors.green.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('🎁 Free Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)), Text('$freeLeft free order(s) remaining — No commission', style: TextStyle(fontSize: 12, color: Colors.green.shade800))]))]));
//     return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [Icon(Icons.percent, color: Colors.orange.shade700, size: 20), const SizedBox(width: 10), Text('${(rate*100).toStringAsFixed(0)}% Commission Per Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700))]),
//         const SizedBox(height: 8),
//         _bRow('Wallet', 'PKR ${balance.toStringAsFixed(0)}', Colors.teal),
//         if (reserved > 0) _bRow('Reserved for other bids', '−PKR ${reserved.toStringAsFixed(0)}', Colors.orange),
//         _bRow('Free Balance', 'PKR ${freeBalance.toStringAsFixed(0)}', Colors.green),
//         _bRow('Commission for this bid', '≈ PKR ${commissionRequired.toStringAsFixed(0)}', Colors.orange),
//       ]));
//   }

//   Widget _buildPlaceBidSection(double budget, bool isInsured) {
//     final isEligible = _sellerInfo?['isEligible'] ?? true;
//     if (!isEligible) return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.block), label: const Text('Cannot Bid — Add Funds First'), style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))));
//     return SizedBox(width: double.infinity, child: ElevatedButton.icon(
//       onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => _PlaceBidSheet(jobId: widget.jobId, jobData: widget.jobData, sellerUid: widget.sellerUid, sellerInfo: _sellerInfo!, onBidPlaced: () => setState(() => _alreadyBid = true))),
//       icon: const Icon(Icons.gavel), label: const Text('Place a Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//     ));
//   }

//   Widget _ir(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 16, color: Colors.grey[500]), const SizedBox(width: 8), Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700])))]);
//   Widget _bRow(String l, String v, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text(v, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600))]));
// }

// // ═══════════════════════════════════════════════════════════════
// //  PLACE BID SHEET — with commission reservation
// // ═══════════════════════════════════════════════════════════════
// class _PlaceBidSheet extends StatefulWidget {
//   final String jobId, sellerUid; final Map<String,dynamic> jobData, sellerInfo; final VoidCallback onBidPlaced;
//   const _PlaceBidSheet({required this.jobId, required this.jobData, required this.sellerUid, required this.sellerInfo, required this.onBidPlaced});
//   @override State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
// }
// class _PlaceBidSheetState extends State<_PlaceBidSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountCtrl  = TextEditingController();
//   final _proposalCtrl = TextEditingController();
//   bool _isSubmitting = false;
//   double? _liveCommission;

//   @override void dispose() { _amountCtrl.dispose(); _proposalCtrl.dispose(); super.dispose(); }

//   void _onAmountChanged(String val) {
//     final amount = double.tryParse(val);
//     final rate   = widget.sellerInfo['rate'] as double? ?? 0.10;
//     final isFree = widget.sellerInfo['isFree'] as bool? ?? false;
//     if (amount == null || isFree) { setState(() => _liveCommission = null); return; }
//     setState(() => _liveCommission = amount * rate);
//   }

//   Future<void> _submitBid() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSubmitting = true);
//     try {
//       final db     = FirebaseFirestore.instance;
//       final amount = double.parse(_amountCtrl.text.trim());
//       final budget = (widget.jobData['budget']??0).toDouble();
//       if (amount > budget) { _snack('Bid cannot exceed PKR ${budget.toStringAsFixed(0)}', Colors.red); setState(() => _isSubmitting = false); return; }

//       // ✅ Re-check eligibility at submit time (race-condition safe)
//       final sellerDoc = await db.collection('sellers').doc(widget.sellerUid).get();
//       final sData     = sellerDoc.data()??{};
//       final jobsCompleted  = (sData['Jobs_Completed']??0) as int;
//       final balance        = (sData['Available_Balance']??0).toDouble();
//       final reserved       = (sData['Reserved_Commission']??0).toDouble();
//       final freeBalance    = balance - reserved;
//       final isFree         = jobsCompleted < kSellerFreeOrderLimit;

//       double rate = widget.sellerInfo['rate'] as double? ?? 0.10;
//       // Always read latest rate
//       try { final cfg = await db.collection('config').doc('commission').get(); if (cfg.exists) rate = (cfg.data()?['rate']??rate).toDouble(); } catch (_) {}

//       final commissionRequired = isFree ? 0.0 : amount * rate;
//       final canBid = isFree || freeBalance >= commissionRequired;

//       if (!canBid) {
//         _snack('Insufficient balance. Need PKR ${commissionRequired.toStringAsFixed(0)} free. Available: PKR ${freeBalance.toStringAsFixed(0)}', Colors.red);
//         setState(() => _isSubmitting = false); return;
//       }

//       final userDoc    = await db.collection('users').doc(widget.sellerUid).get();
//       final userData   = userDoc.data()??{};
//       final sellerName = '${sData['firstName']??''} ${sData['lastName']??''}'.trim();
//       final sellerImage = userData['profileImage']??'';
//       final sellerRating = (sData['Rating']??0).toDouble();
//       final sellerSkills = List<String>.from(sData['skills']??[]);

//       final bidPayload = {
//         'sellerId': widget.sellerUid, 'sellerName': sellerName, 'sellerImage': sellerImage,
//         'rating': sellerRating, 'skills': sellerSkills, 'jobsCompleted': jobsCompleted,
//         'proposedAmount': amount, 'proposal': _proposalCtrl.text.trim(), 'status': 'pending',
//         'jobId': widget.jobId, 'jobTitle': widget.jobData['title']??'',
//         'jobBudget': budget, 'posterName': widget.jobData['posterName']??'',
//         'isInsured': (widget.jobData['orderType']??'simple') == 'insured',
//         // ✅ Store commission metadata for accurate finalization at order placement
//         'commissionRate': rate,
//         'commissionReserved': commissionRequired,
//         'isFreeOrder': isFree,
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       final batch = db.batch();
//       batch.set(db.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid), bidPayload);
//       batch.set(db.collection('sellers').doc(widget.sellerUid).collection('myBids').doc(widget.jobId), bidPayload);
//       batch.update(db.collection('jobs').doc(widget.jobId), {'bidsCount': FieldValue.increment(1)});
//       // ✅ Reserve commission to prevent double-spending across multiple bids
//       if (!isFree && commissionRequired > 0) {
//         batch.update(db.collection('sellers').doc(widget.sellerUid), {
//           'Reserved_Commission': FieldValue.increment(commissionRequired),
//         });
//       }
//       await batch.commit();

//       final buyerUid = widget.jobData['postedBy']as String?  ??'';
//       if (buyerUid.isNotEmpty) await NotificationService.send(toUid: buyerUid, title: '🔔 New Bid Received', body: '$sellerName placed a bid on "${widget.jobData['title']}" for PKR ${amount.toStringAsFixed(0)}.', type: 'bid_received', jobId: widget.jobId, relatedUserName: sellerName);
//       if (!mounted) return;
//       widget.onBidPlaced();
//       Navigator.pop(context);
//       final msg = isFree ? '✅ Bid placed! (Free order — no commission)' : '✅ Bid placed! PKR ${commissionRequired.toStringAsFixed(0)} reserved for commission.';
//       _snack(msg, Colors.green);
//     } catch (e) { _snack('Error: $e', Colors.red); setState(() => _isSubmitting = false); }
//   }

//   void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

//   @override Widget build(BuildContext context) {
//     final budget      = (widget.jobData['budget']??0).toDouble();
//     final title       = widget.jobData['title']??'';
//     final isFree      = widget.sellerInfo['isFree'] as bool? ?? false;
//     final freeLeft    = widget.sellerInfo['freeLeft'] as int? ?? 0;
//     final balance     = widget.sellerInfo['balance'] as double? ?? 0;
//     final reserved    = widget.sellerInfo['reserved'] as double? ?? 0;
//     final freeBalance = widget.sellerInfo['freeBalance'] as double? ?? balance;
//     final isEligible  = widget.sellerInfo['isEligible'] as bool? ?? true;
//     final rate        = widget.sellerInfo['rate'] as double? ?? 0.10;
//     final isInsured   = (widget.jobData['orderType']??'simple') == 'insured';

//     // return Padding(padding: EdgeInsets.only(bottom: 200), //MediaQuery.of(context).viewInsets.bottom
//     return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
//         const SizedBox(height: 16),
//         Row(children: [const Text('Place a Bid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), const GlobalLanguageButton()]),
//         const SizedBox(height: 4),
//         Text('For: $title', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//         const SizedBox(height: 12),
//         Row(children: [
//           Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Text('Max Budget: PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600))),
//           if (isInsured) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.blue), SizedBox(width: 4), Text('Insured', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600))]))],
//         ]),
//         const SizedBox(height: 12),
//         // ✅ Balance overview (only for non-free sellers)
//         if (!isFree) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isEligible ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: isEligible ? Colors.green.shade200 : Colors.red.shade300)),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [Icon(isEligible ? Icons.account_balance_wallet : Icons.warning_amber_rounded, size: 15, color: isEligible ? Colors.green.shade700 : Colors.red.shade700), const SizedBox(width: 6), Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isEligible ? Colors.green.shade700 : Colors.red.shade700)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Text('${(rate*100).toStringAsFixed(0)}% commission', style: TextStyle(fontSize: 10, color: Colors.grey[600])))]),
//             const SizedBox(height: 6),
//             _bRow('Wallet', 'PKR ${balance.toStringAsFixed(0)}', Colors.teal),
//             if (reserved > 0) _bRow('Reserved (other bids)', '−PKR ${reserved.toStringAsFixed(0)}', Colors.orange),
//             _bRow('Free Balance', 'PKR ${freeBalance.toStringAsFixed(0)}', freeBalance <= 0 ? Colors.red : Colors.green),
//             if (_liveCommission != null) ...[const Divider(height: 10), _bRow('Commission for this bid', 'PKR ${_liveCommission!.toStringAsFixed(0)}', Colors.orange), _bRow('Balance after bid', 'PKR ${(freeBalance-_liveCommission!).toStringAsFixed(0)}', (freeBalance-_liveCommission!) < 0 ? Colors.red : Colors.green)],
//             if (!isEligible) ...[const SizedBox(height: 8), Text(widget.sellerInfo['reason'] as String? ?? 'Deposit funds to place bids.', style: TextStyle(fontSize: 11, color: Colors.red.shade800, fontWeight: FontWeight.w500))],
//           ])),
//         if (isFree) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.card_giftcard, size: 14, color: Colors.green.shade700), const SizedBox(width: 8), Expanded(child: Text('🎁 Free order ($freeLeft left) — No commission required', style: TextStyle(fontSize: 12, color: Colors.green.shade800)))])),
//         if (!isInsured) Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)), child: Row(children: [Icon(Icons.payments_outlined, size: 14, color: Colors.blue.shade700), const SizedBox(width: 8), Expanded(child: Text('💵 Cash on Delivery — Collect payment directly from buyer. Commission deducted from wallet when order is placed.', style: TextStyle(fontSize: 11, color: Colors.blue.shade800)))])),
//         const SizedBox(height: 14),
//         TextFormField(
//           controller: _amountCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           decoration: InputDecoration(labelText: 'Your Bid Amount (PKR)', prefixText: 'PKR ', prefixIcon: const Icon(Icons.payments_outlined, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Must be ≤ PKR ${budget.toStringAsFixed(0)}'),
//           onChanged: _onAmountChanged,
//           validator: (v) { if (v==null||v.isEmpty) return 'Enter bid amount'; final amt=double.tryParse(v); if(amt==null||amt<=0) return 'Enter valid amount'; if(amt>budget) return 'Cannot exceed PKR ${budget.toStringAsFixed(0)}'; return null; },
//         ),
//         const SizedBox(height: 14),
//         TextFormField(controller: _proposalCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Your Proposal', prefixIcon: const Icon(Icons.description_outlined, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Why are you the best choice?'), validator: (v) => v==null||v.trim().isEmpty?'Write a proposal':null),
//         const SizedBox(height: 20),
//         if (!isEligible)
//           SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.add_card), label: const Text('Deposit Funds to Enable Bidding'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))))
//         else
//           SizedBox(width: double.infinity, child: ElevatedButton.icon(
//             onPressed: _isSubmitting ? null : _submitBid,
//             icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.gavel),
//             label: Text(_isSubmitting ? 'Submitting...' : 'Submit Bid', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//           )),
//         const SizedBox(height: 8),
//       ]))),
//     );
//   }
//   Widget _bRow(String l, String v, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text(v, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600))]));
// }

// // ═══════════════════════════════════════════════════════════════
// //  MY BIDS TAB
// // ═══════════════════════════════════════════════════════════════
// class _MyBidsList extends StatelessWidget {
//   final String sellerUid;
//   const _MyBidsList({required this.sellerUid});
//   @override Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).collection('myBids').snapshots(),
//       builder: (ctx, snap) {
//         if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//         if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_off, size: 48, color: Colors.red[300]), const SizedBox(height: 12), Text('Error: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13))])));
//         if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.gavel, message: 'No bids placed yet', subtitle: 'Browse open jobs and place your first bid');
//         final docs = snap.data!.docs.toList()..sort((a,b){ final aT=(a.data()as Map)['createdAt']as Timestamp?; final bT=(b.data()as Map)['createdAt']as Timestamp?; if(aT==null||bT==null)return 0; return bT.compareTo(aT); });
//         return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (ctx, i) { final bid=docs[i].data()as Map<String,dynamic>; final jobId=bid['jobId']as String?  ??docs[i].id; return _MyBidCard(bid: bid, jobId: jobId, sellerUid: sellerUid); });
//       },
//     );
//   }
// }

// class _MyBidCard extends StatelessWidget {
//   final Map<String,dynamic> bid; final String jobId, sellerUid;
//   const _MyBidCard({required this.bid, required this.jobId, required this.sellerUid});
//   @override Widget build(BuildContext context) {
//     final amount        = (bid['proposedAmount']??0).toDouble();
//     final proposal      = bid['proposal']??'';
//     final createdAt     = bid['createdAt']as Timestamp?;
//     final jobTitle      = bid['jobTitle']??'Loading...';
//     final posterName    = bid['posterName']??'';
//     final jobBudget     = (bid['jobBudget']??0).toDouble();
//     final isInsured     = bid['isInsured']??false;
//     final commRate      = (bid['commissionRate']??0.10).toDouble();
//     final commReserved  = (bid['commissionReserved']??0).toDouble();
//     final isFreeOrder   = bid['isFreeOrder']??false;

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('bids').doc(sellerUid).snapshots(),
//       builder: (ctx, bidSnap) {
//         final liveBid = bidSnap.data?.data()as Map<String,dynamic>? ?? {};
//         final status  = liveBid['status']??bid['status']??'pending';
//         Color sc; IconData si;
//         switch (status) { case 'accepted': sc=Colors.green; si=Icons.check_circle; break; case 'rejected': sc=Colors.red; si=Icons.cancel; break; default: sc=Colors.orange; si=Icons.hourglass_empty; }

//         return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: status=='accepted'?Colors.green.shade200:status=='rejected'?Colors.red.shade100:Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
//           child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [Expanded(child: Text(jobTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))), if(isInsured==true) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.shield, size: 14, color: Colors.blue))]),
//                 if (posterName.isNotEmpty) Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               ])),
//               Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(si, size: 12, color: sc), const SizedBox(width: 4), Text(status.toUpperCase(), style: TextStyle(color: sc, fontWeight: FontWeight.bold, fontSize: 11))])),
//             ]),
//             if (isInsured != true) ...[const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.payments_outlined, size: 12, color: Colors.green.shade700), const SizedBox(width: 4), Text('💵 Cash on Delivery', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600))]))],
//             if (!isFreeOrder && commReserved > 0) ...[const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)), child: Text('${(commRate*100).toStringAsFixed(0)}% commission reserved: PKR ${commReserved.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.orange.shade700)))],
//             const Divider(height: 16),
//             Row(children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Bid', style: TextStyle(fontSize: 11, color: Colors.grey[500])), Text('PKR ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
//               const SizedBox(width: 20),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[500])), Text('PKR ${jobBudget.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]))]),
//               const Spacer(),
//               if (createdAt != null) Text(DateFormat('dd MMM').format(createdAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//             ]),
//             if (proposal.isNotEmpty) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: TranslatedText(text: proposal, contentId: 'mybid_${jobId}_$sellerUid', style: const TextStyle(fontSize: 13), showListenButton: false))],
//             const SizedBox(height: 10),
//             if (status == 'accepted')
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.celebration, color: Colors.green.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text(isInsured==true?'🎉 Accepted! Wait for buyer to pay before starting.':'🎉 Accepted! Collect cash on job completion.', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)))]))
//             else if (status == 'rejected')
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)), child: Row(children: [Icon(Icons.info_outline, color: Colors.red.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text('Buyer chose another seller. Keep bidding!', style: TextStyle(color: Colors.red.shade700, fontSize: 12)))]))
//             else
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Row(children: [Icon(Icons.hourglass_top, color: Colors.orange.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text('Waiting for buyer to review your bid.', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)))])),
//           ])));
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  ACTIVE JOBS TAB
// // ═══════════════════════════════════════════════════════════════
// class _ActiveJobsList extends StatelessWidget {
//   final String sellerUid;
//   const _ActiveJobsList({required this.sellerUid});
//   @override Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('jobs').where('acceptedBidder', isEqualTo: sellerUid).snapshots(),
//       builder: (ctx, snap) {
//         if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//         if (!snap.hasData) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');
//         final active = snap.data!.docs.where((d){ final s=(d.data()as Map)['status']; return s=='in_progress'||s=='claim_pending'; }).toList();
//         return StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('jobs').where('expertUid', isEqualTo: sellerUid).snapshots(),
//           builder: (ctx, eSnap) {
//             final expertJobs = (eSnap.data?.docs??[]).where((d)=>(d.data()as Map)['status']=='expert_assigned').toList();
//             final allIds = <String>{}; final combined = <QueryDocumentSnapshot>[];
//             for (final d in [...active, ...expertJobs]) { if (allIds.add(d.id)) combined.add(d); }
//             if (combined.isEmpty) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');
//             return ListView.builder(padding: const EdgeInsets.all(12), itemCount: combined.length, itemBuilder: (ctx, i) { final data=combined[i].data()as Map<String,dynamic>; final isExpert=expertJobs.any((d)=>d.id==combined[i].id); return _ActiveJobCard(jobId: combined[i].id, jobData: data, sellerUid: sellerUid, isExpertRole: isExpert); });
//           },
//         );
//       },
//     );
//   }
// }

// class _ActiveJobCard extends StatefulWidget {
//   final String jobId, sellerUid; final Map<String,dynamic> jobData; final bool isExpertRole;
//   const _ActiveJobCard({required this.jobId, required this.jobData, required this.sellerUid, this.isExpertRole = false});
//   @override State<_ActiveJobCard> createState() => _ActiveJobCardState();
// }
// class _ActiveJobCardState extends State<_ActiveJobCard> {
//   bool _isCompleting = false;
//   bool get _isClaim   => widget.jobData['status'] == 'claim_pending';
//   bool get _isInsured => (widget.jobData['orderType']??'simple') == 'insured';

//   Future<void> _markCompleted() async {
//     setState(() => _isCompleting = true);
//     try {
//       final db            = FirebaseFirestore.instance;
//       final acceptedAmount = (widget.jobData['acceptedAmount']??0).toDouble();
//       final claimDeadline  = Timestamp.fromDate(DateTime.now().add(const Duration(days: 3)));
//       final newStatus      = widget.isExpertRole ? 'expert_completed' : 'completed';
//       final batch          = db.batch();

//       batch.update(db.collection('jobs').doc(widget.jobId), {'status': newStatus, 'completedAt': FieldValue.serverTimestamp(), 'claimDeadline': claimDeadline, 'paymentStatus': _isInsured ? 'locked' : 'released', 'insuranceClaimed': false, 'updatedAt': FieldValue.serverTimestamp()});
//       // ✅ Earning tracked, Available_Balance NOT touched:
//       //    Cash: buyer pays physically; Insured: admin releases via admin panel
//       batch.update(db.collection('sellers').doc(widget.sellerUid), {
//         'Jobs_Completed': FieldValue.increment(1), 'Total_Jobs': FieldValue.increment(1), 'Pending_Jobs': FieldValue.increment(-1),
//         'Earning': FieldValue.increment(acceptedAmount),
//       });
//       await batch.commit();

//       final buyerUid = widget.jobData['postedBy']as String?  ??'';
//       if (buyerUid.isNotEmpty) {
//         await NotificationService.send(toUid: buyerUid,
//           title: widget.isExpertRole ? '⭐ Expert completed your job' : '✅ Job Marked Complete',
//           body: _isInsured ? 'Your job "${widget.jobData['title']}" is complete. You can confirm satisfaction or claim insurance.' : 'Job "${widget.jobData['title']}" is done. Cash payment goes to the worker directly.',
//           type: 'job_completed', jobId: widget.jobId);
//       }
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isInsured ? '✅ Job done! Buyer can confirm satisfaction. Admin will release earnings.' : '🎉 Job done! Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from buyer.'), backgroundColor: Colors.green, duration: const Duration(seconds: 6)));
//     } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
//     finally { if (mounted) setState(() => _isCompleting = false); }
//   }

//   // Future<void> _openChat(BuildContext context) async {
//   //   final buyerId    = widget.jobData['postedBy']??'';
//   //   final posterName = widget.jobData['posterName']??'Client';
//   //   if (buyerId.isEmpty) return;
//   //   final db = FirebaseFirestore.instance;
//   //   final phones = [widget.sellerUid, buyerId]..sort();
//   //   final convId = '${phones[0]}_${phones[1]}';
//   //   if (!(await db.collection('conversations').doc(convId).get()).exists) {
//   //     final buyerDoc = await db.collection('users').doc(buyerId).get(); final buyerData = buyerDoc.data()??{};
//   //     final sellerDoc = await db.collection('users').doc(widget.sellerUid).get(); final sellerData = sellerDoc.data()??{};
//   //     await db.collection('conversations').doc(convId).set({'participantIds': [widget.sellerUid, buyerId], 'participantNames': {widget.sellerUid: '${sellerData['firstName']??''} ${sellerData['lastName']??''}'.trim(), buyerId: posterName}, 'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'}, 'participantProfileImages': {widget.sellerUid: sellerData['profileImage']??'', buyerId: buyerData['profileImage']??''}, 'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(), 'unreadCounts': {widget.sellerUid: 0, buyerId: 0}, 'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title']??''});
//   //   }
//   //   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat opened with $posterName')));
//   // }

// Future<void> _openChat(BuildContext context) async {
//   final buyerId    = widget.jobData['postedBy']   as String? ?? '';
//   final posterName = widget.jobData['posterName'] as String? ?? 'Client';
//   final posterImg  = widget.jobData['posterImage'] as String? ?? '';
//   if (buyerId.isEmpty) return;

//   final db = FirebaseFirestore.instance;
//   final phones = [widget.sellerUid, buyerId]..sort();
//   final convId = '${phones[0]}_${phones[1]}';

//   if (!(await db.collection('conversations').doc(convId).get()).exists) {
//     final buyerDoc   = await db.collection('users').doc(buyerId).get();
//     final buyerData  = buyerDoc.data() ?? {};
//     final sellerDoc  = await db.collection('users').doc(widget.sellerUid).get();
//     final sellerData = sellerDoc.data() ?? {};
//     await db.collection('conversations').doc(convId).set({
//       'participantIds': [widget.sellerUid, buyerId],
//       'participantNames': {widget.sellerUid: '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim(), buyerId: posterName},
//       'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'},
//       'participantProfileImages': {widget.sellerUid: sellerData['profileImage'] ?? '', buyerId: buyerData['profileImage'] ?? ''},
//       'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
//       'unreadCounts': {widget.sellerUid: 0, buyerId: 0},
//       'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] ?? '',
//     });
//   }

//   // ✅ Navigate instead of SnackBar
//   if (context.mounted) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
//       convId:     convId,
//       myUid:      widget.sellerUid,
//       otherUid:   buyerId,
//       otherName:  posterName,
//       otherImage: posterImg,
//       otherRole:  'buyer',
//       jobTitle:   widget.jobData['title'] as String? ?? '',
//     )));
//   }
// }
//   @override Widget build(BuildContext context) {
//     final title          = widget.jobData['title']??'';
//     final posterName     = widget.jobData['posterName']??'Client';
//     final acceptedAmount = (widget.jobData['acceptedAmount']??0).toDouble();
//     final skills         = List<String>.from(widget.jobData['skills']??[]);
//     final location       = widget.jobData['location']??'';
//     final description    = widget.jobData['description']??'';
//     final city           = widget.jobData['city']as String?  ??'';
//     Color hc; String sl; Color slc;
//     if (widget.isExpertRole) { hc=Colors.purple.shade50; sl='EXPERT ROLE'; slc=Colors.purple; }
//     else if (_isClaim) { hc=Colors.red.shade50; sl='REVISIT REQUIRED'; slc=Colors.red; }
//     else { hc=_isInsured?Colors.blue.shade50:Colors.green.shade50; sl='IN PROGRESS'; slc=Colors.blue; }

//     return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.isExpertRole?Colors.purple.shade300:_isClaim?Colors.red.shade300:_isInsured?Colors.blue.shade200:Colors.green.shade200, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//         Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: hc, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
//           child: Row(children: [
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: slc.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(sl, style: TextStyle(color: slc, fontSize: 9, fontWeight: FontWeight.bold))), if(_isInsured)...[const SizedBox(width:4),Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),decoration:BoxDecoration(color:Colors.blue,borderRadius:BorderRadius.circular(8)),child:Row(mainAxisSize:MainAxisSize.min,children:const[Icon(Icons.shield,size:9,color:Colors.white),SizedBox(width:2),Text('INS',style:TextStyle(color:Colors.white,fontSize:8,fontWeight:FontWeight.bold))]))],]),
//               Row(children: [Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])), if(city.isNotEmpty)...[const SizedBox(width:8),Icon(Icons.location_city,size:12,color:Colors.grey[400]),const SizedBox(width:3),Text(city,style:TextStyle(fontSize:11,color:Colors.grey[500]))]]),
//             ])),
//             const SizedBox(width: 8),
//             Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//               Text('PKR ${acceptedAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: widget.isExpertRole?Colors.purple:_isInsured?Colors.blue.shade700:Colors.green.shade700)),
//               Text(_isInsured?'Held by company':'Cash on delivery', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//             ]),
//           ])),
//         Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           if (_isClaim) Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade300)), child: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16), const SizedBox(width: 8), Expanded(child: Text('Buyer claimed insurance — revisit and complete the job properly.', style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600)))])),
//           if (widget.isExpertRole) Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple.shade200)), child: Row(children: [Icon(Icons.star, color: Colors.purple.shade700, size: 16), const SizedBox(width: 8), Expanded(child: Text('You are assigned as expert. Assist the seller to deliver the best results.', style: TextStyle(color: Colors.purple.shade800, fontSize: 12, fontWeight: FontWeight.w600)))])),
//           if (location.isNotEmpty) ...[Row(children: [Icon(Icons.location_on, size: 13, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8)],
//           if (description.isNotEmpty) ...[Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: TranslatedText(text: description, contentId: 'active_${widget.jobId}', style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4), maxLines: 3, showListenButton: false)), const SizedBox(height: 8)],
//           JobListenRow(title: title, description: description, location: location, timing: widget.jobData['timing']??'', jobId: widget.jobId),
//           const SizedBox(height: 8),
//           Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _isInsured?Colors.blue.shade50:Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _isInsured?Colors.blue.shade200:Colors.green.shade200)),
//             child: Row(children: [Icon(_isInsured?Icons.lock_outline:Icons.payments_outlined, size: 14, color: _isInsured?Colors.blue.shade700:Colors.green.shade700), const SizedBox(width: 8), Expanded(child: Text(_isInsured?'Payment locked. Admin releases after claim window passes.':'💵 Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from client directly.', style: TextStyle(fontSize: 11, color: _isInsured?Colors.blue.shade800:Colors.green.shade800)))])),
//           const SizedBox(height: 8),
//           Wrap(spacing: 6, runSpacing: 4, children: skills.take(3).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)))).toList()),
//           const SizedBox(height: 14),
//           Row(children: [
//             Expanded(child: OutlinedButton.icon(onPressed: () => _openChat(context), icon: const Icon(Icons.message_outlined, size: 16), label: const Text('Message Client'), style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//             const SizedBox(width: 10),
//             Expanded(child: ElevatedButton.icon(onPressed: _isCompleting ? null : _markCompleted, icon: _isCompleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 16), label: Text(_isCompleting?'Updating...':widget.isExpertRole?'Mark Expert Done':'Mark Done'), style: ElevatedButton.styleFrom(backgroundColor: widget.isExpertRole?Colors.purple:Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//           ]),
//         ])),
//       ]),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  SELLER HISTORY TAB
// // ═══════════════════════════════════════════════════════════════
// class _SellerHistoryTab extends StatelessWidget {
//   final String sellerUid;
//   const _SellerHistoryTab({required this.sellerUid});
//   @override Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).snapshots(),
//       builder: (ctx, sellerSnap) {
//         final sd         = sellerSnap.data?.data()as Map<String,dynamic>? ?? {};
//         final totalEarning = (sd['Earning']??0).toDouble();
//         final balance    = (sd['Available_Balance']??0).toDouble();
//         final rating     = (sd['Rating']??0.0).toDouble();
//         return StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('jobs').where('acceptedBidder', isEqualTo: sellerUid).snapshots(),
//           builder: (ctx, snap) => StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance.collection('jobs').where('expertUid', isEqualTo: sellerUid).snapshots(),
//             builder: (ctx, eSnap) {
//               if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//               final allIds = <String>{}; final allDocs = <QueryDocumentSnapshot>[];
//               for (final d in [...(snap.data?.docs??[]), ...(eSnap.data?.docs??[])]) { if (allIds.add(d.id)) allDocs.add(d); }
//               allDocs.sort((a,b){ final aT=(a.data()as Map)['postedAt']as Timestamp?; final bT=(b.data()as Map)['postedAt']as Timestamp?; if(aT==null||bT==null)return 0; return bT.compareTo(aT); });
//               final completedJobs = allDocs.where((d){ final s=(d.data()as Map)['status']; return s=='completed'||s=='expert_completed'; }).length;
//               final activeJobs    = allDocs.where((d)=>(d.data()as Map)['status']=='in_progress').length;
//               final insuredJobs   = allDocs.where((d)=>(d.data()as Map)['orderType']=='insured').length;
//               final cashJobs      = allDocs.where((d)=>(d.data()as Map)['orderType']=='simple').length;

//               return ListView(padding: const EdgeInsets.all(12), children: [
//                 Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18), const SizedBox(width: 8), const Text('Earnings Overview', style: TextStyle(color: Colors.white70, fontSize: 13))]),
//                     const SizedBox(height: 10),
//                     Text('PKR ${totalEarning.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
//                     const Text('Net Earned (Cash + Insurance total)', style: TextStyle(color: Colors.white60, fontSize: 12)),
//                     const Divider(color: Colors.white24, height: 20),
//                     Row(children: [_et('Wallet','PKR ${balance.toStringAsFixed(0)}',Icons.wallet), _et('Rating','${rating.toStringAsFixed(1)} ⭐',Icons.star), _et('Done','$completedJobs',Icons.task_alt), _et('Active','$activeJobs',Icons.autorenew)]),
//                     const SizedBox(height: 8),
//                     Row(children: [_et('Insured','$insuredJobs',Icons.shield_outlined), _et('Cash','$cashJobs',Icons.payments_outlined)]),
//                     const SizedBox(height: 8),
//                     Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('💡 Cash: collected from buyer. Insurance: released to wallet by admin.', style: TextStyle(fontSize: 11, color: Colors.white70))),
//                   ])),
//                 _BankDetailsSection(sellerUid: sellerUid, jobs: allDocs),
//                 if (allDocs.isEmpty) ...[const SizedBox(height: 40), Center(child: Column(children: [Icon(Icons.history, size: 64, color: Colors.grey[300]), const SizedBox(height: 12), Text('No job history yet', style: TextStyle(fontSize: 16, color: Colors.grey[500]))]))],
//                 ...allDocs.map((doc){ final data=doc.data()as Map<String,dynamic>; return _SellerHistoryCard(jobData: data, jobId: doc.id, sellerUid: sellerUid); }),
//               ]);
//             },
//           ),
//         );
//       },
//     );
//   }
//   Widget _et(String l, String v, IconData i) => Expanded(child: Column(children: [Icon(i, color: Colors.white60, size: 16), const SizedBox(height: 2), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9))]));
// }

// class _BankDetailsSection extends StatefulWidget {
//   final String sellerUid; final List<QueryDocumentSnapshot> jobs;
//   const _BankDetailsSection({required this.sellerUid, required this.jobs});
//   @override State<_BankDetailsSection> createState() => _BankDetailsSectionState();
// }
// class _BankDetailsSectionState extends State<_BankDetailsSection> {
//   bool _hasBankDetails=false, _loading=true, _hasInsuredCompleted=false;
//   @override void initState() { super.initState(); _check(); }
//   Future<void> _check() async {
//     try {
//       final bankDoc    = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).collection('bankDetails').doc('primary').get();
//       final insuredDone = widget.jobs.any((d){ final data=d.data()as Map; return (data['orderType']=='insured')&&(data['status']=='completed'||data['status']=='expert_completed')&&data['paymentStatus']!='released'; });
//       if (mounted) setState(() { _hasBankDetails=bankDoc.exists; _hasInsuredCompleted=insuredDone; _loading=false; });
//     } catch (_) { if (mounted) setState(() => _loading=false); }
//   }
//   void _showBankDetailsSheet() {
//     final bankCtrl=TextEditingController(); final titleCtrl=TextEditingController(); final numCtrl=TextEditingController();
//     showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
//         const SizedBox(height: 16),
//         const Text('Add Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Bank Name', prefixIcon: Icon(Icons.account_balance), border: OutlineInputBorder())),
//         const SizedBox(height: 12),
//         TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Account Title', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
//         const SizedBox(height: 12),
//         TextField(controller: numCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Account Number', prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder())),
//         const SizedBox(height: 20),
//         SizedBox(width: double.infinity, child: ElevatedButton.icon(
//           onPressed: () async {
//             if (bankCtrl.text.trim().isEmpty||titleCtrl.text.trim().isEmpty||numCtrl.text.trim().isEmpty) return;
//             await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).collection('bankDetails').doc('primary').set({'bankName': bankCtrl.text.trim(), 'accountTitle': titleCtrl.text.trim(), 'accountNumber': numCtrl.text.trim(), 'addedAt': FieldValue.serverTimestamp()});
//             if (mounted) { Navigator.pop(context); setState(() => _hasBankDetails=true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Bank details saved! Admin will transfer your earnings.'), backgroundColor: Colors.green)); }
//           },
//           icon: const Icon(Icons.save), label: const Text('Save Bank Details', style: TextStyle(fontSize: 16)),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//         )),
//       ]))));
//   }
//   @override Widget build(BuildContext context) {
//     if (_loading || !_hasInsuredCompleted) return const SizedBox();
//     if (_hasBankDetails) return Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 20), const SizedBox(width: 10), Expanded(child: Text('Bank details saved. Admin will transfer your insured earnings.', style: TextStyle(color: Colors.green.shade800, fontSize: 13)))]));
//     return Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade400, width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Row(children: [Icon(Icons.account_balance, color: Colors.orange.shade700, size: 20), const SizedBox(width: 8), Expanded(child: Text('💰 Add Bank Details to Receive Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 14)))]),
//       const SizedBox(height: 8),
//       Text('Your insured job is complete! Add your bank account so admin can transfer your earnings.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
//       const SizedBox(height: 10),
//       SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _showBankDetailsSheet, icon: const Icon(Icons.add_card), label: const Text('Add Bank Account'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//     ]));
//   }
// }

// class _SellerHistoryCard extends StatelessWidget {
//   final Map<String,dynamic> jobData; final String jobId, sellerUid;
//   const _SellerHistoryCard({required this.jobData, required this.jobId, required this.sellerUid});
//   @override Widget build(BuildContext context) {
//     final title          = jobData['title']??'Untitled';
//     final status         = jobData['status']??'open';
//     final orderType      = jobData['orderType']??'simple';
//     final acceptedAmount = (jobData['acceptedAmount']??0).toDouble();
//     final postedAt       = jobData['postedAt']as Timestamp?;
//     final completedAt    = jobData['completedAt']as Timestamp?;
//     final posterName     = jobData['posterName']??'';
//     final location       = jobData['location']??'';
//     final city           = jobData['city']as String?  ??'';
//     final isInsured      = orderType == 'insured';
//     final paymentStatus  = jobData['paymentStatus']??'';
//     final isExpertRole   = jobData['expertUid'] == sellerUid;
//     final buyerRating    = (jobData['buyerRating']??0)as int;
//     final buyerFeedback  = jobData['buyerFeedback']as String?  ??'';
//     final commRate       = (jobData['commissionRate']??0.0).toDouble();
//     final commAmount     = (jobData['commissionAmount']??0.0).toDouble();
//     Color sc; String sl;
//     switch (status) { case 'completed': case 'expert_completed': sc=Colors.green; sl='Completed'; break; case 'in_progress': sc=Colors.blue; sl='In Progress'; break; case 'claim_pending': sc=Colors.red; sl='Claim Filed'; break; case 'expert_assigned': sc=Colors.purple; sl='Expert Sent'; break; case 'cancelled': sc=Colors.red; sl='Cancelled'; break; default: sc=Colors.grey; sl=status; }

//     return Container(margin: const EdgeInsets.only(bottom:10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
//       child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(sl, style: TextStyle(color: sc, fontWeight: FontWeight.bold, fontSize: 11)))]),
//         const SizedBox(height: 4),
//         if (city.isNotEmpty) Row(children: [Icon(Icons.location_city, size: 12, color: Colors.teal.shade400), const SizedBox(width: 3), Text(city, style: TextStyle(fontSize: 12, color: Colors.teal.shade600, fontWeight: FontWeight.w600))]),
//         if (location.isNotEmpty) Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey[400]), const SizedBox(width: 3), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis))]),
//         if (posterName.isNotEmpty) Row(children: [Icon(Icons.person_outline, size: 12, color: Colors.grey[400]), const SizedBox(width: 3), Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
//         const Divider(height: 14),
//         Wrap(spacing: 6, runSpacing: 4, children: [
//           _chip(isInsured?'🛡 Insured':'💵 Cash', isInsured?Colors.blue:Colors.green),
//           _chip('PKR ${acceptedAmount.toStringAsFixed(0)}', Colors.teal),
//           if (isExpertRole) _chip('⭐ Expert', Colors.purple),
//           if (commAmount > 0) _chip('${(commRate*100).toStringAsFixed(0)}% comm: PKR ${commAmount.toStringAsFixed(0)}', Colors.orange),
//         ]),
//         const SizedBox(height: 6),
//         Row(children: [
//           if (postedAt != null) _dl('Posted', postedAt.toDate()),
//           if (completedAt != null) ...[const SizedBox(width: 12), _dl('Done', completedAt.toDate())],
//           const Spacer(),
//           if (paymentStatus=='released') Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, size: 12, color: Colors.green.shade700), const SizedBox(width: 3), Text(isInsured?'Paid to wallet':'Cash collected', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold))])),
//           if (paymentStatus=='locked') Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock_outline, size: 12, color: Colors.orange.shade700), const SizedBox(width: 3), Text('Pending release', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.bold))])),
//         ]),
//         if (buyerRating > 0) ...[
//           const Divider(height: 14),
//           Row(children: [...List.generate(5,(i)=>Icon(i<buyerRating?Icons.star_rounded:Icons.star_outline_rounded,size:18,color:Colors.amber)), const SizedBox(width: 8), Text('$buyerRating/5 from client', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
//           if (buyerFeedback.isNotEmpty) ...[const SizedBox(height: 4), Text('"$buyerFeedback"', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis)],
//         ],
//       ])));
//   }
//   Widget _chip(String l, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(l, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)));
//   Widget _dl(String l, DateTime dt) => Row(children: [Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]), const SizedBox(width: 3), Text('$l: ${DateFormat('dd MMM yy').format(dt)}', style: TextStyle(fontSize: 11, color: Colors.grey[500]))]);
// }

// class _SellerEmptyState extends StatelessWidget {
//   final IconData icon; final String message, subtitle;
//   const _SellerEmptyState({required this.icon, required this.message, required this.subtitle});
//   @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 60, color: Colors.grey[400]), const SizedBox(height: 12), Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])), const SizedBox(height: 6), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400]))]));
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';
import 'notification_service.dart';
import 'tts_translation_service.dart';
import 'ChatDetailScreen.dart';

const int kSellerFreeOrderLimit = 3;
const double kSellerMinBalance = 500.0;

// ═══════════════════════════════════════════════════════════════
class SellerOrdersPage extends StatefulWidget {
  final String? phoneUID;
  const SellerOrdersPage({super.key, this.phoneUID});
  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _uid;
  String _sellerCity = '';
  StreamSubscription? _balanceSub;
  bool _bannerVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _uid = _resolveUid();
    TtsTranslationService().init();
    _loadSellerCity();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _setupBalanceListener(),
    );
  }

  String _resolveUid() {
    final raw =
        widget.phoneUID ??
        UserSession().phoneUID ??
        UserSession().phone ??
        UserSession().uid ??
        '';
    return _normalizePhone(raw);
  }

  String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    final t = raw.trim();
    if (t.startsWith('+')) return t;
    if (RegExp(r'^\d+$').hasMatch(t)) return '+$t';
    return t;
  }

  Future<void> _loadSellerCity() async {
    if (_uid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      final city = (doc.data() ?? {})['city'] as String? ?? '';
      if (mounted) setState(() => _sellerCity = city.trim());
    } catch (_) {}
  }

  void _setupBalanceListener() {
    if (_uid.isEmpty) return;
    _balanceSub = FirebaseFirestore.instance
        .collection('sellers')
        .doc(_uid)
        .snapshots()
        .listen((snap) {
          if (!mounted || !snap.exists) return;
          final data = snap.data()!;
          final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
          final balance = (data['Available_Balance'] ?? 0).toDouble();
          final isLow = jobsCompleted >= kSellerFreeOrderLimit && balance < 100;

          if (isLow && !_bannerVisible) {
            _bannerVisible = true;
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                backgroundColor: Colors.red.shade50,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Low Balance — Orders Paused',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Free orders used. Balance: PKR ${balance.toStringAsFixed(0)}. Add funds to receive jobs.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _bannerVisible = false;
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    },
                    child: const Text('DISMISS'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _bannerVisible = false;
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ADD FUNDS'),
                  ),
                ],
              ),
            );
          } else if (!isLow && _bannerVisible) {
            _bannerVisible = false;
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          }
        });
  }

  @override
  void dispose() {
    _balanceSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Find Jobs'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Could not identify user. Please log in again.'),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          'Find Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const GlobalLanguageButton(color: Colors.white),
          NotificationBell(
            uid: _uid,
            color: Colors.white,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationsPage(uid: _uid)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Browse Jobs'),
            Tab(text: 'My Bids'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          _SellerBalanceBar(sellerUid: _uid),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OpenJobsList(sellerUid: _uid, sellerCity: _sellerCity),
                _MyBidsList(sellerUid: _uid),
                _ActiveJobsList(sellerUid: _uid),
                _SellerHistoryTab(sellerUid: _uid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance Bar ───────────────────────────────────────────────
class _SellerBalanceBar extends StatelessWidget {
  final String sellerUid;
  const _SellerBalanceBar({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
        final balance = (data['Available_Balance'] ?? 0).toDouble();
        final reserved = (data['Reserved_Commission'] ?? 0).toDouble();
        final earning = (data['Earning'] ?? 0).toDouble();
        final isFree = jobsCompleted < kSellerFreeOrderLimit;
        final freeLeft = isFree ? kSellerFreeOrderLimit - jobsCompleted : 0;
        final isLow = !isFree && balance < 100;
        final freeBalance = balance - reserved;

        Color barColor;
        Widget content;
        if (isFree) {
          barColor = Colors.green.shade700;
          content = Row(
            children: [
              const Icon(Icons.card_giftcard, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                '$freeLeft free order(s) remaining',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Balance: PKR ${balance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    'Earned: PKR ${earning.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ],
          );
        } else if (isLow) {
          barColor = Colors.red.shade700;
          content = Row(
            children: [
              const Icon(Icons.warning_amber, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Low balance (PKR ${balance.toStringAsFixed(0)}) — Add funds to receive orders',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          );
        } else {
          barColor = Colors.green.shade800;
          content = Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 14,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet: PKR ${balance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (reserved > 0)
                    Text(
                      'Reserved: PKR ${reserved.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  Text(
                    'Free: PKR ${freeBalance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net Earned: PKR ${earning.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('config')
                        .doc('commission')
                        .snapshots(),
                    builder: (ctx, cfgSnap) {
                      final rate = cfgSnap.hasData && cfgSnap.data!.exists
                          ? ((cfgSnap.data!.data() as Map)['rate'] ?? 0.10)
                                .toDouble()
                          : 0.10;
                      return Text(
                        '${(rate * 100).toStringAsFixed(0)}% commission',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: barColor,
          child: content,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  BROWSE OPEN JOBS
// ═══════════════════════════════════════════════════════════════
class _OpenJobsList extends StatefulWidget {
  final String sellerUid, sellerCity;
  const _OpenJobsList({required this.sellerUid, required this.sellerCity});
  @override
  State<_OpenJobsList> createState() => _OpenJobsListState();
}

class _OpenJobsListState extends State<_OpenJobsList> {
  String _searchQuery = '';
  bool _showAllCities = false;
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title or skill...',
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
              ),
              if (widget.sellerCity.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 13,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Your city: ${widget.sellerCity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showAllCities = !_showAllCities),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _showAllCities
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _showAllCities
                                ? Colors.blue.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _showAllCities ? '🌍 All Cities' : '📍 My City First',
                          style: TextStyle(
                            fontSize: 11,
                            color: _showAllCities
                                ? Colors.blue.shade700
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .where('status', isEqualTo: 'open')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const _SellerEmptyState(
                  icon: Icons.work_outline,
                  message: 'No open jobs right now',
                  subtitle: 'Check back soon',
                );
              }
              var allDocs = snap.data!.docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                if (data['postedBy'] == widget.sellerUid) return false;
                if (_searchQuery.isNotEmpty) {
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final skills = List<String>.from(
                    data['skills'] ?? [],
                  ).join(' ').toLowerCase();
                  return title.contains(_searchQuery) ||
                      skills.contains(_searchQuery);
                }
                return true;
              }).toList();
              if (widget.sellerCity.isNotEmpty && !_showAllCities) {
                final myCity = widget.sellerCity.toLowerCase().trim();
                final same = allDocs
                    .where(
                      (d) =>
                          ((d.data() as Map)['city'] as String? ?? '')
                              .toLowerCase()
                              .trim() ==
                          myCity,
                    )
                    .toList();
                final other = allDocs
                    .where(
                      (d) =>
                          ((d.data() as Map)['city'] as String? ?? '')
                              .toLowerCase()
                              .trim() !=
                          myCity,
                    )
                    .toList();
                for (final g in [same, other]) {
                  g.sort((a, b) {
                    final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                    final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                    if (aT == null || bT == null) return 0;
                    return bT.compareTo(aT);
                  });
                }
                allDocs = [...same, ...other];
              } else {
                allDocs.sort((a, b) {
                  final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                  final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                  if (aT == null || bT == null) return 0;
                  return bT.compareTo(aT);
                });
              }
              if (allDocs.isEmpty) {
                return const _SellerEmptyState(
                  icon: Icons.search_off,
                  message: 'No jobs match your search',
                  subtitle: 'Try different keywords',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: allDocs.length,
                itemBuilder: (ctx, i) {
                  final data = allDocs[i].data() as Map<String, dynamic>;
                  final isSameCity =
                      widget.sellerCity.isNotEmpty &&
                      (data['city'] as String? ?? '').toLowerCase().trim() ==
                          widget.sellerCity.toLowerCase().trim();
                  return _OpenJobCard(
                    jobId: allDocs[i].id,
                    jobData: data,
                    sellerUid: widget.sellerUid,
                    sellerCity: widget.sellerCity,
                    isSameCity: isSameCity,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OpenJobCard extends StatelessWidget {
  final String jobId, sellerUid, sellerCity;
  final Map<String, dynamic> jobData;
  final bool isSameCity;
  const _OpenJobCard({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
    required this.sellerCity,
    this.isSameCity = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] ?? 'Untitled';
    final budget = (jobData['budget'] ?? 0).toDouble();
    final location = jobData['location'] ?? '';
    final timing = jobData['timing'] ?? '';
    final skills = List<String>.from(jobData['skills'] ?? []);
    final posterName = jobData['posterName'] ?? 'Unknown Client';
    final bidsCount = jobData['bidsCount'] ?? 0;
    final isInsured = (jobData['orderType'] ?? 'simple') == 'insured';
    final postedAt = jobData['postedAt'] as Timestamp?;
    final description = jobData['description'] ?? '';
    final jobCity = jobData['city'] as String? ?? '';
    final currency = jobData['budgetCurrency'] as String? ?? 'PKR';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _JobDetailScreen(
            jobId: jobId,
            jobData: jobData,
            sellerUid: sellerUid,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSameCity
              ? Border.all(color: Colors.green.shade400, width: 2)
              : isInsured
              ? Border.all(color: Colors.blue.shade200, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSameCity
                    ? Colors.green.shade50
                    : isInsured
                    ? Colors.blue.shade50
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isSameCity)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.near_me,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'NEARBY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isInsured) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.shield,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'INSURED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'by $posterName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (jobCity.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_city,
                                size: 12,
                                color: isSameCity
                                    ? Colors.green.shade600
                                    : Colors.grey[400],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                jobCity,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSameCity
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSameCity
                                      ? Colors.green.shade700
                                      : Colors.grey[500],
                                ),
                              ),
                              if (!isSameCity && sellerCity.isNotEmpty)
                                Text(
                                  ' (you: $sellerCity)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${budget.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade700,
                        ),
                      ),
                      if (currency != 'PKR')
                        Text(
                          '($currency)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      Text(
                        'Max Budget',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.isNotEmpty
                              ? location
                              : 'Location not specified',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.schedule, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        timing,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    TranslatedText(
                      text: description,
                      contentId: 'open_$jobId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      showListenButton: false,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills
                        .take(4)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  JobListenRow(
                    title: title,
                    description: description,
                    location: location,
                    timing: timing,
                    jobId: jobId,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: bidsCount > 0
                              ? Colors.orange.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: bidsCount > 0
                                ? Colors.orange.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gavel,
                              size: 13,
                              color: bidsCount > 0
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: bidsCount > 0
                                    ? Colors.orange
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (postedAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM').format(postedAt.toDate()),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _JobDetailScreen(
                                jobId: jobId,
                                jobData: jobData,
                                sellerUid: sellerUid,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.visibility, size: 15),
                          label: const Text('View & Bid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  JOB DETAIL SCREEN — with All Bids + Edit Own Bid
// ═══════════════════════════════════════════════════════════════
class _JobDetailScreen extends StatefulWidget {
  final String jobId, sellerUid;
  final Map<String, dynamic> jobData;
  const _JobDetailScreen({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
  });
  @override
  State<_JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<_JobDetailScreen> {
  bool _alreadyBid = false, _checkingBid = true;
  Map<String, dynamic>? _sellerInfo;
  Map<String, dynamic>?
  _ownBidData; // ← stores own bid details for display/edit

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bidDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .collection('bids')
          .doc(widget.sellerUid)
          .get();
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerUid)
          .get();
      final data = sellerDoc.data() ?? {};
      final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
      final balance = (data['Available_Balance'] ?? 0).toDouble();
      final reserved = (data['Reserved_Commission'] ?? 0).toDouble();
      final freeBalance = balance - reserved;
      final isFree = jobsCompleted < kSellerFreeOrderLimit;

      double rate = 0.10;
      try {
        final cfgDoc = await FirebaseFirestore.instance
            .collection('config')
            .doc('commission')
            .get();
        if (cfgDoc.exists) rate = (cfgDoc.data()?['rate'] ?? 0.10).toDouble();
      } catch (_) {}

      final budget = (widget.jobData['budget'] ?? 0).toDouble();
      final commissionRequired = isFree ? 0.0 : budget * rate;
      final isEligible = isFree || freeBalance >= commissionRequired;

      if (mounted) {
        setState(() {
          _alreadyBid = bidDoc.exists;
          _ownBidData = bidDoc.exists
              ? bidDoc.data() as Map<String, dynamic>
              : null;
          _sellerInfo = {
            'isFree': isFree,
            'freeLeft': isFree ? kSellerFreeOrderLimit - jobsCompleted : 0,
            'balance': balance,
            'reserved': reserved,
            'freeBalance': freeBalance,
            'commissionRequired': commissionRequired,
            'rate': rate,
            'isEligible': isEligible,
            'reason': isEligible
                ? null
                : 'Need PKR ${commissionRequired.toStringAsFixed(0)} free balance. Currently PKR ${freeBalance.toStringAsFixed(0)}.',
          };
          _checkingBid = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _checkingBid = false);
    }
  }

  // ── Called after a successful edit to refresh own bid data ──
  void _refreshOwnBid() async {
    try {
      final bidDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .collection('bids')
          .doc(widget.sellerUid)
          .get();
      if (mounted) {
        setState(
          () => _ownBidData = bidDoc.exists
              ? bidDoc.data() as Map<String, dynamic>
              : null,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.jobData['title'] ?? 'Job Detail';
    final budget = (widget.jobData['budget'] ?? 0).toDouble();
    final location = widget.jobData['location'] ?? '';
    final timing = widget.jobData['timing'] ?? '';
    final description = widget.jobData['description'] ?? '';
    final skills = List<String>.from(widget.jobData['skills'] ?? []);
    final posterName = widget.jobData['posterName'] ?? 'Client';
    final posterImage = widget.jobData['posterImage'] as String?;
    final bidsCount = widget.jobData['bidsCount'] ?? 0;
    final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';
    final postedAt = widget.jobData['postedAt'] as Timestamp?;
    final city = widget.jobData['city'] as String? ?? '';
    final currency = widget.jobData['budgetCurrency'] as String? ?? 'PKR';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [const GlobalLanguageButton(color: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Job Summary Card ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isInsured) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.shield,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'INSURED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    JobListenRow(
                      title: title,
                      description: description,
                      location: location,
                      timing: timing,
                      jobId: widget.jobId,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Max Budget',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'PKR ${budget.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              if (currency != 'PKR')
                                Text(
                                  '(originally $currency)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.gavel,
                                  size: 13,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$bidsCount ${bidsCount == 1 ? 'bid' : 'bids'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.teal.shade100,
                          backgroundImage:
                              posterImage != null && posterImage.isNotEmpty
                              ? NetworkImage(posterImage)
                              : null,
                          child: posterImage == null || posterImage.isEmpty
                              ? Text(
                                  posterName.isNotEmpty
                                      ? posterName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                    fontSize: 14,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Posted by',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              posterName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (postedAt != null) ...[
                          const Spacer(),
                          Text(
                            DateFormat('dd MMM yyyy').format(postedAt.toDate()),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_city,
                              size: 13,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              city,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    if (location.isNotEmpty) ...[
                      _ir(Icons.location_on, 'Address', location),
                      const SizedBox(height: 8),
                    ],
                    if (timing.isNotEmpty) ...[
                      _ir(Icons.schedule, 'Timing', timing),
                      const SizedBox(height: 12),
                    ],
                    if (description.isNotEmpty) ...[
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TranslatedText(
                          text: description,
                          contentId: 'detail_${widget.jobId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          showListenButton: false,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (skills.isNotEmpty) ...[
                      const Text(
                        'Skills Required',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: skills
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Insured notice ──
            if (isInsured) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Insured Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment held by company. Admin releases after 3-day claim window.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Eligibility card ──
            if (_sellerInfo != null) ...[
              _buildEligibilityCard(),
              const SizedBox(height: 16),
            ],

            // ── Bid action section ──
            if (_checkingBid)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else if (_alreadyBid)
              _buildOwnBidSection() // ← NEW: shows own bid + edit button
            else
              _buildPlaceBidSection(budget, isInsured),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════
            // ── ALL BIDS SECTION (NEW) ──────────────────────────────
            // ═══════════════════════════════════════════════════════
            _AllBidsSection(
              jobId: widget.jobId,
              sellerUid: widget.sellerUid,
              sellerInfo: _sellerInfo,
              jobData: widget.jobData,
              onBidEdited: () {
                _refreshOwnBid();
                _loadData();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Own bid section shown when seller already placed a bid ──
  Widget _buildOwnBidSection() {
    final amount = (_ownBidData?['proposedAmount'] ?? 0).toDouble();
    final proposal = _ownBidData?['proposal'] as String? ?? '';
    final status = _ownBidData?['status'] as String? ?? 'pending';
    final createdAt = _ownBidData?['createdAt'] as Timestamp?;
    final isFreeOrder = _ownBidData?['isFreeOrder'] as bool? ?? false;
    final commReserved = (_ownBidData?['commissionReserved'] ?? 0).toDouble();
    final commRate = (_ownBidData?['commissionRate'] ?? 0.10).toDouble();

    Color sc;
    IconData si;
    String sl;
    switch (status) {
      case 'accepted':
        sc = Colors.green;
        si = Icons.check_circle;
        sl = 'ACCEPTED';
        break;
      case 'rejected':
        sc = Colors.red;
        si = Icons.cancel;
        sl = 'REJECTED';
        break;
      default:
        sc = Colors.orange;
        si = Icons.hourglass_empty;
        sl = 'PENDING';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sc.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sc.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel, size: 16, color: sc),
                const SizedBox(width: 8),
                Text(
                  'Your Bid',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: sc,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sc.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(si, size: 12, color: sc),
                      const SizedBox(width: 4),
                      Text(
                        sl,
                        style: TextStyle(
                          color: sc,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bid Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'PKR ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (createdAt != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Submitted',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            DateFormat(
                              'dd MMM, hh:mm a',
                            ).format(createdAt.toDate()),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Commission info
                if (isFreeOrder)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Free order — no commission',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (commReserved > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      '${(commRate * 100).toStringAsFixed(0)}% commission reserved: PKR ${commReserved.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Proposal
                if (proposal.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Proposal',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proposal,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Edit button — only if pending
                if (status == 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => _EditBidSheet(
                          jobId: widget.jobId,
                          jobData: widget.jobData,
                          sellerUid: widget.sellerUid,
                          sellerInfo: _sellerInfo!,
                          existingBid: _ownBidData!,
                          onBidUpdated: () {
                            _refreshOwnBid();
                            _loadData();
                          },
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Edit My Bid',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(
                          color: Colors.green.shade700,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else if (status == 'accepted')
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🎉 Bid accepted! Get ready to start the job.',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (status == 'rejected')
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Buyer chose another seller. Keep bidding on other jobs!',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard() {
    final isFree = _sellerInfo!['isFree'] as bool;
    final freeLeft = _sellerInfo!['freeLeft'] as int;
    final balance = _sellerInfo!['balance'] as double;
    final reserved = _sellerInfo!['reserved'] as double;
    final freeBalance = _sellerInfo!['freeBalance'] as double;
    final commissionRequired = _sellerInfo!['commissionRequired'] as double;
    final rate = _sellerInfo!['rate'] as double;
    final isEligible = _sellerInfo!['isEligible'] as bool;
    final reason = _sellerInfo!['reason'] as String?;

    if (!isEligible) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Cannot Place Bid',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reason != null)
              Text(
                reason,
                style: TextStyle(fontSize: 12, color: Colors.red.shade800),
              ),
            const SizedBox(height: 4),
            _bRow('Wallet', 'PKR ${balance.toStringAsFixed(0)}', Colors.grey),
            if (reserved > 0)
              _bRow(
                'Reserved for other bids',
                '−PKR ${reserved.toStringAsFixed(0)}',
                Colors.orange,
              ),
            _bRow(
              'Free Balance',
              'PKR ${freeBalance.toStringAsFixed(0)}',
              Colors.red,
            ),
            _bRow(
              'Commission needed',
              'PKR ${commissionRequired.toStringAsFixed(0)} (${(rate * 100).toStringAsFixed(0)}%)',
              Colors.red,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_card),
                label: const Text('Deposit Funds to Enable Bidding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (isFree) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎁 Free Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '$freeLeft free order(s) remaining — No commission',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.percent, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 10),
              Text(
                '${(rate * 100).toStringAsFixed(0)}% Commission Per Order',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _bRow('Wallet', 'PKR ${balance.toStringAsFixed(0)}', Colors.teal),
          if (reserved > 0)
            _bRow(
              'Reserved for other bids',
              '−PKR ${reserved.toStringAsFixed(0)}',
              Colors.orange,
            ),
          _bRow(
            'Free Balance',
            'PKR ${freeBalance.toStringAsFixed(0)}',
            Colors.green,
          ),
          _bRow(
            'Commission for this bid',
            '≈ PKR ${commissionRequired.toStringAsFixed(0)}',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceBidSection(double budget, bool isInsured) {
    final isEligible = _sellerInfo?['isEligible'] ?? true;
    if (!isEligible) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.block),
          label: const Text('Cannot Bid — Add Funds First'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PlaceBidSheet(
            jobId: widget.jobId,
            jobData: widget.jobData,
            sellerUid: widget.sellerUid,
            sellerInfo: _sellerInfo!,
            onBidPlaced: () {
              setState(() => _alreadyBid = true);
              _loadData();
            },
          ),
        ),
        icon: const Icon(Icons.gavel),
        label: const Text(
          'Place a Bid',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _ir(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: Colors.grey[500]),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ),
    ],
  );
  Widget _bRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(
          v,
          style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  ALL BIDS SECTION (NEW) — view all competitor bids
// ═══════════════════════════════════════════════════════════════
class _AllBidsSection extends StatelessWidget {
  final String jobId, sellerUid;
  final Map<String, dynamic>? sellerInfo;
  final Map<String, dynamic> jobData;
  final VoidCallback onBidEdited;

  const _AllBidsSection({
    required this.jobId,
    required this.sellerUid,
    required this.sellerInfo,
    required this.jobData,
    required this.onBidEdited,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .collection('bids')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 2,
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                const Icon(Icons.people_outline, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'All Bids on This Job',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    '${docs.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...docs.map((doc) {
              final bid = doc.data() as Map<String, dynamic>;
              final bSellerId = bid['sellerId'] as String? ?? '';
              final isOwn = bSellerId == sellerUid;
              return _BidRowCard(
                bid: bid,
                isOwn: isOwn,
                jobId: jobId,
                sellerUid: sellerUid,
                jobData: jobData,
                sellerInfo: sellerInfo,
                onBidEdited: onBidEdited,
              );
            }),
          ],
        );
      },
    );
  }
}

// ── Single bid row card inside the all-bids list ──────────────
class _BidRowCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final bool isOwn;
  final String jobId, sellerUid;
  final Map<String, dynamic> jobData;
  final Map<String, dynamic>? sellerInfo;
  final VoidCallback onBidEdited;

  const _BidRowCard({
    required this.bid,
    required this.isOwn,
    required this.jobId,
    required this.sellerUid,
    required this.jobData,
    required this.sellerInfo,
    required this.onBidEdited,
  });

  @override
  Widget build(BuildContext context) {
    final sellerName = bid['sellerName'] as String? ?? 'Seller';
    final sellerImage = bid['sellerImage'] as String? ?? '';
    final amount = (bid['proposedAmount'] ?? 0).toDouble();
    final rating = (bid['rating'] ?? 0.0).toDouble();
    final proposal = bid['proposal'] as String? ?? '';
    final skills = List<String>.from(bid['skills'] ?? []);
    final createdAt = bid['createdAt'] as Timestamp?;
    final status = bid['status'] as String? ?? 'pending';
    final isFreeOrder = bid['isFreeOrder'] as bool? ?? false;
    final commReserved = (bid['commissionReserved'] ?? 0).toDouble();
    final commRate = (bid['commissionRate'] ?? 0.10).toDouble();

    Color sc;
    switch (status) {
      case 'accepted':
        sc = Colors.green;
        break;
      case 'rejected':
        sc = Colors.red.shade300;
        break;
      default:
        sc = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isOwn ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwn ? Colors.green.shade400 : Colors.grey.shade200,
          width: isOwn ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: isOwn ? 22 : 18,
                  backgroundColor: isOwn
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  backgroundImage: sellerImage.isNotEmpty
                      ? NetworkImage(sellerImage)
                      : null,
                  child: sellerImage.isEmpty
                      ? Text(
                          sellerName.isNotEmpty
                              ? sellerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOwn
                                ? Colors.green.shade700
                                : Colors.grey[600],
                            fontSize: isOwn ? 16 : 13,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isOwn ? 'You ($sellerName)' : sellerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isOwn ? 14 : 13,
                                color: isOwn
                                    ? Colors.green.shade800
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isOwn)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (rating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOwn ? Colors.green.shade700 : Colors.grey[800],
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        DateFormat(
                          'dd MMM, hh:mm a',
                        ).format(createdAt.toDate()),
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: sc,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Commission info for own bid
            if (isOwn) ...[
              const SizedBox(height: 6),
              isFreeOrder
                  ? _chip('🎁 Free order', Colors.green)
                  : _chip(
                      '${(commRate * 100).toStringAsFixed(0)}% comm reserved: PKR ${commReserved.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
            ],

            // Skills (compact)
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 3,
                children: skills
                    .take(3)
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOwn
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 10,
                            color: isOwn
                                ? Colors.green.shade700
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Proposal — own bid shows full, others show truncated
            if (proposal.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOwn ? Colors.white : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOwn ? Colors.green.shade200 : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  proposal,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: isOwn ? null : 2,
                  overflow: isOwn ? null : TextOverflow.ellipsis,
                ),
              ),
            ],

            // Edit button for own pending bid
            if (isOwn && status == 'pending' && sellerInfo != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => _EditBidSheet(
                      jobId: jobId,
                      jobData: jobData,
                      sellerUid: sellerUid,
                      sellerInfo: sellerInfo!,
                      existingBid: bid,
                      onBidUpdated: onBidEdited,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text(
                    'Edit Bid',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: c.withOpacity(0.3)),
    ),
    child: Text(
      t,
      style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w600),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  EDIT BID SHEET (NEW)
// ═══════════════════════════════════════════════════════════════
class _EditBidSheet extends StatefulWidget {
  final String jobId, sellerUid;
  final Map<String, dynamic> jobData, sellerInfo, existingBid;
  final VoidCallback onBidUpdated;

  const _EditBidSheet({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
    required this.sellerInfo,
    required this.existingBid,
    required this.onBidUpdated,
  });

  @override
  State<_EditBidSheet> createState() => _EditBidSheetState();
}

class _EditBidSheetState extends State<_EditBidSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _proposalCtrl;
  bool _isSubmitting = false;
  double? _liveCommission;

  @override
  void initState() {
    super.initState();
    final existingAmount = (widget.existingBid['proposedAmount'] ?? 0)
        .toDouble();
    _amountCtrl = TextEditingController(
      text: existingAmount.toStringAsFixed(0),
    );
    _proposalCtrl = TextEditingController(
      text: widget.existingBid['proposal'] as String? ?? '',
    );
    // Pre-compute live commission for the existing amount
    _onAmountChanged(existingAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _proposalCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final amount = double.tryParse(val);
    final rate = widget.sellerInfo['rate'] as double? ?? 0.10;
    final isFree = widget.sellerInfo['isFree'] as bool? ?? false;
    if (amount == null || isFree) {
      setState(() => _liveCommission = null);
      return;
    }
    setState(() => _liveCommission = amount * rate);
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final newAmount = double.parse(_amountCtrl.text.trim());
      final budget = (widget.jobData['budget'] ?? 0).toDouble();
      if (newAmount > budget) {
        _snack(
          'Bid cannot exceed PKR ${budget.toStringAsFixed(0)}',
          Colors.red,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Re-read fresh seller data
      final sellerDoc = await db
          .collection('sellers')
          .doc(widget.sellerUid)
          .get();
      final sData = sellerDoc.data() ?? {};
      final jobsCompleted = (sData['Jobs_Completed'] ?? 0) as int;
      final balance = (sData['Available_Balance'] ?? 0).toDouble();
      final reserved = (sData['Reserved_Commission'] ?? 0).toDouble();
      final isFree = jobsCompleted < kSellerFreeOrderLimit;

      double rate = widget.sellerInfo['rate'] as double? ?? 0.10;
      try {
        final cfg = await db.collection('config').doc('commission').get();
        if (cfg.exists) rate = (cfg.data()?['rate'] ?? rate).toDouble();
      } catch (_) {}

      final newCommission = isFree ? 0.0 : newAmount * rate;
      final oldCommission = (widget.existingBid['commissionReserved'] ?? 0)
          .toDouble();
      final delta =
          newCommission -
          oldCommission; // positive = need more, negative = release some
      final freeBalance = balance - reserved;

      // Only check if we need MORE commission than before
      if (!isFree && delta > 0 && freeBalance < delta) {
        _snack(
          'Insufficient free balance. Need PKR ${delta.toStringAsFixed(0)} more.',
          Colors.red,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final updatedPayload = {
        'proposedAmount': newAmount,
        'proposal': _proposalCtrl.text.trim(),
        'commissionRate': rate,
        'commissionReserved': newCommission,
        'isFreeOrder': isFree,
        'editedAt': FieldValue.serverTimestamp(),
      };

      final batch = db.batch();
      // Update bid in jobs subcollection
      batch.update(
        db
            .collection('jobs')
            .doc(widget.jobId)
            .collection('bids')
            .doc(widget.sellerUid),
        updatedPayload,
      );
      // Update bid in seller's myBids subcollection
      batch.update(
        db
            .collection('sellers')
            .doc(widget.sellerUid)
            .collection('myBids')
            .doc(widget.jobId),
        updatedPayload,
      );
      // Adjust Reserved_Commission by the delta
      if (!isFree && delta != 0) {
        batch.update(db.collection('sellers').doc(widget.sellerUid), {
          'Reserved_Commission': FieldValue.increment(delta),
        });
      }
      await batch.commit();

      if (!mounted) return;
      widget.onBidUpdated();
      Navigator.pop(context);
      _snack(
        '✅ Bid updated to PKR ${newAmount.toStringAsFixed(0)}',
        Colors.green,
      );
    } catch (e) {
      _snack('Error: $e', Colors.red);
      setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  @override
  Widget build(BuildContext context) {
    final budget = (widget.jobData['budget'] ?? 0).toDouble();
    final title = widget.jobData['title'] ?? '';
    final isFree = widget.sellerInfo['isFree'] as bool? ?? false;
    final freeLeft = widget.sellerInfo['freeLeft'] as int? ?? 0;
    final balance = widget.sellerInfo['balance'] as double? ?? 0;
    final reserved = widget.sellerInfo['reserved'] as double? ?? 0;
    final freeBalance = widget.sellerInfo['freeBalance'] as double? ?? balance;
    final rate = widget.sellerInfo['rate'] as double? ?? 0.10;
    final oldAmount = (widget.existingBid['proposedAmount'] ?? 0).toDouble();
    final oldCommission = (widget.existingBid['commissionReserved'] ?? 0)
        .toDouble();
    final delta = (_liveCommission ?? 0) - oldCommission;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 200 // MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Your Bid',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const GlobalLanguageButton(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'For: $title',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),

              // Previous bid info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Previous bid: PKR ${oldAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Max: PKR ${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Balance overview
              if (!isFree)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Wallet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(rate * 100).toStringAsFixed(0)}% commission',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _bRow(
                        'Wallet',
                        'PKR ${balance.toStringAsFixed(0)}',
                        Colors.teal,
                      ),
                      if (reserved > 0)
                        _bRow(
                          'Reserved (all bids)',
                          '−PKR ${reserved.toStringAsFixed(0)}',
                          Colors.orange,
                        ),
                      _bRow(
                        'Free Balance',
                        'PKR ${freeBalance.toStringAsFixed(0)}',
                        Colors.green,
                      ),
                      if (oldCommission > 0)
                        _bRow(
                          'Already reserved for this bid',
                          'PKR ${oldCommission.toStringAsFixed(0)}',
                          Colors.blue,
                        ),
                      if (_liveCommission != null) ...[
                        const Divider(height: 10),
                        _bRow(
                          'New commission for this bid',
                          'PKR ${_liveCommission!.toStringAsFixed(0)}',
                          Colors.orange,
                        ),
                        _bRow(
                          'Commission adjustment',
                          '${delta >= 0 ? '+' : ''}PKR ${delta.toStringAsFixed(0)}',
                          delta > 0 ? Colors.red : Colors.green,
                        ),
                        _bRow(
                          'Free balance after update',
                          'PKR ${(freeBalance - delta).toStringAsFixed(0)}',
                          (freeBalance - delta) < 0 ? Colors.red : Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              if (isFree)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🎁 Free order ($freeLeft left) — No commission required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Amount field
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'New Bid Amount (PKR)',
                  prefixText: 'PKR ',
                  prefixIcon: const Icon(
                    Icons.payments_outlined,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText: 'Must be ≤ PKR ${budget.toStringAsFixed(0)}',
                ),
                onChanged: _onAmountChanged,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter bid amount';
                  final amt = double.tryParse(v);
                  if (amt == null || amt <= 0) return 'Enter valid amount';
                  if (amt > budget) {
                    return 'Cannot exceed PKR ${budget.toStringAsFixed(0)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Proposal field
              TextFormField(
                controller: _proposalCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Update Your Proposal',
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText: 'Improve your pitch to stand out',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Write a proposal' : null,
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isSubmitting ? 'Updating...' : 'Update Bid',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(
          v,
          style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  PLACE BID SHEET — unchanged from original
// ═══════════════════════════════════════════════════════════════
class _PlaceBidSheet extends StatefulWidget {
  final String jobId, sellerUid;
  final Map<String, dynamic> jobData, sellerInfo;
  final VoidCallback onBidPlaced;
  const _PlaceBidSheet({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
    required this.sellerInfo,
    required this.onBidPlaced,
  });
  @override
  State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends State<_PlaceBidSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _proposalCtrl = TextEditingController();
  bool _isSubmitting = false;
  double? _liveCommission;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _proposalCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final amount = double.tryParse(val);
    final rate = widget.sellerInfo['rate'] as double? ?? 0.10;
    final isFree = widget.sellerInfo['isFree'] as bool? ?? false;
    if (amount == null || isFree) {
      setState(() => _liveCommission = null);
      return;
    }
    setState(() => _liveCommission = amount * rate);
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final amount = double.parse(_amountCtrl.text.trim());
      final budget = (widget.jobData['budget'] ?? 0).toDouble();
      if (amount > budget) {
        _snack(
          'Bid cannot exceed PKR ${budget.toStringAsFixed(0)}',
          Colors.red,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final sellerDoc = await db
          .collection('sellers')
          .doc(widget.sellerUid)
          .get();
      final sData = sellerDoc.data() ?? {};
      final jobsCompleted = (sData['Jobs_Completed'] ?? 0) as int;
      final balance = (sData['Available_Balance'] ?? 0).toDouble();
      final reserved = (sData['Reserved_Commission'] ?? 0).toDouble();
      final freeBalance = balance - reserved;
      final isFree = jobsCompleted < kSellerFreeOrderLimit;

      double rate = widget.sellerInfo['rate'] as double? ?? 0.10;
      try {
        final cfg = await db.collection('config').doc('commission').get();
        if (cfg.exists) rate = (cfg.data()?['rate'] ?? rate).toDouble();
      } catch (_) {}

      final commissionRequired = isFree ? 0.0 : amount * rate;
      final canBid = isFree || freeBalance >= commissionRequired;

      if (!canBid) {
        _snack(
          'Insufficient balance. Need PKR ${commissionRequired.toStringAsFixed(0)} free. Available: PKR ${freeBalance.toStringAsFixed(0)}',
          Colors.red,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final userDoc = await db.collection('users').doc(widget.sellerUid).get();
      final userData = userDoc.data() ?? {};
      final sellerName =
          '${sData['firstName'] ?? ''} ${sData['lastName'] ?? ''}'.trim();
      final sellerImage = userData['profileImage'] ?? '';
      final sellerRating = (sData['Rating'] ?? 0).toDouble();
      final sellerSkills = List<String>.from(sData['skills'] ?? []);

      final bidPayload = {
        'sellerId': widget.sellerUid,
        'sellerName': sellerName,
        'sellerImage': sellerImage,
        'rating': sellerRating,
        'skills': sellerSkills,
        'jobsCompleted': jobsCompleted,
        'proposedAmount': amount,
        'proposal': _proposalCtrl.text.trim(),
        'status': 'pending',
        'jobId': widget.jobId,
        'jobTitle': widget.jobData['title'] ?? '',
        'jobBudget': budget,
        'posterName': widget.jobData['posterName'] ?? '',
        'isInsured': (widget.jobData['orderType'] ?? 'simple') == 'insured',
        'commissionRate': rate,
        'commissionReserved': commissionRequired,
        'isFreeOrder': isFree,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final batch = db.batch();
      batch.set(
        db
            .collection('jobs')
            .doc(widget.jobId)
            .collection('bids')
            .doc(widget.sellerUid),
        bidPayload,
      );
      batch.set(
        db
            .collection('sellers')
            .doc(widget.sellerUid)
            .collection('myBids')
            .doc(widget.jobId),
        bidPayload,
      );
      batch.update(db.collection('jobs').doc(widget.jobId), {
        'bidsCount': FieldValue.increment(1),
      });
      if (!isFree && commissionRequired > 0) {
        batch.update(db.collection('sellers').doc(widget.sellerUid), {
          'Reserved_Commission': FieldValue.increment(commissionRequired),
        });
      }
      await batch.commit();

      final buyerUid = widget.jobData['postedBy'] as String? ?? '';
      if (buyerUid.isNotEmpty) {
        await NotificationService.send(
          toUid: buyerUid,
          title: '🔔 New Bid Received',
          body:
              '$sellerName placed a bid on "${widget.jobData['title']}" for PKR ${amount.toStringAsFixed(0)}.',
          type: 'bid_received',
          jobId: widget.jobId,
          relatedUserName: sellerName,
        );
      }
      if (!mounted) return;
      widget.onBidPlaced();
      Navigator.pop(context);
      final msg = isFree
          ? '✅ Bid placed! (Free order — no commission)'
          : '✅ Bid placed! PKR ${commissionRequired.toStringAsFixed(0)} reserved for commission.';
      _snack(msg, Colors.green);
    } catch (e) {
      _snack('Error: $e', Colors.red);
      setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  @override
  Widget build(BuildContext context) {
    final budget = (widget.jobData['budget'] ?? 0).toDouble();
    final title = widget.jobData['title'] ?? '';
    final isFree = widget.sellerInfo['isFree'] as bool? ?? false;
    final freeLeft = widget.sellerInfo['freeLeft'] as int? ?? 0;
    final balance = widget.sellerInfo['balance'] as double? ?? 0;
    final reserved = widget.sellerInfo['reserved'] as double? ?? 0;
    final freeBalance = widget.sellerInfo['freeBalance'] as double? ?? balance;
    final isEligible = widget.sellerInfo['isEligible'] as bool? ?? true;
    final rate = widget.sellerInfo['rate'] as double? ?? 0.10;
    final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 150 // MediaQuery.of(context).viewInsets.bottom ,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Place a Bid',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const GlobalLanguageButton(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'For: $title',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Max Budget: PKR ${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isInsured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shield, size: 12, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Insured',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (!isFree)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isEligible
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isEligible
                          ? Colors.green.shade200
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEligible
                                ? Icons.account_balance_wallet
                                : Icons.warning_amber_rounded,
                            size: 15,
                            color: isEligible
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isEligible
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(rate * 100).toStringAsFixed(0)}% commission',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _bRow(
                        'Wallet',
                        'PKR ${balance.toStringAsFixed(0)}',
                        Colors.teal,
                      ),
                      if (reserved > 0)
                        _bRow(
                          'Reserved (other bids)',
                          '−PKR ${reserved.toStringAsFixed(0)}',
                          Colors.orange,
                        ),
                      _bRow(
                        'Free Balance',
                        'PKR ${freeBalance.toStringAsFixed(0)}',
                        freeBalance <= 0 ? Colors.red : Colors.green,
                      ),
                      if (_liveCommission != null) ...[
                        const Divider(height: 10),
                        _bRow(
                          'Commission for this bid',
                          'PKR ${_liveCommission!.toStringAsFixed(0)}',
                          Colors.orange,
                        ),
                        _bRow(
                          'Balance after bid',
                          'PKR ${(freeBalance - _liveCommission!).toStringAsFixed(0)}',
                          (freeBalance - _liveCommission!) < 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ],
                      if (!isEligible) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.sellerInfo['reason'] as String? ??
                              'Deposit funds to place bids.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (isFree)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🎁 Free order ($freeLeft left) — No commission required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isInsured)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '💵 Cash on Delivery — Collect payment directly from buyer. Commission deducted from wallet when order is placed.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Your Bid Amount (PKR)',
                  prefixText: 'PKR ',
                  prefixIcon: const Icon(
                    Icons.payments_outlined,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText: 'Must be ≤ PKR ${budget.toStringAsFixed(0)}',
                ),
                onChanged: _onAmountChanged,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter bid amount';
                  final amt = double.tryParse(v);
                  if (amt == null || amt <= 0) return 'Enter valid amount';
                  if (amt > budget) {
                    return 'Cannot exceed PKR ${budget.toStringAsFixed(0)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _proposalCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your Proposal',
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText: 'Why are you the best choice?',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Write a proposal' : null,
              ),
              const SizedBox(height: 20),
              if (!isEligible)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add_card),
                    label: const Text('Deposit Funds to Enable Bidding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitBid,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.gavel),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Bid',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(
          v,
          style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  MY BIDS TAB — unchanged
// ═══════════════════════════════════════════════════════════════
class _MyBidsList extends StatelessWidget {
  final String sellerUid;
  const _MyBidsList({required this.sellerUid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .collection('myBids')
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const _SellerEmptyState(
            icon: Icons.gavel,
            message: 'No bids placed yet',
            subtitle: 'Browse open jobs and place your first bid',
          );
        }
        final docs = snap.data!.docs.toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['createdAt'] as Timestamp?;
            final bT = (b.data() as Map)['createdAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final bid = docs[i].data() as Map<String, dynamic>;
            final jobId = bid['jobId'] as String? ?? docs[i].id;
            return _MyBidCard(bid: bid, jobId: jobId, sellerUid: sellerUid);
          },
        );
      },
    );
  }
}

class _MyBidCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final String jobId, sellerUid;
  const _MyBidCard({
    required this.bid,
    required this.jobId,
    required this.sellerUid,
  });
  @override
  Widget build(BuildContext context) {
    final amount = (bid['proposedAmount'] ?? 0).toDouble();
    final proposal = bid['proposal'] ?? '';
    final createdAt = bid['createdAt'] as Timestamp?;
    final jobTitle = bid['jobTitle'] ?? 'Loading...';
    final posterName = bid['posterName'] ?? '';
    final jobBudget = (bid['jobBudget'] ?? 0).toDouble();
    final isInsured = bid['isInsured'] ?? false;
    final commRate = (bid['commissionRate'] ?? 0.10).toDouble();
    final commReserved = (bid['commissionReserved'] ?? 0).toDouble();
    final isFreeOrder = bid['isFreeOrder'] ?? false;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .collection('bids')
          .doc(sellerUid)
          .snapshots(),
      builder: (ctx, bidSnap) {
        final liveBid = bidSnap.data?.data() as Map<String, dynamic>? ?? {};
        final status = liveBid['status'] ?? bid['status'] ?? 'pending';
        Color sc;
        IconData si;
        switch (status) {
          case 'accepted':
            sc = Colors.green;
            si = Icons.check_circle;
            break;
          case 'rejected':
            sc = Colors.red;
            si = Icons.cancel;
            break;
          default:
            sc = Colors.orange;
            si = Icons.hourglass_empty;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: status == 'accepted'
                  ? Colors.green.shade200
                  : status == 'rejected'
                  ? Colors.red.shade100
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  jobTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isInsured == true)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.shield,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                          if (posterName.isNotEmpty)
                            Text(
                              'Client: $posterName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(si, size: 12, color: sc),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: sc,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isInsured != true) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '💵 Cash on Delivery',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isFreeOrder && commReserved > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(commRate * 100).toStringAsFixed(0)}% commission reserved: PKR ${commReserved.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
                const Divider(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Bid',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'PKR ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Budget',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'PKR ${jobBudget.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (createdAt != null)
                      Text(
                        DateFormat('dd MMM').format(createdAt.toDate()),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
                if (proposal.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TranslatedText(
                      text: proposal,
                      contentId: 'mybid_${jobId}_$sellerUid',
                      style: const TextStyle(fontSize: 13),
                      showListenButton: false,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (status == 'accepted')
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isInsured == true
                                ? '🎉 Accepted! Wait for buyer to pay before starting.'
                                : '🎉 Accepted! Collect cash on job completion.',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (status == 'rejected')
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Buyer chose another seller. Keep bidding!',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_top,
                          color: Colors.orange.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Waiting for buyer to review your bid.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACTIVE JOBS TAB — unchanged
// ═══════════════════════════════════════════════════════════════
class _ActiveJobsList extends StatelessWidget {
  final String sellerUid;
  const _ActiveJobsList({required this.sellerUid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('acceptedBidder', isEqualTo: sellerUid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }
        if (!snap.hasData) {
          return const _SellerEmptyState(
            icon: Icons.construction,
            message: 'No active jobs',
            subtitle: 'Win a bid to start working',
          );
        }
        final active = snap.data!.docs.where((d) {
          final s = (d.data() as Map)['status'];
          return s == 'in_progress' || s == 'claim_pending';
        }).toList();
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('expertUid', isEqualTo: sellerUid)
              .snapshots(),
          builder: (ctx, eSnap) {
            final expertJobs = (eSnap.data?.docs ?? [])
                .where((d) => (d.data() as Map)['status'] == 'expert_assigned')
                .toList();
            final allIds = <String>{};
            final combined = <QueryDocumentSnapshot>[];
            for (final d in [...active, ...expertJobs]) {
              if (allIds.add(d.id)) combined.add(d);
            }
            if (combined.isEmpty) {
              return const _SellerEmptyState(
                icon: Icons.construction,
                message: 'No active jobs',
                subtitle: 'Win a bid to start working',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: combined.length,
              itemBuilder: (ctx, i) {
                final data = combined[i].data() as Map<String, dynamic>;
                final isExpert = expertJobs.any((d) => d.id == combined[i].id);
                return _ActiveJobCard(
                  jobId: combined[i].id,
                  jobData: data,
                  sellerUid: sellerUid,
                  isExpertRole: isExpert,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ActiveJobCard extends StatefulWidget {
  final String jobId, sellerUid;
  final Map<String, dynamic> jobData;
  final bool isExpertRole;
  const _ActiveJobCard({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
    this.isExpertRole = false,
  });
  @override
  State<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends State<_ActiveJobCard> {
  bool _isCompleting = false;
  bool get _isClaim => widget.jobData['status'] == 'claim_pending';
  bool get _isInsured => (widget.jobData['orderType'] ?? 'simple') == 'insured';

  Future<void> _markCompleted() async {
    setState(() => _isCompleting = true);
    try {
      final db = FirebaseFirestore.instance;
      final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
      final claimDeadline = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 3)),
      );
      final newStatus = widget.isExpertRole ? 'expert_completed' : 'completed';
      final batch = db.batch();

      batch.update(db.collection('jobs').doc(widget.jobId), {
        'status': newStatus,
        'completedAt': FieldValue.serverTimestamp(),
        'claimDeadline': claimDeadline,
        'paymentStatus': _isInsured ? 'locked' : 'released',
        'insuranceClaimed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(db.collection('sellers').doc(widget.sellerUid), {
        'Jobs_Completed': FieldValue.increment(1),
        'Total_Jobs': FieldValue.increment(1),
        'Pending_Jobs': FieldValue.increment(-1),
        'Earning': FieldValue.increment(acceptedAmount),
      });
      await batch.commit();

      final buyerUid = widget.jobData['postedBy'] as String? ?? '';
      if (buyerUid.isNotEmpty) {
        await NotificationService.send(
          toUid: buyerUid,
          title: widget.isExpertRole
              ? '⭐ Expert completed your job'
              : '✅ Job Marked Complete',
          body: _isInsured
              ? 'Your job "${widget.jobData['title']}" is complete. You can confirm satisfaction or claim insurance.'
              : 'Job "${widget.jobData['title']}" is done. Cash payment goes to the worker directly.',
          type: 'job_completed',
          jobId: widget.jobId,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInsured
                ? '✅ Job done! Buyer can confirm satisfaction. Admin will release earnings.'
                : '🎉 Job done! Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from buyer.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Future<void> _openChat(BuildContext context) async {
    final buyerId = widget.jobData['postedBy'] as String? ?? '';
    final posterName = widget.jobData['posterName'] as String? ?? 'Client';
    final posterImg = widget.jobData['posterImage'] as String? ?? '';
    if (buyerId.isEmpty) return;

    final db = FirebaseFirestore.instance;
    final phones = [widget.sellerUid, buyerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';

    if (!(await db.collection('conversations').doc(convId).get()).exists) {
      final buyerDoc = await db.collection('users').doc(buyerId).get();
      final buyerData = buyerDoc.data() ?? {};
      final sellerDoc = await db
          .collection('users')
          .doc(widget.sellerUid)
          .get();
      final sellerData = sellerDoc.data() ?? {};
      await db.collection('conversations').doc(convId).set({
        'participantIds': [widget.sellerUid, buyerId],
        'participantNames': {
          widget.sellerUid:
              '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'
                  .trim(),
          buyerId: posterName,
        },
        'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'},
        'participantProfileImages': {
          widget.sellerUid: sellerData['profileImage'] ?? '',
          buyerId: buyerData['profileImage'] ?? '',
        },
        'lastMessage': '',
        'lastMessageAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'unreadCounts': {widget.sellerUid: 0, buyerId: 0},
        'relatedJobId': widget.jobId,
        'relatedJobTitle': widget.jobData['title'] ?? '',
      });
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            convId: convId,
            myUid: widget.sellerUid,
            otherUid: buyerId,
            otherName: posterName,
            otherImage: posterImg,
            otherRole: 'buyer',
            jobTitle: widget.jobData['title'] as String? ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.jobData['title'] ?? '';
    final posterName = widget.jobData['posterName'] ?? 'Client';
    final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
    final skills = List<String>.from(widget.jobData['skills'] ?? []);
    final location = widget.jobData['location'] ?? '';
    final description = widget.jobData['description'] ?? '';
    final city = widget.jobData['city'] as String? ?? '';
    Color hc;
    String sl;
    Color slc;
    if (widget.isExpertRole) {
      hc = Colors.purple.shade50;
      sl = 'EXPERT ROLE';
      slc = Colors.purple;
    } else if (_isClaim) {
      hc = Colors.red.shade50;
      sl = 'REVISIT REQUIRED';
      slc = Colors.red;
    } else {
      hc = _isInsured ? Colors.blue.shade50 : Colors.green.shade50;
      sl = 'IN PROGRESS';
      slc = Colors.blue;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isExpertRole
              ? Colors.purple.shade300
              : _isClaim
              ? Colors.red.shade300
              : _isInsured
              ? Colors.blue.shade200
              : Colors.green.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hc,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: slc.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sl,
                              style: TextStyle(
                                color: slc,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isInsured) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.shield,
                                    size: 9,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'INS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Client: $posterName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (city.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_city,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              city,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${acceptedAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.isExpertRole
                            ? Colors.purple
                            : _isInsured
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    Text(
                      _isInsured ? 'Held by company' : 'Cash on delivery',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isClaim)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Buyer claimed insurance — revisit and complete the job properly.',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.isExpertRole)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.purple.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are assigned as expert. Assist the seller to deliver the best results.',
                            style: TextStyle(
                              color: Colors.purple.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (location.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (description.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TranslatedText(
                      text: description,
                      contentId: 'active_${widget.jobId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      showListenButton: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                JobListenRow(
                  title: title,
                  description: description,
                  location: location,
                  timing: widget.jobData['timing'] ?? '',
                  jobId: widget.jobId,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isInsured
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isInsured
                          ? Colors.blue.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isInsured
                            ? Icons.lock_outline
                            : Icons.payments_outlined,
                        size: 14,
                        color: _isInsured
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isInsured
                              ? 'Payment locked. Admin releases after claim window passes.'
                              : '💵 Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from client directly.',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isInsured
                                ? Colors.blue.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: skills
                      .take(3)
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openChat(context),
                        icon: const Icon(Icons.message_outlined, size: 16),
                        label: const Text('Message Client'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCompleting ? null : _markCompleted,
                        icon: _isCompleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          _isCompleting
                              ? 'Updating...'
                              : widget.isExpertRole
                              ? 'Mark Expert Done'
                              : 'Mark Done',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isExpertRole
                              ? Colors.purple
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SELLER HISTORY TAB — unchanged
// ═══════════════════════════════════════════════════════════════
class _SellerHistoryTab extends StatelessWidget {
  final String sellerUid;
  const _SellerHistoryTab({required this.sellerUid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .snapshots(),
      builder: (ctx, sellerSnap) {
        final sd = sellerSnap.data?.data() as Map<String, dynamic>? ?? {};
        final totalEarning = (sd['Earning'] ?? 0).toDouble();
        final balance = (sd['Available_Balance'] ?? 0).toDouble();
        final rating = (sd['Rating'] ?? 0.0).toDouble();
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('acceptedBidder', isEqualTo: sellerUid)
              .snapshots(),
          builder: (ctx, snap) => StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .where('expertUid', isEqualTo: sellerUid)
                .snapshots(),
            builder: (ctx, eSnap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }
              final allIds = <String>{};
              final allDocs = <QueryDocumentSnapshot>[];
              for (final d in [
                ...(snap.data?.docs ?? []),
                ...(eSnap.data?.docs ?? []),
              ]) {
                if (allIds.add(d.id)) allDocs.add(d);
              }
              allDocs.sort((a, b) {
                final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                if (aT == null || bT == null) return 0;
                return bT.compareTo(aT);
              });
              final completedJobs = allDocs.where((d) {
                final s = (d.data() as Map)['status'];
                return s == 'completed' || s == 'expert_completed';
              }).length;
              final activeJobs = allDocs
                  .where((d) => (d.data() as Map)['status'] == 'in_progress')
                  .length;
              final insuredJobs = allDocs
                  .where((d) => (d.data() as Map)['orderType'] == 'insured')
                  .length;
              final cashJobs = allDocs
                  .where((d) => (d.data() as Map)['orderType'] == 'simple')
                  .length;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Earnings Overview',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PKR ${totalEarning.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Net Earned (Cash + Insurance total)',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        Row(
                          children: [
                            _et(
                              'Wallet',
                              'PKR ${balance.toStringAsFixed(0)}',
                              Icons.wallet,
                            ),
                            _et(
                              'Rating',
                              '${rating.toStringAsFixed(1)} ⭐',
                              Icons.star,
                            ),
                            _et('Done', '$completedJobs', Icons.task_alt),
                            _et('Active', '$activeJobs', Icons.autorenew),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _et(
                              'Insured',
                              '$insuredJobs',
                              Icons.shield_outlined,
                            ),
                            _et('Cash', '$cashJobs', Icons.payments_outlined),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '💡 Cash: collected from buyer. Insurance: released to wallet by admin.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BankDetailsSection(sellerUid: sellerUid, jobs: allDocs),
                  if (allDocs.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No job history yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ...allDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _SellerHistoryCard(
                      jobData: data,
                      jobId: doc.id,
                      sellerUid: sellerUid,
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _et(String l, String v, IconData i) => Expanded(
    child: Column(
      children: [
        Icon(i, color: Colors.white60, size: 16),
        const SizedBox(height: 2),
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    ),
  );
}

class _BankDetailsSection extends StatefulWidget {
  final String sellerUid;
  final List<QueryDocumentSnapshot> jobs;
  const _BankDetailsSection({required this.sellerUid, required this.jobs});
  @override
  State<_BankDetailsSection> createState() => _BankDetailsSectionState();
}

class _BankDetailsSectionState extends State<_BankDetailsSection> {
  bool _hasBankDetails = false, _loading = true, _hasInsuredCompleted = false;
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final bankDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerUid)
          .collection('bankDetails')
          .doc('primary')
          .get();
      final insuredDone = widget.jobs.any((d) {
        final data = d.data() as Map;
        return (data['orderType'] == 'insured') &&
            (data['status'] == 'completed' ||
                data['status'] == 'expert_completed') &&
            data['paymentStatus'] != 'released';
      });
      if (mounted) {
        setState(() {
          _hasBankDetails = bankDoc.exists;
          _hasInsuredCompleted = insuredDone;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showBankDetailsSheet() {
    final bankCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Bank Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account Title',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (bankCtrl.text.trim().isEmpty ||
                        titleCtrl.text.trim().isEmpty ||
                        numCtrl.text.trim().isEmpty) {
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('sellers')
                        .doc(widget.sellerUid)
                        .collection('bankDetails')
                        .doc('primary')
                        .set({
                          'bankName': bankCtrl.text.trim(),
                          'accountTitle': titleCtrl.text.trim(),
                          'accountNumber': numCtrl.text.trim(),
                          'addedAt': FieldValue.serverTimestamp(),
                        });
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() => _hasBankDetails = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✅ Bank details saved! Admin will transfer your earnings.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Bank Details',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_hasInsuredCompleted) return const SizedBox();
    if (_hasBankDetails) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bank details saved. Admin will transfer your insured earnings.',
                style: TextStyle(color: Colors.green.shade800, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade400, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💰 Add Bank Details to Receive Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your insured job is complete! Add your bank account so admin can transfer your earnings.',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showBankDetailsSheet,
              icon: const Icon(Icons.add_card),
              label: const Text('Add Bank Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerHistoryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId, sellerUid;
  const _SellerHistoryCard({
    required this.jobData,
    required this.jobId,
    required this.sellerUid,
  });
  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] ?? 'Untitled';
    final status = jobData['status'] ?? 'open';
    final orderType = jobData['orderType'] ?? 'simple';
    final acceptedAmount = (jobData['acceptedAmount'] ?? 0).toDouble();
    final postedAt = jobData['postedAt'] as Timestamp?;
    final completedAt = jobData['completedAt'] as Timestamp?;
    final posterName = jobData['posterName'] ?? '';
    final location = jobData['location'] ?? '';
    final city = jobData['city'] as String? ?? '';
    final isInsured = orderType == 'insured';
    final paymentStatus = jobData['paymentStatus'] ?? '';
    final isExpertRole = jobData['expertUid'] == sellerUid;
    final buyerRating = (jobData['buyerRating'] ?? 0) as int;
    final buyerFeedback = jobData['buyerFeedback'] as String? ?? '';
    final commRate = (jobData['commissionRate'] ?? 0.0).toDouble();
    final commAmount = (jobData['commissionAmount'] ?? 0.0).toDouble();
    Color sc;
    String sl;
    switch (status) {
      case 'completed':
      case 'expert_completed':
        sc = Colors.green;
        sl = 'Completed';
        break;
      case 'in_progress':
        sc = Colors.blue;
        sl = 'In Progress';
        break;
      case 'claim_pending':
        sc = Colors.red;
        sl = 'Claim Filed';
        break;
      case 'expert_assigned':
        sc = Colors.purple;
        sl = 'Expert Sent';
        break;
      case 'cancelled':
        sc = Colors.red;
        sl = 'Cancelled';
        break;
      default:
        sc = Colors.grey;
        sl = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sc.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: sc.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sl,
                    style: TextStyle(
                      color: sc,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (city.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 12,
                    color: Colors.teal.shade400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            if (location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (posterName.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.person_outline, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(
                    'Client: $posterName',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            const Divider(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _chip(
                  isInsured ? '🛡 Insured' : '💵 Cash',
                  isInsured ? Colors.blue : Colors.green,
                ),
                _chip('PKR ${acceptedAmount.toStringAsFixed(0)}', Colors.teal),
                if (isExpertRole) _chip('⭐ Expert', Colors.purple),
                if (commAmount > 0)
                  _chip(
                    '${(commRate * 100).toStringAsFixed(0)}% comm: PKR ${commAmount.toStringAsFixed(0)}',
                    Colors.orange,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (postedAt != null) _dl('Posted', postedAt.toDate()),
                if (completedAt != null) ...[
                  const SizedBox(width: 12),
                  _dl('Done', completedAt.toDate()),
                ],
                const Spacer(),
                if (paymentStatus == 'released')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isInsured ? 'Paid to wallet' : 'Cash collected',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (paymentStatus == 'locked')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Pending release',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (buyerRating > 0) ...[
              const Divider(height: 14),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < buyerRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$buyerRating/5 from client',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (buyerFeedback.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '"$buyerFeedback"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String l, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: c.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      l,
      style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600),
    ),
  );
  Widget _dl(String l, DateTime dt) => Row(
    children: [
      Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]),
      const SizedBox(width: 3),
      Text(
        '$l: ${DateFormat('dd MMM yy').format(dt)}',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
    ],
  );
}

class _SellerEmptyState extends StatelessWidget {
  final IconData icon;
  final String message, subtitle;
  const _SellerEmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    ),
  );
}
