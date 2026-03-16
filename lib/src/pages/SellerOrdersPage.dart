
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';

// const int kSellerFreeOrderLimit = 3;
// const double kSellerCommissionRate = 0.10;
// const double kSellerMinBalance = 500.0;

// class SellerOrdersPage extends StatefulWidget {
//   final String? phoneUID;
//   const SellerOrdersPage({super.key, this.phoneUID});
//   @override
//   State<SellerOrdersPage> createState() => _SellerOrdersPageState();
// }

// class _SellerOrdersPageState extends State<SellerOrdersPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late String _uid;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _uid = _resolveUid();
//     _checkBalanceAndNotify();
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

//   Future<void> _checkBalanceAndNotify() async {
//     if (_uid.isEmpty) return;
//     try {
//       final doc = await FirebaseFirestore.instance.collection('sellers').doc(_uid).get();
//       if (!doc.exists || !mounted) return;
//       final data = doc.data()!;
//       final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//       final balance = (data['Available_Balance'] ?? 0).toDouble();
//       if (jobsCompleted >= kSellerFreeOrderLimit && balance < 100) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) _showLowBalanceBanner(balance);
//         });
//       }
//     } catch (_) {}
//   }

//   void _showLowBalanceBanner(double balance) {
//     ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
//       backgroundColor: Colors.red.shade50,
//       content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
//           const SizedBox(width: 8),
//           Text('Low Balance — Orders Paused',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 13)),
//         ]),
//         const SizedBox(height: 4),
//         Text('Free orders used. Balance: PKR ${balance.toStringAsFixed(0)}. Add funds.',
//             style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
//       ]),
//       actions: [
//         TextButton(
//             onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
//             child: const Text('DISMISS')),
//         ElevatedButton(
//             onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
//             child: const Text('ADD FUNDS')),
//       ],
//     ));
//   }

//   @override
//   void dispose() {
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
//         backgroundColor: Colors.green.shade700,
//         foregroundColor: Colors.white,
//         elevation: 1,
//         automaticallyImplyLeading: false,
//         title: const Text('Find Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white60,
//           tabs: const [Tab(text: 'Browse Jobs'), Tab(text: 'My Bids'), Tab(text: 'Active')],
//         ),
//       ),
//       body: Column(children: [
//         _SellerBalanceBar(sellerUid: _uid),
//         Expanded(
//           child: TabBarView(controller: _tabController, children: [
//             _OpenJobsList(sellerUid: _uid),
//             _MyBidsList(sellerUid: _uid),
//             _ActiveJobsList(sellerUid: _uid),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// class _SellerBalanceBar extends StatelessWidget {
//   final String sellerUid;
//   const _SellerBalanceBar({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).snapshots(),
//       builder: (context, snap) {
//         if (!snap.hasData) return const SizedBox();
//         final data = snap.data?.data() as Map<String, dynamic>? ?? {};
//         final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//         final balance = (data['Available_Balance'] ?? 0).toDouble();
//         final isFree = jobsCompleted < kSellerFreeOrderLimit;
//         final freeLeft = isFree ? kSellerFreeOrderLimit - jobsCompleted : 0;
//         final isLow = !isFree && balance < 100;

//         Color barColor;
//         Widget content;
//         if (isFree) {
//           barColor = Colors.green.shade700;
//           content = Row(children: [
//             const Icon(Icons.card_giftcard, size: 14, color: Colors.white70),
//             const SizedBox(width: 8),
//             Text('$freeLeft free order(s) remaining', style: const TextStyle(color: Colors.white70, fontSize: 12)),
//             const Spacer(),
//             Text('Balance: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
//           ]);
//         } else if (isLow) {
//           barColor = Colors.red.shade700;
//           content = Row(children: [
//             const Icon(Icons.warning_amber, size: 14, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(child: Text('Low balance (PKR ${balance.toStringAsFixed(0)}) — Add funds to receive orders',
//                 style: const TextStyle(color: Colors.white, fontSize: 12))),
//           ]);
//         } else {
//           barColor = Colors.green.shade800;
//           content = Row(children: [
//             const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white70),
//             const SizedBox(width: 8),
//             Text('Balance: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
//             const Spacer(),
//             Text('10% commission per order', style: TextStyle(color: Colors.white60, fontSize: 11)),
//           ]);
//         }
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: barColor,
//           child: content,
//         );
//       },
//     );
//   }
// }

// // ── Browse Open Jobs ──────────────────────────────────────────
// class _OpenJobsList extends StatefulWidget {
//   final String sellerUid;
//   const _OpenJobsList({required this.sellerUid});
//   @override
//   State<_OpenJobsList> createState() => _OpenJobsListState();
// }

// class _OpenJobsListState extends State<_OpenJobsList> {
//   String _searchQuery = '';
//   final _searchController = TextEditingController();

//   @override
//   void dispose() { _searchController.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Container(
//         color: Colors.white,
//         padding: const EdgeInsets.all(12),
//         child: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search by title or skill...',
//             prefixIcon: const Icon(Icons.search, color: Colors.green),
//             suffixIcon: _searchQuery.isNotEmpty
//                 ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
//                 : null,
//             filled: true, fillColor: Colors.grey.shade100,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           ),
//           onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
//         ),
//       ),
//       Expanded(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('jobs').where('status', isEqualTo: 'open').snapshots(),
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//             if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.work_outline, message: 'No open jobs right now', subtitle: 'Check back soon');

//             final docs = snap.data!.docs.where((d) {
//               final data = d.data() as Map<String, dynamic>;
//               if (data['postedBy'] == widget.sellerUid) return false;
//               if (_searchQuery.isNotEmpty) {
//                 final title = (data['title'] ?? '').toString().toLowerCase();
//                 final skills = List<String>.from(data['skills'] ?? []).join(' ').toLowerCase();
//                 return title.contains(_searchQuery) || skills.contains(_searchQuery);
//               }
//               return true;
//             }).toList()
//               ..sort((a, b) {
//                 final aT = (a.data() as Map)['postedAt'] as Timestamp?;
//                 final bT = (b.data() as Map)['postedAt'] as Timestamp?;
//                 if (aT == null || bT == null) return 0;
//                 return bT.compareTo(aT);
//               });

//             if (docs.isEmpty) return const _SellerEmptyState(icon: Icons.search_off, message: 'No jobs match your search', subtitle: 'Try different keywords');

//             return ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: docs.length,
//               itemBuilder: (ctx, i) {
//                 final data = docs[i].data() as Map<String, dynamic>;
//                 return _OpenJobCard(jobId: docs[i].id, jobData: data, sellerUid: widget.sellerUid);
//               },
//             );
//           },
//         ),
//       ),
//     ]);
//   }
// }

// class _OpenJobCard extends StatelessWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;
//   const _OpenJobCard({required this.jobId, required this.jobData, required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     final title = jobData['title'] ?? 'Untitled';
//     final budget = (jobData['budget'] ?? 0).toDouble();
//     final location = jobData['location'] ?? '';
//     final timing = jobData['timing'] ?? '';
//     final skills = List<String>.from(jobData['skills'] ?? []);
//     final posterName = jobData['posterName'] ?? 'Unknown Client';
//     final bidsCount = jobData['bidsCount'] ?? 0;
//     final isInsured = (jobData['orderType'] ?? 'simple') == 'insured';
//     final postedAt = jobData['postedAt'] as Timestamp?;
//     final description = jobData['description'] ?? '';

//     return GestureDetector(
//       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))),
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: isInsured ? Border.all(color: Colors.blue.shade200, width: 1.5) : null,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: isInsured ? Colors.blue.shade50 : Colors.green.shade50,
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//             ),
//             child: Row(children: [
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [
//                   Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   if (isInsured) _insuredBadge(),
//                 ]),
//                 const SizedBox(height: 3),
//                 Text('by $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               ])),
//               const SizedBox(width: 8),
//               Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                 Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700)),
//                 Text('Max Budget', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//               ]),
//             ]),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
//                 const SizedBox(width: 4),
//                 Expanded(child: Text(location.isNotEmpty ? location : 'Location not specified', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
//                 Icon(Icons.schedule, size: 13, color: Colors.grey[500]),
//                 const SizedBox(width: 4),
//                 Text(timing, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               ]),
//               if (description.isNotEmpty) ...[
//                 const SizedBox(height: 6),
//                 Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
//               ],
//               const SizedBox(height: 8),
//               Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
//                 child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
//               )).toList()),
//               const SizedBox(height: 10),
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: bidsCount > 0 ? Colors.orange.shade50 : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: bidsCount > 0 ? Colors.orange.shade300 : Colors.grey.shade300),
//                   ),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.gavel, size: 13, color: bidsCount > 0 ? Colors.orange : Colors.grey),
//                     const SizedBox(width: 5),
//                     Text('$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: bidsCount > 0 ? Colors.orange : Colors.grey, fontSize: 12)),
//                   ]),
//                 ),
//                 if (postedAt != null) ...[
//                   const SizedBox(width: 8),
//                   Text(DateFormat('dd MMM').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//                 ],
//                 const Spacer(),
//                 Flexible(child: ElevatedButton.icon(
//                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))),
//                   icon: const Icon(Icons.visibility, size: 15),
//                   label: const Text('View & Bid'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                 )),
//               ]),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _insuredBadge() => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//     decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
//     child: Row(mainAxisSize: MainAxisSize.min, children: const [
//       Icon(Icons.shield, size: 10, color: Colors.white),
//       SizedBox(width: 3),
//       Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
//     ]),
//   );
// }

// // ── Job Detail Screen ─────────────────────────────────────────
// class _JobDetailScreen extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;
//   const _JobDetailScreen({required this.jobId, required this.jobData, required this.sellerUid});
//   @override
//   State<_JobDetailScreen> createState() => _JobDetailScreenState();
// }

// class _JobDetailScreenState extends State<_JobDetailScreen> {
//   bool _alreadyBid = false;
//   bool _checkingBid = true;
//   Map<String, dynamic>? _sellerInfo;

//   @override
//   void initState() { super.initState(); _loadData(); }

//   Future<void> _loadData() async {
//     try {
//       final bidDoc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid).get();
//       final sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).get();
//       final data = sellerDoc.data() ?? {};
//       final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//       final balance = (data['Available_Balance'] ?? 0).toDouble();
//       final isFree = jobsCompleted < kSellerFreeOrderLimit;
//       if (mounted) {
//         setState(() {
//           _alreadyBid = bidDoc.exists;
//           _sellerInfo = {'isFree': isFree, 'jobsCompleted': jobsCompleted, 'freeLeft': isFree ? kSellerFreeOrderLimit - jobsCompleted : 0, 'balance': balance, 'isEligible': isFree || balance >= kSellerMinBalance};
//           _checkingBid = false;
//         });
//       }
//     } catch (e) { if (mounted) setState(() => _checkingBid = false); }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.jobData['title'] ?? 'Job Detail';
//     final budget = (widget.jobData['budget'] ?? 0).toDouble();
//     final location = widget.jobData['location'] ?? '';
//     final timing = widget.jobData['timing'] ?? '';
//     final description = widget.jobData['description'] ?? '';
//     final skills = List<String>.from(widget.jobData['skills'] ?? []);
//     final posterName = widget.jobData['posterName'] ?? 'Client';
//     final posterImage = widget.jobData['posterImage'] as String?;
//     final bidsCount = widget.jobData['bidsCount'] ?? 0;
//     final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';
//     final postedAt = widget.jobData['postedAt'] as Timestamp?;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
//                 if (isInsured) ...[
//                   const SizedBox(width: 8),
//                   Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.white), SizedBox(width: 4), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
//                 ],
//               ]),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
//                 child: Row(children: [
//                   Icon(Icons.payments_outlined, color: Colors.green.shade700, size: 20),
//                   const SizedBox(width: 10),
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//                     Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
//                   ]),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade300)),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(Icons.gavel, size: 13, color: Colors.orange.shade700),
//                       const SizedBox(width: 5),
//                       Text('$bidsCount ${bidsCount == 1 ? 'bid' : 'bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700, fontSize: 12)),
//                     ]),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 14),
//               Row(children: [
//                 CircleAvatar(radius: 18, backgroundColor: Colors.teal.shade100,
//                   backgroundImage: posterImage != null && posterImage.isNotEmpty ? NetworkImage(posterImage) : null,
//                   child: posterImage == null || posterImage.isEmpty ? Text(posterName.isNotEmpty ? posterName[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)) : null),
//                 const SizedBox(width: 10),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Posted by', style: TextStyle(fontSize: 11, color: Colors.grey)),
//                   Text(posterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//                 ]),
//                 if (postedAt != null) ...[const Spacer(), Text(DateFormat('dd MMM yyyy').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
//               ]),
//               const Divider(height: 20),
//               if (location.isNotEmpty) ...[_infoRow(Icons.location_on, 'Location', location), const SizedBox(height: 8)],
//               if (timing.isNotEmpty) ...[_infoRow(Icons.schedule, 'Timing', timing), const SizedBox(height: 12)],
//               if (description.isNotEmpty) ...[
//                 const Text('Job Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
//                   child: Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5))),
//                 const SizedBox(height: 14),
//               ],
//               if (skills.isNotEmpty) ...[
//                 const Text('Skills Required', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Wrap(spacing: 8, runSpacing: 6, children: skills.map((s) => Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
//                   child: Text(s, style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
//                 )).toList()),
//               ],
//             ])),
//           ),
//           const SizedBox(height: 16),
//           if (isInsured) ...[
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 18), const SizedBox(width: 8), Text('Insured Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14))]),
//                 const SizedBox(height: 8),
//                 Text('Payment held by company. Released after 3-day claim window.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
//               ]),
//             ),
//             const SizedBox(height: 16),
//           ],
//           if (_sellerInfo != null) ...[_buildEligibilityCard(), const SizedBox(height: 16)],
//           if (_checkingBid)
//             const Center(child: CircularProgressIndicator(color: Colors.green))
//           else if (_alreadyBid)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
//               child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
//                 const SizedBox(width: 10),
//                 Expanded(child: Text('You have already placed a bid on this job', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14))),
//               ]),
//             )
//           else
//             _buildPlaceBidSection(budget, isInsured),
//           const SizedBox(height: 20),
//         ]),
//       ),
//     );
//   }

//   Widget _buildEligibilityCard() {
//     final isFree = _sellerInfo!['isFree'] as bool;
//     final freeLeft = _sellerInfo!['freeLeft'] as int;
//     final balance = _sellerInfo!['balance'] as double;
//     final isEligible = _sellerInfo!['isEligible'] as bool;
//     if (!isEligible) {
//       return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
//         child: Row(children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20), const SizedBox(width: 10),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Insufficient Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
//             Text('Need min PKR ${kSellerMinBalance.toStringAsFixed(0)}. Current: PKR ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
//           ])),
//         ]));
//     }
//     if (isFree) {
//       return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
//         child: Row(children: [
//           Icon(Icons.card_giftcard, color: Colors.green.shade700, size: 20), const SizedBox(width: 10),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('🎁 Free Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
//             Text('$freeLeft free order(s) remaining — No commission', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
//           ])),
//         ]));
//     }
//     return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
//       child: Row(children: [
//         Icon(Icons.percent, color: Colors.orange.shade700, size: 20), const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text('10% Commission Per Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
//           Text('Deducted when buyer accepts. Balance: PKR ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
//         ])),
//       ]));
//   }

//   Widget _buildPlaceBidSection(double budget, bool isInsured) {
//     final isEligible = _sellerInfo?['isEligible'] ?? true;
//     if (!isEligible) {
//       return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.block), label: const Text('Cannot Bid — Add Funds First'),
//         style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))));
//     }
//     return SizedBox(width: double.infinity, child: ElevatedButton.icon(
//       onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         builder: (_) => _PlaceBidSheet(jobId: widget.jobId, jobData: widget.jobData, sellerUid: widget.sellerUid, sellerInfo: _sellerInfo!, onBidPlaced: () => setState(() => _alreadyBid = true))),
//       icon: const Icon(Icons.gavel),
//       label: const Text('Place a Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//     ));
//   }

//   Widget _infoRow(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Icon(icon, size: 16, color: Colors.grey[500]), const SizedBox(width: 8),
//     Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//     Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
//   ]);
// }

// // ── Place Bid Sheet ───────────────────────────────────────────
// class _PlaceBidSheet extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;
//   final Map<String, dynamic> sellerInfo;
//   final VoidCallback onBidPlaced;
//   const _PlaceBidSheet({required this.jobId, required this.jobData, required this.sellerUid, required this.sellerInfo, required this.onBidPlaced});
//   @override
//   State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
// }

// class _PlaceBidSheetState extends State<_PlaceBidSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountCtrl = TextEditingController();
//   final _proposalCtrl = TextEditingController();
//   bool _isSubmitting = false;

//   @override
//   void dispose() { _amountCtrl.dispose(); _proposalCtrl.dispose(); super.dispose(); }

//   Future<void> _submitBid() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSubmitting = true);
//     try {
//       final db = FirebaseFirestore.instance;
//       final amount = double.parse(_amountCtrl.text.trim());
//       final budget = (widget.jobData['budget'] ?? 0).toDouble();
//       if (amount > budget) { _snack('Bid cannot exceed PKR ${budget.toStringAsFixed(0)}', Colors.red); setState(() => _isSubmitting = false); return; }

//       final sellerDoc = await db.collection('sellers').doc(widget.sellerUid).get();
//       final sellerData = sellerDoc.data() ?? {};
//       final userDoc = await db.collection('users').doc(widget.sellerUid).get();
//       final userData = userDoc.data() ?? {};

//       final sellerName = '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim();
//       final sellerImage = userData['profileImage'] ?? '';
//       final rating = (sellerData['Rating'] ?? 0).toDouble();
//       final skills = List<String>.from(sellerData['skills'] ?? []);
//       final jobsCompleted = (sellerData['Jobs_Completed'] ?? 0) as int;

//       final bidPayload = {
//         'sellerId': widget.sellerUid, 'sellerName': sellerName, 'sellerImage': sellerImage,
//         'rating': rating, 'skills': skills, 'jobsCompleted': jobsCompleted,
//         'proposedAmount': amount, 'proposal': _proposalCtrl.text.trim(), 'status': 'pending',
//         'jobId': widget.jobId, 'jobTitle': widget.jobData['title'] ?? '',
//         'jobBudget': budget, 'posterName': widget.jobData['posterName'] ?? '',
//         'isInsured': (widget.jobData['orderType'] ?? 'simple') == 'insured',
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       final batch = db.batch();
//       // Write 1: jobs/{jobId}/bids/{sellerUID}  ← buyer sees bids
//       batch.set(db.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid), bidPayload);
//       // Write 2: sellers/{sellerUID}/myBids/{jobId}  ← seller sees own bids, NO collectionGroup index needed
//       batch.set(db.collection('sellers').doc(widget.sellerUid).collection('myBids').doc(widget.jobId), bidPayload);
//       // Increment bids count
//       batch.update(db.collection('jobs').doc(widget.jobId), {'bidsCount': FieldValue.increment(1)});

//       await batch.commit();
//       if (!mounted) return;
//       widget.onBidPlaced();
//       Navigator.pop(context);
//       _snack('✅ Bid placed successfully!', Colors.green);
//     } catch (e) { _snack('Error: $e', Colors.red); setState(() => _isSubmitting = false); }
//   }

//   void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

//   @override
//   Widget build(BuildContext context) {
//     final budget = (widget.jobData['budget'] ?? 0).toDouble();
//     final title = widget.jobData['title'] ?? '';
//     final isFree = widget.sellerInfo['isFree'] as bool;
//     final freeLeft = widget.sellerInfo['freeLeft'] as int;
//     final balance = widget.sellerInfo['balance'] as double;
//     final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';

//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
//         const SizedBox(height: 16),
//         const Text('Place a Bid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text('For: $title', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//         const SizedBox(height: 12),
//         Row(children: [
//           Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
//             child: Text('Max Budget: PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600))),
//           if (isInsured) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.blue), SizedBox(width: 4), Text('Insured', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600))]))],
//         ]),
//         const SizedBox(height: 12),
//         Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isFree ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isFree ? Colors.green.shade200 : Colors.orange.shade200)),
//           child: Row(children: [
//             Icon(isFree ? Icons.card_giftcard : Icons.percent, size: 14, color: isFree ? Colors.green.shade700 : Colors.orange.shade700),
//             const SizedBox(width: 8),
//             Expanded(child: Text(isFree ? '🎁 Free order ($freeLeft free left) — No commission' : '10% deducted on acceptance • Balance: PKR ${balance.toStringAsFixed(0)}',
//                 style: TextStyle(fontSize: 12, color: isFree ? Colors.green.shade800 : Colors.orange.shade800))),
//           ])),
//         const SizedBox(height: 14),
//         TextFormField(controller: _amountCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           decoration: InputDecoration(labelText: 'Your Bid Amount (PKR)', prefixText: 'PKR ', prefixIcon: const Icon(Icons.payments_outlined, color: Colors.green),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Must be ≤ PKR ${budget.toStringAsFixed(0)}'),
//           validator: (v) { if (v == null || v.isEmpty) return 'Enter bid amount'; final amt = double.tryParse(v); if (amt == null || amt <= 0) return 'Enter valid amount'; if (amt > budget) return 'Cannot exceed PKR ${budget.toStringAsFixed(0)}'; return null; }),
//         const SizedBox(height: 14),
//         TextFormField(controller: _proposalCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Your Proposal', prefixIcon: const Icon(Icons.description_outlined, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Why are you the best choice?'),
//           validator: (v) => v == null || v.trim().isEmpty ? 'Write a proposal' : null),
//         const SizedBox(height: 20),
//         SizedBox(width: double.infinity, child: ElevatedButton.icon(
//           onPressed: _isSubmitting ? null : _submitBid,
//           icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.gavel),
//           label: Text(_isSubmitting ? 'Submitting...' : 'Submit Bid', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//         )),
//         const SizedBox(height: 8),
//       ]))),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  MY BIDS TAB
// //  ✅ Reads sellers/{uid}/myBids — single collection query, ZERO index needed
// // ═══════════════════════════════════════════════════════════════
// class _MyBidsList extends StatelessWidget {
//   final String sellerUid;
//   const _MyBidsList({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       // ✅ Simple subcollection on seller — no index, no collectionGroup
//       stream: FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(sellerUid)
//           .collection('myBids')
//           .snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//         if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(Icons.cloud_off, size: 48, color: Colors.red[300]), const SizedBox(height: 12),
//           Text('Error: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
//         ])));
//         if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.gavel, message: 'No bids placed yet', subtitle: 'Browse open jobs and place your first bid');

//         // Sort newest first in Dart
//         final docs = snap.data!.docs.toList()
//           ..sort((a, b) {
//             final aT = (a.data() as Map)['createdAt'] as Timestamp?;
//             final bT = (b.data() as Map)['createdAt'] as Timestamp?;
//             if (aT == null || bT == null) return 0;
//             return bT.compareTo(aT);
//           });

//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: docs.length,
//           itemBuilder: (ctx, i) {
//             final bid = docs[i].data() as Map<String, dynamic>;
//             final jobId = bid['jobId'] as String? ?? docs[i].id;
//             return _MyBidCard(bid: bid, jobId: jobId, sellerUid: sellerUid);
//           },
//         );
//       },
//     );
//   }
// }

// class _MyBidCard extends StatelessWidget {
//   final Map<String, dynamic> bid;
//   final String jobId;
//   final String sellerUid;
//   const _MyBidCard({required this.bid, required this.jobId, required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     final amount = (bid['proposedAmount'] ?? 0).toDouble();
//     final proposal = bid['proposal'] ?? '';
//     final createdAt = bid['createdAt'] as Timestamp?;
//     final jobTitle = bid['jobTitle'] ?? 'Loading...';
//     final posterName = bid['posterName'] ?? '';
//     final jobBudget = (bid['jobBudget'] ?? 0).toDouble();
//     final isInsured = bid['isInsured'] ?? false;

//     return StreamBuilder<DocumentSnapshot>(
//       // ✅ Real-time status from the original bid document (live updates when buyer accepts/rejects)
//       stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('bids').doc(sellerUid).snapshots(),
//       builder: (context, bidSnap) {
//         final liveBidData = bidSnap.data?.data() as Map<String, dynamic>? ?? {};
//         final status = liveBidData['status'] ?? bid['status'] ?? 'pending';

//         Color statusColor; IconData statusIcon;
//         switch (status) {
//           case 'accepted': statusColor = Colors.green; statusIcon = Icons.check_circle; break;
//           case 'rejected': statusColor = Colors.red; statusIcon = Icons.cancel; break;
//           default: statusColor = Colors.orange; statusIcon = Icons.hourglass_empty;
//         }

//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: Colors.white, borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: status == 'accepted' ? Colors.green.shade200 : status == 'rejected' ? Colors.red.shade100 : Colors.grey.shade200),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
//           ),
//           child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [
//                   Expanded(child: Text(jobTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
//                   if (isInsured == true) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.shield, size: 14, color: Colors.blue)),
//                 ]),
//                 if (posterName.isNotEmpty) Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               ])),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   Icon(statusIcon, size: 12, color: statusColor), const SizedBox(width: 4),
//                   Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
//                 ]),
//               ),
//             ]),
//             const Divider(height: 16),
//             Row(children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Your Bid', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//                 Text('PKR ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
//               ]),
//               const SizedBox(width: 20),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//                 Text('PKR ${jobBudget.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
//               ]),
//               const Spacer(),
//               if (createdAt != null) Text(DateFormat('dd MMM').format(createdAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//             ]),
//             if (proposal.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
//                 child: Text(proposal, style: const TextStyle(fontSize: 13))),
//             ],
//             const SizedBox(height: 10),
//             if (status == 'accepted')
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
//                 child: Row(children: [
//                   Icon(Icons.celebration, color: Colors.green.shade600, size: 16), const SizedBox(width: 8),
//                   Expanded(child: Text(isInsured == true ? '🎉 Accepted! Wait for buyer to pay company before starting.' : '🎉 Accepted! Collect cash on job completion.', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600))),
//                 ]))
//             else if (status == 'rejected')
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
//                 child: Row(children: [
//                   Icon(Icons.info_outline, color: Colors.red.shade600, size: 16), const SizedBox(width: 8),
//                   Expanded(child: Text('Buyer chose another seller. Keep bidding!', style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
//                 ]))
//             else
//               Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
//                 child: Row(children: [
//                   Icon(Icons.hourglass_top, color: Colors.orange.shade600, size: 16), const SizedBox(width: 8),
//                   Expanded(child: Text('Waiting for buyer to review your bid.', style: TextStyle(color: Colors.orange.shade700, fontSize: 12))),
//                 ])),
//           ])),
//         );
//       },
//     );
//   }
// }

// // ── Active Jobs Tab ───────────────────────────────────────────
// class _ActiveJobsList extends StatelessWidget {
//   final String sellerUid;
//   const _ActiveJobsList({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('jobs').where('acceptedBidder', isEqualTo: sellerUid).snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
//         if (!snap.hasData) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');
//         final docs = snap.data!.docs.where((d) => (d.data() as Map)['status'] == 'in_progress').toList();
//         if (docs.isEmpty) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');
//         return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (ctx, i) {
//           final data = docs[i].data() as Map<String, dynamic>;
//           return _ActiveJobCard(jobId: docs[i].id, jobData: data, sellerUid: sellerUid);
//         });
//       },
//     );
//   }
// }

// class _ActiveJobCard extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;
//   const _ActiveJobCard({required this.jobId, required this.jobData, required this.sellerUid});
//   @override
//   State<_ActiveJobCard> createState() => _ActiveJobCardState();
// }

// class _ActiveJobCardState extends State<_ActiveJobCard> {
//   bool _isCompleting = false;

//   Future<void> _markCompleted() async {
//     setState(() => _isCompleting = true);
//     try {
//       final db = FirebaseFirestore.instance;
//       final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
//       final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';
//       final claimDeadline = Timestamp.fromDate(DateTime.now().add(const Duration(days: 3)));
//       final batch = db.batch();
//       batch.update(db.collection('jobs').doc(widget.jobId), {'status': 'completed', 'completedAt': FieldValue.serverTimestamp(), 'claimDeadline': claimDeadline, 'paymentStatus': isInsured ? 'locked' : 'released'});
//       if (!isInsured) {
//         batch.update(db.collection('sellers').doc(widget.sellerUid), {'Jobs_Completed': FieldValue.increment(1), 'Total_Jobs': FieldValue.increment(1), 'Pending_Jobs': FieldValue.increment(-1), 'Earning': FieldValue.increment(acceptedAmount), 'Available_Balance': FieldValue.increment(acceptedAmount)});
//       } else {
//         batch.update(db.collection('sellers').doc(widget.sellerUid), {'Jobs_Completed': FieldValue.increment(1), 'Total_Jobs': FieldValue.increment(1), 'Pending_Jobs': FieldValue.increment(-1)});
//       }
//       await batch.commit();
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isInsured ? '✅ Job done! Buyer has 3 days to claim. Earnings released after.' : '🎉 Job done! Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from buyer.'), backgroundColor: Colors.green, duration: const Duration(seconds: 6)));
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
//     } finally { if (mounted) setState(() => _isCompleting = false); }
//   }

//   Future<void> _openChat(BuildContext context) async {
//     final buyerId = widget.jobData['postedBy'] ?? '';
//     final posterName = widget.jobData['posterName'] ?? 'Client';
//     if (buyerId.isEmpty) return;
//     final db = FirebaseFirestore.instance;
//     final phones = [widget.sellerUid, buyerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';
//     final convDoc = await db.collection('conversations').doc(convId).get();
//     if (!convDoc.exists) {
//       final buyerDoc = await db.collection('users').doc(buyerId).get();
//       final buyerData = buyerDoc.data() ?? {};
//       final sellerDoc = await db.collection('users').doc(widget.sellerUid).get();
//       final sellerData = sellerDoc.data() ?? {};
//       await db.collection('conversations').doc(convId).set({
//         'participantIds': [widget.sellerUid, buyerId],
//         'participantNames': {widget.sellerUid: '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim(), buyerId: posterName},
//         'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'},
//         'participantProfileImages': {widget.sellerUid: sellerData['profileImage'] ?? '', buyerId: buyerData['profileImage'] ?? ''},
//         'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
//         'unreadCounts': {widget.sellerUid: 0, buyerId: 0}, 'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] ?? '',
//       });
//     }
//     if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat opened with $posterName')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.jobData['title'] ?? '';
//     final posterName = widget.jobData['posterName'] ?? 'Client';
//     final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
//     final skills = List<String>.from(widget.jobData['skills'] ?? []);
//     final location = widget.jobData['location'] ?? '';
//     final description = widget.jobData['description'] ?? '';
//     final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';

//     return Container(
//       width: double.infinity, margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isInsured ? Colors.blue.shade200 : Colors.green.shade200, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(color: isInsured ? Colors.blue.shade50 : Colors.green.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
//           child: Row(children: [
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                 if (isInsured) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 10, color: Colors.white), SizedBox(width: 3), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))])),
//               ]),
//               Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//             ])),
//             const SizedBox(width: 8),
//             Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//               Text('PKR ${acceptedAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isInsured ? Colors.blue.shade700 : Colors.green.shade700)),
//               Text(isInsured ? 'Held by company' : 'Cash on delivery', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//             ]),
//           ]),
//         ),
//         Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           if (location.isNotEmpty) ...[
//             Row(children: [Icon(Icons.location_on, size: 13, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis))]),
//             const SizedBox(height: 8),
//           ],
//           if (description.isNotEmpty) ...[
//             Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
//               child: Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)),
//             const SizedBox(height: 8),
//           ],
//           Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isInsured ? Colors.blue.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isInsured ? Colors.blue.shade200 : Colors.green.shade200)),
//             child: Row(children: [
//               Icon(isInsured ? Icons.lock_outline : Icons.payments_outlined, size: 14, color: isInsured ? Colors.blue.shade700 : Colors.green.shade700),
//               const SizedBox(width: 8),
//               Expanded(child: Text(isInsured ? 'Payment locked. Released after 3-day claim window.' : 'Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from client on completion.', style: TextStyle(fontSize: 11, color: isInsured ? Colors.blue.shade800 : Colors.green.shade800))),
//             ])),
//           const SizedBox(height: 8),
//           Wrap(spacing: 6, runSpacing: 4, children: skills.take(3).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)))).toList()),
//           const SizedBox(height: 14),
//           Row(children: [
//             Expanded(child: OutlinedButton.icon(onPressed: () => _openChat(context), icon: const Icon(Icons.message_outlined, size: 16), label: const Text('Message Client'),
//               style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//             const SizedBox(width: 10),
//             Expanded(child: ElevatedButton.icon(onPressed: _isCompleting ? null : _markCompleted,
//               icon: _isCompleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 16),
//               label: Text(_isCompleting ? 'Updating...' : 'Mark Done'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//           ]),
//         ])),
//       ]),
//     );
//   }
// }

// class _SellerEmptyState extends StatelessWidget {
//   final IconData icon;
//   final String message;
//   final String subtitle;
//   const _SellerEmptyState({required this.icon, required this.message, required this.subtitle});

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//       Icon(icon, size: 60, color: Colors.grey[400]),
//       const SizedBox(height: 12),
//       Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
//       const SizedBox(height: 6),
//       Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//     ]));
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';
import 'notification_service.dart';

const int kSellerFreeOrderLimit = 3;
const double kSellerCommissionRate = 0.10;
const double kSellerMinBalance = 500.0;

// ═══════════════════════════════════════════════════════════════
//  SELLER ORDERS PAGE
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

  @override
  void initState() {
    super.initState();
    // 4 tabs: Browse | My Bids | Active | History
    _tabController = TabController(length: 4, vsync: this);
    _uid = _resolveUid();
    _checkBalanceAndNotify();
  }

  String _resolveUid() {
    final raw = widget.phoneUID ?? UserSession().phoneUID ?? UserSession().phone ?? UserSession().uid ?? '';
    return _normalizePhone(raw);
  }

  String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    final t = raw.trim();
    if (t.startsWith('+')) return t;
    if (RegExp(r'^\d+$').hasMatch(t)) return '+$t';
    return t;
  }

  Future<void> _checkBalanceAndNotify() async {
    if (_uid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('sellers').doc(_uid).get();
      if (!doc.exists || !mounted) return;
      final data = doc.data()!;
      final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
      final balance = (data['Available_Balance'] ?? 0).toDouble();
      if (jobsCompleted >= kSellerFreeOrderLimit && balance < 100) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showLowBalanceBanner(balance);
        });
      }
    } catch (_) {}
  }

  void _showLowBalanceBanner(double balance) {
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      backgroundColor: Colors.red.shade50,
      content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Text('Low Balance — Orders Paused', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        Text('Free orders used. Balance: PKR ${balance.toStringAsFixed(0)}. Add funds.', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
      ]),
      actions: [
        TextButton(onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), child: const Text('DISMISS')),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
          child: const Text('ADD FUNDS'),
        ),
      ],
    ));
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find Jobs'), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
        body: const Center(child: Text('Could not identify user. Please log in again.')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('Find Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          NotificationBell(
            uid: _uid,
            color: Colors.white,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage(uid: _uid))),
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
      body: Column(children: [
        _SellerBalanceBar(sellerUid: _uid),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            _OpenJobsList(sellerUid: _uid),
            _MyBidsList(sellerUid: _uid),
            _ActiveJobsList(sellerUid: _uid),
            _SellerHistoryTab(sellerUid: _uid),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Balance Bar
// ─────────────────────────────────────────────────────────────
class _SellerBalanceBar extends StatelessWidget {
  final String sellerUid;
  const _SellerBalanceBar({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
        final balance = (data['Available_Balance'] ?? 0).toDouble();
        final isFree = jobsCompleted < kSellerFreeOrderLimit;
        final freeLeft = isFree ? kSellerFreeOrderLimit - jobsCompleted : 0;
        final isLow = !isFree && balance < 100;
        Color barColor; Widget content;
        if (isFree) {
          barColor = Colors.green.shade700;
          content = Row(children: [
            const Icon(Icons.card_giftcard, size: 14, color: Colors.white70), const SizedBox(width: 8),
            Text('$freeLeft free order(s) remaining', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Text('Balance: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]);
        } else if (isLow) {
          barColor = Colors.red.shade700;
          content = Row(children: [
            const Icon(Icons.warning_amber, size: 14, color: Colors.white), const SizedBox(width: 8),
            Expanded(child: Text('Low balance (PKR ${balance.toStringAsFixed(0)}) — Add funds to receive orders', style: const TextStyle(color: Colors.white, fontSize: 12))),
          ]);
        } else {
          barColor = Colors.green.shade800;
          content = Row(children: [
            const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white70), const SizedBox(width: 8),
            Text('Balance: PKR ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Text('10% commission per order', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]);
        }
        return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: barColor, child: content);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  BROWSE OPEN JOBS — city-priority + all jobs option
// ═══════════════════════════════════════════════════════════════
class _OpenJobsList extends StatefulWidget {
  final String sellerUid;
  const _OpenJobsList({required this.sellerUid});
  @override
  State<_OpenJobsList> createState() => _OpenJobsListState();
}

class _OpenJobsListState extends State<_OpenJobsList> {
  String _searchQuery = '';
  bool _showAllCities = false;
  String _sellerCity = '';
  final _searchController = TextEditingController();

  @override
  void initState() { super.initState(); _loadSellerCity(); }

  Future<void> _loadSellerCity() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.sellerUid).get();
      final city = (doc.data() ?? {})['city'] as String? ?? '';
      if (mounted) setState(() => _sellerCity = city.toLowerCase().trim());
    } catch (_) {}
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title or skill...',
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
              filled: true, fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
          if (_sellerCity.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.location_city, size: 14, color: Colors.green.shade700),
              const SizedBox(width: 6),
              Text(_showAllCities ? 'Showing all cities' : 'Showing jobs in your city first', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAllCities = !_showAllCities),
                child: Text(_showAllCities ? 'My city only' : 'Show all cities', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              ),
            ]),
          ],
        ]),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').where('status', isEqualTo: 'open').snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
            if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.work_outline, message: 'No open jobs right now', subtitle: 'Check back soon');

            var allDocs = snap.data!.docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              if (data['postedBy'] == widget.sellerUid) return false;
              if (_searchQuery.isNotEmpty) {
                final title = (data['title'] ?? '').toString().toLowerCase();
                final skills = List<String>.from(data['skills'] ?? []).join(' ').toLowerCase();
                return title.contains(_searchQuery) || skills.contains(_searchQuery);
              }
              return true;
            }).toList();

            // City-based sorting: same city first, then others
            if (_sellerCity.isNotEmpty && !_showAllCities) {
              final sameCityDocs = allDocs.where((d) {
                final city = ((d.data() as Map)['city'] as String? ?? '').toLowerCase().trim();
                return city == _sellerCity;
              }).toList();
              final otherCityDocs = allDocs.where((d) {
                final city = ((d.data() as Map)['city'] as String? ?? '').toLowerCase().trim();
                return city != _sellerCity;
              }).toList();

              // Sort each group by date
              for (final group in [sameCityDocs, otherCityDocs]) {
                group.sort((a, b) {
                  final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                  final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                  if (aT == null || bT == null) return 0;
                  return bT.compareTo(aT);
                });
              }
              allDocs = [...sameCityDocs, ...otherCityDocs];
            } else {
              allDocs.sort((a, b) {
                final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                if (aT == null || bT == null) return 0;
                return bT.compareTo(aT);
              });
            }

            if (allDocs.isEmpty) return const _SellerEmptyState(icon: Icons.search_off, message: 'No jobs match your search', subtitle: 'Try different keywords');

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allDocs.length,
              itemBuilder: (ctx, i) {
                final data = allDocs[i].data() as Map<String, dynamic>;
                final jobCity = (data['city'] as String? ?? '').toLowerCase().trim();
                final isSameCity = _sellerCity.isNotEmpty && jobCity == _sellerCity;
                return _OpenJobCard(jobId: allDocs[i].id, jobData: data, sellerUid: widget.sellerUid, isSameCity: isSameCity);
              },
            );
          },
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Open Job Card
// ─────────────────────────────────────────────────────────────
class _OpenJobCard extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;
  final bool isSameCity;
  const _OpenJobCard({required this.jobId, required this.jobData, required this.sellerUid, this.isSameCity = false});

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
    final city = jobData['city'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: isSameCity ? Border.all(color: Colors.green.shade300, width: 2) : isInsured ? Border.all(color: Colors.blue.shade200, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSameCity ? Colors.green.shade50 : isInsured ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  if (isSameCity) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.near_me, size: 10, color: Colors.white), SizedBox(width: 3), Text('NEARBY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))])),
                  if (isInsured) ...[const SizedBox(width: 4), _insuredBadge()],
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.person_outline, size: 12, color: Colors.grey[500]), const SizedBox(width: 3),
                  Text('by $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (city.isNotEmpty) ...[const SizedBox(width: 8), Icon(Icons.location_city, size: 12, color: Colors.grey[400]), const SizedBox(width: 3), Text(city, style: TextStyle(fontSize: 12, color: Colors.grey[500]))],
                ]),
              ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700)),
                Text('Max Budget', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.location_on, size: 13, color: Colors.grey[500]), const SizedBox(width: 4),
                Expanded(child: Text(location.isNotEmpty ? location : 'Location not specified', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Icon(Icons.schedule, size: 13, color: Colors.grey[500]), const SizedBox(width: 4),
                Text(timing, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ]),
              if (description.isNotEmpty) ...[const SizedBox(height: 6), Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)],
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
                child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
              )).toList()),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: bidsCount > 0 ? Colors.orange.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: bidsCount > 0 ? Colors.orange.shade300 : Colors.grey.shade300)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.gavel, size: 13, color: bidsCount > 0 ? Colors.orange : Colors.grey), const SizedBox(width: 5),
                    Text('$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: bidsCount > 0 ? Colors.orange : Colors.grey, fontSize: 12)),
                  ]),
                ),
                if (postedAt != null) ...[const SizedBox(width: 8), Text(DateFormat('dd MMM').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
                const Spacer(),
                Flexible(child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailScreen(jobId: jobId, jobData: jobData, sellerUid: sellerUid))),
                  icon: const Icon(Icons.visibility, size: 15), label: const Text('View & Bid'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _insuredBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 10, color: Colors.white), SizedBox(width: 3), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))]),
  );
}

// ═══════════════════════════════════════════════════════════════
//  JOB DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════
class _JobDetailScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;
  const _JobDetailScreen({required this.jobId, required this.jobData, required this.sellerUid});
  @override
  State<_JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<_JobDetailScreen> {
  bool _alreadyBid = false;
  bool _checkingBid = true;
  Map<String, dynamic>? _sellerInfo;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final bidDoc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid).get();
      final sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).get();
      final data = sellerDoc.data() ?? {};
      final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
      final balance = (data['Available_Balance'] ?? 0).toDouble();
      final isFree = jobsCompleted < kSellerFreeOrderLimit;
      if (mounted) {
        setState(() {
          _alreadyBid = bidDoc.exists;
          _sellerInfo = {'isFree': isFree, 'jobsCompleted': jobsCompleted, 'freeLeft': isFree ? kSellerFreeOrderLimit - jobsCompleted : 0, 'balance': balance, 'isEligible': isFree || balance >= kSellerMinBalance};
          _checkingBid = false;
        });
      }
    } catch (e) { if (mounted) setState(() => _checkingBid = false); }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              if (isInsured) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.white), SizedBox(width: 4), Text('INSURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]))],
            ]),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
              child: Row(children: [
                Icon(Icons.payments_outlined, color: Colors.green.shade700, size: 20), const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text('PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade300)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.gavel, size: 13, color: Colors.orange.shade700), const SizedBox(width: 5), Text('$bidsCount ${bidsCount == 1 ? 'bid' : 'bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700, fontSize: 12))])),
              ])),
            const SizedBox(height: 14),
            Row(children: [
              CircleAvatar(radius: 18, backgroundColor: Colors.teal.shade100,
                backgroundImage: posterImage != null && posterImage.isNotEmpty ? NetworkImage(posterImage) : null,
                child: posterImage == null || posterImage.isEmpty ? Text(posterName.isNotEmpty ? posterName[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)) : null),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Posted by', style: TextStyle(fontSize: 11, color: Colors.grey)), Text(posterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]),
              if (postedAt != null) ...[const Spacer(), Text(DateFormat('dd MMM yyyy').format(postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
            ]),
            if (city.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_city, size: 13, color: Colors.teal.shade700), const SizedBox(width: 4), Text(city, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600))])),
            ],
            const Divider(height: 20),
            if (location.isNotEmpty) ...[_infoRow(Icons.location_on, 'Location', location), const SizedBox(height: 8)],
            if (timing.isNotEmpty) ...[_infoRow(Icons.schedule, 'Timing', timing), const SizedBox(height: 12)],
            if (description.isNotEmpty) ...[
              const Text('Job Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5))),
              const SizedBox(height: 14),
            ],
            if (skills.isNotEmpty) ...[
              const Text('Skills Required', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: skills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w500)))).toList()),
            ],
          ]))),
          const SizedBox(height: 16),
          if (isInsured) ...[
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 18), const SizedBox(width: 8), Text('Insured Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14))]),
                const SizedBox(height: 8),
                Text('Payment held by company. Released after 3-day claim window.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
              ])),
            const SizedBox(height: 16),
          ],
          if (_sellerInfo != null) ...[_buildEligibilityCard(), const SizedBox(height: 16)],
          if (_checkingBid)
            const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (_alreadyBid)
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20), const SizedBox(width: 10),
                Expanded(child: Text('You have already placed a bid on this job', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14))),
              ]))
          else
            _buildPlaceBidSection(budget, isInsured),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildEligibilityCard() {
    final isFree = _sellerInfo!['isFree'] as bool;
    final freeLeft = _sellerInfo!['freeLeft'] as int;
    final balance = _sellerInfo!['balance'] as double;
    final isEligible = _sellerInfo!['isEligible'] as bool;
    if (!isEligible) {
      return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
        child: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Insufficient Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
          Text('Need min PKR ${kSellerMinBalance.toStringAsFixed(0)}. Current: PKR ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
        ]))]));
    }
    if (isFree) {
      return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
        child: Row(children: [Icon(Icons.card_giftcard, color: Colors.green.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎁 Free Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
          Text('$freeLeft free order(s) remaining — No commission', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
        ]))]));
    }
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: Row(children: [Icon(Icons.percent, color: Colors.orange.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('10% Commission Per Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
        Text('Deducted when buyer accepts. Balance: PKR ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
      ]))]));
  }

  Widget _buildPlaceBidSection(double budget, bool isInsured) {
    final isEligible = _sellerInfo?['isEligible'] ?? true;
    if (!isEligible) {
      return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.block), label: const Text('Cannot Bid — Add Funds First'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))));
    }
    return SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _PlaceBidSheet(jobId: widget.jobId, jobData: widget.jobData, sellerUid: widget.sellerUid, sellerInfo: _sellerInfo!, onBidPlaced: () => setState(() => _alreadyBid = true))),
      icon: const Icon(Icons.gavel),
      label: const Text('Place a Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    ));
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 16, color: Colors.grey[500]), const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
  ]);
}

// ═══════════════════════════════════════════════════════════════
//  PLACE BID SHEET
// ═══════════════════════════════════════════════════════════════
class _PlaceBidSheet extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;
  final Map<String, dynamic> sellerInfo;
  final VoidCallback onBidPlaced;
  const _PlaceBidSheet({required this.jobId, required this.jobData, required this.sellerUid, required this.sellerInfo, required this.onBidPlaced});
  @override
  State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends State<_PlaceBidSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _proposalCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() { _amountCtrl.dispose(); _proposalCtrl.dispose(); super.dispose(); }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final amount = double.parse(_amountCtrl.text.trim());
      final budget = (widget.jobData['budget'] ?? 0).toDouble();
      if (amount > budget) { _snack('Bid cannot exceed PKR ${budget.toStringAsFixed(0)}', Colors.red); setState(() => _isSubmitting = false); return; }

      final sellerDoc = await db.collection('sellers').doc(widget.sellerUid).get();
      final sellerData = sellerDoc.data() ?? {};
      final userDoc = await db.collection('users').doc(widget.sellerUid).get();
      final userData = userDoc.data() ?? {};

      final sellerName = '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim();
      final sellerImage = userData['profileImage'] ?? '';
      final rating = (sellerData['Rating'] ?? 0).toDouble();
      final skills = List<String>.from(sellerData['skills'] ?? []);
      final jobsCompleted = (sellerData['Jobs_Completed'] ?? 0) as int;

      final bidPayload = {
        'sellerId': widget.sellerUid, 'sellerName': sellerName, 'sellerImage': sellerImage,
        'rating': rating, 'skills': skills, 'jobsCompleted': jobsCompleted,
        'proposedAmount': amount, 'proposal': _proposalCtrl.text.trim(), 'status': 'pending',
        'jobId': widget.jobId, 'jobTitle': widget.jobData['title'] ?? '',
        'jobBudget': budget, 'posterName': widget.jobData['posterName'] ?? '',
        'isInsured': (widget.jobData['orderType'] ?? 'simple') == 'insured',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final batch = db.batch();
      // Write 1: jobs/{jobId}/bids/{sellerUID} ← buyer sees bids
      batch.set(db.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid), bidPayload);
      // Write 2: sellers/{sellerUID}/myBids/{jobId} ← seller sees bids, NO collectionGroup index
      batch.set(db.collection('sellers').doc(widget.sellerUid).collection('myBids').doc(widget.jobId), bidPayload);
      batch.update(db.collection('jobs').doc(widget.jobId), {'bidsCount': FieldValue.increment(1)});
      await batch.commit();

      // Notify buyer
      final buyerUid = widget.jobData['postedBy'] as String? ?? '';
      if (buyerUid.isNotEmpty) {
        await NotificationService.send(toUid: buyerUid, title: '🔔 New Bid Received', body: '$sellerName placed a bid on "${widget.jobData['title']}" for PKR ${amount.toStringAsFixed(0)}.', type: 'bid_received', jobId: widget.jobId, relatedUserName: sellerName);
      }

      if (!mounted) return;
      widget.onBidPlaced();
      Navigator.pop(context);
      _snack('✅ Bid placed successfully!', Colors.green);
    } catch (e) { _snack('Error: $e', Colors.red); setState(() => _isSubmitting = false); }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  @override
  Widget build(BuildContext context) {
    final budget = (widget.jobData['budget'] ?? 0).toDouble();
    final title = widget.jobData['title'] ?? '';
    final isFree = widget.sellerInfo['isFree'] as bool;
    final freeLeft = widget.sellerInfo['freeLeft'] as int;
    final balance = widget.sellerInfo['balance'] as double;
    final isInsured = (widget.jobData['orderType'] ?? 'simple') == 'insured';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('Place a Bid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('For: $title', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: Text('Max Budget: PKR ${budget.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600))),
          if (isInsured) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 12, color: Colors.blue), SizedBox(width: 4), Text('Insured', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600))]))],
        ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isFree ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isFree ? Colors.green.shade200 : Colors.orange.shade200)),
          child: Row(children: [
            Icon(isFree ? Icons.card_giftcard : Icons.percent, size: 14, color: isFree ? Colors.green.shade700 : Colors.orange.shade700), const SizedBox(width: 8),
            Expanded(child: Text(isFree ? '🎁 Free order ($freeLeft free left) — No commission' : '10% deducted on acceptance • Balance: PKR ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: isFree ? Colors.green.shade800 : Colors.orange.shade800))),
          ])),
        const SizedBox(height: 14),
        TextFormField(controller: _amountCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Your Bid Amount (PKR)', prefixText: 'PKR ', prefixIcon: const Icon(Icons.payments_outlined, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Must be ≤ PKR ${budget.toStringAsFixed(0)}'),
          validator: (v) { if (v == null || v.isEmpty) return 'Enter bid amount'; final amt = double.tryParse(v); if (amt == null || amt <= 0) return 'Enter valid amount'; if (amt > budget) return 'Cannot exceed PKR ${budget.toStringAsFixed(0)}'; return null; }),
        const SizedBox(height: 14),
        TextFormField(controller: _proposalCtrl, maxLines: 3,
          decoration: InputDecoration(labelText: 'Your Proposal', prefixIcon: const Icon(Icons.description_outlined, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), helperText: 'Why are you the best choice?'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Write a proposal' : null),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitBid,
          icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.gavel),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Bid', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
        const SizedBox(height: 8),
      ]))),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MY BIDS TAB — reads sellers/{uid}/myBids, zero index
// ═══════════════════════════════════════════════════════════════
class _MyBidsList extends StatelessWidget {
  final String sellerUid;
  const _MyBidsList({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).collection('myBids').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
        if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.red[300]), const SizedBox(height: 12),
          Text('Error: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ])));
        if (!snap.hasData || snap.data!.docs.isEmpty) return const _SellerEmptyState(icon: Icons.gavel, message: 'No bids placed yet', subtitle: 'Browse open jobs and place your first bid');
        final docs = snap.data!.docs.toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['createdAt'] as Timestamp?;
            final bT = (b.data() as Map)['createdAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        return ListView.builder(
          padding: const EdgeInsets.all(12), itemCount: docs.length,
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
  final String jobId;
  final String sellerUid;
  const _MyBidCard({required this.bid, required this.jobId, required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    final amount = (bid['proposedAmount'] ?? 0).toDouble();
    final proposal = bid['proposal'] ?? '';
    final createdAt = bid['createdAt'] as Timestamp?;
    final jobTitle = bid['jobTitle'] ?? 'Loading...';
    final posterName = bid['posterName'] ?? '';
    final jobBudget = (bid['jobBudget'] ?? 0).toDouble();
    final isInsured = bid['isInsured'] ?? false;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('bids').doc(sellerUid).snapshots(),
      builder: (context, bidSnap) {
        final liveBidData = bidSnap.data?.data() as Map<String, dynamic>? ?? {};
        final status = liveBidData['status'] ?? bid['status'] ?? 'pending';
        Color statusColor; IconData statusIcon;
        switch (status) {
          case 'accepted': statusColor = Colors.green; statusIcon = Icons.check_circle; break;
          case 'rejected': statusColor = Colors.red; statusIcon = Icons.cancel; break;
          default: statusColor = Colors.orange; statusIcon = Icons.hourglass_empty;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: status == 'accepted' ? Colors.green.shade200 : status == 'rejected' ? Colors.red.shade100 : Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(jobTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  if (isInsured == true) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.shield, size: 14, color: Colors.blue)),
                ]),
                if (posterName.isNotEmpty) Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(statusIcon, size: 12, color: statusColor), const SizedBox(width: 4), Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11))])),
            ]),
            const Divider(height: 16),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Bid', style: TextStyle(fontSize: 11, color: Colors.grey[500])), Text('PKR ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
              const SizedBox(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Max Budget', style: TextStyle(fontSize: 11, color: Colors.grey[500])), Text('PKR ${jobBudget.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]))]),
              const Spacer(),
              if (createdAt != null) Text(DateFormat('dd MMM').format(createdAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]),
            if (proposal.isNotEmpty) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Text(proposal, style: const TextStyle(fontSize: 13)))],
            const SizedBox(height: 10),
            if (status == 'accepted')
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                child: Row(children: [Icon(Icons.celebration, color: Colors.green.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text(isInsured == true ? '🎉 Accepted! Wait for buyer to pay company before starting.' : '🎉 Accepted! Collect cash on job completion.', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)))]))
            else if (status == 'rejected')
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                child: Row(children: [Icon(Icons.info_outline, color: Colors.red.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text('Buyer chose another seller. Keep bidding!', style: TextStyle(color: Colors.red.shade700, fontSize: 12)))]))
            else
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                child: Row(children: [Icon(Icons.hourglass_top, color: Colors.orange.shade600, size: 16), const SizedBox(width: 8), Expanded(child: Text('Waiting for buyer to review your bid.', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)))])),
          ])),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACTIVE JOBS TAB — includes expert_assigned + claim_pending
// ═══════════════════════════════════════════════════════════════
class _ActiveJobsList extends StatelessWidget {
  final String sellerUid;
  const _ActiveJobsList({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').where('acceptedBidder', isEqualTo: sellerUid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
        if (!snap.hasData) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');

        // Active = in_progress + claim_pending (seller must revisit)
        final active = snap.data!.docs.where((d) {
          final s = (d.data() as Map)['status'];
          return s == 'in_progress' || s == 'claim_pending';
        }).toList();

        // Expert jobs where this seller is the assigned expert
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').where('expertUid', isEqualTo: sellerUid).snapshots(),
          builder: (context, expertSnap) {
            final expertJobs = (expertSnap.data?.docs ?? []).where((d) {
              final s = (d.data() as Map)['status'];
              return s == 'expert_assigned';
            }).toList();

            // Combine active + expert jobs, deduplicate by id
            final allIds = <String>{};
            final combined = <QueryDocumentSnapshot>[];
            for (final d in [...active, ...expertJobs]) {
              if (allIds.add(d.id)) combined.add(d);
            }

            if (combined.isEmpty) return const _SellerEmptyState(icon: Icons.construction, message: 'No active jobs', subtitle: 'Win a bid to start working');

            return ListView.builder(
              padding: const EdgeInsets.all(12), itemCount: combined.length,
              itemBuilder: (ctx, i) {
                final data = combined[i].data() as Map<String, dynamic>;
                final isExpert = expertJobs.any((d) => d.id == combined[i].id);
                return _ActiveJobCard(jobId: combined[i].id, jobData: data, sellerUid: sellerUid, isExpertRole: isExpert);
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active Job Card
// ─────────────────────────────────────────────────────────────
class _ActiveJobCard extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;
  final bool isExpertRole;
  const _ActiveJobCard({required this.jobId, required this.jobData, required this.sellerUid, this.isExpertRole = false});
  @override
  State<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends State<_ActiveJobCard> {
  bool _isCompleting = false;

  bool get _isClaim => widget.jobData['status'] == 'claim_pending';
  bool get _isExpert => widget.jobData['status'] == 'expert_assigned';
  bool get _isInsured => (widget.jobData['orderType'] ?? 'simple') == 'insured';

  Future<void> _markCompleted() async {
    setState(() => _isCompleting = true);
    try {
      final db = FirebaseFirestore.instance;
      final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
      final claimDeadline = Timestamp.fromDate(DateTime.now().add(const Duration(days: 3)));
      final batch = db.batch();
      final newStatus = widget.isExpertRole ? 'expert_completed' : 'completed';

      batch.update(db.collection('jobs').doc(widget.jobId), {
        'status': newStatus, 'completedAt': FieldValue.serverTimestamp(),
        'claimDeadline': claimDeadline, 'paymentStatus': _isInsured ? 'locked' : 'released',
        'insuranceClaimed': false, 'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!_isInsured) {
        batch.update(db.collection('sellers').doc(widget.sellerUid), {'Jobs_Completed': FieldValue.increment(1), 'Total_Jobs': FieldValue.increment(1), 'Pending_Jobs': FieldValue.increment(-1), 'Earning': FieldValue.increment(acceptedAmount), 'Available_Balance': FieldValue.increment(acceptedAmount)});
      } else {
        batch.update(db.collection('sellers').doc(widget.sellerUid), {'Jobs_Completed': FieldValue.increment(1), 'Total_Jobs': FieldValue.increment(1), 'Pending_Jobs': FieldValue.increment(-1)});
      }
      await batch.commit();

      // Notify buyer
      final buyerUid = widget.jobData['postedBy'] as String? ?? '';
      if (buyerUid.isNotEmpty) {
        await NotificationService.send(
          toUid: buyerUid,
          title: widget.isExpertRole ? '⭐ Expert completed your job' : '✅ Job Marked Complete',
          body: _isInsured ? 'Your job "${widget.jobData['title']}" is complete. You have 3 days to accept or claim insurance.' : 'Job "${widget.jobData['title']}" is done. Please confirm payment.',
          type: 'job_completed', jobId: widget.jobId,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isInsured ? '✅ Job done! Buyer has 3 days to claim. Earnings released after.' : '🎉 Job done! Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from buyer.'),
        backgroundColor: Colors.green, duration: const Duration(seconds: 6),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _isCompleting = false); }
  }

  Future<void> _openChat(BuildContext context) async {
    final buyerId = widget.jobData['postedBy'] ?? '';
    final posterName = widget.jobData['posterName'] ?? 'Client';
    if (buyerId.isEmpty) return;
    final db = FirebaseFirestore.instance;
    final phones = [widget.sellerUid, buyerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';
    final convDoc = await db.collection('conversations').doc(convId).get();
    if (!convDoc.exists) {
      final buyerDoc = await db.collection('users').doc(buyerId).get();
      final buyerData = buyerDoc.data() ?? {};
      final sellerDoc = await db.collection('users').doc(widget.sellerUid).get();
      final sellerData = sellerDoc.data() ?? {};
      await db.collection('conversations').doc(convId).set({
        'participantIds': [widget.sellerUid, buyerId],
        'participantNames': {widget.sellerUid: '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim(), buyerId: posterName},
        'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'},
        'participantProfileImages': {widget.sellerUid: sellerData['profileImage'] ?? '', buyerId: buyerData['profileImage'] ?? ''},
        'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
        'unreadCounts': {widget.sellerUid: 0, buyerId: 0}, 'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] ?? '',
      });
    }
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat opened with $posterName')));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.jobData['title'] ?? '';
    final posterName = widget.jobData['posterName'] ?? 'Client';
    final acceptedAmount = (widget.jobData['acceptedAmount'] ?? 0).toDouble();
    final skills = List<String>.from(widget.jobData['skills'] ?? []);
    final location = widget.jobData['location'] ?? '';
    final description = widget.jobData['description'] ?? '';

    Color headerColor; String statusLabel; Color statusLabelColor;
    if (widget.isExpertRole) { headerColor = Colors.purple.shade50; statusLabel = 'EXPERT ROLE'; statusLabelColor = Colors.purple; }
    else if (_isClaim) { headerColor = Colors.red.shade50; statusLabel = 'REVISIT REQUIRED'; statusLabelColor = Colors.red; }
    else { headerColor = _isInsured ? Colors.blue.shade50 : Colors.green.shade50; statusLabel = 'IN PROGRESS'; statusLabelColor = Colors.blue; }

    return Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.isExpertRole ? Colors.purple.shade300 : _isClaim ? Colors.red.shade300 : _isInsured ? Colors.blue.shade200 : Colors.green.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: headerColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: statusLabelColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel, style: TextStyle(color: statusLabelColor, fontSize: 9, fontWeight: FontWeight.bold))),
                if (_isInsured) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield, size: 9, color: Colors.white), SizedBox(width: 2), Text('INS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))]))],
              ]),
              Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('PKR ${acceptedAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: widget.isExpertRole ? Colors.purple : _isInsured ? Colors.blue.shade700 : Colors.green.shade700)),
              Text(_isInsured ? 'Held by company' : 'Cash on delivery', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ]),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Claim alert banner
          if (_isClaim) Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade300)),
            child: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16), const SizedBox(width: 8), Expanded(child: Text('Buyer claimed insurance — you must revisit and complete the job properly.', style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600)))])),
          // Expert banner
          if (widget.isExpertRole) Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple.shade200)),
            child: Row(children: [Icon(Icons.star, color: Colors.purple.shade700, size: 16), const SizedBox(width: 8), Expanded(child: Text('You are assigned as expert for this job. Assist the seller to deliver the best results.', style: TextStyle(color: Colors.purple.shade800, fontSize: 12, fontWeight: FontWeight.w600)))])),

          if (location.isNotEmpty) ...[Row(children: [Icon(Icons.location_on, size: 13, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8)],
          if (description.isNotEmpty) ...[Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)), const SizedBox(height: 8)],
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _isInsured ? Colors.blue.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _isInsured ? Colors.blue.shade200 : Colors.green.shade200)),
            child: Row(children: [
              Icon(_isInsured ? Icons.lock_outline : Icons.payments_outlined, size: 14, color: _isInsured ? Colors.blue.shade700 : Colors.green.shade700), const SizedBox(width: 8),
              Expanded(child: Text(_isInsured ? 'Payment locked. Released after 3-day claim window.' : 'Collect PKR ${acceptedAmount.toStringAsFixed(0)} cash from client on completion.', style: TextStyle(fontSize: 11, color: _isInsured ? Colors.blue.shade800 : Colors.green.shade800))),
            ])),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: skills.take(3).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)), child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)))).toList()),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _openChat(context), icon: const Icon(Icons.message_outlined, size: 16), label: const Text('Message Client'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: _isCompleting ? null : _markCompleted,
              icon: _isCompleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 16),
              label: Text(_isCompleting ? 'Updating...' : widget.isExpertRole ? 'Mark Expert Done' : 'Mark Done'),
              style: ElevatedButton.styleFrom(backgroundColor: widget.isExpertRole ? Colors.purple : Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          ]),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SELLER HISTORY TAB
// ═══════════════════════════════════════════════════════════════
class _SellerHistoryTab extends StatelessWidget {
  final String sellerUid;
  const _SellerHistoryTab({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sellers').doc(sellerUid).snapshots(),
      builder: (context, sellerSnap) {
        final sellerData = sellerSnap.data?.data() as Map<String, dynamic>? ?? {};
        final totalEarning = (sellerData['Earning'] ?? 0).toDouble();
        final totalJobs = (sellerData['Jobs_Completed'] ?? 0) as int;
        final balance = (sellerData['Available_Balance'] ?? 0).toDouble();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').where('acceptedBidder', isEqualTo: sellerUid).snapshots(),
          builder: (context, snap) {
            // Also get expert jobs
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('jobs').where('expertUid', isEqualTo: sellerUid).snapshots(),
              builder: (context, expertSnap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));

                // Merge all, deduplicate
                final allIds = <String>{};
                final allDocs = <QueryDocumentSnapshot>[];
                for (final d in [...(snap.data?.docs ?? []), ...(expertSnap.data?.docs ?? [])]) {
                  if (allIds.add(d.id)) allDocs.add(d);
                }

                allDocs.sort((a, b) {
                  final aT = (a.data() as Map)['postedAt'] as Timestamp?;
                  final bT = (b.data() as Map)['postedAt'] as Timestamp?;
                  if (aT == null || bT == null) return 0;
                  return bT.compareTo(aT);
                });

                // Stats from docs
                final completedJobs = allDocs.where((d) { final s = (d.data() as Map)['status']; return s == 'completed' || s == 'expert_completed'; }).length;
                final activeJobs = allDocs.where((d) { final s = (d.data() as Map)['status']; return s == 'in_progress'; }).length;
                final insuredJobs = allDocs.where((d) { final t = (d.data() as Map)['orderType']; return t == 'insured'; }).length;
                final cashJobs = allDocs.where((d) { final t = (d.data() as Map)['orderType']; return t == 'simple'; }).length;

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    // ── Earnings Summary Card ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18), const SizedBox(width: 8), const Text('Earnings Overview', style: TextStyle(color: Colors.white70, fontSize: 13))]),
                        const SizedBox(height: 10),
                        Text('PKR ${totalEarning.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Total Earned', style: TextStyle(color: Colors.white60, fontSize: 12)),
                        const Divider(color: Colors.white24, height: 20),
                        Row(children: [
                          _earningsTile('Available', 'PKR ${balance.toStringAsFixed(0)}', Icons.wallet),
                          _earningsTile('Jobs Done', '$totalJobs', Icons.task_alt),
                          _earningsTile('Completed', '$completedJobs', Icons.check_circle_outline),
                          _earningsTile('Active', '$activeJobs', Icons.autorenew),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          _earningsTile('Insured', '$insuredJobs', Icons.shield_outlined),
                          _earningsTile('Cash', '$cashJobs', Icons.payments_outlined),
                        ]),
                      ]),
                    ),

                    if (allDocs.isEmpty) Column(children: [
                      const SizedBox(height: 40),
                      Icon(Icons.history, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No job history yet', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                    ]),

                    // Bank details section for insured completed jobs
                    _BankDetailsSection(sellerUid: sellerUid, jobs: allDocs),

                    // Job list
                    ...allDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _SellerHistoryCard(jobData: data, jobId: doc.id, sellerUid: sellerUid);
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _earningsTile(String label, String value, IconData icon) => Expanded(child: Column(children: [
    Icon(icon, color: Colors.white60, size: 16), const SizedBox(height: 2),
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
  ]));
}

// ─────────────────────────────────────────────────────────────
// Bank Details Section — shown when insured jobs are completed
// ─────────────────────────────────────────────────────────────
class _BankDetailsSection extends StatefulWidget {
  final String sellerUid;
  final List<QueryDocumentSnapshot> jobs;
  const _BankDetailsSection({required this.sellerUid, required this.jobs});
  @override
  State<_BankDetailsSection> createState() => _BankDetailsSectionState();
}

class _BankDetailsSectionState extends State<_BankDetailsSection> {
  bool _hasBankDetails = false;
  bool _loading = true;
  bool _hasInsuredCompleted = false;

  @override
  void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    try {
      final bankDoc = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).collection('bankDetails').doc('primary').get();
      final insuredDone = widget.jobs.any((d) {
        final data = d.data() as Map;
        return (data['orderType'] == 'insured') && (data['status'] == 'completed' || data['status'] == 'expert_completed') && data['paymentStatus'] != 'released';
      });
      if (mounted) setState(() { _hasBankDetails = bankDoc.exists; _hasInsuredCompleted = insuredDone; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showBankDetailsSheet() {
    final bankCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Add Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Required to receive insurance payment transfer', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 16),
          TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Bank Name', prefixIcon: Icon(Icons.account_balance), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Account Title', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: numCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Account Number', prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () async {
              if (bankCtrl.text.trim().isEmpty || titleCtrl.text.trim().isEmpty || numCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUid).collection('bankDetails').doc('primary').set({'bankName': bankCtrl.text.trim(), 'accountTitle': titleCtrl.text.trim(), 'accountNumber': numCtrl.text.trim(), 'addedAt': FieldValue.serverTimestamp()});
              if (mounted) { Navigator.pop(context); setState(() => _hasBankDetails = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Bank details saved! Admin will transfer your earnings.'), backgroundColor: Colors.green)); }
            },
            icon: const Icon(Icons.save), label: const Text('Save Bank Details', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_hasInsuredCompleted) return const SizedBox();
    if (_hasBankDetails) {
      return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
        child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 20), const SizedBox(width: 10), Expanded(child: Text('Bank details saved. Admin will transfer your insured earnings.', style: TextStyle(color: Colors.green.shade800, fontSize: 13)))]));
    }
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade400, width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.account_balance, color: Colors.orange.shade700, size: 20), const SizedBox(width: 8), Expanded(child: Text('💰 Add Bank Details to Receive Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 14)))]),
        const SizedBox(height: 8),
        Text('Your insured job is complete! Add your bank account so the company can transfer your earnings.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _showBankDetailsSheet, icon: const Icon(Icons.add_card), label: const Text('Add Bank Account'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        )),
      ]));
  }
}

// ─────────────────────────────────────────────────────────────
// Seller History Card
// ─────────────────────────────────────────────────────────────
class _SellerHistoryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  final String sellerUid;
  const _SellerHistoryCard({required this.jobData, required this.jobId, required this.sellerUid});

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
    final isInsured = orderType == 'insured';
    final paymentStatus = jobData['paymentStatus'] ?? '';
    final isExpertRole = jobData['expertUid'] == sellerUid;

    Color statusColor;
    switch (status) {
      case 'completed': case 'expert_completed': statusColor = Colors.green; break;
      case 'in_progress': statusColor = Colors.blue; break;
      case 'claim_pending': statusColor = Colors.red; break;
      case 'expert_assigned': statusColor = Colors.purple; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    String statusLabel;
    switch (status) {
      case 'completed': statusLabel = 'Completed'; break;
      case 'expert_completed': statusLabel = 'Expert Done'; break;
      case 'in_progress': statusLabel = 'In Progress'; break;
      case 'claim_pending': statusLabel = 'Claim Filed'; break;
      case 'expert_assigned': statusLabel = 'Expert Sent'; break;
      case 'cancelled': statusLabel = 'Cancelled'; break;
      default: statusLabel = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11))),
        ]),
        const SizedBox(height: 6),
        if (location.isNotEmpty) Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey[400]), const SizedBox(width: 3), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis))]),
        if (posterName.isNotEmpty) Row(children: [Icon(Icons.person_outline, size: 12, color: Colors.grey[400]), const SizedBox(width: 3), Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
        const Divider(height: 14),
        Row(children: [
          _chip(isInsured ? '🛡 Insured' : '💵 Cash', isInsured ? Colors.blue : Colors.green),
          const SizedBox(width: 6),
          _chip('PKR ${acceptedAmount.toStringAsFixed(0)}', Colors.teal),
          if (isExpertRole) ...[const SizedBox(width: 6), _chip('⭐ Expert', Colors.purple)],
        ]),
        const SizedBox(height: 6),
        Row(children: [
          if (postedAt != null) _dateLabel('Posted', postedAt.toDate()),
          if (completedAt != null) ...[const SizedBox(width: 12), _dateLabel('Done', completedAt.toDate())],
          const Spacer(),
          if (paymentStatus == 'released') Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, size: 12, color: Colors.green.shade700), const SizedBox(width: 3), Text('Paid', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold))])),
          if (paymentStatus == 'locked') Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock_outline, size: 12, color: Colors.orange.shade700), const SizedBox(width: 3), Text('Pending', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.bold))])),
        ]),
      ])),
    );
  }

  Widget _chip(String label, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)));
  Widget _dateLabel(String label, DateTime dt) => Row(children: [Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]), const SizedBox(width: 3), Text('$label: ${DateFormat('dd MMM yy').format(dt)}', style: TextStyle(fontSize: 11, color: Colors.grey[500]))]);
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════
class _SellerEmptyState extends StatelessWidget {
  final IconData icon; final String message; final String subtitle;
  const _SellerEmptyState({required this.icon, required this.message, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 60, color: Colors.grey[400]), const SizedBox(height: 12),
    Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])), const SizedBox(height: 6),
    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
  ]));
}